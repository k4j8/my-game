extends Node2D

var grid
var type

func _ready():
	grid = get_parent()
	type = grid.ENEMY