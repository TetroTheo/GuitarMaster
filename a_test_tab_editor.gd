#@tool
extends HBoxContainer
#var tim = [] # array of ints
#var melody = [] # array of intnotes
#var pos = []
var tripled = false
var dotted = false
var measure_scn : PackedScene = load("res://measure.tscn")
var files : Array[SaveTAB] = [SaveTAB.new()]
var current_file : int = 0
var file = files[0]
var tim = file.tim
var melody = file.melody
var numTabs : int = 1

var left = load("res://metro_l.png")
var right = load("res://metro_r.png")

#signal disp_note_highlight
@onready var BarContainer = $"../../../ScrollContainer/BarContainer"
@onready var SettingsPanel = $"../../../../ControlBar/HBoxContainer/SettingsTAB/SettingsPanel"
const MEASURE = 4
var node_arr = []
## edit bars
var editor_mode : bool = false

## makes connections, gets the position of every dispnote
func _ready():
	for child:Node in get_children():
		if child is BaseButton:
			child.pressed.connect(on_pressed.bind(child))
	%TabBar.add_tab("New TAB")
	current_file = 0
	%TabBar.current_tab = current_file
	var mini_arr = []
	for i in range(23):
		mini_arr.append(0)
	for j in range(6):
		node_arr.append(mini_arr.duplicate())
	##Canon Rock!!!
	_on_loader_file_selected("res://saves/Canon Rock - Jerry C.tres")
	await get_tree().create_timer(0.1).timeout
	highlight.emit(-1,-1)
	#await get_tree().create_timer(1).timeout
	#print(node_arr)
	#save()

## checks if shift is unpressed, and if a multinote array has been formed.
## then it adds the multinote to melody.
func _process(_delta: float) -> void:
	#return
	if Input.is_action_just_released("multi_note"):
		if multinote.size() > 1:
			add_tim()
			var new_multinote : intNotes = intNotes.new().set_arr(multinote)
			for i in new_multinote.get_arr():
				## we want to play our multinote to preview it!
				audio_stuff(i)
				## we also want to transfer mod data to all notes, just because
				i.mod = next_mod
				i.bend = next_bend
				i.vibrato = next_vibrato
			melody.append(new_multinote)
			#melody.append(intNotes.new().set_arr(multinote))
			multinote.clear()
			refresh_measures()

## appends a tim interval to tim depending on the selected measure
func add_tim():
	if not (tripled or dotted):
		tim.append(4/type)
	elif tripled:
		tim.append(4/(3*type)) 
	elif dotted:
		tim.append(4/((2.0/3.0)*type))

## stops playing, updates necessary variables
func _on_tab_bar_tab_changed(tab: int) -> void:
	if tab >= numTabs:
		push_warning("Tab not found")
		%TabBar.remove_tab(tab)
		return
	current_file = tab
	stop = true
	refresh_file_saving()

## based on what the current_file is, we make sure we have read and loaded
## everything from the file, and will now write everything to that file
func refresh_file_saving():
	file = files[current_file]
	tim = file.tim
	melody = file.melody
	%SettingsName.text = file.name
	%SettingsMetro.value = file.tempo
	%Key.select(file.key)
	%Scale.select(file.scale)
	%Metro.value = file.tempo
	%SettingsKey.text = %Key.get_item_text(file.key) + " " + %Scale.get_item_text(file.scale)
	## now we must also reset the fretboard
	%DisplayNoteContainer.scale_mode = file.scale
	%DisplayNoteContainer.key = file.key
	%DisplayNoteContainer.refresh_board()
	refresh_measures()

## stops play, clears the data for the current tab,
## if there is more than one tab, we can switch and the tab will emit a signal for that
## if there is one tab we add a new tab before deleting the current one
func _on_close_pressed() -> void:
	#if numTabs == 1: 
	#	_on_clear_pressed()
	#	return ## we cannot have 0 tabs
	stop = true
	print(current_file)
	files[current_file] = SaveTAB.new()
	files.remove_at(current_file)
	if numTabs == 1:
		## this adds +1 numTabs
		_on_new_tab_pressed()
	## this will trigger the change tab function
	%TabBar.remove_tab(current_file)
	
	#files.remove_at(current_file)
	#current_file = %TabBar.current_tab
	#print(current_file)
	numTabs -= 1
	#refresh_file_saving()

## creates fresh new tab and with the newtab title.
## the saveTAB will default to all the predetermined values
func _on_new_tab_pressed() -> void:
	files.append(SaveTAB.new())
	%TabBar.add_tab("New TAB")
	numTabs += 1

