# Control how enemies interact with heroes
extends Area2D


func _ready():
	connect("body_enter", self, "reset_game")


func reset_game(body):
	# Reset game if hero enters area
	get_overlapping_bodies()[0].free() # kill hero hit by enemy
	if not ( has_node("../../Hero 1") or has_node("../../Hero 2") ): # reset game if all heroes dead, otherwise play sound effect
		get_tree().reload_current_scene()
	else:
		get_tree().get_root().get_node("Main").get_node("World").get_node("Sound").play("reset")