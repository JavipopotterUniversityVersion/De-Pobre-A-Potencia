extends Button

const GAMBLING_WINDOW_SCENE := preload("res://Scenes/gambling_window.tscn")


func _ready() -> void:
	button_up.connect(_open_gambling_window)


func _open_gambling_window() -> void:
	var current_scene := get_tree().current_scene
	if current_scene == null:
		return

	if current_scene.has_node("GamblingWindow"):
		return

	var gambling_window := GAMBLING_WINDOW_SCENE.instantiate()
	current_scene.add_child(gambling_window)
