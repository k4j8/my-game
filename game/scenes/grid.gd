# Collection of functions to work with a Grid. Stores all its children in the grid array
extends TileMap

enum ENTITY_TYPES {HERO, ENEMY}

var tile_size = get_cell_size()
var half_tile_size = tile_size / 2
var grid_size = Vector2(16, 16)

var grid = []
onready var enemy = preload("res://enemy/enemy.tscn")
onready var hero = preload("res://hero/hero.tscn")

func _ready():

	# Generate grid
	for x in range(grid_size.x):
		grid.append([])
		for y in range(grid_size.y):
			grid[x].append(null)

	# Place hero in world
	var new_hero = hero.instance()
	new_hero.set_pos(map_to_world(Vector2(2,2)) + half_tile_size)
	add_child(new_hero)

	# Generate locations to place enemies in world
	var positions = []
	for x in range(5):
		var placed = false
		while not placed:
			var grid_pos = Vector2(randi() % int(grid_size.x), randi() % int(grid_size.y))
			if not grid[grid_pos.x][grid_pos.y]:
				if not grid_pos in positions:
					positions.append(grid_pos)
					placed = true
#	var positions = [Vector2(2,8)]

	# Place enemies in world and mark in grid
	for pos in positions:
		var new_enemy = enemy.instance()
		new_enemy.set_pos(map_to_world(pos) + half_tile_size)
		grid[pos.x][pos.y] = new_enemy.get_name()
		add_child(new_enemy)


func get_cell_content(pos=Vector2()):
	return grid[pos.x][pos.y]


func is_cell_vacant(pos=Vector2(), direction=Vector2()):
	# Returns true if cell is vacant and not outside of grid
	var grid_pos = world_to_map(pos) + direction

	if grid_pos.x < grid_size.x and grid_pos.x >= 0:
		if grid_pos.y < grid_size.y and grid_pos.y >= 0:
			return true if grid[grid_pos.x][grid_pos.y] == null else false
	return false


func update_child_pos(new_pos, direction, type):
	# Remove node from current cell, add it to the new cell, returns the new target move_to position
	var grid_pos = world_to_map(new_pos)
#	print(grid_pos)
	grid[grid_pos.x][grid_pos.y] = null
	
	var new_grid_pos = grid_pos + direction
	grid[new_grid_pos.x][new_grid_pos.y] = type
	
	var target_pos = map_to_world(new_grid_pos) + half_tile_size
	return target_pos