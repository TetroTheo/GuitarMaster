@tool
extends Node

## we're making this a variable for multi-track support in the future. hopefully!
@onready var track = $Track
var duration := 0.25
## so we keep track of what modifier mode we're in
var duration_modifier := 1.0
var chord_notes : Array[Note] = []
var chord_creation := false

## if any key is pressed, tell the sheet to add a note
func key_pressed(note : Note):
	## if we are creating a chord, keep it to yourself for now.
	## we will add all notes of the chord at once!
	if chord_creation:
		chord_notes.append(note)
		return
	var npkg = NotePackage.new()
	## apply modifier here
	npkg.duration = duration * duration_modifier
	npkg.notes.append(note)
	track.add_note_pkg(npkg)
	#play_sound(note)
	note.play_sound($AudioPlayers)

func play_sound(note : Note):
	var audio_player := AudioStreamPlayer.new()
	audio_player.stream = load("uid://jre4lw6j7p4d")
	audio_player.finished.connect(on_audio_player_finished.bind(audio_player))
	audio_player.pitch_scale = note.scale_pitch()
	$AudioPlayers.add_child(audio_player)
	audio_player.play()


func on_audio_player_finished(audio_player):
	audio_player.queue_free()


func on_duration_changed(index: int) -> void:
	duration = pow(0.5, index)

## add a rest
func on_rest_pressed() -> void:
	var npkg = NotePackage.new()
	npkg.duration = duration * duration_modifier
	track.add_note_pkg(npkg)

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
				# make sure that notes do not repeat strings later
				npkg.notes.append(note)
			track.add_note_pkg(npkg)
			chord_notes.clear()

## TODO:
## make sure notes do not repeat strings in a chord
# be able to move measures around
# delete a measure
# move a measure
## delete an npkgn (if all are deleted in a measure, then delete the measure)
# duplicate a measure
# adding notes will never overload a measure
## make a guitar sound effect
## calculate pitch frequency for a given integer pitch
## compile one unbroken array of note packages
## connect the sync test with the note packages

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
	var song = track.get_song()
	print(song)

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
