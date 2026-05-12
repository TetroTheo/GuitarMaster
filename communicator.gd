@tool
extends Node

## we're making this a variable for multi-track support in the future. hopefully!
@onready var track = $Track
## for convenience
@onready var generator = $AudioStreamGenerator
var duration := 0.25
## for editing
## so we keep track of what modifier mode we're in
var duration_modifier := 1.0
var chord_notes : Array[Note] = []
var chord_creation := false
var selected_npkgn: Node
## for track playback
var song : SongPackage
var song_position := 0.0
var song_note_index := 0
var song_measure_index := 0
var last_song_note_position := 0.0
var loop := false
var BPM := 120.0
var last_song_note_duration := 0.0
var last_metronome_tick_position := 0.0
var last_metronome_tick_duration := 0.0
var metronome_on := false
## I copied this over from the old script.
## is it inconvenient? yes! but it works!
## though, these should probably be made resources in the future.
const interval_presets = [
	[0, 2, 4, 5, 7, 9, 11], #major
	[0, 2, 3, 5, 7, 8, 10], #minor
	[0, 2, 4, 7, 9], #pent major
	[0, 3, 5, 7, 10], # pent minor
	[0, 2, 3, 5, 7, 9, 10], # dorian
	[0, 1, 3, 5, 7, 8, 10], # phrygian
	[0, 2, 4, 6, 7, 9, 11], # lydian
	[0, 2, 4, 5, 7, 9, 10], # mixolydian
	[0, 1, 3, 5, 6, 8, 10], # locrian
	[0, 2, 3, 5, 7, 8, 11], # harmonic
	[0, 2, 3, 5, 7, 9, 11], # melodic
	[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11] # chromatic
]
var selected_interval_key := 0
var selected_pitch_key := 0

## so that we can connect to the track, so that it will tell us when a measure is deleted
func _ready() -> void:
	track.measure_deleted.connect(on_measure_deleted)
	$Editing/NoteEdit.get_popup().id_pressed.connect(note_edit_option_selected)


func note_edit_option_selected(index: int):
	match index:
		0: ## rewrite
			## the next time a note is played, the track will write to this node!
			track.overwrite_npkg = selected_npkgn
		1: ## delete
			$Editing/NoteEdit.disabled = true
			## if this is the last npkgn in the measure, delete that, too!
			var measure : Measure = selected_npkgn.get_parent().get_parent()
			if len(measure.get_nkpgn()) == 1:
				track.on_delete(measure)
			else:
				selected_npkgn.queue_free()
				selected_npkgn = null
				## note does not delete instantly, but when it does,
				## refresh the measure's controls!
				await get_tree().create_timer(0).timeout
				measure.call_deferred("set_add_note_visibility")
		2: ## play from here
			for note : Note in selected_npkgn.note_pkg:
				note.play_sound($AudioPlayers)



## if we delete a measure with the selected npkgn, then reset the button
func on_measure_deleted(measure: Measure):
	for npkgn in measure.get_nkpgn():
		if npkgn == selected_npkgn:
			selected_npkgn = null
			$Editing/NoteEdit.disabled = true

## if any key is pressed, tell the sheet to add a note
func key_pressed(note : Note):
	## if we are creating a chord, keep it to yourself for now.
	## we will add all notes of the chord at once!
	if chord_creation:
		## if the same note is clicked twice, than assume the user wants to delete it!
		if note in chord_notes:
			chord_notes.erase(note)
			note.key.toggle_off()
			return
		## overwrite any notes in the chord that may be on this note's string
		## there will only be one!
		for c_note in chord_notes:
			if c_note.string == note.string:
				chord_notes.erase(c_note)
				c_note.key.toggle_off()
				break
		note.key.toggle_on()
		chord_notes.append(note)
		note.play_sound($AudioPlayers)
		return
	var npkg = NotePackage.new()
	## apply the duration modifier to the npkg
	npkg.duration = duration * duration_modifier
	npkg.notes.append(note)
	track.add_note_pkg(self, npkg)
	note.play_sound($AudioPlayers)


func on_duration_changed(index: int) -> void:
	duration = pow(0.5, index)

