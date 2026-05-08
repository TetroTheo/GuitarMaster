extends Control

var measure_number : int


## the measure cannot set its own, so it relies on this function
func set_measure_number(n : int):
	measure_number = n
	$HBoxContainer/Label.text = str(n)

## add up the duration of all child npkgs
func get_duration() -> float:
	var duration := 0.0
	for npkgn in $NotePackageNodes.get_children():
		duration += npkgn.note_pkg.duration
	return duration
