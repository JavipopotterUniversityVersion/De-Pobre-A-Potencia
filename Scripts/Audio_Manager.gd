extends Node

func play_sound(name:String):
	var audio_player:AudioStreamPlayer = get_node(name)
	audio_player.play()

func stop_sound(name:String):
	var audio_player:AudioStreamPlayer = get_node(name)
	audio_player.stop()
