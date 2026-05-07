#@tool
extends MarginContainer
#var fret
#var stk
var note : intNote
signal clicked

## yet another useless function
func glow(yes:bool):
	if yes:
		$DisplayNote.color = Color.AQUA
	else:
		$DisplayNote.color = Color.BLACK

## somewhat useful
func setColor(col):
	$DisplayNote.color = col

signal here
#var margin_value = 0
func _ready():
	#print(note.note)
	#add_theme_constant_override("margin_top", margin_value)
	#add_theme_constant_override("margin_left", margin_value)
	#add_theme_constant_override("margin_bottom", margin_value)
	#add_theme_constant_override("margin_right", margin_value)
	if note.fret == 0: ## fret 0 spacing
		add_theme_constant_override("margin_right",5)
	#print("fret %s at string %s" % [fret, str])
	# debug
	
	#$Label.text = "(%s, %s)" % [fret, stk]
	#print(note.name)
	#await get_tree().create_timer(0.1).timeout
	$Label.text = note.get_note_name()
	
	refresh()
	## this is actually important because the editor needs the path to send signals to this node
	## also this signal is kind of delayed so don't let anyone click on notes immediately
	## after the game starts or this all just crashes
	here.emit(self)

func refresh(key = 0,scale_arr = [0,2,4,5,7,9,11]):
	if note.note == key:
		setColor(Color.MEDIUM_SPRING_GREEN)
	elif note.note in scale_arr:
		setColor(Color.AQUA)
	else:
		setColor(Color.BLACK)

## when scale dropdown item is chosen
func on_scale_change(key,scale_arr):
	refresh(key,scale_arr)

#func _gui_input(event: InputEvent) -> void:
#	if event is InputEventMouseButton and event.pressed:
#		print(note.name)
func on_highlight(fret,stk):
	print("hey")
	if (not (note.fret == fret)) or (not (note.stk == stk)):
		print("PRINT")
		return
	$AnimationPlayer.play("flash")
	print("?")

## wtf happened to signals though...
func fucking_highlight():
	$AnimationPlayer.stop()
	$AnimationPlayer.play("flash")
	#print("i am fucking useless")

## hitbox for this display note
func _on_texture_button_pressed() -> void:
	#print(note.name)
	## sends a copy so that if the note is manipulated, then this note is unaffected
	clicked.emit(note.copy())
