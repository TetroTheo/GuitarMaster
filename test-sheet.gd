extends ScrollContainer

## adds an npkg to the sheet. if the last measure is full, we make a new one.
## either way, we add the measure to an available space in a measure.
func add_note_pkg(pkg: NotePackage):
	var npkgn = load("uid://bqhqm608hhbdx").instantiate()
	var last_measure = $MeasureContainer.get_child(-1)
	var current_measure
	if last_measure.get_duration() < 1.0 and not is_equal_approx(last_measure.get_duration(), 4.0):
		current_measure = last_measure
	else:
		var new_measure = load("res://test-measure.tscn").instantiate()
		$MeasureContainer.add_child(new_measure)
		new_measure.set_measure_number($MeasureContainer.get_child_count())
		current_measure = new_measure
	current_measure.get_node("NotePackageNodes").add_child(npkgn)
	npkgn.set_note_pkg(pkg)
