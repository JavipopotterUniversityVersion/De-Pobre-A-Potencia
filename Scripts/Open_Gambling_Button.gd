extends Button

const GAMBLING_WINDOW_SCENE := preload("res://Scenes/gambling_window.tscn")
var elapsed_time:float = 0
var appear_time:float = 20

func _ready() -> void:
	hide()
	button_up.connect(_open_gambling_window)

func _process(delta: float) -> void:
	if visible: return
	
	elapsed_time += delta
	if elapsed_time >= appear_time:
		elapsed_time = 0
		show()

func _open_gambling_window() -> void:
	hide()
	var current_scene := get_tree().current_scene
	if current_scene == null:
		return

	if current_scene.has_node("GamblingWindow"):
		return

	var gambling_window := GAMBLING_WINDOW_SCENE.instantiate()
	current_scene.add_child(gambling_window)
