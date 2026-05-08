@tool
extends ScrollContainer


var tuning : Array[String] = ['E2', 'A2', 'D3', 'G3', 'B3', 'E4']

## instantiates keys in the fretboard
func _ready() -> void:
	for i in range(5,-1,-1):
		var fret = HBoxContainer.new()
		fret.name = "String " + str(i)
		## sets the starting pitch
		var pitch = Note.pitch_from_string(tuning[i])
		## adds keys on frets along the current string, 
		## starting on fret 0
		for j in range(25):
			var key = Key.new()
			key.set_note(Note.new(j, pitch, i))
			fret.add_child(key)
			pitch += 1
		## there will be 6 total frets
		$Strings.add_child(fret)
