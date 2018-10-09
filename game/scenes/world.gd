# Base world to be loaded by default
extends Node2D

enum ENTITY_TYPES {NONE, WALL, HERO, ENEMY}
var steps = 0 # number of steps taken by enemies


func _ready():
	set_process_input(true)
	set_pause_mode(PAUSE_MODE_PROCESS)


func _input(event):

	# Pause game
	if event.is_action_pressed("pause"):
		if get_tree().is_paused():
			get_tree().set_pause(false)
			get_node("PausePopup").hide()
		else:
			get_node("PausePopup").show()
			get_tree().set_pause(true)
