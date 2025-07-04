class_name Coin_Button
extends TextureButton
var particles_handler:Particles_Handler
var original_scale

func _ready():
	original_scale = scale
	particles_handler = get_node("Particles_Handler")
	button_up.connect(add_money)
	mouse_entered.connect(on_mouse_entered)
	mouse_exited.connect(on_mouse_exited)

func on_mouse_entered():
	TweensDataBase.get_tween("pop_up").call({
		"object":self,
		"new_scale":scale*1.1,
		"duration":0.1
	})

func on_mouse_exited():
	TweensDataBase.get_tween("pop_up").call({
		"object":self,
		"new_scale":original_scale,
		"duration":0.1
	})

func add_money():
	GameManager.add_button_money()
	TweensDataBase.get_tween("pop").call({
		"object":self,
		"new_scale":scale*1.1,
		"duration":0.1
	})
	particles_handler.emit()
