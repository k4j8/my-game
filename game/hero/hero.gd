# Define how heroes should move
extends KinematicBody2D

# Properties
var type
const SPEEDS = [ 250, 300, 325, 350 ] # current speed depends on level

# Movement
var grid
var world
var direction = Vector2()
var velocity = Vector2()
var target_pos = Vector2()
var target_direction = Vector2()
var target_tile
var new_grid_pos = Vector2()
var is_moving = false

# Ray-casting
var dir_x_open
var dir_y_open


func _ready():
	grid = get_parent()
	world = grid.get_parent()
	type = world.HERO
	set_fixed_process(true)


func is_tile_open(direction):
	# Check if target tile is not blocked by tilemap
	var space_state = get_world_2d().get_direct_space_state()
	target_tile = space_state.intersect_ray( get_pos(), get_pos() + direction * grid.tile_size * 2, [ self ], 1 )
	return true if target_tile.empty() else false


func _fixed_process(delta):
	direction = Vector2() # resets direction so hero doesn't keep going same direction

	# Get direction from player input
	if Input.is_action_pressed("ui_up"):
			direction.y = -1
	elif Input.is_action_pressed("ui_down"):
			direction.y = 1
	if Input.is_action_pressed("ui_left"):
			direction.x = -1
	elif Input.is_action_pressed("ui_right"):
			direction.x = 1

	# Check if tile is blocked by tilemap
	dir_x_open = is_tile_open( Vector2(direction[0], 0) )
	dir_y_open = is_tile_open( Vector2(0, direction[1]) )
	if is_tile_open( direction ) and dir_x_open and dir_y_open: # move along an angle
		pass
	elif dir_y_open: # if blocked in x-axis only, travel along y-axis
		direction.x = 0
	elif dir_x_open: # if blocked in y-axis only, travel along x-axis
		direction.y = 0
	else:
		direction = Vector2( 0, 0 )

	if not is_moving and direction != Vector2():

		# Initialize moving
		target_direction = direction.normalized()
		var target_arr = grid.update_child_pos(get_pos(), direction * 2, type)
		target_pos = target_arr[0]
		new_grid_pos = target_arr[1]
#		print( "Hero position: ", new_grid_pos )
		is_moving = true

	elif is_moving:

		var speed = SPEEDS[ get_node("/root/global").level % 4 ]

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
