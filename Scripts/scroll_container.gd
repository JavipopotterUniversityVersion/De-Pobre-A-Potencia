extends ScrollContainer

var dragging := false
var last_touch_pos := Vector2.ZERO
var touch_index := -1

func _unhandled_input(event):
	if event is InputEventScreenTouch:
		if event.pressed and touch_index == -1:
			dragging = true
			last_touch_pos = event.position
			touch_index = event.index
		elif not event.pressed and event.index == touch_index:
			dragging = false
			touch_index = -1

	elif event is InputEventScreenDrag and dragging and event.index == touch_index:
		var delta = event.position - last_touch_pos
		scroll_vertical -= delta.y
		scroll_horizontal -= delta.x
		last_touch_pos = event.position
