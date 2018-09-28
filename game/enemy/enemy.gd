# Define how enemies should move
extends KinematicBody2D

# Properties
var type
const SPEEDS = [ 50, 80, 100, 120 ] # current speed depends on level
enum AI_MOVEMENT_TYPES {LEFT, RIGHT, RAND, FOLLOW}
export var AI_MOVEMENT_TYPE = LEFT

# Movement
var grid
var world
var hero1
var hero2
var direction = Vector2()
var velocity = Vector2()
var target_pos = Vector2()
var target_direction = Vector2()
var new_grid_pos = Vector2()
var is_moving = false

# AI
const AI_DIR_ORDER = [ Vector2(1, 0), Vector2(0, 1), Vector2(-1, 0), Vector2(0, -1) ] # right, down, left, up
var ai_dir_num = 1 # current direction as defined by an element in AI_DIR_ORDER
var rotation = 0
var available_dir = []

# AI follower
# Define global variables
var best_path = {'directions':[], 'distance':999, 'length':999}
var current_path = {'directions':[], 'distance':999, 'locations':[]}


func _ready():
	grid = get_parent()
	world = grid.get_parent()
	hero1 = grid.get_node("Hero 1")
	hero2 = grid.get_node("Hero 2")
	type = world.ENEMY
	set_fixed_process(true)

	# Make black dot on enemy point to direction of attempted direction instead of forwards
#	if AI_MOVEMENT_TYPE == LEFT: rotation = PI / 2
#	if AI_MOVEMENT_TYPE == RIGHT: rotation = -PI / 2


func find_path(current_pos, ai_dir_num_follow, current_path_length):

	if current_path_length != 0:
#		print('Current position')
#		print( current_pos )
		# Compare against best_path to abort if best_path is better
		if best_path['distance'] == 0 and best_path['length'] <= current_path_length:
			return

		# Check if previously visited
		if current_pos in current_path['locations']:
			return

		# Get current tile type
		var current_type = grid.check_location(current_pos, AI_DIR_ORDER[fposmod(ai_dir_num_follow + 2, 4)])

		# Check if not open
		if current_type == world.WALL:
			return
		current_path['distance'] = min( ( current_pos - hero1.get_pos() ).length(), ( current_pos - hero2.get_pos() ).length() ) # distance to hero as the crow flies
		if best_path['distance'] > current_path['distance'] or ( best_path['distance'] == current_path['distance'] and best_path['length'] > current_path_length ): # if closer to hero than previous best or tied distance in a shorter path
			best_path['directions'] = current_path['directions']
			best_path['distance'] = current_path['distance']
			best_path['length'] = current_path_length
		if current_type == world.HERO:
			return

	# Try all directions
	var ai_dir_num_follow_try = 0
	for ai_dir_num_follow_try in range(0, 4):
		if ai_dir_num_follow_try != fposmod(ai_dir_num_follow + 2, 4): # skip if opposite direction of travel
			current_path['directions'].append(ai_dir_num_follow_try)
			current_path['locations'].append(current_pos)
			find_path(current_pos + AI_DIR_ORDER[ai_dir_num_follow_try] * grid.tile_size * 2, ai_dir_num_follow_try, current_path_length + 1)

			# Remove last entity from current_path['directions']
			current_path['directions_new'] = []
			for j in range(0, current_path['directions'].size() ):
				current_path['directions_new'].append( current_path['directions'][j] )
			current_path['directions'] = current_path['directions_new']
	return


func get_ai_direction(type):
	# Determine how enemy should move


	if type == LEFT or type == RIGHT:
		# Left- or right-seeking enemies
		var i
		if type == LEFT:
			i = 1 # check previous direction in AI_DIR_ORDER then proceed forwards
		else:
			i = -1 # check next direction in AI_DIR_ORDER then proceed backwards

		ai_dir_num -= i # check previous/next direction first
		rotation += (PI / 2 * i)
		ai_dir_num = int( fposmod(ai_dir_num, 4) )
		while grid.check_location( get_pos(), AI_DIR_ORDER[ai_dir_num] ) == 1:
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
			if grid.check_location( get_pos(), AI_DIR_ORDER[ int( fposmod(ai_dir_num + turn, 4) ) ] ) != 1:
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


	if type == FOLLOW:
		# Begin search
		for i in range(0, 3):
			current_path['directions'] = [ai_dir_num + i]
			find_path( get_pos(), fposmod(ai_dir_num + i, 4), 0 )
#		print('Final best path')
#		print(best_path['directions'])
#		print('Locations visited')
#		print(current_path['locations'])
		if best_path['directions'].size() == 0: # if dead end
			return AI_DIR_ORDER[ ai_dir_num + 2 ] # turn around
		return AI_DIR_ORDER[ best_path['directions'][0] ]


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
