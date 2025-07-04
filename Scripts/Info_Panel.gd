extends Panel

func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered():
	var description:String = get_parent().get_description()
	GameManager.set_info_panel(global_position, description)

func _on_mouse_exited():
	GameManager.hide_info_panel()
