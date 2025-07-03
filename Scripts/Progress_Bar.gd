class_name Progress_Bar
extends ProgressBar

var label:Label
const YELLOW:Color = Color(0,1,1,1)

func _ready():
	GameManager.on_country_changed.connect(_on_country_changed)

func _on_country_changed(index:int):
	max_value = Country_Data_Base.Get_next_country_cost(index)

func _process(delta):
	value = GameManager.get_current_money()
