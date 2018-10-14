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
var heroes
var direction = Vector2()
var velocity = Vector2()
var target_pos = Vector2()
var target_direction = Vector2()
#var new_grid_pos = Vector2()
var is_moving = false

# AI
const DIR_VECTOR = [Vector2(1, 0), Vector2(0, 1), Vector2(-1, 0), Vector2(0, -1)] # right, down, left, up
var dir = 1 # current direction as defined by an element in DIR_VECTOR
var steps = 0

# AI follower
# Define global variables
var best_path = {'directions':[], 'distance':999999, 'steps':999999}
var current_path = {'directions':[], 'distance':999999}
var locations_visited = {}


# Variables reset after each actual move

# dir = current direction of enemy (all enemy types)

# best_path['directions'] = directions in the form of integers in order
# best_path['distance'] = distance to hero at end of locations
# best_path['steps'] = number of moves in locations

# locations_visited[current_pos]['dir_attempts_remaining'] = directions untried at this position
# locations_visited[current_pos]['steps'] = number of steps to get o this position


# Variables reset after each theoretical move

# dir_initial = first direction to try
# dir_find_path_current = current direction being tested by find_path
# dir_find_path_attempts = directions to recursively search for within find_path
# dir_find_path_attempt = direction being recursively searched within find_path (cycles through dir_find_path_attempts)

# current_path['directions'] = directions in the form of integers in order
# current_path['directions_new'] = used to temporarily store "current_path['directions']" so the last item can be removed
# current_path['distance'] = distance to hero at end of locations
# current_path_steps = number of moves in locations


func _ready():
	grid = get_parent()
	world = grid.get_parent()
	instructor = world.get_node("Instructor")
	instructor.enemies.append(self)
	type = world.ENEMY
	set_fixed_process(true)


func find_path(current_pos, dir_find_path_current, current_path_steps):

	# If path to hero has already been found, abort if that path is shorter than current
	if best_path['distance'] == 0 and best_path['steps'] <= current_path_steps:
		return

	# Get current tile type
	var current_tile_type = grid.check_location(current_pos, DIR_VECTOR[fposmod(dir_find_path_current + 2, 4)])

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
#			print('Current:', current_pos)
#			print('Hero:', hero.get_pos())
#			print('Distance:', (current_pos - hero.get_pos()).length())

	# Update best_path if applicable
	if best_path['distance'] > current_path['distance'] or (best_path['distance'] == current_path['distance'] and best_path['steps'] > current_path_steps): # if closer to hero than previous best or tied distance in a shorter path
		best_path['directions'] = current_path['directions']
		best_path['distance'] = current_path['distance']
		best_path['steps'] = current_path_steps

	# Check if current_tile_type is a hero
	if current_tile_type == world.HERO:
		return


	# Try all directions

	var dir_find_path_attempts = []
	for i in locations_visited[current_pos]['dir_attempts_remaining']:
		dir_find_path_attempts.append(i)

	for dir_find_path_attempt in dir_find_path_attempts:
		if dir_find_path_attempt == fposmod(dir_find_path_current + 2, 4): # skip if opposite direction of travel
			continue
		current_path['directions'].append(dir_find_path_attempt)
		locations_visited[current_pos]['dir_attempts_remaining'].erase(dir_find_path_attempt)
		find_path(current_pos + DIR_VECTOR[dir_find_path_attempt] * grid.tile_size * 2, dir_find_path_attempt, current_path_steps + 1)

		# Remove last entity from current_path['directions']
		current_path['directions_new'] = []
		for j in range(0, current_path['directions'].size() - 1):
			current_path['directions_new'].append(current_path['directions'][j])
		current_path['directions'] = current_path['directions_new']
	return


func get_ai_direction():
	# Determine how enemy should move


	if AI_MOVEMENT_TYPE == LEFT or AI_MOVEMENT_TYPE == RIGHT:
		# Left- or right-seeking enemies
		var i
		if AI_MOVEMENT_TYPE == LEFT:
			i = 1 # check previous direction in DIR_VECTOR then proceed forwards
		else:
			i = -1 # check next direction in DIR_VECTOR then proceed backwards

		dir -= i # check previous/next direction first
		dir = int(fposmod(dir, 4))
		while grid.check_location(get_pos(), DIR_VECTOR[dir]) == world.WALL:
			dir += i # proceed forwards/backwards through DIR_VECTOR
			dir = int(fposmod(dir, 4))
		return DIR_VECTOR[dir]


	if AI_MOVEMENT_TYPE == RAND:
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


	if AI_MOVEMENT_TYPE == FOLLOW:
		# Takes shortest path to closest hero

		best_path = {'directions':[], 'distance':99999, 'steps':99999}
		current_path = {'directions':[], 'distance':99999}
		locations_visited = {}

		# Begin search
		print(get_pos())
		for turn in range(-1,2): # try turn left, go straight, and turn right
			var dir_initial = fposmod(dir + turn, 4)
			if grid.check_location(get_pos(), DIR_VECTOR[dir_initial]) != world.WALL:
				current_path['directions'] = [dir_initial]
				find_path(get_pos() + DIR_VECTOR[dir_initial] * grid.tile_size * 2, dir_initial, 0)
		print('Best path: ', best_path['directions'])
		print('Best distance: ', best_path['distance'])
		if best_path['directions'].size() == 0: # if dead end
			dir = fposmod(dir + 2, 4) # turn around
		else:
			dir = best_path['directions'][0]
		return DIR_VECTOR[dir]


	if AI_MOVEMENT_TYPE == PATROL:
		# Follows path defined by AI_PATROL_PATHS on global and AI_PATROL_PATH

		var path = global.AI_PATROL_PATHS[AI_PATROL_PATH]
		dir = path[fposmod(steps, path.size())]
		return DIR_VECTOR[dir]


func _fixed_process(delta):

	if not is_moving:
		if self in instructor.instructions:
			dir = instructor.instructions[self]['dir']
		else: # for first movement before instructor has loaded
			dir = 1
		direction = DIR_VECTOR[dir]

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
