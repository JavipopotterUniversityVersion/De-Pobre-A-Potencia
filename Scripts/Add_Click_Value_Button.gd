extends Node

var click_value_cost:Big = Big.new(50)
var upgrade_cost:Big = Big.new(1000)

var number_of_clicks_to_buy:Big = Big.new(1)

var _level = 1
var SCALING_FACTOR:Big = Big.new(1.05)

var coin_value_button:Button
var upgrade_button:Button

func _ready():
	coin_value_button = get_node("coin_value_button")
	upgrade_button = get_node("upgrade_button")
	
	GameManager.on_load_data.connect(load_data)
	
	_update_coin_value_button()
	coin_value_button.button_up.connect(_add_click_value)
	
	_update_upgrade_button()
	upgrade_button.button_up.connect(_upgrade)

func _add_click_value():
	if GameManager.try_buy(click_value_cost):
		AudioManager.play_sound("Buy")
		GameManager.add_click_value(number_of_clicks_to_buy)
		click_value_cost = Big.roundDown(Big.times(click_value_cost, Big.powers(SCALING_FACTOR,_level)))
		upgrade_cost = Big.roundDown(Big.times(upgrade_cost, Big.powers(SCALING_FACTOR,_level)))
		_update_coin_value_button()
		_update_upgrade_button()
		_save_data()

func _upgrade():
	if GameManager.try_buy(upgrade_cost):
		AudioManager.play_sound("Buy")
		click_value_cost = Big.times(click_value_cost, 10)
		number_of_clicks_to_buy = Big.times(number_of_clicks_to_buy, 10)
		upgrade_cost = Big.times(upgrade_cost, 10)
		_update_upgrade_button()
		_update_coin_value_button()
		_save_data()

func _save_data():
	CrazySDK.save_data("coin_upgrade", {
		"click_value_cost": {
			"mantissa": click_value_cost.mantissa,
			"exponent": click_value_cost.exponent
		},
		"upgrade_cost": {
			"mantissa": upgrade_cost.mantissa,
			"exponent": upgrade_cost.exponent
		},
		"number_of_clicks_to_buy": {
			"mantissa": number_of_clicks_to_buy.mantissa,
			"exponent": number_of_clicks_to_buy.exponent
		},
		"level": _level
	})

func load_data():
	var data = CrazySDK.get_data("coin_upgrade")
	if(data != {}):
		click_value_cost = Big.new(data.click_value_cost.mantissa, data.click_value_cost.exponent)
		upgrade_cost = Big.new(data.upgrade_cost.mantissa, data.upgrade_cost.exponent)
		number_of_clicks_to_buy = Big.new(data.number_of_clicks_to_buy.mantissa, data.number_of_clicks_to_buy.exponent)
		_level = data.level
		_update_coin_value_button()
		_update_upgrade_button()

func _update_coin_value_button():
	coin_value_button.get_node("Label").text = "Buy x" + number_of_clicks_to_buy.toAA() + ": " + click_value_cost.toAA() + "€"

func _update_upgrade_button():
	upgrade_button.text = "Upgrade: " + upgrade_cost.toAA() + "€"

func get_description():
	return "Generate " + GameManager._coin_button_value.toAA() + "€/click"
