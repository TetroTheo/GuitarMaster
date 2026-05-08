extends Node

func key_pressed(note):
	var npkg = NotePackage.new()
	npkg.duration = 1.0
	npkg.notes.append(note)
	$Sheet.add_note_pkg(npkg)
