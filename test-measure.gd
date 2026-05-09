extends Control

var measure_number : int

## the sheet calls this when making a new measure, so that the new measure may
## bind all of its editing buttons directly to that sheet.
func connect_editing_buttons(sheet):
	$HBoxContainer/Delete.pressed.connect(sheet.on_delete.bind(self))
	$HBoxContainer/Duplicate.pressed.connect(sheet.on_duplicate.bind(self))
	$HBoxContainer/Right.pressed.connect(sheet.on_move_right.bind(self))
	$HBoxContainer/Left.pressed.connect(sheet.on_move_left.bind(self))

## the measure cannot set its own, so it relies on this function
func set_measure_number(n : int):
	measure_number = n
	$HBoxContainer/Label.text = str(n)

## changes measure number by given amount
func change_measure_number(increment : int):
	set_measure_number(measure_number + increment)

## add up the duration of all child npkgs
func get_duration() -> float:
	var duration := 0.0
	for npkgn in $NotePackageNodes.get_children():
		duration += npkgn.note_pkg.duration
	return duration


func edit_mode(toggled_on : bool):
	var v = toggled_on
	$HBoxContainer/Left.visible = v
	$HBoxContainer/Right.visible = v
	$HBoxContainer/Duplicate.visible = v
	$HBoxContainer/Delete.visible = v