func on_disp_note_clicked(note):
	audio_stuff(note)
	if not editor_mode: return
	if not Input.is_action_pressed("cancel_adding"):
		if Input.is_action_pressed("multi_note"):
			#add_multinote(note)
			multinote.append(note)
		else:
			add_note(note)

func fuck_you(node):
	#node.on_highlight(node.note.fret,node.note.stk)
	await get_tree().create_timer(0.5).timeout
	node_arr[node.note.stk][node.note.fret] = node

## given a single intNote, creates a new audiostream and plays that note.
## audio modifiers are taken into consideration here.
func audio_stuff(note : intNote):
	## proof the data has been transmitted: all of these are 0/false on the fretboard
	#print("mod ",note.mod," bend ",note.bend," vibrato ",note.vibrato)
	if note.mod == 3:
		return ##rest
	#print(note.get_note_name())
	#print("yo")
	if (note.fret > -1) and (note.stk > -1):
		#print("yes")
		if node_arr[note.stk][note.fret] is int:
			push_error("Loading error")
			return
		node_arr[note.stk][note.fret].fucking_highlight()
		#fuck.emit(note.fret,note.stk)
	#else: print("hm")
	var audio = AudioStreamPlayer.new()
	add_child(audio)
	## if you need to change the default sound, this is it
	audio.stream = load("res://A440.wav")
	#var freq = pow(2,note.get_pitch()/12.0) * 440 
	if not (note.mod == 2): ## this would be muted strings
		## exponent math. the starting pitch is 440, so we multiply by 2^1/12
		## to get to the note after that, EX A#0. in this code we lower the
		## sound by three octaves before dividing so that the sound doesn't scale too high.
		audio.pitch_scale = pow(2,(note.get_pitch()-36)/12.0)
	else:
		audio.pitch_scale = 0.1
	if (note.mod == 1 or note.mod == 2): ## palm mute or string mute
		audio.volume_db = -5
	#if false: print(freq)
	audio.play()
	## delete the player after it has played the sound in full
	await get_tree().create_timer(5.0).timeout
	audio.queue_free()

## this is the inverse of the actual note length.
## EX 1/4 = 0.25
var type = 4.0
var next_mod : int = 0
var next_bend : int = 0 ## default for no bend
var next_vibrato : bool = false
@onready var selected_button = $"4"
@onready var selected_mod = $m0
func on_pressed(button):
	if &"time" in button.get_groups():
		if button is CheckButton:
			if button.name == "Triplet":
				tripled = not tripled
			elif button.name == "Dotted":
				dotted = not dotted
			## we are not adding anything so no debug needed
			return
		type = float(button.name)
		selected_button.modulate = Color.WHITE
		selected_button = button
		selected_button.modulate = Color.MEDIUM_SPRING_GREEN
	elif &"mod" in button.get_groups():
		match button.name:
			"vibrato":
				next_vibrato = not next_vibrato
			"bend":
				next_bend = (next_bend + 1)%3
			_:
				#print(button.name.substr(1,1))
				next_mod = int(button.name.substr(1,1))
				selected_mod.modulate = Color.WHITE
				selected_mod = button
				selected_mod.modulate = Color.MEDIUM_SPRING_GREEN
	#print("?????????????????????????????????????????FUCK YOU FUCK YOU FUCK YOU")
	
## generated based off tim
var bar
## generated based off melody
var notes
## tell a bar note to highlight
signal highlight

## multinote queue
var multinote : Array[intNote] = []

func add_note(note):
	add_tim()
	## one quarter note is ALWAYS 1 beat, so we are ALWAYS in MEASURE/4
	## we reset the modification after applying it to the note, but I won't :)
	note.mod = next_mod
	note.bend = next_bend
	note.vibrato = next_vibrato
	#print("mod ",note.mod," bend ",note.bend," vibrato ",next_vibrato)
	melody.append(note)
	refresh_measures()

