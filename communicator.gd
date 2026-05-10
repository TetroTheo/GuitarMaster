@tool
extends Node

## we're making this a variable for multi-track support in the future. hopefully!
@onready var track = $Track
## for convenience
@onready var generator = $AudioStreamGenerator
var duration := 0.25
## so we keep track of what modifier mode we're in
var duration_modifier := 1.0
var chord_notes : Array[Note] = []
var chord_creation := false
## for track playback
var song : Array[NotePackage]
var song_position := 0.0
var song_note_index := 0
var last_song_note_position := 0.0
var loop := false
var BPM := 120.0
var selected_npkgn: Node
var song_just_started := true

## so that we can connect to the track, so that it will tell us when a measure is deleted
func _ready() -> void:
	track.measure_deleted.connect(on_measure_deleted)
	$Editing/NoteEdit.get_popup().id_pressed.connect(note_edit_option_selected)


func note_edit_option_selected(index: int):
	match index:
		0: ## rewrite
			pass
		1: ## delete
			$Editing/NoteEdit.disabled = true
			selected_npkgn.queue_free()
			selected_npkgn = null
		2: ## play from here
			pass



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
## delete an npkgn (if all are deleted in a measure, then delete the measure)
# duplicate a measure
# adding notes will never overload a measure
# make a guitar sound effect
# calculate pitch frequency for a given integer pitch
# compile one unbroken array of note packages
# connect the sync test with the note packages
# fix chord editing

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
	last_song_note_position = 0.0
	song_just_started = true
	generator.play()

func _process(_delta: float) -> void:
	if not song or not generator.playing:
		return
	song_position = generator.get_playback_position() + AudioServer.get_time_since_last_mix()
	song_position -= AudioServer.get_output_latency() + 0.25
	## the scaling factor is the reciprocal of seconds per beat multiplied by four
	song_position /= 4 * 60.0 / BPM
	var last_song_note_duration = song[song_note_index - 1].duration
	if song_note_index == 0 and song_just_started:
		last_song_note_duration = 0.0
		song_just_started = false
	## play as many notes as the song position has passed
	while last_song_note_position + last_song_note_duration < song_position:
		for note in song[song_note_index].notes:
			note.play_sound(get_node("AudioPlayers"))
		last_song_note_position = song_position
		song_note_index += 1
		## check if this was the last note
		if song_note_index >= len(song):
			if loop:
				## start from the first note
				song_note_index = 0
			else:
				## end playback
				stop_song()
				break

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
