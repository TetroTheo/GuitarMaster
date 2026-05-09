class_name Measure
extends Control

var measure_number : int

## the sheet calls this when making a new measure, so that the new measure may
## bind all of its editing buttons directly to that sheet.
func connect_editing_buttons(sheet):
	$HBoxContainer/Delete.pressed.connect(sheet.on_delete.bind(self))
	$HBoxContainer/Duplicate.pressed.connect(sheet.on_duplicate.bind(self))
	$HBoxContainer/Right.pressed.connect(sheet.on_move_right.bind(self))
	$HBoxContainer/Left.pressed.connect(sheet.on_move_left.bind(self))
	$HBoxContainer/AddNote.pressed.connect(sheet.add_to.bind(self))

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
		if not npkgn.note_pkg:
			print("ERROR: NPKG NOT FOUND")
			continue
		duration += npkgn.note_pkg.duration
	return duration

## returns whether or not this measure is completely filled with notes
func is_full() -> bool:
	return is_equal_approx(get_duration(), 1.0)

## returns whether or not the note's duration will fit within the measure or fill it entirely!
func can_fit(npkg: NotePackage) -> bool:
	return get_duration() + npkg.duration < 1.0 or is_equal_approx(get_duration() + npkg.duration, 1.0)

## adds the Note Package Node to this measure
func add_npkgn(npkgn, pkg):
	$NotePackageNodes.add_child(npkgn)
	## sets the size, and notes
	npkgn.set_note_pkg(pkg)
	## hide the Add Notes button if the measure is full!
	if $HBoxContainer/AddNote.visible and is_full():
		$HBoxContainer/AddNote.hide()

## instead of accessing nkpgns directly, the measure should just return them when requested.
func get_nkpgn():
	return $NotePackageNodes.get_children()

func edit_mode(toggled_on : bool):
	$HBoxContainer/Left.visible = toggled_on
	$HBoxContainer/Right.visible = toggled_on
	$HBoxContainer/Duplicate.visible = toggled_on
	$HBoxContainer/Delete.visible = toggled_on
	## this should only be visible when you can add notes!
	$HBoxContainer/AddNote.visible = toggled_on and not is_full()
