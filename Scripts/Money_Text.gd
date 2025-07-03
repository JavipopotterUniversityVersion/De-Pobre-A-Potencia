extends Label

func _ready():
	GameManager.on_money_changed.connect(_update_money)
	pass

func _update_money(money:Big):
	text = money.toAA() + "€" 
