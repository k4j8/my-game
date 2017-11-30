extends KinematicBody2D

var direction = Vector2()

const SPEED = 100

var velocity = Vector2()

var target_pos = Vector2()
var target_direction = Vector2()
var is_moving = false

var type
var grid


func _ready():
	grid = get_parent()
	type = grid.HERO
	set_fixed_process(true)


func _fixed_process(delta):
	direction = Vector2() # resets direction

	if Input.is_action_pressed("ui_up"):
		direction.y = -1
	elif Input.is_action_pressed("ui_down"):
		direction.y = 1

	if Input.is_action_pressed("ui_left"):
		direction.x = -1
	elif Input.is_action_pressed("ui_right"):
		direction.x = 1

	if not is_moving and direction != Vector2():

		# Initialize moving
		target_direction = direction.normalized()
		if grid.is_cell_vacant(get_pos(), direction):
			target_pos = grid.update_child_pos(get_pos(), direction, type)
			is_moving = true

	elif is_moving:

		# Prepare to stop moving if target will be reached
		var move_distance = velocity.length()
		var distance_to_target = get_pos().distance_to(target_pos)
		if move_distance > distance_to_target:
			velocity = target_direction * distance_to_target
			is_moving = false
		else:
			# Get vector to start or continue moving
			velocity = SPEED * target_direction * delta

		# Move
		move(velocity)
