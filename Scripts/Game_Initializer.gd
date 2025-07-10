extends Node

func _ready():
	var current_country = CrazySDK.get_data("current_country_index")
	if current_country != {}:
		GameManager.country_index = current_country["current_country_index"]
	
	var current_money = CrazySDK.get_data("current_money")
	if current_money != {}:
		GameManager._current_money = Big.new(current_money["mantissa"], current_money["exponent"])
	
	var coin_button_value = CrazySDK.get_data("coin_button_value")
	if coin_button_value != {}:
		GameManager._coin_button_value = Big.new(coin_button_value["mantissa"], coin_button_value["exponent"])
	
	GameManager.init_country()
	GameManager.load_data()
