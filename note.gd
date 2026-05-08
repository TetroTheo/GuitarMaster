@tool
class_name Note
extends Resource

@export_range(0,24,1) var fret : int
@export var pitch : int
@export_range(0,5,1) var string : int

static var pitch_to_string : Array[String] = [
		'C','C#','D','D#','E','F',
		'F#','G','G#','A','A#','B'
]

func _init(f := 0, p := 0, s := 0) -> void:
	fret = f
	pitch = p
	string = s


func pitch_letter() -> String:
	return pitch_to_string[pitch % 12]


func octave() -> int:
	return floori(pitch / 12.0)


func note_name()-> String:
	return pitch_letter() + str(octave())


static func pitch_from_string(name: String) -> int:
	var name_parts = name.split()
	var new_pitch := 0
	new_pitch += pitch_to_string.find(name_parts[0])
	new_pitch += 12 * int(name_parts[1])
	return new_pitch


func _to_string() -> String:
	return note_name() + ' (S' + str(string) + 'F' + str(fret) + ')'
