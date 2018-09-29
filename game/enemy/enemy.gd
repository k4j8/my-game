# Define how enemies should move
extends KinematicBody2D

# Properties
var type
const SPEEDS = [50, 80, 100, 120] # current speed depends on level
enum AI_MOVEMENT_TYPES {LEFT, RIGHT, RAND, FOLLOW}
export var AI_MOVEMENT_TYPE = LEFT

# Movement
var grid
var world
var heroes
var direction = Vector2()
var velocity = Vector2()
var target_pos = Vector2()
var target_direction = Vector2()
var new_grid_pos = Vector2()
var is_moving = false

# AI
const DIR_VECTOR = [Vector2(1, 0), Vector2(0, 1), Vector2(-1, 0), Vector2(0, -1)] # right, down, left, up
var dir = 1 # current direction as defined by an element in DIR_VECTOR

# AI follower
# Define global variables
var best_path = {'locations':[], 'distance':999, 'steps':999}
var current_path = {'locations':[], 'distance':999}
var locations_visited = {}


# Variables reset after each actual move

# dir = current direction of enemy (all enemy types)

# best_path['locations'] = locations in order
# best_path['distance'] = distance to hero at end of locations
# best_path['steps'] = number of moves in locations

# locations_visited[current_pos]['dir_attempts_remaining'] = directions untried at this position
# locations_visited[current_pos]['steps'] = number of steps to get o this position


# Variables reset after each theoretical move

# dir_initial = first direction to try
# dir_find_path = current direction being tested by find_path
# dir_find_path_attempts = directions to recursively search for within find_path
# dir_find_path_attempt = direction being recursively searched within find_path (cycles through dir_find_path_attempts)

# current_path['locations'] = locations in order
# current_path['distance'] = distance to hero at end of locations
# current_path_steps = number of moves in locations


func _ready():
	grid = get_parent()
	world = grid.get_parent()
	type = world.ENEMY
	set_fixed_process(true)


func find_path(current_pos, dir_find_path_dir, current_path_steps):

	# If path to hero exists, abort if shorter path already found
	if best_path['distance'] == 0 and best_path['steps'] <= current_path_steps:
		return

	# Get current tile type
	var current_tile_type = grid.check_location(current_pos, DIR_VECTOR[fposmod(dir_find_path_dir + 2, 4)])

	# Check if current_tile_type is a wall
	if current_tile_type == world.WALL:
		return

	# Check if previously visited
	if current_pos in locations_visited.keys(): # if new, initialize
		pass
	else:
		locations_visited[current_pos] = {}
		locations_visited[current_pos]['dir_attempts_remaining'] = range(0, 4)
		locations_visited[current_pos]['steps'] = current_path_steps
	if locations_visited[current_pos]['steps'] > current_path_steps: # found shorter path, reset locations_visited[current_pos]
		locations_visited[current_pos]['dir_attempts_remaining'] = range(0, 4)
		locations_visited[current_pos]['steps'] = current_path_steps
	if locations_visited[current_pos]['dir_attempts_remaining'].size() == 0:
		return

	# Calculate closest hero
	heroes = [grid.find_node("Hero 1"), grid.find_node("Hero 2")]
	current_path['distance'] = 999
	for hero in heroes:
		if hero != null:
			current_path['distance'] = min(current_path['distance'], (current_pos - hero.get_pos()).length())

	# Update best_path if applicable
	if best_path['distance'] > current_path['distance'] or (best_path['distance'] == current_path['distance'] and best_path['steps'] > current_path_steps): # if closer to hero than previous best or tied distance in a shorter path
		best_path['locations'] = current_path['locations']
		best_path['distance'] = current_path['distance']
		best_path['steps'] = current_path_steps

	# Check if current_tile_type is a hero
	if current_tile_type == world.HERO:
		return

	# Try all directions
	var dir_find_path_attempts = locations_visited[current_pos]['dir_attempts_remaining']
	for dir_find_path_attempt in dir_find_path_attempts:
		if dir_find_path_attempt != fposmod(dir_find_path_dir + 2, 4): # skip if opposite direction of travel
			current_path['locations'].append(dir_find_path_attempt)
			locations_visited[current_pos]['dir_attempts_remaining'].erase(dir_find_path_attempt)
			find_path(current_pos + DIR_VECTOR[dir_find_path_attempt] * grid.tile_size * 2, dir_find_path_attempt, current_path_steps + 1)

			# Remove last entity from current_path['locations']
			current_path['directions_new'] = []
			for j in range(0, current_path['locations'].size() - 1):
				current_path['directions_new'].append(current_path['locations'][j])
			current_path['locations'] = current_path['directions_new']
	return


func get_ai_direction(type):
	# Determine how enemy should move


	if type == LEFT or type == RIGHT:
		# Left- or right-seeking enemies
		var i
		if type == LEFT:
			i = 1 # check previous direction in DIR_VECTOR then proceed forwards
		else:
			i = -1 # check next direction in DIR_VECTOR then proceed backwards

		dir -= i # check previous/next direction first
		dir = int(fposmod(dir, 4))
		while grid.check_location(get_pos(), DIR_VECTOR[dir]) == world.WALL:
			dir += i # proceed forwards/backwards through DIR_VECTOR
			dir = int(fposmod(dir, 4))
		return DIR_VECTOR[dir]


	if type == RAND:
		# Picks random valid direction except backwards after each move

		# Populate available_dir with valid (non-blocked) directions
		var available_dir = []
		for turn in range(-1,2): # try turn left, go straight, and turn right
			if grid.check_location(get_pos(), DIR_VECTOR[int(fposmod(dir + turn, 4))]) != world.WALL:
				available_dir.append(int(fposmod((dir + turn), 4)))

		if available_dir.size() == 0:
			# If no directions found, turn around
			dir -= 2 # turn around
		else:
			# If directions found, select one at random
			dir = available_dir[randi() % available_dir.size()]

		dir = int(fposmod(dir, 4))
		return DIR_VECTOR[dir]


	if type == FOLLOW:
		best_path = {'locations':[], 'distance':999, 'steps':999}
		current_path = {'locations':[], 'distance':999}
		locations_visited = {}

		# Begin search
		print(get_pos())
		for turn in range(-1,2): # try turn left, go straight, and turn right
			var dir_initial = fposmod(dir + turn, 4)
			if grid.check_location( get_pos(), DIR_VECTOR[dir_initial] ) != world.WALL:
				current_path['locations'] = [dir_initial]
				find_path(get_pos() + DIR_VECTOR[dir_initial] * grid.tile_size * 2, dir_initial, 0)
		print('Final best path')
		print(best_path['locations'])
		if best_path['locations'].size() == 0: # if dead end
			dir += 2 # turn around
		else:
			dir = best_path['locations'][0]
		return DIR_VECTOR[dir]


func _fixed_process(delta):

	if not is_moving:
		direction = get_ai_direction(AI_MOVEMENT_TYPE)

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
		if dir == 0: self.set_rot(PI / 2)
		elif dir == 1: self.set_rot(0)
		elif dir == 2: self.set_rot(3 * PI / 2)
		elif dir == 3: self.set_rot(PI)
