extends Label

func _ready():
	GameManager.on_money_changed.connect(_update_money)
	pass

func _update_money(money:int):
	text = str(money) + "€" 
