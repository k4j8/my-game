# Control how enemies interact with heroes
extends Area2D


func _ready():
	connect("body_enter", self, "reset_game")


func reset_game(body):
	# Reset game if hero enters area
#	get_tree().get_root().get_node("World").get_node("Sound").play("reset") # it tries to play but reloading the scene stops it
	get_tree().reload_current_scene()
