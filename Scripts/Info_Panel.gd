extends Panel
#var info_panel

func _ready():
#	info_panel = get_node("Info_Panel")
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
 
func _on_mouse_entered():
#	info_panel.visible = true
	var description:String = get_parent().get_description()
#	info_panel.get_node("Description").text = description
	GameManager.set_info_panel(global_position + Vector2(-951.522,-350.482), description)

func _on_mouse_exited():
#	info_panel.visible = false
	GameManager.hide_info_panel()
