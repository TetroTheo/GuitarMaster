extends Node

## here, we check if any input events match with note events.

func check_events():
	for note_event: Event in $Notes.get_children():
		for input_event: Event in $Inputs.get_children():
			## inputs only have one note!
			if input_event.notes[0] in note_event.notes:
				## the condition is satisfied
				var timing: float = note_event.age() - input_event.age()
				print(timing)
				note_event.queue_free()
				input_event.queue_free()
