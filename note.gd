@tool
class_name Note
extends Resource

@export_range(0,24,1) var fret : int
@export var pitch : int
@export_range(0,5,1) var string : int

var key : Key

static var pitch_to_string : Array[String] = [
		'C','C#','D','D#','E','F',
		'F#','G','G#','A','A#','B'
]

## Fret Pitch String
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

## we start at C0, but the audio is E2, so offset by 28
## example inputs: 
## 'E1' (pitch = 16) -> 0.5
## 'E2' (pitch = 28) -> 1.0
## 'E3' (pitch = 40) -> 2.0
func scale_pitch() -> float:
	return exp(log(2) * (pitch - 28) / 12)


func _to_string() -> String:
	return note_name() + '(S' + str(string) + 'F' + str(fret) + ')'

## so that you can easily play a note from any node!
func play_sound(node : Node):
	var audio_player := AudioStreamPlayer.new()
	audio_player.stream = load("uid://jre4lw6j7p4d")
	audio_player.finished.connect(on_audio_player_finished.bind(audio_player))
	audio_player.pitch_scale = scale_pitch()
	node.add_child(audio_player)
	audio_player.play()

static func on_audio_player_finished(audio_player):
	audio_player.queue_free()
