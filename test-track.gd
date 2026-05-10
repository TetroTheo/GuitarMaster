@tool
class_name Track
extends ScrollContainer


@onready var measures = $MeasureContainer
var measure_mode := false
var measure_to_add_to := -1
var overwrite_npkg : Node = null
signal measure_deleted

func _ready() -> void:
	create_new_measure()


## adds an npkg to the sheet. if the last measure is full, we make a new one.
## either way, we add the measure to an available space in a measure.
func add_note_pkg(communicator: Node, pkg: NotePackage):
	## instead of adding a note, we write to an existing npkg,
	## if the communicator has told us to!
	if overwrite_npkg:
		overwrite_npkg.note_pkg = pkg
		## because the text does not update itself
		overwrite_npkg.update_note_display()
		## we remove the reference, but the node still exists!
		overwrite_npkg = null
		return
	var npkgn = load("uid://bqhqm608hhbdx").instantiate()
	var current_measure : Measure
	if measures.get_children():
		var last_measure = measures.get_child(measure_to_add_to)
		if last_measure.can_fit(pkg):
			current_measure = last_measure
		else:
			## if we were not adding to the last measure, then now we are!
			## because the measure we were adding to must be full!
			if measure_to_add_to > -1:
				measure_to_add_to = -1
				## make an attempt to add to the last measure if unfilled
				## otherwise, we make a new one!
				var new_last_measure = measures.get_child(-1)
				if new_last_measure.can_fit(pkg):
					current_measure = new_last_measure
				else:
					current_measure = create_new_measure()
			## if we were adding to the last measure, then let's make a new measure!
			else:
				current_measure = create_new_measure()
	else:
		current_measure = create_new_measure()
	current_measure.add_npkgn(communicator, npkgn, pkg)


func create_new_measure() -> Measure:
	var new_measure = load("res://test-measure.tscn").instantiate()
	new_measure.set_measure_number(measures.get_child_count())
	new_measure.connect_editing_buttons(self)
	new_measure.edit_mode(measure_mode)
	measures.add_child(new_measure)
	return new_measure


func edit_measure_mode(toggled_on: bool):
	measure_mode = toggled_on
	for measure in measures.get_children():
		measure.edit_mode(toggled_on)

## deletes the measure that sent this
## moves measures that come after it backwards by one.
func on_delete(measure):
	## for the communicator to update any buttons connected to this measure
	measure_deleted.emit(measure)
	for i in range(measure.measure_number, measures.get_child_count()):
		measures.get_child(i).change_measure_number(-1)
	measure.queue_free()

## duplicates the measure that sent this signal, and inserts that measure right after where it was duplicated.
## it moves measures that come after forward by one.
func on_duplicate(measure : Measure):
	for i in range(measure.measure_number + 1, measures.get_child_count()):
		measures.get_child(i).change_measure_number(+1)
	## should we just create a new measure?
	#var copy = create_new_measure()
	
	
	var copy = measure.duplicate()
	## some annoying extra duplication, because the resources are not duplicated properly!
	var index := 0
	for npkgn in measure.get_node("NotePackageNodes").get_children():
		copy.get_node("NotePackageNodes").get_child(index).note_pkg = npkgn.note_pkg.duplicate()
		index += 1
	copy.set_measure_number(measure.measure_number + 1)
	## duplication does not copy signal connections!
	copy.connect_editing_buttons(self)
	## it also does not copy time signatures or tempo
	copy.time_signature_numerator = measure.time_signature_numerator
	copy.time_signature_denominator = measure.time_signature_denominator
	copy.tempo = measure.tempo
	measures.add_child(copy)
	measures.move_child(copy, copy.measure_number)

## moves the measure that sent this right, while moving the one after it backwards.
func on_move_right(measure):
	measures.move_child(measure, measure.measure_number + 1)
	measures.get_child(measure.measure_number).change_measure_number(-1)
	measure.change_measure_number(+1)

## moves the measure that sent this left, while moving the one before it forwards.
func on_move_left(measure):
	measures.move_child(measure, measure.measure_number - 1)
	measures.get_child(measure.measure_number).change_measure_number(+1)
	measure.change_measure_number(-1)


## if a measure is unfilled, this lets us add more notes to it!
func add_to(measure):
	measure_to_add_to = measure.measure_number

## returns the full song of this track for playback
func get_song() -> SongPackage:
	var song_pkg := SongPackage.new()
	for measure in measures.get_children():
		var measure_pkg := MeasurePackage.new()
		measure_pkg.tempo = measure.tempo
		measure_pkg.time_signature_numerator = measure.time_signature_numerator
		measure_pkg.time_signature_denominator = measure.time_signature_denominator
		for npkgn in measure.get_nkpgn():
			measure_pkg.note_packages.append(npkgn.note_pkg)
		song_pkg.measure_packages.append(measure_pkg)
	return song_pkg

## this works perfectly, somehow!
func load_song(communicator : Node, song : SongPackage):
	clear_song()
	for measure in song.measure_packages:
		var new_measure = create_new_measure()
		new_measure.tempo = measure.tempo
		new_measure.time_signature_numerator = measure.time_signature_numerator
		new_measure.time_signature_denominator = measure.time_signature_denominator
		new_measure.update_display()
		for npkg in measure.note_packages:
			var npkgn = load("uid://bqhqm608hhbdx").instantiate()
			new_measure.add_npkgn(communicator, npkgn, npkg)


func clear_song():
	for child in measures.get_children():
		child.queue_free()
	await get_tree().create_timer(0.1).timeout
	


func change_tempo(value : float, measure : Measure):
	print(measures.get_children())
	var tempo_to_change : float
	for i in range(measure.measure_number, measures.get_child_count()):
		## think of this like a paint bucket tool, where we keep changing similar measures!
		if i == 1:
			tempo_to_change = measures.get_child(i).tempo
		if i > 1 and not is_equal_approx(measures.get_child(i).tempo,tempo_to_change):
			break
		measures.get_child(i).tempo = value
		measures.get_child(i).update_display()
