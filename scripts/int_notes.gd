#@tool
extends Resource
class_name intNotes
@export var arr : Array[intNote] = []
## copies
func copy() -> intNotes:
	var new = intNotes.new()
	new.arr = arr
	return new
## this automatically copies from the given array
func set_arr(new_arr : Array[intNote]) -> intNotes:
	arr = new_arr.duplicate()
	return self
## returns stored arr
func get_arr() -> Array[intNote]:
	return arr
