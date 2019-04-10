# Define how enemies should move
extends KinematicBody2D

# Properties
var type
const SPEEDS = [50, 80, 100, 120] # current speed depends on level
enum AI_MOVEMENT_TYPES {LEFT, RIGHT, RAND, FOLLOW, PATROL}
export var AI_MOVEMENT_TYPE = LEFT
export var AI_PATROL_PATH = 0

# Movement
var grid
var world
var instructor
var ai
var direction = Vector2()
var velocity = Vector2()
var target_pos = Vector2()
var target_direction = Vector2()
#var new_grid_pos = Vector2()
var is_moving = false

# AI
var dir = 1 # current direction as defined by an element in DIR_VECTOR
var steps = 0


func _ready():
	grid = get_parent()
	world = grid.get_parent()
	instructor = world.get_node("Instructor")
	ai = world.get_node("AI")
	instructor.enemies.append(self)
	type = world.ENEMY
	target_pos = get_pos()
	set_fixed_process(true)


func _fixed_process(delta):

	if not is_moving:
		if self in instructor.instructions and (instructor.instructions[self]['steps'] > 1):
			# Get instructions from instructor
			if AI_MOVEMENT_TYPE == 3:
				print(instructor.instructions[self])
			dir = instructor.instructions[self]['dir']
		else:
			# For first movement before instructor has loaded
			dir = ai.get_ai_direction(self, dir)
		direction = ai.DIR_VECTOR[dir]
		instructor.start_instructor()

		# Initialize moving
		target_direction = direction.normalized()
		var target_arr = grid.update_child_pos(get_pos(), direction * 2, type)
		target_pos = target_arr[0]
#		new_grid_pos = target_arr[1]
		steps += 1
		is_moving = true

	elif is_moving:

		var speed = SPEEDS[global.level % 4]

		# Prepare to stop moving if target will be reached
		var move_distance = velocity.length() * 2
		var distance_to_target = get_pos().distance_to(target_pos)
		if move_distance > distance_to_target:
			# Prepare to stop moving since target will be reached
			velocity = target_direction * distance_to_target
			is_moving = false
		else:
			# Get vector to start or continue moving
			velocity = speed * target_direction * delta

		# Move
		move(velocity)
		if dir == 0: self.set_rot(PI / 2)
		elif dir == 1: self.set_rot(0)
		elif dir == 2: self.set_rot(3 * PI / 2)
		elif dir == 3: self.set_rot(PI)
