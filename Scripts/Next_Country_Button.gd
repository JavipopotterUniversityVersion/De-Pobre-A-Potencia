extends TextureButton
var label:Label

func _ready():
	label = get_node("Label")
	visible = false
	GameManager.on_money_changed.connect(_check_next_country)
	button_up.connect(_buy_country)

func _check_next_country(amount:Big):
	if(amount.isGreaterThanOrEqualTo(GameManager.get_next_country_cost())):
		label.text = "Upgrade Country: " + GameManager.get_next_country_cost().toAA() + "€"
		visible = true
	else:
		visible = false

func _buy_country():
	if(GameManager.try_buy(GameManager.get_next_country_cost())):
		CrazySDK.show_midgame_ad()
		AudioManager.play_sound("Upgrade")
		GameManager.upgrade_country()
		visible = false
