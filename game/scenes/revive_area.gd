# Win conditions and feedback
extends Area2D


func _ready():
	connect("body_enter", self, "revive") # need to update so this only plays when all heroes enter


func revive(body):

	if not has_node("../Grid/Hero 1") or not has_node("../Grid/Hero 2"):

		# Play revive sound effect
		get_tree().get_root().get_node("Main").get_node("World").get_node("Sound").play("revive") # update to revive

		var grid = get_node("../Grid")
		grid.add_hero(Vector2(450,210))
