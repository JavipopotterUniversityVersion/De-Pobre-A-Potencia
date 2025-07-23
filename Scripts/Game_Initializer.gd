extends Node

func _ready():
	GameManager.init_country()
	await get_tree().create_timer(0.1).timeout
	var current_country = CrazySDK.get_data("current_country_index")
	if current_country != {}:
		GameManager.country_index = current_country["current_country_index"]
	
	var current_money = CrazySDK.get_data("current_money")
	if current_money != {}:
		GameManager._current_money = Big.new(current_money["mantissa"], current_money["exponent"])
	
	var coin_button_value = CrazySDK.get_data("coin_button_value")
	if coin_button_value != {}:
		GameManager._coin_button_value = Big.new(coin_button_value["mantissa"], coin_button_value["exponent"])
	
	GameManager.load_data()
	GameManager.init_country()
