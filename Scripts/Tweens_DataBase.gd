extends Node

signal on_animation_start
signal on_animation_end

func get_tween(tween_name):
	emit_signal("on_animation_start")
	return tweens[tween_name]

var tweens = {
	"go_to":
		func(context):
			var tween:Tween = context.object.create_tween()
			tween.tween_property(context.object, 'global_position', context.pos, context.duration)
			await context.object.get_tree().create_timer(context.duration).timeout
			emit_signal("on_animation_end")
			context.call_back.call(),
			
	"arc_go_to":
		func(context):
			var object = context.object
			var start_pos: Vector2 = object.global_position
			var end_pos: Vector2 = context.pos
			var height_offset: float = 90.0  # altura del arco (ajústalo a gusto)
			var duration: float = context.duration

			var tween: Tween = object.create_tween()

			tween.tween_method(func(t):
				var curved_pos = start_pos.lerp(end_pos, t)
				curved_pos.y += height_offset * sin(PI * t)
				object.global_position = curved_pos
			, 0.0, 1.0, duration)

			await object.get_tree().create_timer(duration).timeout
			emit_signal("on_animation_end")
			context.call_back.call(),
			
	"attack_left":
		func(context):
			var tween:Tween = context.object.create_tween()
			var init_pos = context.object.position
			tween.tween_property(context.object, 'position', init_pos + Vector2(50,0), context.duration*2/4)
			tween.tween_property(context.object, 'position', init_pos - Vector2(100,0) , context.duration/4)
			tween.tween_property(context.object, 'position', init_pos, context.duration/4)
			await context.object.get_tree().create_timer(context.duration).timeout
			context.call_back.call()
			emit_signal("on_animation_end"),
			
	"attack_right":
		func(context):
			var tween:Tween = context.object.create_tween()
			var init_pos = context.object.position
			tween.tween_property(context.object, 'position', init_pos - Vector2(50,0), context.duration*2/4)
			tween.tween_property(context.object, 'position', init_pos + Vector2(100,0) , context.duration/4)
			tween.tween_property(context.object, 'position', init_pos, context.duration/4)
			await context.object.get_tree().create_timer(context.duration).timeout
			context.call_back.call()
			emit_signal("on_animation_end"),
	
	"die":
		func(context:Sprite2D):
			var tween:Tween = context.create_tween()
			var init_pos = context.position
			tween.tween_property(context, 'rotation', 2 * PI, 0.2)
			tween.tween_property(context, 'modulate', Color(1,0,0,0), 0.3)
			emit_signal("on_animation_end"),
	
	"get_dmg_from_left":
		func(context):
			var tween:Tween = context.create_tween()
			var init_pos = context.position
			tween.tween_property(context, 'position', init_pos + Vector2(50,0), 0.1)
			tween.tween_property(context, 'position', init_pos, 0.2)
			emit_signal("on_animation_end"),
			
	"get_dmg_from_right":
		func(context):
			var tween:Tween = context.create_tween()
			var init_pos = context.position
			tween.tween_property(context, 'position', init_pos - Vector2(50,0), 0.1)
			tween.tween_property(context, 'position', init_pos, 0.2)
			emit_signal("on_animation_end"),
}
