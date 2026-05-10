extends Button

var note_pkg : NotePackage

## sets size according to the npkg duration, and changes the label to match.
## can show multiple notes for chords, and displays a rest when there are no notes.
func set_note_pkg(measure : Measure, communicator : Node, pkg : NotePackage):
	note_pkg = pkg
	size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	## works perfectly, for any measure size, and duration, and any time signature!
	custom_minimum_size.x = measure.custom_minimum_size.x * pkg.duration / measure.measure_length
	if pkg.notes:
		$Label.text = ''
		for note in pkg.notes:
			$Label.text += note.note_name() + '\n'
	else:
		$Label.text = 'REST'
	## we have passed the communicater all the way through, just for this one connection!
	pressed.connect(communicator.on_npkgn_pressed.bind(self))
