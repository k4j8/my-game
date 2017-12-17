# Define how enemies should move
extends KinematicBody2D

# Properties
var type
const SPEEDS = [ 50, 80, 100, 120 ] # current speed depends on level
enum AI_MOVEMENT_TYPES {LEFT, RIGHT, RAND, FOLLOW}
export var AI_MOVEMENT_TYPE = LEFT

# Movement
var grid
var direction = Vector2()
var velocity = Vector2()
var target_pos = Vector2()
var target_direction = Vector2()
var target_tile
var new_grid_pos = Vector2()
var is_moving = false

# AI
const AI_DIR_ORDER = [ Vector2(1, 0), Vector2(0, 1), Vector2(-1, 0), Vector2(0, -1) ] # right, down, left, up
var ai_dir_num = 1 # current direction as defined by an element in AI_DIR_ORDER
var rotation = 0
var i
var available_dir = []


func _ready():
	grid = get_parent()
	type = grid.ENEMY
	set_fixed_process(true)

	# Make black dot on enemy point to direction of attempted direction instead of forwards
#	if AI_MOVEMENT_TYPE == LEFT: rotation = PI / 2
#	if AI_MOVEMENT_TYPE == RIGHT: rotation = -PI / 2


func is_tile_open(direction):
	# Check if target tile is not blocked by tilemap
	var space_state = get_world_2d().get_direct_space_state()
	target_tile = space_state.intersect_ray( get_pos(), get_pos() + direction*grid.tile_size * 2, [ self ], 1 )
	return true if target_tile.empty() else false


func get_ai_direction(type):
	# Determine how enemy should move

	if type == LEFT or type == RIGHT:
		# Left- or right-seeking enemies
		if type == LEFT:
			i = 1 # check previous direction in AI_DIR_ORDER then proceed forwards
		else:
			i = -1 # check next direction in AI_DIR_ORDER then proceed backwards

		ai_dir_num -= i # check previous/next direction first
		rotation += (PI / 2 * i)
		ai_dir_num = int( fposmod(ai_dir_num, 4) )
		while is_tile_open( AI_DIR_ORDER[ai_dir_num] ) == false:
			ai_dir_num += i # proceed forwards/backwards through AI_DIR_ORDER
			rotation -= (PI / 2 * i)
			ai_dir_num = int( fposmod(ai_dir_num, 4) )
		self.set_rot(rotation)
		return AI_DIR_ORDER[ai_dir_num]

	if type == RAND:
		# Picks random valid direction except backwards after each move

		# Populate available_dir with valid (non-blocked) directions
		available_dir = []
		for turn in range(-1,2): # try turn left, go straight, and turn right
			if is_tile_open( AI_DIR_ORDER[ int( fposmod(ai_dir_num + turn, 4) ) ] ):
				available_dir.append( int( fposmod((ai_dir_num + turn), 4) ) )

		if available_dir.size() == 0:
			# If no directions found, turn around
			ai_dir_num -= 2 # turn around
		else:
			# If directions found, select one at random
			ai_dir_num = available_dir[randi() % available_dir.size()]

		ai_dir_num = int( fposmod(ai_dir_num, 4) )
		if ai_dir_num == 0: self.set_rot(PI / 2)
		elif ai_dir_num == 1: self.set_rot(0)
		elif ai_dir_num == 2: self.set_rot(3 * PI / 2)
		elif ai_dir_num == 3: self.set_rot(PI)
		return AI_DIR_ORDER[ ai_dir_num ]


func _fixed_process(delta):

	if not is_moving:
		direction = get_ai_direction( AI_MOVEMENT_TYPE )

		# Initialize moving
		target_direction = direction.normalized()
		var target_arr = grid.update_child_pos(get_pos(), direction * 2, type)
		target_pos = target_arr[0]
		new_grid_pos = target_arr[1]
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
