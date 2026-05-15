@tool
class_name Note
extends Resource

@export_range(0,24,1) var fret : int
@export var pitch : int
@export_range(0,5,1) var string : int

#var key : Key

static var pitch_to_string : Array[String] = [
		'C','C#','D','D#','E','F',
		'F#','G','G#','A','A#','B'
]

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

static var audio_file : String = "res://audio/guitar-E2-distorted-shortened.wav"

## Fret Pitch String
func _init(f := 0, p := 0, s := 0) -> void:
	fret = f
	pitch = p
	string = s
	#print(pitch_from_string("A4"))


func pitch_letter() -> String:
	return pitch_to_string[pitch % 12]


func octave() -> int:
	return floori(pitch / 12.0)

## example -> "A4"
func note_name() -> String:
	return pitch_letter() + str(octave())


static func pitch_from_string(name: String) -> int:
	var name_parts = name.split()
	var new_pitch := 0
	new_pitch += pitch_to_string.find(name_parts[0])
	new_pitch += 12 * int(name_parts[1])
	return new_pitch

## A4 = 440 is an exact definition for the pitch scale,
## so we start with that, because we know the exact pitch value it will land on.
## from there, determining the rest of the function is easy.
static func pitch_from_frequency(frq: float) -> int:
	return roundi(12 * log(frq / 440)/log(2) + 57)
	

## (in our pitch variable) we store C0 as pitch = 0, 
## but the audio is E2, so offset by 28
## example inputs: 
## 'E1' (pitch = 16) -> 0.5
## 'E2' (pitch = 28) -> 1.0
## 'E3' (pitch = 40) -> 2.0
func scale_pitch() -> float:
	return exp(log(2) * (pitch - 28) / 12)


func _to_string() -> String:
	return note_name() + '(S' + str(string) + 'F' + str(fret) + ')'

## so that you can easily play a note from any node!
# make the audio configurable!
func play_sound(node : Node):
	var audio_player := AudioStreamPlayer.new()
	audio_player.stream = load(audio_file)
	audio_player.finished.connect(on_audio_player_finished.bind(audio_player))
	audio_player.pitch_scale = scale_pitch()
	node.add_child(audio_player)
	audio_player.play()

static func on_audio_player_finished(audio_player):
	audio_player.queue_free()

## returns whether or not this note's pitch is in the given scale.
func in_scale(pitch_key : int, interval_key : int) -> bool:
	## pretend our pitch has been moved down to the key of C.
	## the +12 keeps the value positive before the modulo operation.
	var offset_pitch := (pitch - pitch_key + 12) % 12
	## if our key in C matches the allowed intervals, it's in the scale!
	return offset_pitch in interval_presets[interval_key]

## the pitch value is dependent on the octave,
## so this modulus removes that dependency.
func same_note_name_as(other_pitch: int):
	return pitch % 12 == other_pitch % 12
