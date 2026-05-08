class_name Note
extends Resource

@export_range(0,24,1) var fret : int
@export var pitch : int
@export_range(0,5,1) var string : int

func _init(f:= 0, p := 0, s:= 0) -> void:
	fret = f
	pitch = p
	string = s
