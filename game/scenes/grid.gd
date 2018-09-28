# Collection of functions to work with a Grid.
extends TileMap

var tile_size = get_cell_size()
var half_tile_size = tile_size / 2

onready var enemy = preload("res://enemy/enemy.tscn")
onready var hero = preload("res://hero/hero1.tscn")
onready var hero2 = preload("res://hero/hero2.tscn")

var target_tile
var world


func _ready():
	world = get_parent()


func add_hero(pos):
	if not has_node("Hero 1") or not has_node("Hero 2"):
		var new_hero
		if not has_node("Hero 1"):
			new_hero = hero.instance()
			new_hero.set_name("Hero")
		elif not has_node("Hero 2"):
			new_hero = hero2.instance()
			new_hero.set_name("Hero 2")
		new_hero.set_pos(pos)
		add_child(new_hero)


func update_child_pos(new_pos, direction, type):
	# Returns the new target move_to position
	var grid_pos = world_to_map(new_pos)
	var new_grid_pos = grid_pos + direction
	var target_pos = map_to_world(new_grid_pos) + half_tile_size
	return [ target_pos, new_grid_pos ]


func check_location(ray_start, direction):
	# Get tile type
	var space_state = get_world_2d().get_direct_space_state()

	var ray_end = ray_start + direction * tile_size * 2
	target_tile = space_state.intersect_ray( ray_start, ray_end, [self], 1 )
	if not target_tile.empty():
		return world.WALL
	target_tile = space_state.intersect_ray( ray_start, ray_end, [self], 2 )
	if not target_tile.empty():
		return world.HERO
	return world.NONE
