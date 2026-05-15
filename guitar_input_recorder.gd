extends AudioStreamPlayer
@onready var capture : AudioEffect = AudioServer.get_bus_effect(1,0)
@onready var analyze = AudioServer.get_bus_effect_instance(1,1)
@onready var sample_rate = AudioServer.get_mix_rate()
@onready var MIN_RATE := 48#int(sample_rate / 80.0) #48
@onready var MAX_RATE := 600#int(sample_rate / 1000.0) #600

var fixed_data := PackedFloat32Array()
## keep this at above 2048, or it will become too inaccurate!
const MAX_DATA = 2048
## anything below 0.001 is low confidence,
## at least with this microphone.
const MIN_VOL := 0.001
var new_pitch_cooldown = 0
var thread := Thread.new()
var current_pitch := 0.0

signal note_detected

func _ready():
	## mutes the audio without actually preventing audio capture!
	AudioServer.set_bus_mute(1,true)

func main():
	var frames = capture.get_frames_available()
	if frames < MAX_DATA: return
	## convert raw input to mono channel
	var data = capture.get_buffer(frames)
	for frame in data:
		var mono = (frame.x + frame.y) * 0.5
		fixed_data.append(mono)
	## trim to the most recent 2048 frames
	if fixed_data.size() > MAX_DATA:
		fixed_data = fixed_data.slice(fixed_data.size() - MAX_DATA)
	if not volume_check(fixed_data):
		new_pitch_cooldown = 0
		return
	if thread.is_alive(): return
	if new_pitch_cooldown > 0: 
		new_pitch_cooldown -= 1
		return
	## pass our data to a detector thread
	thread.start(autocorrelate.bind(fixed_data))
	var pitch = thread.wait_to_finish()
	## just send the most likely note to the communicator
	note_detected.emit(pitch[0])
	## the rest is for debugging
	return
	@warning_ignore("unreachable_code")
	var notes := ""
	for frq: float in pitch:
		var note := Note.new()
		note.pitch = Note.pitch_from_frequency(frq)
		notes += str(note) + str(roundi(frq)) + " "
	print(notes)

## Don't close the game without removing the thread!
func _exit_tree():
	if thread.is_started():
		thread.wait_to_finish()


func volume_check(samples) -> bool:
	var rin = samples.size()
	var sum = 0
	for s in samples:
		sum += s * s
	var rms = sqrt(sum / rin)
	#print(rms)
	return not (rms < MIN_VOL)

func autocorrelate(samples):
	var rin = samples.size()
	## check to make sure array is big enough
	if rin < 2: 
		print("Error!")
		return 0.0
	## average of sample magnitude
	var center := 0.0
	for s in samples:
		center += s
	center /= rin
	## remove the average from sample
	var moved_samples := PackedFloat32Array()
	moved_samples.resize(rin)
	for i in range(rin):
		moved_samples[i] = samples[i] - center
	## finding the best lag
	var best_lag := 0
	var best_core := -1.0
	var best_lag2 := 0
	var best_core2 := -1.0
	var best_lag3 := 0
	var best_core3 := -1.0
	for lag in range(MIN_RATE,MAX_RATE):
		var core := 0.0
		for i in range(rin - lag):
			core += moved_samples[i] * moved_samples[i + lag]
		if core > best_core:
			best_core3 = best_core2
			best_core2 = best_core
			best_core = core
			best_lag3 = best_lag2
			best_lag2 = best_lag
			best_lag = lag
		elif core > best_core2:
			best_core3 = best_core2
			best_core2 = core
			best_lag3 = best_lag2
			best_lag2 = lag
		elif core > best_core3:
			best_core3 = core
			best_lag3 = lag
	var lag_arr = [best_lag,best_lag2,best_lag3]
	var pitch_arr = []
	pitch_arr.resize(3)
	for i in range(len(lag_arr)):
		pitch_arr[i] = sample_rate/lag_arr[i]
	return pitch_arr


func _on_input_event_timeout() -> void:
	main()
