# Provide instructions (which direction to go) to all enemies
extends Node2D

var enemies = [] # list of all enemies populated by the enemies themselves
var instructions = {} # dictionary with keys matching enemies and values equal to the number of instructions provided
var _timer = null


func _ready():
	var grid = get_node("../Grid")
	give_instructions()

	_timer = Timer.new()
	add_child(_timer)

	_timer.connect("timeout", self, "_on_Timer_timeout")
	_timer.set_wait_time(0.3)
	_timer.set_one_shot(false) # make sure it loops
	_timer.start()


func _on_Timer_timeout():
	give_instructions()


func give_instructions():
	# Search for new enemies in enemies variable and add to instructions if found
	for enemy in enemies:
		if not enemy in instructions.keys():
			instructions[enemy] = 0

		if enemy.steps > 0:
			print('Enemy ',enemy, ' has taken ', enemy.steps, ' steps')
