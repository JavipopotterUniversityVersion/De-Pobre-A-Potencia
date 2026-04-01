extends Node

@warning_ignore("unused_signal")
signal on_money_changed
@warning_ignore("unused_signal")
signal on_country_changed

@warning_ignore("unused_signal")
signal on_bonus_active
@warning_ignore("unused_signal")
signal on_bonus_deactive

@warning_ignore("unused_signal")
signal on_load_data
@warning_ignore("unused_signal")
signal on_save_data

var _current_scene
var GAME_SCENE = preload("res://Scenes/GameScene.tscn")

var _current_money:Big = Big.new(100)
var _coin_button_value:Big = Big.new(1)
var country_index = 0

var info_panel
var bonus_active

func start_bonus():
	bonus_active = true
	emit_signal("on_bonus_active")
	#AudioManager.stop_sound("Main_Theme")
	#AudioManager.play_sound("Bonus_Theme")
	await get_tree().create_timer(120).timeout
	#AudioManager.stop_sound("Bonus_Theme")
	#AudioManager.play_sound("Main_Theme")
	emit_signal("on_bonus_deactive")
	bonus_active = false

func assign_info_panel(panel):
	info_panel = panel

func _ready():
	add_child(info_panel)

func get_next_country_cost():
	return Country_Data_Base.Get_next_country_cost(country_index)

func get_current_country_name():
	return Country_Data_Base.Get_country_name(country_index)

func get_current_money():
	return _current_money

func upgrade_country():
	country_index = country_index + 1
	emit_signal("on_country_changed", country_index)
	CrazySDK.happy_time()
	save_data()

func init_country():
	emit_signal("on_country_changed", country_index)

func can_buy(amount:Big):
	return amount.isLessThanOrEqualTo(_current_money)

func try_buy(amount:Big):
	var bought = can_buy(amount)
	if bought:
		sub_money(amount)
	else:
		AudioManager.play_sound("Deny")
	return bought

func add_button_money():
	add_money(_coin_button_value)
	emit_signal("on_money_changed", _current_money)

func add_money(amount:Big):
	if(bonus_active):
		amount = Big.times(amount, 2)
	_current_money = Big.add(_current_money, amount)
	emit_signal("on_money_changed", _current_money)

func sub_money(amount:Big):
	_current_money = Big.subtract(_current_money, amount)
	emit_signal("on_money_changed", _current_money)

func add_click_value(amount:Big):
	_coin_button_value = Big.add(_coin_button_value, amount)

func set_info_panel(position:Vector2, description:String):
	info_panel.visible = true
	info_panel.global_position = position
	info_panel.get_node("Description").text = description

func hide_info_panel():
	info_panel.visible = false

func reset():
	CrazySDK.clear_data()
	
	if(_current_scene == null): get_tree().get_root().get_node("GameScene").queue_free()
	else: _current_scene.queue_free()
	
	_current_money = Big.new(0)
	_coin_button_value = Big.new(1)
	country_index = 0
	bonus_active = false
		
	_current_scene = GAME_SCENE.instantiate()
	get_tree().get_root().add_child(_current_scene)

func load_data():
	emit_signal("on_load_data")
	
func save_data():
	emit_signal("on_save_data")
	
	CrazySDK.save_data("current_money",{ 
			"mantissa": _current_money.mantissa,
			"exponent": _current_money.exponent
	})
	
	CrazySDK.save_data("current_country_index", {
		"current_country_index" : country_index
	})
	
	CrazySDK.save_data("coin_button_value", { 
			"mantissa": _coin_button_value.mantissa,
			"exponent": _coin_button_value.exponent
	})
