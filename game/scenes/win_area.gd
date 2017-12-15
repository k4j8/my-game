# Win conditions and feedback
extends Area2D


func _ready():
	connect("body_enter", self, "win") # need to update so this only plays when all heroes enter


func win(body):

	# Play win sound effect
	get_tree().get_root().get_node("World").get_node("StreamPlayer").stop()
	get_tree().get_root().get_node("World").get_node("Sounds").play("win")

	# Start timer to reset game
	var timer = Timer.new()
	timer.connect("timeout",self,"_on_timer_timeout") 
	add_child(timer)
	timer.start()


func _on_timer_timeout():
	# Increase level and reset game
	get_node("/root/global").level +=1
	get_tree().reload_current_scene()
