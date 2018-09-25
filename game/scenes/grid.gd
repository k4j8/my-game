# Collection of functions to work with a Grid.
extends TileMap

var tile_size = get_cell_size()
var half_tile_size = tile_size / 2

onready var enemy = preload("res://enemy/enemy.tscn")
onready var hero = preload("res://hero/hero1.tscn")
onready var hero2 = preload("res://hero/hero2.tscn")


func _ready():
	pass

func add_hero(pos):
#	# Place hero in world

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

#	# Place enemies in world
#	var positions = [ Vector2(4,4) ]
#	for pos in positions:
#		var new_enemy = enemy.instance()
#		new_enemy.set_pos(map_to_world(pos) + half_tile_size)
#		add_child(new_enemy)


func update_child_pos(new_pos, direction, type):
	# Returns the new target move_to position
	var grid_pos = world_to_map(new_pos)
	var new_grid_pos = grid_pos + direction
	var target_pos = map_to_world(new_grid_pos) + half_tile_size
	return [ target_pos, new_grid_pos ]


func check_location(current_pos, direction):
	# Get tile type
	var space_state = get_world_2d().get_direct_space_state()
	target_tile = space_state.intersect_ray( current_pos, current_pos + direction * grid.tile_size * 2, [self], 1 )
	if target_tile.empty():
		return -1
	else:
		print(target_tile.collider.get_parent())
		return target_tile.collider.get_parent().type()
