extends ScrollContainer

func add_note_pkg(pkg: NotePackage):
	var npkgn = load("uid://bqhqm608hhbdx").instantiate()
	$MeasureContainer/Measure.add_child(npkgn)
	npkgn.set_note_pkg(pkg)
