extends Label

func _ready():
	GameManager.on_money_changed.connect(_update_money)
	GameManager.on_load_data.connect(func(): _update_money(GameManager._current_money))

func _update_money(money:Big):
	text = money.toAA()
