extends Button

func _ready():
	button_up.connect(_execute_bonus)

func _execute_bonus():
	CrazySDK.show_rewarded_ad(GameManager.start_bonus)
