# Store persistant variables
extends Node

var level = 0 # current difficulty level, increases upon completion
var AI_PATROL_PATHS = {0: [0, 1, 1, 1, 2, 0, 3, 3, 3, 2]} # paths for PATROL enemy types


func _ready():
	pass
