class_name Measure
extends Control

## so that we know where we are in the track's array of measures
var measure_number : int
## changes the numberator of the song's time signature.
## examples:
## 1.0 = 4/4
## 1.5 = 6/4
## 0.75 = 3/4
var measure_length : float = 1.0
## for more song info
var tempo : float = 120
var time_signature_numerator : int = 4
var time_signature_denominator : int = 4

## the sheet calls this when making a new measure, so that the new measure may
## bind all of its editing buttons directly to that sheet.
func connect_editing_buttons(sheet : Track):
	$HBoxContainerLower/Delete.pressed.connect(sheet.on_delete.bind(self))
	$HBoxContainerLower/Duplicate.pressed.connect(sheet.on_duplicate.bind(self))
	$HBoxContainerUpper/Right.pressed.connect(sheet.on_move_right.bind(self))
	$HBoxContainerUpper/Left.pressed.connect(sheet.on_move_left.bind(self))
	$HBoxContainerLower/AddNote.pressed.connect(sheet.add_to.bind(self))
	$HBoxContainerUpperRight/Tempo.value_changed.connect(sheet.change_tempo.bind(self))

## the measure cannot set its own, so it relies on this function
func set_measure_number(n : int):
	measure_number = n
	$HBoxContainerUpper/Label.text = str(n)

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
	return is_equal_approx(get_duration(), measure_length) or get_duration() > measure_length

## returns whether or not the note's duration will fit within the measure or fill it entirely!
func can_fit(npkg: NotePackage) -> bool:
	return get_duration() + npkg.duration < measure_length or is_equal_approx(get_duration() + npkg.duration, measure_length)

## adds the Note Package Node to this measure
func add_npkgn(communicator, npkgn, pkg : NotePackage):
	$NotePackageNodes.add_child(npkgn)
	## sets the size, and notes
	## we send ourself as an argument so that the note can easier tell what to resize to!
	npkgn.set_note_pkg(self, communicator, pkg)
	set_add_note_visibility()

## instead of accessing nkpgns directly, the measure should just return them when requested.
func get_nkpgn():
	return $NotePackageNodes.get_children()

func edit_mode(toggled_on : bool):
	$HBoxContainerUpper/Left.visible = toggled_on
	$HBoxContainerUpper/Right.visible = toggled_on
	$HBoxContainerLower/Duplicate.visible = toggled_on
	$HBoxContainerLower/Delete.visible = toggled_on
	$HBoxContainerUpperRight.visible = toggled_on
	$HBoxContainerLowerRight.visible = toggled_on
	## this should only be visible when you can add notes!
	$HBoxContainerLower/AddNote.visible = toggled_on and not is_full()

## hide the Add Notes button if the measure is full!
## show this button when the measure is no longer full!
func set_add_note_visibility():
	if $HBoxContainerLower/AddNote.visible and is_full():
		$HBoxContainerLower/AddNote.hide()
	## check to see if another editing button is toggled.
	## if so, we are in editing mode!
	if $HBoxContainerLower/Delete.visible and not is_full():
		$HBoxContainerLower/AddNote.show()


func _on_tsn_value_changed(value: float) -> void:
	time_signature_numerator = int(value)
	update_measure_length()

func _on_tsd_value_changed(value: float) -> void:
	time_signature_denominator = int(value)
	update_measure_length()

## when changing the time signature, then we change the size ratio. so our notes should resize!
func update_measure_length():
	measure_length = float(time_signature_numerator) / time_signature_denominator
	for npkgn in get_nkpgn():
		npkgn.resize(self)
	set_add_note_visibility()


func _on_tempo_value_changed(value: float) -> void:
	tempo = value

## when loading a measure, it doesn't start with default text!
func update_display():
	update_measure_length()
	$HBoxContainerUpperRight/Tempo.set_value_no_signal(tempo)
	$HBoxContainerLowerRight/TSN.set_value_no_signal(time_signature_numerator)
	$HBoxContainerLowerRight/TSD.set_value_no_signal(time_signature_denominator)
