extends TextureButton

func _ready():
	visible = false
	GameManager.on_money_changed.connect(_check_next_country)
	button_up.connect(_buy_country)

func _check_next_country(amount:Big):
	if(amount.isGreaterThanOrEqualTo(GameManager.get_next_country_cost())):
		visible = true

func _buy_country():
	if(GameManager.try_buy(GameManager.get_next_country_cost())):
		GameManager.upgrade_country()
		visible = false
