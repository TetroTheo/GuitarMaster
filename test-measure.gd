extends Control

var measure_number : int

func set_measure_number(n : int):
	measure_number = n
	$Label.text = str(n)


func get_duration() -> float:
	var duration := 0.0
	for npkgn in $NotePackageNodes.get_children():
		duration += npkgn.note_pkg.duration
	return duration
