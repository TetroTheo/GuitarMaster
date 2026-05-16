class_name Event
extends Timer
## A timer that deletes itself and stores note data

## this updates across all events
static var max_wait_time: float = 1.0

## stores the notes
var notes: Array[Note]

func _init() -> void:
	wait_time = max_wait_time
	autostart = true
	timeout.connect(on_timeout)
	name = "Event |"


## this is a function so that we can set the event name
func add_note(note: Note):
	notes.append(note)
	name += " " + note.note_name()


func on_timeout():
	queue_free()


## returns how long (in seconds) the event has been alive.
func age() -> float:
	return max_wait_time - time_left
