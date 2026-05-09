@tool
extends ScrollContainer


var tuning : Array[String] = ['E2', 'A2', 'D3', 'G3', 'B3', 'E4']
var bass_tuning : Array[String] = ['E1', 'A1', 'D2', 'G2']
var left_handed := false
var bass_mode := false

## instantiates keys in the fretboard
func _ready() -> void:
	create_keys()

## builds all the keys and adds them to this fretboard, with connections.
## this will be useful for when switching between left-handed or bass mode
func create_keys():
	## switches the tuning to bass (and there are four strings)
	if bass_mode:
		tuning = bass_tuning
	for i in range(len(tuning)-1,-1,-1):
		var string = HBoxContainer.new()
		string.name = "String " + str(i)
		## sets the starting pitch
		var pitch = Note.pitch_from_string(tuning[i])
		## adds keys on frets along the current string, 
		## starting on fret 0
		var keys : Array[Key] = []
		for j in range(25):
			var key = Key.new()
			key.set_note(Note.new(j, pitch, i))
			## if we are running this scene on its own, then this shouldn't run!
			if get_parent().name == "Communicator":
				key.key_pressed.connect(get_parent().key_pressed)
			keys.append(key)
			pitch += 1
		## now that the keys are in an array, we flip them like this:
		if left_handed:
			keys.reverse()
		## now we add them to the string all at once
		for key in keys:
			string.add_child(key)
		## there will be 6 total strings
		## unless we're in bass mode!
		$Strings.add_child(string)
