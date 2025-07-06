extends Node
class_name Particles_Handler
var particles:GPUParticles2D

func _ready():
	particles = get_node("GPUParticles2D")
	GameManager.on_country_changed.connect(_on_country_changed)

func emit():
	particles.global_position = get_viewport().get_mouse_position() * 4.33
	particles.emitting = true
	await get_tree().create_timer(0.1).timeout
	particles.emitting = false

func _on_country_changed(country_index:int):
	var country_name = Country_Data_Base.Get_country_name(country_index)
	particles.texture = load("res://Sprites/" + country_name + "/" + country_name + "_Coin.png")
