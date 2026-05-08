extends Button

var note_pkg : NotePackage

func set_note_pkg(pkg : NotePackage):
	note_pkg = pkg
	size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	custom_minimum_size.x = get_parent().custom_minimum_size.x / (4 / pkg.duration)
	if pkg.notes:
		$Label.text = ''
		for note in pkg.notes:
			$Label.text += note.note_name() + '\n'
	else:
		$Label.text = 'REST'
