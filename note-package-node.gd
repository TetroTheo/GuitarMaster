extends Button

var note_pkg : NotePackage

## sets size according to the npkg duration, and changes the label to match.
## can show multiple notes for chords, and displays a rest when there are no notes.
func set_note_pkg(measure : Measure, communicator : Node, pkg : NotePackage):
	note_pkg = pkg
	size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	## resizes the node according to the measure size and time signature, and the note itself!
	resize(measure)
	update_note_display()
	## we have passed the communicater all the way through, just for this one connection!
	pressed.connect(communicator.on_npkgn_pressed.bind(self))

## works perfectly, for any measure size, and duration, and any time signature!
func resize(measure : Measure):
	custom_minimum_size.x = measure.custom_minimum_size.x * note_pkg.duration / measure.measure_length

## for when rewriting a node
func update_note_display():
	if note_pkg.notes:
		$Label.text = ''
		for note in note_pkg.notes:
			$Label.text += note.note_name() + '\n'
	else:
		$Label.text = 'REST'
	## you can change the duration when rewriting, too!
	resize(get_parent().get_parent())
	get_parent().get_parent().update_display()
