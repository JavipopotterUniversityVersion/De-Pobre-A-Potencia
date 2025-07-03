extends Node
var _industries = []
var _coin:TextureButton

func _ready():
	_industries = get_node("Industries").get_children()
	_coin = get_node("Coin_Button")
	GameManager.on_country_changed.connect(_update_country)

func _update_country(country_index:int):
	var country_name = Country_Data_Base.Get_country_name(country_index)
	get_node("Country_Label").text = country_name
	
	Country_Data_Base.Set_Country(country_name, _coin)
	var data = Country_Data_Base.Get_industry_data(country_index)
	_industries[country_index].set_industry(data)
