# Provide instructions (which direction to go) to all enemies
extends Node2D

var grid
var ai

var enemies = [] # list of all enemies populated by the enemies themselves
var instructions = {} # dictionary with keys matching enemies and values equal to the number of instructions provided
var _timer = null


func _ready():
	grid = get_node("../Grid")
	ai = get_node("../AI")
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
	for enemy in enemies:

		# Search for new enemies in enemies variable and add to instructions if found
		if not enemy in instructions.keys():
			instructions[enemy] = {}
			instructions[enemy]['steps'] = 1

		# Create instructions as needed
		if enemy.steps == instructions[enemy]['steps']:
			instructions[enemy]['dir'] = ai.get_ai_direction(enemy, enemy.dir)
			instructions[enemy]['steps'] += 1
