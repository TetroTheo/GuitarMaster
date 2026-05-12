@tool
extends ScrollContainer

## tuning settings
var tuning : Array[String] = ['E2', 'A2', 'D3', 'G3', 'B3', 'E4']
var bass_tuning : Array[String] = ['E1', 'A1', 'D2', 'G2']
## configurable options
var LEFT_HANDED := false
var BASS_MODE := false
var FRET_NUMBER := 24
var SCALE_FRETS := true
## we derived the scaling constant!
const SCALE_FRET_FACTOR : float = (1 - (2 ** (-1/12.0))) ** -1

## instantiates keys in the fretboard
func _ready() -> void:
	create_keys()

## builds all the keys and adds them to this fretboard, with connections.
## this will be useful for when switching between left-handed or bass mode
func create_keys():
	## switches the tuning to bass (and there are four strings)
	if BASS_MODE:
		tuning = bass_tuning
	# for debugging
	for string_note in tuning:
		print(Note.pitch_from_string(string_note))
	for i in range(len(tuning)-1,-1,-1):
		var string = HBoxContainer.new()
		string.name = "String " + str(i)
		## sets the starting pitch
		var pitch = Note.pitch_from_string(tuning[i])
		## adds keys on frets along the current string, 
		## starting on fret 0
		var keys : Array[Key] = []
		## determine the length of each fret (may change)
		var fret_length : float
		var remaining_length : float = 3_000
		if SCALE_FRETS:
			fret_length = remaining_length / SCALE_FRET_FACTOR
		else: ## constant length
			fret_length = 42
		## add one to include fret zero
		for j in range(FRET_NUMBER + 1):
			var key = Key.new()
			if SCALE_FRETS and not j:
				key.set_length(40)
			else:
				key.set_length(fret_length)
			key.set_note(Note.new(j, pitch, i))
			## if we are running this scene on its own, then this shouldn't run!
			if get_parent().name == "Communicator":
				key.key_pressed.connect(get_parent().key_pressed)
			keys.append(key)
			pitch += 1
			## apparently, we follow the rule of 18
			## TODO: find out where this number came from!
			if SCALE_FRETS:
				remaining_length -= fret_length
				fret_length = remaining_length / SCALE_FRET_FACTOR
				print(fret_length, " ", SCALE_FRET_FACTOR)
		## now that the keys are in an array, we flip them like this:
		if LEFT_HANDED:
			keys.reverse()
		## now we add them to the string all at once
		for key in keys:
			string.add_child(key)
		## there will be 6 total strings
		## unless we're in bass mode!
		$Strings.add_child(string)
