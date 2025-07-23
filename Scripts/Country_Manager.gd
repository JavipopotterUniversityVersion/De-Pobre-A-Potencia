extends Node
@export var industries_container:Node
var _industries = []
var _coin:TextureButton
var background:Background_Transitioner

var total_revenue:Big
var total_revenue_label:Label
var bonus_active:bool = false

func _ready():
	total_revenue_label = get_node("total_revenue_label")
	background = get_node("Background")
	var industries_temp = industries_container.get_node("ScrollContainer/VBoxContainer").get_children()
	
	for value in industries_temp:
		_industries.push_back(value.get_child(0))
	
	for i in range(0,19):
		var data = Country_Data_Base.Get_industry_data(i)
		_industries[i].set_industry(data)
		_industries[i].on_revenue_change.connect(func():
			total_revenue = Big.new(0)
			for industry in _industries:
				total_revenue = Big.add(total_revenue, industry._revenue)
			if bonus_active:
				total_revenue = Big.times(total_revenue, 2)
			total_revenue_label.text = total_revenue.toAA() + "€/s")
				
	GameManager.on_bonus_active.connect(
		func():
			total_revenue = Big.new(0)
			for industry in _industries:
				total_revenue = Big.add(total_revenue, industry._revenue)
			total_revenue = Big.times(total_revenue, 2)
			bonus_active = true
			total_revenue_label.text = total_revenue.toAA() + "€/s"
			)

	GameManager.on_bonus_deactive.connect(
		func():
			total_revenue = Big.new(0)
			for industry in _industries:
				total_revenue = Big.add(total_revenue, industry._revenue)
			bonus_active = false
			total_revenue_label.text = total_revenue.toAA() + "€/s"
			)
	
	_coin = get_node("Coin_Button")
	GameManager.on_country_changed.connect(_update_country)
	GameManager.assign_info_panel(get_node("Info_Panel"))

func _update_country(country_index:int):
	var country_name = Country_Data_Base.Get_country_name(country_index)
	JavaScriptBridge.eval("console.log('COUNTRY INDEX " + str(country_index) + "')")
	var new_tex = load("res://Sprites/" + country_name + "/" + country_name + "_Background.png")
	background.set_background(new_tex)
	get_node("Country_Label").text = country_name
	
	Country_Data_Base.Set_Country(country_name, _coin)
	var data = Country_Data_Base.Get_industry_data(country_index)
	_industries[country_index].set_industry(data, false)
	
	total_revenue = Big.new(0)
	for industry in _industries:
		total_revenue = Big.add(total_revenue, industry._revenue)
	total_revenue_label.text = total_revenue.toAA() + "€/s"
