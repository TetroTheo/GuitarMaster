#@tool
extends VBoxContainer
var disp_note_scn : PackedScene = load("res://display_note.tscn")
#var tuning : Array[intNote] = intNote.fromString(["E2","A2","D3","G3","B3","E4"])
var str_tuning : Array[String] = ["E2","A2","D3","G3","B3","E4"]
signal scale_change
@onready var editor_container = %EditorContainer

func _ready():
	#var stks : Array[intNote]
	## stk is an array of 6 intNotes
	#for stk in ["E2","A2","D3","G3","B3","E4"]:
	#	stks.append(intNote.named(stk))
	str_tuning.reverse()
	#for i in stks:
		#print(i.note," ",i.octave)
	#stks.reverse()
	for stk in range(0,6): # stk = string key
		var Stk = HBoxContainer.new()
		Stk.name = "Stk"+str(stk+1)
		## we set the intNote to be the stkth string of the tuning array
		var smol_note : intNote = intNote.named(str_tuning[stk])#stks[stk]
		for fret in range(23):
			var disp_note = disp_note_scn.instantiate()
			disp_note.note = smol_note.copy()
			disp_note.note.fret = fret
			disp_note.note.stk = stk
			scale_change.connect(disp_note.on_scale_change)
			disp_note.clicked.connect(editor_container.on_disp_note_clicked)#.bind(disp_note.note,disp_note.fret,disp_note.stk))
			disp_note.here.connect(editor_container.fuck_you)
			Stk.add_child(disp_note)
			smol_note.up()
			#print(smol_note.note)
		add_child(Stk)
	
	return
	
	## old useless code
	@warning_ignore("unreachable_code")
	#tuning.reverse() ## because we go from top to bottom
	for i in range(0):
		#print(i.note)
		pass
	#	i.step(0)
	for stk in range(1,7): # stk = string key
		var Stk = HBoxContainer.new()
		Stk.name = "Stk"+str(stk) # very useful!
		# now we are putting notes on a new string at fret 0
		#var carrot_note : intNote = tuning[stk-1].duplicate() ## this is an intNote object
		for fret in range(23): #23
			var disp_note = disp_note_scn.instantiate()
			#disp_note.fret = fret
			#disp_note.stk = stk
			#disp_note.note = carrot_note.duplicate()
			disp_note.note.fret = fret
			disp_note.note.stk = stk
			scale_change.connect(disp_note.on_scale_change)
			#editor_container.disp_note_highlight.connect(disp_note.on_highlight)
			#editor_container.fuck.connect(disp_note.on_highlight)
			disp_note.clicked.connect(editor_container.on_disp_note_clicked)#.bind(disp_note.note,disp_note.fret,disp_note.stk))
			#editor_container.disp_note_highlight.connect(disp_note.on_highlight)
			Stk.add_child(disp_note)
		#	carrot_note.up()
		add_child(Stk)

## yeah this code doesn't do anything either
func on_disp_note_clicked(note):
	print(note.get_note_name())
	#%AudioStreamPlayer.play()
	var audio = AudioStreamPlayer.new()
	add_child(audio)
	audio.stream = load("res://A440.wav")
	var freq = pow(2,note.get_pitch()/12.0) * 440 
	audio.pitch_scale = pow(2,(note.get_pitch()-24)/12.0)
	print(freq)
	audio.play()
	await get_tree().create_timer(5.0).timeout
	audio.queue_free()
	#%AudioStreamPlayer.play()

## current key
var key = 0
## based on the options for the scale select dropdown
var scale_mode = 0
## this is important, do not change it.
const scale_presets = [
	[0, 2, 4, 5, 7, 9, 11], #major
	[0, 2, 3, 5, 7, 8, 10], #minor
	[0, 2, 4, 7, 9], #pent major
	[0, 3, 5, 7, 10], # pent minor
	[0, 2, 3, 5, 7, 9, 10], # dorian
	[0, 1, 3, 5, 7, 8, 10], # phrygian
	[0, 2, 4, 6, 7, 9, 11], # lydian
	[0, 2, 4, 5, 7, 9, 10], # mixolydian
	[0, 1, 3, 5, 6, 8, 10], # locrian
	[0, 2, 3, 5, 7, 8, 11], # harmonic
	[0, 2, 3, 5, 7, 9, 11], # melodic
	[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11] # chromatic
]
## current arr of scales based on scale_presets and what mode we are in
var scale_arr : Array = scale_presets[scale_mode]

## when a new scale is set
func _on_scale_item_selected(index: int) -> void:
	scale_mode = index
	refresh_board()

## we set the new scale array to be offset by the current key
func refresh_board():
	scale_arr = scale_presets[scale_mode].duplicate()
	for i in range(scale_arr.size()):
		scale_arr[i] = (scale_arr[i]+key)%12 ## hopefully works well
	#print(scale_arr)
	scale_change.emit(key,scale_arr)


func _on_key_item_selected(index: int) -> void:
	key = index
	refresh_board()
