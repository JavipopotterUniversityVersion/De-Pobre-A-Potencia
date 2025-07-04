extends Button
class_name Industry_Button

var _is_bought:bool
var _industry_name:String
var _level:int
var _upgrade_cost:Big
var _revenue:Big
var _original_revenue:Big

func _ready():
	disabled = true
	button_up.connect(_on_press)

func set_industry(data, inactive = true):
	disabled = inactive
	_level = 0
	_industry_name = data.name
	_upgrade_cost = data.cost
	_revenue = data.revenue
	_original_revenue = data.revenue
	_update_text()

func _on_press():
	if(GameManager.try_buy(_upgrade_cost)):
		if(_is_bought):
			_upgrade()
		else: 
			_buy()

func _buy():
	_is_bought = true
	while(_is_bought):
		await get_tree().create_timer(60).timeout
		GameManager.add_money(_revenue)

func _upgrade():
	_revenue = Big.add(_revenue, _original_revenue)
#	_upgrade_cost = Big.times(_upgrade_cost, 1.5)
	_update_text()

func _update_text():
	if disabled:
		text = "?"
	else:
		text = _industry_name + "\n"
#		 + " " + _revenue.toAA() + "€/min\n"
		if(_is_bought):
			text = text + "Upgrade: " + _upgrade_cost.toAA() + "€"
		else:
			text = text + "Buy: " + _upgrade_cost.toAA() +  "€"

func get_description():
	return "Generate " + _revenue.toAA() + "€/min"


