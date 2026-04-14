extends Button
class_name Industry_Button

@warning_ignore("unused_signal")
signal on_revenue_change

var _is_bought:bool
var _industry_name:String
var _upgrade_cost:Big
var _revenue:Big = Big.new(0)
var _original_revenue:Big
var _name_label:Label
var _price_label:Label
var _icon:TextureRect
var _level:int = 1
var SCALING_FACTOR:Big = Big.new(1.05)

const _INDUSTRY_ICON_PATH_TEMPLATE := "res://Sprites/icons/%s.png"

func _ready():
	_name_label = %INDUSTRY_NAME
	_price_label = %PRICE_DISPLAY
	_icon = %ICON
	button_up.connect(_on_press)
	disabled = true
	modulate = Color.BLACK

	mouse_entered.connect(func(): 
		if !disabled:
			modulate = Color(0.7,0.7,0.7,1))
		
	mouse_exited.connect(func(): 
		if !disabled:
			modulate = Color(1,1,1,1))
	
	#GameManager.on_load_data.connect(_load_industry)
	await get_tree().create_timer(0.25).timeout
	_load_industry()
	
func set_industry(data, inactive = true):
	disabled = inactive
	_industry_name = data.name
	_set_icon_texture(_industry_name)
	
	if inactive:
		modulate = Color.BLACK
		_name_label.modulate = Color.WHITE
		_price_label.modulate = Color.WHITE
	else:
		create_tween().tween_property(self, "modulate", Color.WHITE, 1.0)
		_name_label.modulate = Color.WHITE
		_price_label.modulate = Color.WHITE
		_upgrade_cost = data.cost
		if CrazySDK.get_data(data.name) == {}:
			_save_industry()
	
	_original_revenue = Big.roundDown(Big.division(data.revenue, 60))
	_update_text()
	_load_industry()

func _on_press():
	if(GameManager.try_buy(_upgrade_cost)):
		_upgrade_cost = Big.roundDown(Big.times(_upgrade_cost, Big.powers(SCALING_FACTOR,_level)))
		_level = _level+1
		if(_is_bought):
			_upgrade()
		else: 
			_buy()
		AudioManager.play_sound("Buy")
		emit_signal("on_revenue_change")
		_save_industry()

func _buy():
	_is_bought = true
	_revenue = _original_revenue
	_update_text()
	while(_is_bought):
		await get_tree().create_timer(1).timeout
		GameManager.add_money(_revenue)

func _upgrade():
	_revenue = Big.add(_revenue, _original_revenue)
	_update_text()

func _update_text():
	if disabled:
		_name_label.text = "?"
		_price_label.text = "?"
	else:
		_name_label.text = _industry_name
		if(_is_bought):
			_price_label.text = "$" + _upgrade_cost.toAA()
		else:
			_price_label.text = "$" + _upgrade_cost.toAA()

func get_description():
	return "Generate " + _revenue.toAA() + "$/s"

func _save_industry():
	var industry_data = {
		"bought" = _is_bought,
		"revenue" = {
			"mantissa": _revenue.mantissa,
			"exponent": _revenue.exponent
			},
		"active" = !disabled,
		"level" = _level,
		"upgrade_cost" = {
			"mantissa": _upgrade_cost.mantissa,
			"exponent": _upgrade_cost.exponent
			},
	}
	CrazySDK.save_data(_industry_name, industry_data)

func _load_industry():
	if _industry_name.is_empty():
		return

	var industry_data = CrazySDK.get_data(_industry_name)
	if industry_data != {}:
		_is_bought = industry_data.bought
		_revenue = Big.new(industry_data.revenue.mantissa, industry_data.revenue.exponent)
		_level = industry_data.level
		_upgrade_cost = Big.new(industry_data.upgrade_cost.mantissa, industry_data.upgrade_cost.exponent)
		
		if(industry_data.active):
			create_tween().tween_property(self, "modulate", Color.WHITE, 1.0)
			_name_label.modulate = Color.WHITE
			_price_label.modulate = Color.WHITE
			disabled = false
			
		emit_signal("on_revenue_change")
		_update_text()
		
		while(_is_bought):
			await get_tree().create_timer(1).timeout
			GameManager.add_money(_revenue)

func _set_icon_texture(industry_name:String):
	var icon_path = _INDUSTRY_ICON_PATH_TEMPLATE % industry_name
	if ResourceLoader.exists(icon_path):
		_icon.texture = load(icon_path)
