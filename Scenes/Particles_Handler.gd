extends Node
class_name Particles_Handler
var particles:GPUParticles2D

var MONEY_PARTICLES:ParticleProcessMaterial = preload("res://Particles/Money_Particles.tres")
var MONEY_PARTICLES_BONUS:ParticleProcessMaterial = preload("res://Particles/Money_Particles_Bonus.tres")

func _ready():
	particles = get_node("GPUParticles2D")
	GameManager.on_country_changed.connect(_on_country_changed)
	
	GameManager.on_bonus_active.connect(func():
		particles.amount = 30
		particles.process_material = MONEY_PARTICLES_BONUS)
	
	GameManager.on_bonus_deactive.connect(func():
		particles.amount = 20
		particles.process_material = MONEY_PARTICLES)

func emit():
	particles.global_position = get_viewport().get_mouse_position() * 4.33
	particles.emitting = true
	await get_tree().create_timer(0.1).timeout
	particles.emitting = false

func _on_country_changed(country_index:int):
	var country_name = Country_Data_Base.Get_country_name(country_index)
	var coin_texture:Texture2D = load("res://Sprites/" + country_name + "/" + country_name + "_Coin.png")
	particles.texture = coin_texture
	
	MONEY_PARTICLES.scale_min = 400.0 / coin_texture.get_width()
	MONEY_PARTICLES.scale_max = 425.0 / coin_texture.get_width()
	MONEY_PARTICLES_BONUS.scale_min = MONEY_PARTICLES.scale_min * 1.1
	MONEY_PARTICLES_BONUS.scale_max = MONEY_PARTICLES.scale_max * 1.1
