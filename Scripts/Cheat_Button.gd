extends Button
@export var mantisa:float
@export var exponente:int

func _ready():
	button_up.connect(
		func():
			GameManager.add_money(Big.new(mantisa, exponente))
			)
