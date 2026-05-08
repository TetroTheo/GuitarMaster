extends Node

var duration := 1.0
var chord_notes : Array[Note] = []
var chord_creation := false

func key_pressed(note):
	if chord_creation:
		chord_notes.append(note)
		return
	var npkg = NotePackage.new()
	npkg.duration = duration
	npkg.notes.append(note)
	$Sheet.add_note_pkg(npkg)


func on_duration_changed(index: int) -> void:
	duration = 4 * pow(0.5, index)


func on_rest_pressed() -> void:
	var npkg = NotePackage.new()
	npkg.duration = duration
	$Sheet.add_note_pkg(npkg)


func on_chord_toggled(toggled_on: bool) -> void:
	chord_creation = toggled_on
	if not chord_creation:
		if chord_notes:
			var npkg = NotePackage.new()
			npkg.duration = duration
			for note in chord_notes:
				# make sure that notes do not repeat strings later
				npkg.notes.append(note)
			$Sheet.add_note_pkg(npkg)
			chord_notes.clear()
