extends Button

func _ready() -> void:
	button_up.connect(clear_data)

func clear_data():
	GameManager.reset()
