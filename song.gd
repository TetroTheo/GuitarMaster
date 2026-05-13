extends Resource
class_name SongPackage

@export var measure_packages : Array[MeasurePackage]

func _to_string() -> String:
	return "SONG|" + str(measure_packages)