func refresh_measures():
	#print("tim = "+str(tim))
	var total = 0
	#for b in tim:
	#	total += b
	#print("total beats = "+str(total))
	#var measures = total / MEASURE
	#print("measures = "+str(measures))
	#var full_measures = floori(total / MEASURE)
	#print("full measures = "+str(full_measures))
	## we are reloading bar and notes in this script basically,
	## because either tim or melody has been updated
	bar = []
	## represents a measure of bar
	var smol_bar = []
	notes = []
	## one measure worth of notes
	var smol_notes = []
	#total = 0
	## i need a girlfriend so badly
	## girlfriend girlfriend girlfriend girlfriend girlfriend girlfriend girlfriend girlfriend
	## girlfriend girlfriend girlfriend girlfriend girlfriend girlfriend girlfriend girlfriend
	## girlfriend girlfriend girlfriend girlfriend girlfriend girlfriend girlfriend girlfriend
	if not (tim.size() == melody.size()):
		push_error("the arrays are not the same size!")

	for i in range(tim.size()):
		total += tim[i]
		#print(total)
		## measure overflow
		if total > 4:
			#print("FUCK YOU")
			## we add the smols to the mains
			## then we put the current notes into the next smol/measure
			bar.append(smol_bar.duplicate())
			notes.append(smol_notes.duplicate())
			smol_bar = [tim[i]]
			smol_notes = [melody[i]]
			total = tim[i]
		else:
			## default for adding notes to smol
			smol_bar.append(tim[i])
			smol_notes.append(melody[i])
	## leftover smol to new measure
	bar.append(smol_bar.duplicate())
	notes.append(smol_notes.duplicate())
	## EXTRA array?
	#bar.append([])
	#notes.append([])
	## inefficiently clear all of barcontainer display
	for i in BarContainer.get_children():
		i.queue_free() 
	## so that the measure knows which number it is
	var count := 0
	## adding measures based on the list of smol bars
	for i in bar.size():
		var measure = measure_scn.instantiate()
		## each measure gets its own smol bar
		measure.bar = bar[i]
		measure.notes = notes[i]
		measure.count = count
		## bar note highlighting
		highlight.connect(measure.on_highlight)
		BarContainer.add_child(measure)
		count += 1
	#highlight.emit(0,0)

var bpm : float = 120

## this triggers even when value is changed by switching tabs,
## which is just what I sought after!
func _on_metro_value_changed(value: float) -> void:
	bpm = value

## when stop is true, then the async will pause when it can
var stop = false
var looping = false

## old code, ignore this
func _on_play_pressed() -> void:
	#print(bar)
	#print(notes)
	return
	@warning_ignore("unreachable_code")
	if bar == null: return
	for i in range(bar.size()):
		#%MetroSound.play()
		metro()
		for j in range(bar[i].size()):
			audio_stuff(notes[i][j])
			highlight.emit(i,j)
			await get_tree().create_timer( (60/bpm) * bar[i][j]).timeout
			if stop == true: return
	while looping:
		for i in range(bar.size()):
			#%MetroSound.play()
			metro()
			for j in range(bar[i].size()):
				audio_stuff(notes[i][j])
				highlight.emit(i,j)
				await get_tree().create_timer( (60/bpm) * bar[i][j]).timeout
				if looping == false: return
	highlight.emit(-1,-1)

var metro_side := false
## plays four times for each measure
## will not do anything if metro_mute is true
func metro():
	if metro_mute: 
		%MetronomeMode.modulate = Color.WHITE
		return
	%MetronomeMode.modulate = Color.MEDIUM_SPRING_GREEN
	for i in range(4):
		%MetroSound.play()
		metro_side = not metro_side
		%MetronomeMode.icon = right if metro_side else left
		await get_tree().create_timer(60/bpm).timeout
		if (stop == true) or (metro_mute): break
	%MetronomeMode.modulate = Color.WHITE if metro_mute else Color.AQUA

## yeah don't ever use this lol, it creates weird exporting errors
## like if you clear and make something new and then export,
## then it exports the original savefile before you had cleared it...
func _on_clear_pressed() -> void:
	push_warning("this function is bugged, don't use it!")
	stop = true
	melody = []
	tim = []
	for i in BarContainer.get_children():
		i.queue_free() # is this inefficient? most likely yes
	bar.clear()
	notes.clear()

## loop
func _on_loop_toggled(toggled_on: bool) -> void:
	looping = toggled_on
	%Loop.modulate = Color.MEDIUM_SPRING_GREEN if looping else Color.WHITE
	#print(looping)

## settings
func _on_settings_tab_toggled(toggled_on: bool) -> void:
	## so that everything in the button will toggle on/off
	%SettingsTAB.self_modulate = Color.MEDIUM_SPRING_GREEN if toggled_on else Color.WHITE
	for i in %SettingsTAB.get_children():
		i.visible = toggled_on

## rename tab
func _on_settings_name_text_submitted(new_text: String) -> void:
	file.name = new_text
	%TabBar.set_tab_title(current_file,file.name)

