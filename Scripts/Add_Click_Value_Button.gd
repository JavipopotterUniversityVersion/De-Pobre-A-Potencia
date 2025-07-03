extends Node

var click_value_cost:Big = Big.new(50)
var upgrade_cost:Big = Big.new(1000)

var number_of_clicks_to_buy:Big = Big.new(1)

var coin_value_button:Button
var upgrade_button:Button

func _ready():
	coin_value_button = get_node("coin_value_button")
	upgrade_button = get_node("upgrade_button")
	
	_update_coin_value_button()
	coin_value_button.button_up.connect(_add_click_value)
	
	_update_upgrade_button()
	upgrade_button.button_up.connect(_upgrade)

func _add_click_value():
	if GameManager.try_buy(click_value_cost):
		GameManager.add_click_value(number_of_clicks_to_buy)
#		click_value_cost = ceil(float(click_value_cost) * 1.01)
		_update_coin_value_button()

func _upgrade():
	if GameManager.try_buy(upgrade_cost):
		click_value_cost = Big.times(click_value_cost, 10)
		number_of_clicks_to_buy = Big.times(number_of_clicks_to_buy, 10)
		upgrade_cost = Big.times(upgrade_cost, 2)
		_update_upgrade_button()
		_update_coin_value_button()

func _update_coin_value_button():
	coin_value_button.text = "+" + GameManager._coin_button_value.toAA() + "€ por Click \n" + "Comprar x" + number_of_clicks_to_buy.toAA() + ": " + click_value_cost.toMetricName() + "€"

func _update_upgrade_button():
	upgrade_button.text = "Mejorar: " + upgrade_cost.toAA() + "€"
