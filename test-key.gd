@tool
class_name Key
extends Button

var key_note : Note

func set_note(note: Note):
	key_note = note
	text = str(key_note.pitch)