## set file tempo
func _on_settings_metro_value_changed(value: float) -> void:
	file.tempo = value
	refresh_file_saving()

## select where to import from
func _on_import_pressed() -> void:
	%Loader.popup_centered()

## select where to save file
func _on_export_pressed() -> void:
	%Saver.popup_centered()

## actually saves to disk
func _on_saver_file_selected(path: String) -> void:
	## we copy so that we can have multiple separate files in the same program
	ResourceSaver.save(file.copy(),path)

## loads resource from selected path
func _on_loader_file_selected(path: String) -> void:
	stop = true
	#print(path)
	files[current_file] = load(path).duplicate(true)
	refresh_file_saving()
	%TabBar.set_tab_title(current_file,file.name)

## don't know what to do with this info yet
func _on_tab_bar_tab_rmb_clicked(_tab: int) -> void:
	%PopupPanel.popup_centered()

var play = load("res://play.png")
var pause = load("res://pause.png")

## if playing, then stop. if not playing, then play.
## for every smol bar, triggers metro,
## and for every element in smol bar, we play it (if it's an intNote;
## otherwise, we play for every intNote in the intNotes)
## same for looping
func _on_play_toggled(toggled_on: bool) -> void:
	if not toggled_on:
		stop = true
		%Play.icon = play
		return
	stop = false
	%Play.icon = pause
	if bar == null: return
	for i in range(bar.size()):
		#%MetroSound.play()
		metro()
		for j in range(bar[i].size()):
			var note = notes[i][j]
			if note is intNote:
				audio_stuff(notes[i][j])
			elif note is intNotes:
				for k in note.get_arr():
					audio_stuff(k)
			else:
				push_warning("unknown resource!")
			highlight.emit(i,j)
			await get_tree().create_timer( (60/bpm) * bar[i][j]).timeout
			if stop == true: 
				%Play.icon = play
				return
	while looping:
		for i in range(bar.size()):
			#%MetroSound.play()
			metro()
			for j in range(bar[i].size()):
				#audio_stuff(notes[i][j])
				var note = notes[i][j]
				if note is intNote:
					audio_stuff(notes[i][j])
				elif note is intNotes:
					for k in note.get_arr():
						audio_stuff(k)
				else:
					push_warning("unknown resource!")
				## somewhere a measure will accept this and make a bar note highlighted
				highlight.emit(i,j)
				## remember, bar is [[],[]] so bar[i] is [] so bar[i][j] is a time interval
				## and notes[i][j] is intNote/intNotes
				await get_tree().create_timer( (60/bpm) * bar[i][j]).timeout
				## add (looping == false) or () if you want it to immediately stop looping if in
				## loop mode. currently it will play until the very end until deciding to stop.
				if (stop == true): 
					## so that turning off by looping still resets the play button
					stop = true ## for metronome
					%Play.set_pressed_no_signal(false) 
					%Play.icon = play
					return
	stop = true ## for the metronome
	%Play.set_pressed_no_signal(false)
	%Play.icon = play
	## so that no notes are highlighted
	highlight.emit(-1,-1)

## toggle editorbar visibility and editor mode
func _on_editor_mode_toggled(toggled_on: bool) -> void:
	editor_mode = toggled_on
	%EditorMode.modulate = Color.MEDIUM_SPRING_GREEN if editor_mode else Color.WHITE
	%DebugBar.visible = editor_mode
	## so that the editor overlay is hidden
	if not editor_mode:
		highlight.emit(-1,-1)
	else:
		refresh_measures()

var metro_mute = false ## default is metro + thing, then thing


func _on_metronome_mode_toggled(toggled_on: bool) -> void:
	metro_mute = toggled_on
	%MetronomeMode.modulate = Color.WHITE if metro_mute else Color.AQUA
	%MetronomeMode.icon = left


func _on_control_mouse_entered() -> void:
	%FretMarkers.show()


func _on_control_mouse_exited() -> void:
	%FretMarkers.hide()

## this really just removes the last bar note added
func _on_undo_pressed() -> void:
	stop = true ## so we don't go idx out of bounds somehow
	tim.pop_back()
	melody.pop_back()
	refresh_measures()

## saves the current scale and key to file, then updates text
func _on_settings_key_pressed() -> void:
	file.key = %Key.selected
	file.scale = %Scale.selected
	refresh_file_saving()
	#%SettingsKey.text = %Key.get_item_text(file.key) + " " + %Scale.get_item_text(file.scale)
	


func _on_area_2d_mouse_entered() -> void:
	pass # Replace with function body.
