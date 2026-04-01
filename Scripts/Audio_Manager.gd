extends Node

func play_sound(sound_name:String):
	var audio_player:AudioStreamPlayer = get_node(sound_name)
	audio_player.play()

func stop_sound(sound_name:String):
	var audio_player:AudioStreamPlayer = get_node(sound_name)
	audio_player.stop()
