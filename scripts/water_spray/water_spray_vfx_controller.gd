extends Sprite2D
## Attach to the WaterSpray Sprite2D. Use these methods to modulate the spray shader from script.
## Or from another node: $Character/WaterSpray.set_density(0.5)

func _get_shader_material() -> ShaderMaterial:
	var mat = material
	if mat is ShaderMaterial:
		return mat as ShaderMaterial
	push_error("WaterSpray: material is not a ShaderMaterial")
	return null

## 0 = off, 1+ = visible (default ~1.2)
func set_density(value: float) -> void:
	var m := _get_shader_material()
	if m: m.set_shader_parameter("density", value)

## How wide/soft the cone is (e.g. 0.1 = narrow, 2.5 = wide)
func set_cone_softness(value: float) -> void:
	var m := _get_shader_material()
	if m: m.set_shader_parameter("cone_softness", value)

## Center of spray 0–1 (0.5 = middle)
func set_cone_center(value: float) -> void:
	var m := _get_shader_material()
	if m: m.set_shader_parameter("cone_center", value)

## Mist grain size (higher = finer)
func set_mist_scale(value: float) -> void:
	var m := _get_shader_material()
	if m: m.set_shader_parameter("mist_scale", value)

## How visible the mist is (e.g. 0.2–0.5)
func set_mist_strength(value: float) -> void:
	var m := _get_shader_material()
	if m: m.set_shader_parameter("mist_strength", value)

func get_mist_strength() -> float:
	var m := _get_shader_material()
	if m: return m.get_shader_parameter("mist_strength")
	return 0.0

## Mist movement (e.g. Vector2(0, 2) for vertical)
func set_scroll(value: Vector2) -> void:
	var m := _get_shader_material()
	if m: m.set_shader_parameter("scroll", value)

## Fade toward far end 0–1
func set_falloff(value: float) -> void:
	var m := _get_shader_material()
	if m: m.set_shader_parameter("falloff", value)

## Use texture noise (true/false)
func set_use_noise_texture(value: bool) -> void:
	var m := _get_shader_material()
	if m: m.set_shader_parameter("use_noise_texture", value)

## Set any shader uniform by name (for advanced use)
func set_shader_param(name: StringName, value: Variant) -> void:
	var m := _get_shader_material()
	if m: m.set_shader_parameter(name, value)
