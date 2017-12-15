# Play background music
extends StreamPlayer

var songs = [ "bg_music_01_05_pitch.ogg", "bg_music_01_10_pitch.ogg", "bg_music_01_15_pitch.ogg", "bg_music_01_20_pitch.ogg" ] # current song depends on level
var song


func _ready():
	# Play song that correspends to level
	song = load("res://music/" + songs[ get_node("/root/global").level % 4 ] )
	set_stream(song)
	play()
