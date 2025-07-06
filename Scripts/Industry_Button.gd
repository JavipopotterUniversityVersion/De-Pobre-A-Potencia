extends NinePatchRect
class_name Industry_Button

var _is_bought:bool
var _industry_name:String
var _level:int
var _upgrade_cost:Big
var _revenue:Big
var _original_revenue:Big
var _text
var disabled:bool

func _ready():
	disabled = true
	_text = get_node("Label")
	$Button.button_up.connect(_on_press)

	$Button.mouse_entered.connect(func(): 
		modulate = Color(0.7,0.7,0.7,1))
		
	$Button.mouse_exited.connect(func(): 
		modulate = Color(1,1,1,1))

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
		_text.text = "?"
	else:
		_text.text = _industry_name + "\n"
#		 + " " + _revenue.toAA() + "€/min\n"
		if(_is_bought):
			_text.text = _text.text + "Upgrade: " + _upgrade_cost.toAA() + "€"
		else:
			_text.text = _text.text + "Buy: " + _upgrade_cost.toAA() +  "€"

func get_description():
	return "Generate " + _revenue.toAA() + "€/min"


