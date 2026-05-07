extends Node2D

var bpm = 120
var seconds_per_beat = 60.0 /bpm
var song_pos_in_beats
var song_position
var last_checked_beat = 0
var measure = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AudioStreamPlayer.play()
	
# thank you so much to this reddit post for helping me out!!
# https://www.reddit.com/r/godot/comments/15jqlqh/how_do_i_make_a_metronome_that_activates_triggers/
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	song_position = $AudioStreamPlayer.get_playback_position() + AudioServer.get_time_since_last_mix()
	song_position -= AudioServer.get_output_latency()
	song_pos_in_beats = floori(song_position / seconds_per_beat)
	check_beat()

func check_beat():
	if not last_checked_beat < song_pos_in_beats:
		return
	$MetroSound.play()
	print("beat ", song_pos_in_beats, " measure ", measure)
	measure += 1
	if measure % 4 == 0:
		measure = 0
	last_checked_beat = song_pos_in_beats
