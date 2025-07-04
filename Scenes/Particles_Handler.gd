extends Node
class_name Particles_Handler
var particles:GPUParticles2D

func _ready():
	particles = get_node("GPUParticles2D")

func emit():
	particles.global_position = get_viewport().get_mouse_position()
	particles.emitting = true
	await get_tree().create_timer(0.1).timeout
	particles.emitting = false
