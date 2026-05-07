#@tool
extends Resource
class_name intNote
## conveniently can switch between named and int thanks to this
static var note_names = ["C","C#","D","D#","E","F","F#","G","G#","A","A#","B"]

## really bad function, the first I wrote for this project. don't use it!!
static func fromString(names:Array[String]):
	var arr : Array[intNote] = []
	for my_name in names:
		var new_note : intNote = intNote.new()
		new_note.note = note_names.find(my_name.substr(0,1))
		#print(new_note.note)
		new_note.octave = int(my_name.substr(1,1))
		arr.append(new_note)
		#arr.append(intNote.new( note_names.find(my_name.substr(0,1)), int(my_name.substr(1,1)) ))
	return arr

## default values
@export var fret : int = -1
@export var stk : int = -1

@export var note : int
@export var octave : int




#var pitch
#var name
## constructors are destructive if you want to store these in a passive resource
func _init(): 
	#print(note)
	#print(octave)
	pass
	#note = note_names.find(my_name.substr(0,1))
	#octave = int(my_name.substr(1,1))
	#note = my_note
	#octave = my_octave
	#update_info()

## creates an intNote based on a string EX: "E2" will return an intNote with note 4, octave 2
static func named(my_name:String) -> intNote:
	var new_note : intNote = intNote.new()
	new_note.note = note_names.find(my_name.substr(0,1))
	new_note.octave = int(my_name.substr(1,1))
	return new_note

## these variables are now in get functions to be more efficient
func update_info():
	pass
	#pitch = note + (12 * (octave-1))
	#print(note_names[note])
	#name = str(note_names[note])#+str(octave)
	#print(name)

func get_pitch():
	return note + (12 * (octave-1)) + 3 ## +3 so that A0 will return 0

func get_note_name() -> String:
	if note == null:
		push_error("idiot")
		note = 0
	return str(note_names[note])+str(octave)

## increases by one semitone
func up():
	note += 1
	if note == 12:
		note = 0
		octave += 1
	update_info()

## lowers by one semitone
func down():
	note -= 1
	if note == -1:
		note = 11
		octave -= 1
	update_info()

## how much to increase the pitch per one semitone
func step(delta):
	if delta < 0:
		for i in range(abs(delta)):
			down()
	elif delta > 0:
		for i in range(delta):
			up()

## 0 is normal, 1 is palm muted, 2 is string muted, 3 is rest
## 4 is tap, 5 is harmonic, 6 is slide up, 7 is slide down
@export var mod : int = 0
@export var vibrato : bool = false
## 0 is none, 1 is half bend, 2 is full bend
@export var bend : int = 0
func copy() -> intNote:
	update_info()
	var new = intNote.new()
	## necessary data
	new.note = note
	new.octave = octave
	new.fret = fret
	new.stk = stk
	new.mod = mod
	new.bend = bend
	new.vibrato = vibrato
	return new
