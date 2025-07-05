extends Node
@export var industries_container:Node
var _industries = []
var _coin:TextureButton
var background:TextureRect

func _ready():
	background = get_node("Background")
	_industries = industries_container.get_children()
	
	for i in range(0,6):
		var data = Country_Data_Base.Get_industry_data(i)
		_industries[i].set_industry(data)
	
	_coin = get_node("Coin_Button")
	GameManager.on_country_changed.connect(_update_country)

func _update_country(country_index:int):
	var country_name = Country_Data_Base.Get_country_name(country_index)
	background.texture = load("res://Sprites/" + country_name + "/" + country_name + "_Background.png")
	get_node("Country_Label").text = country_name
	
	Country_Data_Base.Set_Country(country_name, _coin)
	var data = Country_Data_Base.Get_industry_data(country_index)
	_industries[country_index].set_industry(data, false)