## add a rest
func on_rest_pressed() -> void:
	var npkg = NotePackage.new()
	npkg.duration = duration * duration_modifier
	track.add_note_pkg(self, npkg)

## if we are turning off the chord feature, then
## if we had saved notes to the chord, we add all of them at once to an npkg
func on_chord_toggled(toggled_on: bool) -> void:
	chord_creation = toggled_on
	if not chord_creation:
		if chord_notes:
			## create an npkg, but not a node for it.
			## only the track manages nodes!
			var npkg = NotePackage.new()
			## apply modifier here
			npkg.duration = duration * duration_modifier
			for note in chord_notes:
				npkg.notes.append(note)
				note.key.toggle_off()
				## just play for fun!
				note.play_sound($AudioPlayers)
			## include ourselves so that the npkgn can conect to us
			track.add_note_pkg(self, npkg)
			chord_notes.clear()

## TODO:
# make sure notes do not repeat strings in a chord
# be able to move measures around
# delete a measure
# move a measure
# delete an npkgn (if all are deleted in a measure, then delete the measure)
# duplicate a measure
# adding notes will never overload a measure
# make a guitar sound effect
# calculate pitch frequency for a given integer pitch
# compile one unbroken array of note packages
# connect the sync test with the note packages
# fix chord editing
## tempo and signature changes should affect all measures directly to the right with the same property

## SETTINGS:
# left-handed mode
# bass mode
## scaling (constant | logarithmic)




func on_measure_edit_toggled(toggled_on: bool) -> void:
	track.edit_measure_mode(toggled_on)


## at this point, I'm worried that I'm creating too much clutter 
## by not organizing all the different features. I hope this doesn't lead 
## to the downfall of this project!


func _on_play_song_pressed() -> void:
	$Editing/PauseSong.button_pressed = false
	if generator.playing:
		stop_song()
		return
	song = track.get_song()
	print("Now Playing: " + str(song))
	song_note_index = 0
	song_measure_index = 0
	last_song_note_position = 0.0
	last_song_note_duration = 0.0
	last_metronome_tick_position = 0.0
	last_metronome_tick_duration = 0.0
	## set the song tempo to start off with!
	BPM = song.measure_packages[song_measure_index].tempo
	generator.play()


## let's take a moment to talk about time signatures. I finally understand them now.
## so, think of the numerator as how many notes there are, and the bottom as the duration of each note.
## a time signature of X/Y would have measures that contain X notes that are each a duration of Y.
## here are some examples:
## 6/4 = six quarter notes
## 3/2 = three half notes
## 2/1 = two whole notes
## 4/4 = four quarter notes
## 6/8 = six eigth notes
## what's important to note is that while different fractions have the same ratio, the metronome plays differently.
## for example, in 6/4, we play the metronome every quarter note, but in 3/2, we play it for every half note.
## in terms of this program, the duration of the metronome should be 4/Y for any time signature X/Y.
## (but we still need to store X and Y. both to calculate the ratio of the measure, and for display.)

