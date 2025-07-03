extends Node

signal on_money_changed
signal on_country_changed

var _current_money:int = 0
var _coin_button_value:int = 1
var country_index = 0

func get_next_country_cost():
	return Country_Data_Base.Get_next_country_cost(country_index)

func get_current_money():
	return _current_money

func upgrade_country():
	country_index = country_index + 1
	emit_signal("on_country_changed", country_index)

func init_country():
	emit_signal("on_country_changed", country_index)

func can_buy(amount:int):
	return amount <= _current_money 

func try_buy(amount:int):
	var bought = can_buy(amount)
	if bought: sub_money(amount)
	return bought

func add_button_money():
	_current_money = _current_money + _coin_button_value
	emit_signal("on_money_changed", _current_money)

func add_money(amount:int):
	_current_money = _current_money + amount
	emit_signal("on_money_changed", _current_money)

func sub_money(amount:int):
	_current_money = _current_money - amount
	emit_signal("on_money_changed", _current_money)

func add_click_value(amount:int):
	_coin_button_value = _coin_button_value + amount
