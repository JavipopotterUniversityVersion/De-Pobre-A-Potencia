class_name Coin_Button
extends TextureButton

func _ready():
	button_up.connect(add_money)

func add_money():
	GameManager.add_button_money()

