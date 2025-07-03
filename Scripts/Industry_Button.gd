extends Button
class_name Industry_Button

var _is_bought:bool
var _industry_name:String
var _level:int
var _upgrade_cost:int
var _revenue:int

func _ready():
	visible = false
	button_up.connect(_on_press)

func set_industry(data):
	visible = true
	_level = 0
	_industry_name = data.name
	_upgrade_cost = data.cost
	_revenue = data.revenue
	_update_text()

func _on_press():
	if(_is_bought): 
		_upgrade()
	else: 
		if(GameManager.try_buy(_upgrade_cost)):
			_buy()

func _buy():
	_is_bought = true
	while(_is_bought):
		GameManager.add_money(_revenue)
		await get_tree().create_timer(1).timeout

func _upgrade():
	_revenue = _revenue + 10
	_upgrade_cost = _upgrade_cost * 1.5
	_update_text()

func _update_text():
	text = _industry_name + " " + str(_revenue) + "€/s\n"
	if(_is_bought):
		text = text + "Mejorar: " + str(_upgrade_cost) + "€"
	else:
		text = text + "Comprar: " + str(_upgrade_cost) +  "€"



