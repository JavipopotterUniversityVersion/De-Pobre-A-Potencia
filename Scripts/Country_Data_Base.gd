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
		"name" : "Fishing",
		"cost": Big.new(1, 2),
		"revenue": Big.new(2, 2)
	},
	{
		"name" : "Crafts",
		"cost": Big.new(1, 3),
		"revenue": Big.new(2, 3)
	},
	{
		"name" : "Mechanical Workshop",
		"cost": Big.new(4, 3),
		"revenue": Big.new(8, 3)
	},
	{
		"name" : "Street Food",
		"cost": Big.new(4, 4),
		"revenue": Big.new(8, 4)
	},
	{
		"name" : "Media",
		"cost": Big.new(4, 5),
		"revenue": Big.new(8, 5)
	},
	{
		"name" : "Gastronomy",
		"cost": Big.new(6, 6),
		"revenue": Big.new(1.2, 7) # 1.2×10^7
	},
	{
		"name" : "Tourism",
		"cost": Big.new(6, 7),
		"revenue": Big.new(1.2, 8)
	},
	{
		"name" : "Weaponry",
		"cost": Big.new(6, 8),
		"revenue": Big.new(1.2, 9)
	},
	{
		"name": "Luxury Cars",
		"cost": Big.new(6, 9),
		"revenue": Big.new(1.2, 10)
	},
	{
		"name": "Product Export",
		"cost": Big.new(4.5, 10),
		"revenue": Big.new(9, 10)
	},
	{
		"name": "Entertainment and Finance",
		"cost": Big.new(4.5, 11),
		"revenue": Big.new(9, 11)
	},
	{
		"name": "Tech Mining",
		"cost": Big.new(4.5, 12),
		"revenue": Big.new(9, 12)
	},
	{
		"name": "Video Games and Robotics",
		"cost": Big.new(5, 13),
		"revenue": Big.new(9, 13)
	},
	{
		"name": "Big Tech and Space",
		"cost": Big.new(4.5, 14),
		"revenue": Big.new(9, 14)
	},
	{
		"name": "Private Banking",
		"cost": Big.new(4.5, 15),
		"revenue": Big.new(9, 15)
	},
	{
		"name": "Luxury Real Estate",
		"cost": Big.new(4.5, 16),
		"revenue": Big.new(9, 16)
	},
	{
		"name": "Energy (Oil and Gas)",
		"cost": Big.new(4.5, 17),
		"revenue": Big.new(9, 17)
	},
	{
		"name": "Advanced Robotics",
		"cost": Big.new(4.5, 18),
		"revenue": Big.new(9, 18)
	},
	{
		"name": "Financial Sector and Tax Regime",
		"cost": Big.new(4.5, 19),
		"revenue": Big.new(9, 19)
	}

]

static var _countries_names = ["Burundi", "Haiti", "Yemeni", "India", "Brasil", "Spain", "France", "Rusia", "China", "United Kingdom", "Australia", "Japan", "United States", "Switzerland", "United Arab Emirates", "Qatar", "Singapore", "Luxemburg"]

static func Get_country_name(country_index:int):
	return _countries_names[country_index]

static var _next_country_cost = [
	Big.new(1, 3),      # 1.000 BIF (Burundi -> Haití)
	Big.new(1, 4),      # 10.000 HTG (Haití -> Yemen)
	Big.new(5, 4),      # 50.000 YER (Yemen -> India)
	Big.new(5, 5),      # 500.000 ₹ (India -> Brasil)
	Big.new(5, 6),      # 5M R$ (Brasil -> España)
	Big.new(6, 7),      # 60M € (España -> Francia)
	Big.new(7, 8),      # 700M € (Francia -> Rusia)
	Big.new(8, 9),      # 8B CHF (Rusia -> Alemania)
	Big.new(1, 11),     # 100B QAR (Alemania -> China)
	Big.new(1, 12),     # 1T SGD (China -> Reino Unido)
	Big.new(1.2, 13),   # 12T £ (Reino Unido -> Australia)
	Big.new(1.4, 14),   # 140T AUD (Australia -> Japón)
	Big.new(1.5, 15),   # 1.5Q CAD (Japón -> EE.UU.)
	Big.new(1.8, 16),   # 18Q ¥ (EE.UU. -> Suiza)
	Big.new(2.2, 17),   # 220Q AED (Suiza -> EAU)
	Big.new(2.5, 18),   # 2.5 Quint $ (EAU -> Qatar)
	Big.new(3, 19),     # 30 Quint NOK (Qatar -> Singapur)
	Big.new(3.5, 20)    # 350 Quint KWD (Singapur -> Luxemburgo)
]

static func Get_next_country_cost(index:int):
	return _next_country_cost[index]


