#@tool
extends Resource
class_name SaveTAB
## default values
@export var tim : Array
@export var melody : Array
@export var name : String = "New TAB"
@export var tempo : float = 120
@export var key : int = 0
@export var scale : int = 0

## copies everything and returns a new savetab
func copy():
	var new = SaveTAB.new()
	new.tim = tim
	new.melody = melody
	new.name = name
	new.tempo = tempo
	new.key = key
	new.scale = scale
	return new
