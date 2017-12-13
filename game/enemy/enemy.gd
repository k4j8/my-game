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

var ai_current_dir = 0
var ai_dir = [ Vector2(1,0), Vector2(0,1), Vector2(-1,0), Vector2(0,-1) ] # right, down, left, up

func _ready():
	grid = get_parent()
	type = grid.ENEMY
	set_fixed_process(true)


func is_tile_open(direction):
	# Check if target tile is not blocked by tilemap
	var space_state = get_world_2d().get_direct_space_state()
	target_tile = space_state.intersect_ray( get_pos(), get_pos() + direction*grid.tile_size * 2, [ self ], 1 )
	return true if target_tile.empty() else false


func _fixed_process(delta):

	# Get direction by trying previous direction then progressing through list (will result in following wall on left side)
	if not is_moving:
		while is_tile_open( ai_dir[ai_current_dir] ) == false:
			ai_current_dir += 1
			if ai_current_dir == 4: ai_current_dir = 0
		direction = ai_dir[ai_current_dir]
		ai_current_dir -= 1
		if ai_current_dir == -1: ai_current_dir = 3

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
