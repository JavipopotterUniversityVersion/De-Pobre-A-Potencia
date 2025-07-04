extends Node

signal on_money_changed
signal on_country_changed

var _current_money:Big = Big.new(0)
var _coin_button_value:Big = Big.new(1)
var country_index = 0

const INFO_PANEL = preload("res://Prefabs/info_panel.tscn")
var info_panel

func _ready():
	info_panel = INFO_PANEL.instantiate()
	add_child(info_panel)
	info_panel.visible = false

func get_next_country_cost():
	return Country_Data_Base.Get_next_country_cost(country_index)

func get_current_money():
	return _current_money

func upgrade_country():
	country_index = country_index + 1
	emit_signal("on_country_changed", country_index)

func init_country():
	emit_signal("on_country_changed", country_index)

func can_buy(amount:Big):
	return amount.isLessThanOrEqualTo(_current_money)

func try_buy(amount:Big):
	var bought = can_buy(amount)
	if bought: sub_money(amount)
	return bought

func add_button_money():
	_current_money = Big.add(_current_money, _coin_button_value)
	emit_signal("on_money_changed", _current_money)

func add_money(amount:Big):
	_current_money = Big.add(_current_money, amount)
	emit_signal("on_money_changed", _current_money)

func sub_money(amount:Big):
	_current_money = Big.subtract(_current_money, amount)
	emit_signal("on_money_changed", _current_money)

func add_click_value(amount:Big):
	_coin_button_value = Big.add(_coin_button_value, amount)

func set_info_panel(position:Vector2, description:String):
	info_panel.visible = true
	info_panel.get_node("Info_Panel").global_position = position - Vector2(140,70)
	info_panel.get_node("Info_Panel/Description").text = description

func hide_info_panel():
	info_panel.visible = false
