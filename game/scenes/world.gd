extends Node2D

func _ready():
	set_process_input(true)
	set_pause_mode(PAUSE_MODE_PROCESS)

func _input(event):

	# Pause game
	if event.is_action_pressed("pause"):
		if get_tree().is_paused():
			get_tree().set_pause(false)
			get_node("pause_popup").hide()
		else:
			get_node("pause_popup").show()
			get_tree().set_pause(true)