class_name MeasurePackage
extends Resource

@export var note_packages : Array[NotePackage]
@export var time_signature_numerator : int
@export var time_signature_denominator : int
@export var tempo : float

func _to_string() -> String:
	var string := ""
	string += str(time_signature_numerator) + "/" + str(time_signature_denominator) + "|"
	string += str(tempo) + "BPM|"
	string += str(note_packages)
	return string
