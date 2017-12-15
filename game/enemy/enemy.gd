extends KinematicBody2D

var direction = Vector2()
const SPEED = 50
var velocity = Vector2()

var target_pos = Vector2()
var target_direction = Vector2()
var new_grid_pos = Vector2()
var is_moving = false

var grid
var type
var target_tile

var ai_current_dir = 1
var ai_dir = [ Vector2(1,0), Vector2(0,1), Vector2(-1,0), Vector2(0,-1) ] # right, down, left, up
enum AI_MOVEMENT_TYPE {LEFT, RIGHT, RAND, FOLLOW}
var i
var available_dir = []

func _ready():
	grid = get_parent()
	type = grid.ENEMY
	set_fixed_process(true)


func is_tile_open(direction):
	# Check if target tile is not blocked by tilemap
	var space_state = get_world_2d().get_direct_space_state()
	target_tile = space_state.intersect_ray( get_pos(), get_pos() + direction*grid.tile_size * 2, [ self ], 1 )
	return true if target_tile.empty() else false


func get_ai_direction(type):
	# Determine how enemy should move

	if type == LEFT or type == RIGHT:
		if type == LEFT:
			i = 1
		else:
			i = -1
		ai_current_dir -= i
		ai_current_dir = ai_current_dir % 4
		while is_tile_open( ai_dir[ai_current_dir] ) == false:
			ai_current_dir += i
			ai_current_dir = ai_current_dir % 4
		return ai_dir[ai_current_dir]
	
	if type == RAND:
		available_dir = []
		for turn in range(-1,2): # try turn left, go straight, and turn right
			if is_tile_open( ai_dir[(ai_current_dir + turn) % 4] ):
				available_dir.append((ai_current_dir + turn) % 4)
		if available_dir.size() == 0:
			ai_current_dir -= 2 # turn around
		else:
			ai_current_dir = available_dir[randi() % available_dir.size()] # select one of available directions at random
		ai_current_dir = ai_current_dir % 4
		return ai_dir[ ai_current_dir ]


func _fixed_process(delta):

	if not is_moving:
		direction = get_ai_direction( LEFT )

		# Initialize moving
		target_direction = direction.normalized()
		var target_arr = grid.update_child_pos(get_pos(), direction * 2, type)
		target_pos = target_arr[0]
		new_grid_pos = target_arr[1]
		is_moving = true

	elif is_moving:

		# Prepare to stop moving if target will be reached
		var move_distance = velocity.length() * 2
		var distance_to_target = get_pos().distance_to(target_pos)
		if move_distance > distance_to_target:
			# Prepare to stop moving since target will be reached
			velocity = target_direction * distance_to_target
			is_moving = false
		else:
			# Get vector to start or continue moving
			velocity = SPEED * target_direction * delta

		# Move
		move(velocity)
