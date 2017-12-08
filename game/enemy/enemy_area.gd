extends Area2D

func _ready():
	connect("body_enter", self, "reset_game")

func reset_game ( body ):
	# Reset game if hero enters area
    get_tree().reload_current_scene()