extends StaticBody2D

var type
var world = grid.get_parent()


func _ready():
	type = world.WALL
