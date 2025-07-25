extends ScrollContainer

var dragging := false
var last_touch_pos := Vector2.ZERO

func _gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		dragging = true
		last_touch_pos = event.position
	elif event is InputEventMouseMotion and dragging:
		var delta = event.position - last_touch_pos
		scroll_vertical -= delta.y
		scroll_horizontal -= delta.x
		last_touch_pos = event.position
	elif event is InputEventMouseButton and not event.pressed:
		dragging = false
	
	print(dragging)
