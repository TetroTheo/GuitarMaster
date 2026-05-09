extends ScrollContainer

var measure_mode := false
var add_to_measure := -1

func _ready() -> void:
	create_new_measure()


## adds an npkg to the sheet. if the last measure is full, we make a new one.
## either way, we add the measure to an available space in a measure.
func add_note_pkg(pkg: NotePackage):
	var npkgn = load("uid://bqhqm608hhbdx").instantiate()
	var current_measure
	if $MeasureContainer.get_children():
		var last_measure = $MeasureContainer.get_child(add_to_measure)
		if last_measure.get_duration() + pkg.duration < 1.0 or is_equal_approx(last_measure.get_duration() + pkg.duration, 1.0):
			current_measure = last_measure
		else:
			## if we were not adding to the last measure, then now we are!
			## because the measure we were adding to must be full!
			if add_to_measure > -1:
				add_to_measure = -1
				## make an attempt to add to the last measure if unfilled
				## otherwise, we make a new one!
				var new_last_measure = $MeasureContainer.get_child(-1)
				if new_last_measure.get_duration() + pkg.duration < 1.0 or is_equal_approx(new_last_measure.get_duration() + pkg.duration, 1.0):
					current_measure = new_last_measure
				else:
					current_measure = create_new_measure()
			## if we were adding to the last measure, then let's make a new measure!
			else:
				current_measure = create_new_measure()
	else:
		current_measure = create_new_measure()
	current_measure.add_npkgn(npkgn, pkg)


func create_new_measure() -> Node:
	var new_measure = load("res://test-measure.tscn").instantiate()
	new_measure.set_measure_number($MeasureContainer.get_child_count())
	new_measure.connect_editing_buttons(self)
	new_measure.edit_mode(measure_mode)
	$MeasureContainer.add_child(new_measure)
	return new_measure


func edit_measure_mode(toggled_on: bool):
	measure_mode = toggled_on
	for measure in $MeasureContainer.get_children():
		measure.edit_mode(toggled_on)

## deletes the measure that sent this
## moves measures that come after it backwards by one.
func on_delete(measure):
	for i in range(measure.measure_number, $MeasureContainer.get_child_count()):
		$MeasureContainer.get_child(i).change_measure_number(-1)
		measure.queue_free()

## duplicates the measure that sent this signal, and inserts that measure right after where it was duplicated.
## it moves measures that come after forward by one.
func on_duplicate(measure):
	for i in range(measure.measure_number + 1, $MeasureContainer.get_child_count()):
		$MeasureContainer.get_child(i).change_measure_number(+1)
	var copy = measure.duplicate()
	## some annoying extra duplication, because the resources are not duplicated properly!
	var index := 0
	for npkgn in measure.get_node("NotePackageNodes").get_children():
		copy.get_node("NotePackageNodes").get_child(index).note_pkg = npkgn.note_pkg.duplicate()
		index += 1
	duplicate()
	copy.set_measure_number(measure.measure_number + 1)
	## duplication does not copy signal connections!
	copy.connect_editing_buttons(self)
	$MeasureContainer.add_child(copy)
	$MeasureContainer.move_child(copy, copy.measure_number)

## moves the measure that sent this right, while moving the one after it backwards.
func on_move_right(measure):
	$MeasureContainer.move_child(measure, measure.measure_number + 1)
	$MeasureContainer.get_child(measure.measure_number).change_measure_number(-1)
	measure.change_measure_number(+1)

## moves the measure that sent this left, while moving the one before it forwards.
func on_move_left(measure):
	$MeasureContainer.move_child(measure, measure.measure_number - 1)
	$MeasureContainer.get_child(measure.measure_number).change_measure_number(+1)
	measure.change_measure_number(-1)


## if a measure is unfilled, this lets us add more notes to it!
func add_to(measure):
	add_to_measure = measure.measure_number
