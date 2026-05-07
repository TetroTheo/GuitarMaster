#@tool
extends ColorRect
var bar : Array
var notes : Array
var count : int
@onready var bar_note_scn : PackedScene = load("res://bar_note.tscn")

## reads from bar to determine how many bar notes it should have
## assigns each bar note a corresponding element from notes
func _ready():
	#print(notes)
	#print(bar)
	$count.text = str(count+1)
	for i in range(bar.size()):
		#var new_block = ColorRect.new()
		#new_block.custom_minimum_size = Vector2(288/4.0 * bar[i],0)
		#new_block.color = Color.from_hsv((1.0/bar[i])/8,1,1)
		var bar_note = bar_note_scn.instantiate()
		bar_note.note = notes[i]
		bar_note.custom_minimum_size = Vector2($block.size.x/4.0 * bar[i],0)
		bar_note.color = Color.from_hsv((0.12*bar[i] + 0.5),0.8,1,0.3)
		print(bar[i])
		bar_note.tim = bar[i]
		if (i+1) == bar.size():
			bar_note.next_tim = 99
		else:
			bar_note.next_tim = bar[i+1]
		#new_block.add_child(bar_note)
		#new_block.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		#$block.add_child(new_block)
		$block.add_child(bar_note)

## if this is the right count, then make the jth child highlighted
func on_highlight(measure,j):
	#print("hey")
	
	for i in $block.get_children():
		i.disable()
	if not (count == measure): return
	$block.get_child(j).enable()
