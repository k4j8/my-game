extends Area2D

var hero_count = 1


func _ready():
	connect("body_enter", self, "win")


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
	get_tree().reload_current_scene()