# Provide instructions (which direction to go) to all enemies
extends Node2D

var grid
var ai

var enemies = [] # list of all enemies populated by the enemies themselves
var instructions = {} # dictionary with keys matching enemies and values equal to the number of instructions provided
var _timer = null
var thread = null


func _ready():
	grid = get_node("../Grid")
	ai = get_node("../AI")
	give_instructions('blank')


func start_instructor():
	thread = Thread.new()
	thread.start(self, "give_instructions", 'blank', 0)
	thread.wait_to_finish()

func give_instructions(blank):
	#print('running give_instructions')
	#print(enemies.size())
	for enemy in enemies:

		# Search for new enemies in enemies variable and add to instructions if found
		if not enemy in instructions.keys():
			instructions[enemy] = {}
			instructions[enemy]['steps'] = 1

		# Create instructions as needed
		if enemy.steps == instructions[enemy]['steps']:
			instructions[enemy]['dir'] = ai.get_ai_direction(enemy, enemy.dir)
			instructions[enemy]['steps'] += 1
