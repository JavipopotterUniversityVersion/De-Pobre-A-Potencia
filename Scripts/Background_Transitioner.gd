extends TextureRect
class_name Background_Transitioner

func set_background(new_background:Texture2D):
	material.set("shader_parameter/texture_2", material.get("shader_parameter/texture_1"))
	material.set("shader_parameter/texture_1", new_background)
	await animate_shader_param("transform_ratio", 1)
	#material.set("shader_parameter/texture_1", new_background)

func animate_shader_param(param_name: String, duration: float) -> void:
	var time := 0.0
	while time < duration:
		var t := time / duration
		material.set("shader_parameter/" + param_name, t)
		await get_tree().process_frame
		time += get_process_delta_time()
	
	material.set("shader_parameter/" + param_name, 1.0)
