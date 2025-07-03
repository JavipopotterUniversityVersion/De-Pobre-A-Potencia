class_name Country_Data_Base
extends Node

static func Set_Country(country_name:String, coin_button:TextureButton):
	var button_texture = load("res://Sprites/" + country_name + "/" + country_name + "_Coin.png")
	
	coin_button.texture_normal = button_texture
	coin_button.texture_pressed = button_texture
	coin_button.texture_hover = button_texture
	coin_button.texture_disabled = button_texture
	coin_button.texture_focused = button_texture

static func Get_industry_data(country_index:int):
	return _industries_data[country_index]

static var _industries_data = [
	{
		"name" : "Agricultura",
		"cost": 200,
		"revenue": 10
	},
	{
		"name" : "Pesca",
		"cost": 500,
		"revenue": 30
	}
]

static var _countries_names = ["Burundi", "Haiti", "Yemen", "India", "Brasil", "España", "Alemania"]

static func Get_country_name(country_index:int):
	return _countries_names[country_index]

static var _next_country_cost = [1000, 50000, 100000]

static func Get_next_country_cost(index:int):
	return _next_country_cost[index]


