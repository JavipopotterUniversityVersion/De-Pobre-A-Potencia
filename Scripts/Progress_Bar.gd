class_name Progress_Bar
extends ProgressBar

var label:Label
const YELLOW:Color = Color(0,1,1,1)

func _process(_delta):
	value = Big.division(GameManager.get_current_money(), GameManager.get_next_country_cost()).toFloat()
	pass
