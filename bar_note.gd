#@tool
extends ColorRect
var note
var next_tim #: float
var tim
## it knows what its note is, and has full access to all the note features!!
func _ready():
	#print(next_tim)
	if not note: 
		return
	#if note is intNote:
	#	text = "single"
	#elif note is intNotes:
	#	text = "multi"
	#else:
	#	text = "unknown"
	
	#text = note.get_note_name()
	## it works!!
	#if note.bend > 0:
	#	$ColorRect.color = Color.AQUA
	#await get_parent().ready
	#print(size)
	await get_tree().create_timer(0).timeout
	
	if note is intNote:
		add_label(note)
	elif note is intNotes:
		for i in note.get_arr():
			add_label(i)
	else:
		push_error("no proper note")
		return
	#print(size)
	#$quarter.position.x = 0#size.x / 2.0

func add_label(new_note):
	var new = Label.new()
	new.text = str(new_note.fret)
	new.position = Vector2(0,(new_note.stk*20))
	#print(new.position)
	#new.size.x = size.x
	#new.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	new.z_index = 2
	add_child(new)
	## for visuals
	#print(tim)
	$PM.visible = (new_note.mod == 1)
	if tim <= 2:
		$half.show()
	if tim <= 1:
		$quarter.show()
	if tim <= 0.5:
		$eighth.show()
	if tim <= 0.25:
		$sixteenth.show()
	if tim <= 0.125:
		$thirtytwo.show()
	if next_tim <= 0.5:
		$eighth.size.x = size.x
	if next_tim <= 0.25:
		$sixteenth.size.x = size.x
	if next_tim <= 0.125:
		$thirtytwo.size.x = size.x
	## extra support for eights? someday

##highlighting

func enable():
	#$ColorRect.show()
	#color.a = 0.5
	$ColorRect.color.a = 0.5

func disable():
	#$ColorRect.hide()
	color.a = 0
	$ColorRect.color.a = 0
