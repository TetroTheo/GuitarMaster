@tool
extends ScrollContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(6):
		var fret = HBoxContainer.new()
		fret.name = "Fret " + str(i)
		var pitch = 0
		for j in range(25):
			pitch += 1
			var key = Key.new()
			#key.set_script("uid://cxcf8fy3mqae6")
			key.set_note(Note.new(j, pitch, i))
			fret.add_child(key)
		$Strings.add_child(fret)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