## plays the song
func _process(_delta: float) -> void:
	if not song or not generator.playing:
		return
	## there may be a song without measures!
	if not song.measure_packages:
		return
	song_position = generator.get_playback_position() + AudioServer.get_time_since_last_mix()
	song_position -= AudioServer.get_output_latency() + 0.25
	## the scaling factor is the reciprocal of seconds per beat multiplied by four
	## here, we're using the BPM to uniformly scale the song position,
	## so that we won't have to scale the metronome or any notes after this.
	## the BPM will also not be needed.
	song_position /= 4 * 60.0 / BPM
	## play the metronome!
	while last_metronome_tick_position + last_metronome_tick_duration < song_position:
		## even if not currently enabled, keep track of the metronome,
		## so that it can be turned on and off properly during playback!
		if metronome_on:
			#print("beep boop")
			## make this a configurable setting later! because it's only useful sometimes!
			## for the first note of the measure, play a slightly different sound!
			if song_note_index == 0:
				$Metronome.pitch_scale = 2.0
			else:
				$Metronome.pitch_scale = 1.0
			$Metronome.play()
		## don't delete this line! I crashed my computer after I forgot this one...
		last_metronome_tick_position = song_position
		## metronome frequency is based on the current time signature
		#print(1.0/song.measure_packages[song_measure_index].time_signature_denominator)
		last_metronome_tick_duration = 1.0/song.measure_packages[song_measure_index].time_signature_denominator
	## play as many notes as the song position has passed
	while last_song_note_position + last_song_note_duration < song_position:
		for note in song.measure_packages[song_measure_index].note_packages[song_note_index].notes:
			note.play_sound(get_node("AudioPlayers"))
		last_song_note_position = song_position
		## we need to get the LAST note that was played!
		last_song_note_duration = song.measure_packages[song_measure_index].note_packages[song_note_index].duration
		song_note_index += 1
		## check if this was the last note in the measure
		if song_note_index >= len(song.measure_packages[song_measure_index].note_packages):
			## move to next measure
			song_measure_index += 1
			song_note_index = 0
			## check if this was the last note of the last measure
			if song_measure_index >= len(song.measure_packages):
				if loop:
					## start from the first note of the first measure
					song_note_index = 0
					song_measure_index = 0
				else:
					## end playback
					stop_song()
					break
			## if we made it here, we're still playing! we should change the tempo!
			## undo normalization
			song_position *= 4 * 60.0 / BPM
			last_song_note_position *= 4 * 60.0 / BPM
			last_metronome_tick_position *= 4 * 60.0 / BPM
			## will this help?
			last_song_note_duration *= 4 * 60.0 / BPM
			last_metronome_tick_duration *= 4 * 60.0 / BPM
			BPM = song.measure_packages[song_measure_index].tempo
			## re-scale all position variables that depended on the song position,
			## as well as the song position itself
			song_position /= 4 * 60.0 / BPM
			last_song_note_position /= 4 * 60.0 / BPM
			last_metronome_tick_position /= 4 * 60.0 / BPM
			last_song_note_duration /= 4 * 60.0 / BPM
			last_metronome_tick_duration /= 4 * 60.0 / BPM
			

## stops the song
## (did I really have to write this?)
func stop_song():
	generator.stop()

## this keeps the note index!
func pause_song(toggle: bool):
	generator.stream_paused = toggle

## can be changed mid-song!
func _on_bpm_value_changed(value: float) -> void:
	BPM = value

## toggles song looping
func _on_loop_toggled(toggled_on: bool) -> void:
	loop = toggled_on


## gives more configurability to the note
## allows triplets, dotted, and double dotted
## of course, this will make playback a bit trickier, but not too much more than it already will be!
func _on_duration_modifiers_item_selected(index: int) -> void:
	match index:
		0: ## normal
			duration_modifier = 1.0
		1: ## triplet
			duration_modifier = 1.0/3
		2: ## dotted
			duration_modifier = 1.5
		3: ## double dotted
			duration_modifier = 1.75

## at last, we can connect to these!
func on_npkgn_pressed(npkgn):
	selected_npkgn = npkgn
	$Editing/NoteEdit.disabled = false


func _on_save_file_pressed() -> void:
	$SaveFile.popup_centered_clamped()


func _on_save_file_file_selected(path: String) -> void:
	## create the resource
	var song_rc = track.get_song()
	var error := ResourceSaver.save(song_rc, path)
	if error: push_warning("Saving error: " + error_string(error))


func _on_load_file_file_selected(path: String) -> void:
	print(path)
	var song_rc : SongPackage = ResourceLoader.load(path)
	track.load_song(self, song_rc)


func _on_load_file_pressed() -> void:
	$Editing/NoteEdit.disabled = true
	$LoadFile.popup_centered_clamped()


func _on_delete_file_pressed() -> void:
	$Editing/NoteEdit.disabled = true
	track.clear_song()


func _on_metronome_toggled(toggled_on: bool) -> void:
	metronome_on = toggled_on


func _on_pitch_key_item_selected(index: int) -> void:
	selected_pitch_key = index


func _on_interval_key_item_selected(index: int) -> void:
	selected_interval_key = index
