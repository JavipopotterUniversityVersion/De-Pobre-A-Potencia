extends NinePatchRect
class_name Industry_Button

signal on_revenue_change

var _is_bought:bool
var _industry_name:String
var _upgrade_cost:Big
var _revenue:Big = Big.new(0)
var _original_revenue:Big
var _text

func _ready():
	_text = get_node("Label")
	$Button.button_up.connect(_on_press)
	$Button.disabled = true
	modulate = Color.BLACK

	$Button.mouse_entered.connect(func(): 
		if !$Button.disabled:
			modulate = Color(0.7,0.7,0.7,1))
		
	$Button.mouse_exited.connect(func(): 
		if !$Button.disabled:
			modulate = Color(1,1,1,1))
	
	GameManager.on_load_data.connect(_load_industry)
	GameManager.on_save_data.connect(_save_industry)
	
func set_industry(data, inactive = true):
	$Button.disabled = inactive
	
	if inactive:
		modulate = Color.BLACK
		_text.modulate = Color.WHITE
	else:
		modulate = Color.WHITE
		_text.modulate = Color.WHITE
		
	_industry_name = data.name
	_upgrade_cost = data.cost
	_original_revenue = Big.roundDown(Big.division(data.revenue, 60))
	
	_update_text()

func _on_press():
	if(GameManager.try_buy(_upgrade_cost)):
		if(_is_bought):
			_upgrade()
		else: 
			_buy()
		AudioManager.play_sound("Buy")
		emit_signal("on_revenue_change")

func _buy():
	_is_bought = true
	_revenue = _original_revenue
	_update_text()
	while(_is_bought):
		await get_tree().create_timer(1).timeout
		GameManager.add_money(_revenue)

func _upgrade():
	_revenue = Big.add(_revenue, _original_revenue)
#	_upgrade_cost = Big.times(_upgrade_cost, 1.5)
	_update_text()

func _update_text():
	if $Button.disabled:
		_text.text = "?"
	else:
		_text.text = _industry_name + "\n"
#		 + " " + _revenue.toAA() + "€/min\n"
		if(_is_bought):
			_text.text = _text.text + "Upgrade: " + _upgrade_cost.toAA() + "€"
		else:
			_text.text = _text.text + "Buy: " + _upgrade_cost.toAA() +  "€"

func get_description():
	return "Generate " + _revenue.toAA() + "€/s"

func _save_industry():
	var industry_data = {
		"bought" = _is_bought,
		"revenue" = {
			"mantissa": _revenue.mantissa,
			"exponent": _revenue.exponent
			}
	}
	CrazySDK.save_data(_industry_name, industry_data)

func _load_industry():
	var industry_data = CrazySDK.get_data(_industry_name)
	if industry_data != {}:
		_is_bought = industry_data.bought
		_revenue = Big.new(industry_data.mantissa, industry_data.exponent)
