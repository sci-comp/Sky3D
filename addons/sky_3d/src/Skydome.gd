# Copyright (c) 2023-2024 Cory Petkovsek and Contributors
# Copyright (c) 2021 J. Cuellar

@tool
class_name Skydome
extends Node


# Enums
enum SkyQuality {
	Low, High
}

enum MoonResolution {
	R64, R128, R256, R512, R1024,
}

# Members
var is_scene_built: bool
var sky_mesh: MeshInstance3D
var sky_sphere: SphereMesh
var moon_render: Node
var clouds_cumulus_mesh: MeshInstance3D
var fog_mesh: MeshInstance3D

var sky_material: Material
var moon_material: Material
var clouds_cumulus_material: Material
var fog_material: Material

func __setup_mesh_instance(target: MeshInstance3D, origin: Vector3) -> void:
	target.transform.origin = origin
	target.extra_cull_margin = Sky3DConstants.MAX_EXTRA_CULL_MARGIN
	target.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

func build_scene():
	if is_scene_built:
		return

	# Sky Mesh
	sky_mesh = MeshInstance3D.new()
	sky_mesh.name = Sky3DConstants.SKY_INSTANCE
	sky_sphere = SphereMesh.new()
	sky_mesh.mesh = sky_sphere
	sky_material = ShaderMaterial.new()
	sky_material.shader = Sky3DConstants._pv_sky_shader
	sky_material.set_shader_parameter(Sky3DConstants.NOISE_TEX, Sky3DConstants._stars_field_noise)
	sky_mesh.material_override = sky_material
	__setup_mesh_instance(sky_mesh, Sky3DConstants.DEFAULT_POSITION)
	add_child(sky_mesh)
	
	# Moon Render
	moon_render = Sky3DConstants._moon_render.instantiate()
	moon_render.name = Sky3DConstants.MOON_INSTANCE
	var moon_mesh = moon_render.get_node("MoonTransform/Camera3D/Mesh") as MeshInstance3D
	moon_material = moon_mesh.material_override
	add_child(moon_render)
	
	# Clouds Cumulus Mesh
	clouds_cumulus_mesh = MeshInstance3D.new()
	clouds_cumulus_mesh.name = Sky3DConstants.CLOUDS_C_INSTANCE
	var clouds_cumulus_sphere = SphereMesh.new()
	clouds_cumulus_sphere.radial_segments = 8
	clouds_cumulus_sphere.rings = 8
	clouds_cumulus_mesh.mesh = clouds_cumulus_sphere
	clouds_cumulus_material = ShaderMaterial.new()
	clouds_cumulus_material.shader = Sky3DConstants._clouds_cumulus_shader
	clouds_cumulus_mesh.material_override = clouds_cumulus_material
	__setup_mesh_instance(clouds_cumulus_mesh, Sky3DConstants.DEFAULT_POSITION)
	add_child(clouds_cumulus_mesh)
	
	fog_mesh = MeshInstance3D.new()
	fog_mesh.name = Sky3DConstants.FOG_INSTANCE
	var fog_screen_quad = QuadMesh.new()
	var size: Vector2
	size.x = 2.0
	size.y = 2.0
	fog_screen_quad.size = size
	fog_mesh.mesh = fog_screen_quad
	fog_material = ShaderMaterial.new()
	fog_material.shader = Sky3DConstants._fog_shader
	fog_material.render_priority = 127
	fog_mesh.material_override = fog_material
	__setup_mesh_instance(fog_mesh, Vector3.ZERO)
	add_child(fog_mesh)

	is_scene_built = true
	

# General.
func update_sky_visible():
	if !is_scene_built:
		return
	
	sky_mesh.visible = sky_visible
	
var sky_visible: bool = true: set = set_sky_visible
func set_sky_visible(value: bool) -> void:
	if value == sky_visible:
		return
	
	sky_visible = value 
	update_sky_visible()

func update_dome_radius():
	if !is_scene_built:
		return

	sky_mesh.scale = dome_radius * Vector3.ONE
	clouds_cumulus_mesh.scale = dome_radius * Vector3.ONE

var dome_radius: float = 10.0: set = set_dome_radius
func set_dome_radius(value: float) -> void:
	if value == dome_radius:
		return
	
	dome_radius = value
	update_dome_radius()
		
func update_color_correction_params() -> void:
	if !is_scene_built:
		return

	var p: Vector2
	p.x = tonemap_level
	p.y = exposure
	sky_material.set_shader_parameter(Sky3DConstants.COLOR_CORRECTION_P, p)
	fog_material.set_shader_parameter(Sky3DConstants.COLOR_CORRECTION_P, p)

var tonemap_level: float = 0.0: set = set_tonemap_level
func set_tonemap_level(value: float) -> void:
	if value == tonemap_level:
		return
	
	tonemap_level = value
	update_color_correction_params()

var exposure: float = 1.3: set = set_exposure
func set_exposure(value: float) -> void:
	if value == exposure:
		return
	
	exposure = value
	update_color_correction_params()
		
func update_ground_color():
	if !is_scene_built:
		return

	sky_material.set_shader_parameter(Sky3DConstants.GROUND_COLOR_P, ground_color)

var ground_color:= Color(0.3, 0.3, 0.3, 1.0): set = set_ground_color
func set_ground_color(value: Color) -> void:
	if value == ground_color:
		return

	ground_color = value
	update_ground_color()
		
func update_sky_layers():
	if !is_scene_built:
		return

	sky_mesh.layers = sky_layers
	clouds_cumulus_mesh.layers = sky_layers

var sky_layers: int = 4: set = set_sky_layers
func set_sky_layers(value: int) -> void:
	if sky_layers == value:
		return
	
	sky_layers = value
	update_sky_layers()
		
func update_sky_render_priority() -> void:
	if !is_scene_built:
		return

	sky_material.render_priority = sky_render_priority
	clouds_cumulus_material.render_priority = sky_render_priority + 1

var sky_render_priority: int = -128: set = set_sky_render_priority
func set_sky_render_priority(value: int) -> void:
	if value == sky_render_priority:
		return
	
	sky_render_priority = value
	update_sky_render_priority()

func update_horizon_level() -> void:
	if !is_scene_built:
		return

	sky_material.set_shader_parameter(Sky3DConstants.HORIZON_LEVEL, horizon_level)
	
var horizon_level: float = 0.0: set = set_horizon_level
func set_horizon_level(value: float) -> void:
	if value == horizon_level:
		return

	horizon_level = value
	update_horizon_level()

# Sun Coords.
var sun_azimuth: float = 0.0: set = set_sun_azimuth
func set_sun_azimuth(value: float) -> void:
	if value == sun_azimuth:
		return
	
	sun_azimuth = value
	update_sun_coords()

var sun_altitude: float = -27.387: set = set_sun_altitude
func set_sun_altitude(value: float) -> void:
	if value == sun_altitude:
		return
	
	sun_altitude = value
	update_sun_coords()

var __finish_set_sun_pos: bool = false

var __sun_transform:= Transform3D()
func get_sun_transform() -> Transform3D:
	return __sun_transform

func sun_direction() -> Vector3:
	return __sun_transform.origin - Sky3DConstants.DEFAULT_POSITION

signal sun_direction_changed(value)
signal sun_transform_changed(value)

# Moon Coords.
var moon_azimuth: float = 5.0: set = set_moon_azimuth
func set_moon_azimuth(value: float) -> void:
	if value == moon_azimuth:
		return
	
	moon_azimuth = value
	update_moon_coords()

var moon_altitude: float = -80.0: set = set_moon_altitude
func set_moon_altitude(value: float) -> void:
	if value == moon_altitude:
		return
	
	moon_altitude = value
	update_moon_coords()

var __finish_set_moon_pos = false

var __moon_transform:= Transform3D()
func get_moon_transform() -> Transform3D:
	return __moon_transform

func moon_direction() -> Vector3:
	return __moon_transform.origin - Sky3DConstants.DEFAULT_POSITION

signal moon_direction_changed(value)
signal moon_transform_changed(value)

## Atmosphere.
func update_atm_quality() -> void:
	if !is_scene_built:
		return

	if atm_quality == SkyQuality.Low:
		sky_material.shader = Sky3DConstants._sky_shader
		sky_sphere.radial_segments = 16
		sky_sphere.rings = 8
	else:
		sky_material.shader = Sky3DConstants._pv_sky_shader
		sky_sphere.radial_segments = 64
		sky_sphere.rings = 64

var atm_quality: int = 1: set = set_atm_quality
func set_atm_quality(value: int) -> void:
	if value == atm_quality:
		return

	atm_quality = value
	update_atm_quality()

var atm_wavelenghts:= Vector3(680.0, 550.0, 440.0): set = set_atm_wavelenghts
func set_atm_wavelenghts(value : Vector3) -> void:
	if value == atm_wavelenghts:
		return
	
	atm_wavelenghts = value
	update_beta_ray()
	
func update_atm_darkness() -> void:
	if !is_scene_built:
		return
	
	sky_material.set_shader_parameter(Sky3DConstants.ATM_DARKNESS_P, atm_darkness)
	fog_material.set_shader_parameter(Sky3DConstants.ATM_DARKNESS_P, atm_darkness)

var atm_darkness: float = 0.5: set = set_atm_darkness
func set_atm_darkness(value: float) -> void:
	if value == atm_darkness:
		return
	
	atm_darkness = value
	update_atm_darkness()

func update_atm_sun_intensity() -> void:
	if !is_scene_built:
		return

	sky_material.set_shader_parameter(Sky3DConstants.ATM_SUN_INTENSITY_P, atm_sun_intensity)
	fog_material.set_shader_parameter(Sky3DConstants.ATM_SUN_INTENSITY_P, atm_sun_intensity)

var atm_sun_intensity: float = 30.0: set = set_atm_sun_intensity
func set_atm_sun_intensity(value: float) -> void:
	if value == atm_sun_intensity:
		return

	atm_sun_intensity = value
	update_atm_sun_intensity()

func update_atm_day_tint() -> void:
	if !is_scene_built:
		return

	sky_material.set_shader_parameter(Sky3DConstants.ATM_DAY_TINT_P, atm_day_tint)
	fog_material.set_shader_parameter(Sky3DConstants.ATM_DAY_TINT_P, atm_day_tint)


var atm_day_tint:= Color(0.807843, 0.909804, 1.0): set = set_atm_day_tint
func set_atm_day_tint(value: Color) -> void:
	if value == atm_day_tint:
		return
	
	atm_day_tint = value
	update_atm_day_tint()

func update_atm_horizon_light_tint() -> void:
	if !is_scene_built:
		return

	sky_material.set_shader_parameter(Sky3DConstants.ATM_HORIZON_LIGHT_TINT_P, atm_horizon_light_tint)
	fog_material.set_shader_parameter(Sky3DConstants.ATM_HORIZON_LIGHT_TINT_P, atm_horizon_light_tint)

var atm_horizon_light_tint:= Color(0.980392, 0.635294, 0.462745, 1.0): set = set_atm_horizon_light_tint
func set_atm_horizon_light_tint(value: Color) -> void:
	if value == atm_horizon_light_tint:
		return

	atm_horizon_light_tint = value
	update_atm_horizon_light_tint()

var atm_enable_moon_scatter_mode: bool = false: set = set_atm_enable_moon_scatter_mode
func set_atm_enable_moon_scatter_mode(value: bool) -> void:
	if value == atm_enable_moon_scatter_mode:
		return

	atm_enable_moon_scatter_mode = value
	update_night_intensity()

var atm_night_tint:= Color(0.168627, 0.2, 0.25098, 1.0): set = set_atm_night_tint
func set_atm_night_tint(value: Color) -> void:
	if value == atm_night_tint:
		return

	atm_night_tint = value
	update_night_intensity()

func update_atm_level_params():
	if !is_scene_built:
		return

	sky_material.set_shader_parameter(Sky3DConstants.ATM_LEVEL_PARAMS_P, atm_level_params)
	fog_material.set_shader_parameter(Sky3DConstants.ATM_LEVEL_PARAMS_P, atm_level_params + fog_atm_level_params_offset)

var atm_level_params:= Vector3(1.0, 0.0, 0.0): set = set_atm_level_params
func set_atm_level_params(value: Vector3) -> void:
	if value == atm_level_params:
		return
	
	atm_level_params = value
	update_atm_level_params()

func update_atm_thickness():
	if !is_scene_built:
		return

	sky_material.set_shader_parameter(Sky3DConstants.ATM_THICKNESS_P, atm_thickness)
	fog_material.set_shader_parameter(Sky3DConstants.ATM_THICKNESS_P, atm_thickness)

var atm_thickness: float = 0.7: set = set_atm_thickness
func set_atm_thickness(value: float) -> void:
	if value == atm_thickness:
		return

	atm_thickness = value
	update_atm_thickness()

var atm_mie: float = 0.07: set = set_atm_mie
func set_atm_mie(value: float) -> void:
	if value == atm_mie:
		return

	atm_mie = value
	update_beta_mie()

var atm_turbidity: float = 0.001: set = set_atm_turbidity
func set_atm_turbidity(value: float) -> void:
	if value == atm_turbidity:
		return

	atm_turbidity = value
	update_beta_mie()

func update_atm_sun_mie_tint() -> void:
	if !is_scene_built:
		return

	sky_material.set_shader_parameter(Sky3DConstants.ATM_SUN_MIE_TINT_P, atm_sun_mie_tint)
	fog_material.set_shader_parameter(Sky3DConstants.ATM_SUN_MIE_TINT_P, atm_sun_mie_tint)
	clouds_cumulus_material.set_shader_parameter(Sky3DConstants.ATM_SUN_MIE_TINT_P, atm_sun_mie_tint)

var atm_sun_mie_tint:= Color(1.0, 1.0, 1.0, 1.0): set = set_atm_sun_mie_tint
func set_atm_sun_mie_tint(value: Color) -> void:
	if value == atm_sun_mie_tint:
		return

	atm_sun_mie_tint = value
	update_atm_sun_mie_tint()

func update_atm_sun_mie_intensity() -> void:
	if !is_scene_built:
		return

	sky_material.set_shader_parameter(Sky3DConstants.ATM_SUN_MIE_INTENSITY_P, atm_sun_mie_intensity)
	fog_material.set_shader_parameter(Sky3DConstants.ATM_SUN_MIE_INTENSITY_P, atm_sun_mie_intensity)

var atm_sun_mie_intensity: float = 1.0: set = set_atm_sun_mie_intensity
func set_atm_sun_mie_intensity(value: float) -> void:
	if value == atm_sun_mie_intensity:
		return

	atm_sun_mie_intensity = value
	update_atm_sun_mie_intensity()

func update_atm_sun_mie_anisotropy() -> void:
	if !is_scene_built:
		return

	var partial = ScatterLib.get_partial_mie_phase(atm_sun_mie_anisotropy)
	sky_material.set_shader_parameter(Sky3DConstants.ATM_SUN_PARTIAL_MIE_PHASE_P, partial)
	fog_material.set_shader_parameter(Sky3DConstants.ATM_SUN_PARTIAL_MIE_PHASE_P, partial)

var atm_sun_mie_anisotropy: float = 0.8: set = set_atm_sun_mie_anisotropy
func set_atm_sun_mie_anisotropy(value: float) -> void:
	if value == atm_sun_mie_anisotropy:
		return

	atm_sun_mie_anisotropy = value
	update_atm_sun_mie_anisotropy()
	
func update_atm_moon_mie_tint() -> void:
	if !is_scene_built:
		return

	sky_material.set_shader_parameter(Sky3DConstants.ATM_MOON_MIE_TINT_P, atm_moon_mie_tint)
	fog_material.set_shader_parameter(Sky3DConstants.ATM_MOON_MIE_TINT_P, atm_moon_mie_tint)
	clouds_cumulus_material.set_shader_parameter(Sky3DConstants.ATM_MOON_MIE_TINT_P, atm_moon_mie_tint)

var atm_moon_mie_tint:= Color(0.137255, 0.184314, 0.292196): set = set_atm_moon_mie_tint
func set_atm_moon_mie_tint(value: Color) -> void:
	if value == atm_moon_mie_tint:
		return
	
	atm_moon_mie_tint = value
	update_atm_moon_mie_tint()
	
func update_atm_moon_mie_intensity() -> void:
	if !is_scene_built:
		return

	sky_material.set_shader_parameter(Sky3DConstants.ATM_MOON_MIE_INTENSITY_P, atm_moon_mie_intensity * atm_moon_phases_mult())
	fog_material.set_shader_parameter(Sky3DConstants.ATM_MOON_MIE_INTENSITY_P, atm_moon_mie_intensity * atm_moon_phases_mult())

var atm_moon_mie_intensity: float = 0.7: set = set_atm_moon_mie_intensity
func set_atm_moon_mie_intensity(value: float) -> void:
	if value == atm_moon_mie_intensity:
		return
	
	atm_moon_mie_intensity = value
	update_atm_sun_mie_intensity()

func update_atm_moon_mie_anisotropy() -> void:
	if !is_scene_built:
		return

	var partial = ScatterLib.get_partial_mie_phase(atm_moon_mie_anisotropy)
	sky_material.set_shader_parameter(Sky3DConstants.ATM_MOON_PARTIAL_MIE_PHASE_P, partial)
	fog_material.set_shader_parameter(Sky3DConstants.ATM_MOON_PARTIAL_MIE_PHASE_P, partial)

var atm_moon_mie_anisotropy: float = 0.8: set = set_atm_moon_mie_anisotropy
func set_atm_moon_mie_anisotropy(value: float) -> void:
	if value == atm_moon_mie_anisotropy:
		return
	
	atm_moon_mie_anisotropy = value
	update_atm_moon_mie_anisotropy()

func atm_moon_phases_mult() -> float:
	if not atm_enable_moon_scatter_mode:
		return atm_night_intensity()
	return TOD_Math.saturate(-sun_direction().dot(moon_direction()) + 0.60)

func atm_night_intensity() -> float:
	if not atm_enable_moon_scatter_mode:
		return TOD_Math.saturate(-sun_direction().y + 0.30)
	return TOD_Math.saturate(moon_direction().y) * atm_moon_phases_mult()

func fog_atm_night_intensity() -> float:
	if not atm_enable_moon_scatter_mode:
		return TOD_Math.saturate(-sun_direction().y + 0.70)
	return TOD_Math.saturate(-sun_direction().y) * atm_moon_phases_mult()

## Atmospheric fog.
func update_fog_visible() -> void:
	if !is_scene_built:
		return

	fog_mesh.visible = fog_visible

var fog_visible: bool = true: set = set_fog_visible
func set_fog_visible(value: bool) -> void:
	if value == fog_visible:
		return
	
	fog_visible = value
	update_fog_visible()

func update_fog_atm_level_params_offset() -> void:
	if !is_scene_built:
		return

	fog_material.set_shader_parameter(Sky3DConstants.ATM_LEVEL_PARAMS_P, atm_level_params + fog_atm_level_params_offset)

var fog_atm_level_params_offset:= Vector3(0.0, 0.0, -1.0): set = set_fog_atm_level_params_offset
func set_fog_atm_level_params_offset(value: Vector3) -> void:
	if value == fog_atm_level_params_offset:
		return
	
	fog_atm_level_params_offset = value
	update_fog_atm_level_params_offset()

func update_fog_density() -> void:
	if !is_scene_built:
		return

	fog_material.set_shader_parameter(Sky3DConstants.ATM_FOG_DENSITY_P, fog_density)

var fog_density: float = 0.00015: set = set_fog_density
func set_fog_density(value: float) -> void:
	if value == fog_density:
		return
	
	fog_density = value
	update_fog_density()

func update_fog_start() -> void:
	if !is_scene_built:
		return

	fog_material.set_shader_parameter(Sky3DConstants.ATM_FOG_START, fog_start)

var fog_start: float = 0.0: set = set_fog_start
func set_fog_start(value: float) -> void:
	if value == fog_start:
		return
	
	fog_start = value
	update_fog_start()

func update_fog_end() -> void:
	if !is_scene_built:
		return

	fog_material.set_shader_parameter(Sky3DConstants.ATM_FOG_END, fog_end)

var fog_end: float = 1000: set = set_fog_end
func set_fog_end(value: float) -> void:
	if value == fog_end:
		return
	
	fog_end = value
	update_fog_end()

func update_fog_rayleigh_depth() -> void:
	if !is_scene_built:
		return

	fog_material.set_shader_parameter(Sky3DConstants.ATM_FOG_RAYLEIGH_DEPTH_P, fog_rayleigh_depth)

var fog_rayleigh_depth: float = 0.116: set = set_fog_rayleigh_depth
func set_fog_rayleigh_depth(value: float) -> void:
	if value == fog_rayleigh_depth:
		return
	
	fog_rayleigh_depth = value
	update_fog_rayleigh_depth()

func update_fog_mie_depth() -> void:
	if !is_scene_built:
		return

	fog_material.set_shader_parameter(Sky3DConstants.ATM_FOG_MIE_DEPTH_P, fog_mie_depth)

var fog_mie_depth: float = 0.0001: set = set_fog_mie_depth
func set_fog_mie_depth(value: float) -> void:
	if value == fog_mie_depth:
		return
	
	fog_mie_depth = value
	update_fog_mie_depth()

func update_fog_falloff() -> void:
	if !is_scene_built:
		return

	fog_material.set_shader_parameter(Sky3DConstants.ATM_FOG_FALLOFF, fog_falloff)

var fog_falloff: float = 3.0: set = set_fog_falloff
func set_fog_falloff(value: float) -> void:
	if value == fog_falloff:
		return
	
	fog_falloff = value
	update_fog_falloff()

func update_fog_layers() -> void:
	if !is_scene_built:
		return

	fog_mesh.layers = fog_layers

var fog_layers: int = 524288: set = set_fog_layers
func set_fog_layers(value: int) -> void:
	if value == fog_layers:
		return
	
	fog_layers = value
	update_fog_layers()

func update_fog_render_priority() -> void:
	if !is_scene_built:
		return

	fog_material.render_priority = fog_render_priority

var fog_render_priority: int = 123: set = set_fog_render_priority
func set_fog_render_priority(value: int) -> void:
	if value == fog_render_priority:
		return
	
	fog_render_priority = value
	update_fog_render_priority()

## Near space.
func update_sun_disk_color() -> void:
	if !is_scene_built:
		return

	sky_material.set_shader_parameter(Sky3DConstants.SUN_DISK_COLOR_P, sun_disk_color)

var sun_disk_color:= Color(0.996094, 0.541334, 0.140076): set = set_sun_disk_color
func set_sun_disk_color(value: Color) -> void:
	if value == sun_disk_color:
		return
	
	sun_disk_color = value
	update_sun_disk_color()

func update_sun_disk_intensity() -> void:
	if !is_scene_built:
		return

	sky_material.set_shader_parameter(Sky3DConstants.SUN_DISK_INTENSITY_P, sun_disk_intensity)

var sun_disk_intensity: float = 2.0: set = set_sun_disk_intensity
func set_sun_disk_intensity(value: float) -> void:
	if value == sun_disk_intensity:
		return
	
	sun_disk_intensity = value
	update_sun_disk_intensity()

func update_sun_disk_size() -> void:
	if !is_scene_built:
		return

	sky_material.set_shader_parameter(Sky3DConstants.SUN_DISK_SIZE_P, sun_disk_size)

var sun_disk_size: float = 0.015: set = set_sun_disk_size
func set_sun_disk_size(value: float) -> void:
	if value == sun_disk_size:
		return
	
	sun_disk_size = value
	update_sun_disk_size()

func update_moon_color() -> void:
	if !is_scene_built:
		return

	sky_material.set_shader_parameter(Sky3DConstants.MOON_COLOR_P, moon_color)

var moon_color:= Color.WHITE: set = set_moon_color
func set_moon_color(value: Color) -> void:
	if value == moon_color:
		return
	
	moon_color = value
	update_moon_color()

func update_moon_size() -> void:
	if !is_scene_built:
		return

	sky_material.set_shader_parameter(Sky3DConstants.MOON_SIZE_P, moon_size)

var moon_size: float = 0.07: set = set_moon_size
func set_moon_size(value: float) -> void:
	if value == moon_size:
		return
	
	moon_size = value
	update_moon_size()
	
var enable_set_moon_texture = false: set = set_enable_set_moon_texture
func set_enable_set_moon_texture(value: bool) -> void:
	enable_set_moon_texture = value
	if not value:
		set_moon_texture(Sky3DConstants._moon_texture)
	
	notify_property_list_changed()

func update_moon_texture() -> void:
	if !is_scene_built:
		return

	moon_material.set_shader_parameter(Sky3DConstants.TEXTURE_P, moon_texture)

var moon_texture: Texture2D = null: set = set_moon_texture
func set_moon_texture(value: Texture2D) -> void:
	if value == moon_texture:
		return
	
	moon_texture = value
	update_moon_texture()

func update_moon_resolution() -> void:
	if !is_scene_built:
		return

	match moon_resolution:
		MoonResolution.R64: moon_render.size = Vector2.ONE * 64
		MoonResolution.R128: moon_render.size = Vector2.ONE * 128
		MoonResolution.R256: moon_render.size = Vector2.ONE * 256
		MoonResolution.R512: moon_render.size = Vector2.ONE * 512
		MoonResolution.R1024: moon_render.size = Vector2.ONE * 1024
	
	sky_material.set_shader_parameter(Sky3DConstants.MOON_TEXTURE_P, moon_render.get_texture())

var moon_resolution: int = MoonResolution.R256: set = set_moon_resolution
func set_moon_resolution(value: int) -> void:
	if value == moon_resolution:
		return
	
	moon_resolution = value
	update_moon_resolution()

## Near space lights.
func update_sun_light_color() -> void:
	if __sun_light_node == null:
		return

	var sun_light_altitude_mult: float = TOD_Math.saturate(sun_direction().y * 2)
	__sun_light_node.light_color = TOD_Math.plerp_color(sun_horizon_light_color, sun_light_color, sun_light_altitude_mult)

var sun_light_color:= Color(0.984314, 0.843137, 0.788235): set = set_sun_light_color
func set_sun_light_color(value: Color) -> void:
	if value == sun_light_color:
		return
	
	sun_light_color = value
	update_sun_light_color()

var sun_horizon_light_color:= Color(1.0, 0.384314, 0.243137, 1.0): set = set_sun_horizon_light_color
func set_sun_horizon_light_color(value: Color) -> void:
	if value == sun_horizon_light_color:
		return
	
	sun_horizon_light_color = value
	update_sun_light_color()

var sun_light_energy: float = 1.0: set = set_sun_light_energy
func set_sun_light_energy(value: float) -> void:
	if value == sun_light_energy:
		return
	
	sun_light_energy = value
	update_sun_light_energy()
	
var __sun_light_node: DirectionalLight3D = null
func update_sun_light_path() -> void:
	if sun_light_path != null:
		__sun_light_node = get_node_or_null(sun_light_path) as DirectionalLight3D
	else:
		__sun_light_node = null

var sun_light_path: NodePath: set = set_sun_light_path
func set_sun_light_path(value: NodePath) -> void:
	sun_light_path = value

	update_sun_light_path()
	update_sun_coords()

func update_moon_light_color() -> void:
	if __moon_light_node == null:
		return
		
	__moon_light_node.light_color = moon_light_color

var moon_light_color:= Color(0.572549, 0.776471, 0.956863, 1.0): set = set_moon_light_color
func set_moon_light_color(value: Color) -> void:
	if value == moon_light_color:
		return
	
	moon_light_color = value
	update_moon_light_color()

var moon_light_energy: float = 0.3: set = set_moon_light_energy
func set_moon_light_energy(value: float) -> void:
	moon_light_energy = value
	update_moon_light_energy()
	
func update_moon_light_path() -> void:
	if moon_light_path != null:
		__moon_light_node = get_node_or_null(moon_light_path) as DirectionalLight3D
	else:
		__moon_light_node = null

var moon_light_path: NodePath: set = set_moon_light_path
func set_moon_light_path(value: NodePath) -> void:
	moon_light_path = value
	update_moon_light_path()
	update_moon_coords()

var __moon_light_node: DirectionalLight3D
var __moon_light_altitude_mult: float = 0.0

## Deep space.
func update_deep_space_basis() -> void:
	if !is_scene_built:
		return

	sky_material.set_shader_parameter(Sky3DConstants.DEEP_SPACE_MATRIX_P, __deep_space_basis)

var deep_space_euler:= Vector3(-0.752, 2.56, 0.0): set = set_deep_space_euler
func set_deep_space_euler(value: Vector3) -> void:
	deep_space_euler = value
	__deep_space_basis = Basis.from_euler(value)
	update_deep_space_basis()
	var quat: Quaternion = __deep_space_basis.get_rotation_quaternion()
	if deep_space_quat.angle_to(quat) < 0.01:
		return
	deep_space_quat = quat

var deep_space_quat:= Quaternion.IDENTITY: set = set_deep_space_quat
func set_deep_space_quat(value: Quaternion) -> void:
	deep_space_quat = value
	__deep_space_basis = Basis(value)
	update_deep_space_basis()
	var euler: Vector3 = __deep_space_basis.get_euler()
	if deep_space_euler.angle_to(euler) < 0.01:
		return
	deep_space_euler = euler

var __deep_space_basis: Basis

func update_background_color() -> void:
	if !is_scene_built:
		return

	sky_material.set_shader_parameter(Sky3DConstants.BG_COL_P, background_color)

var background_color:= Color(0.709804, 0.709804, 0.709804, 0.854902): set = set_background_color
func set_background_color(value: Color) -> void:
	if value == background_color:
		return
	
	background_color = value
	update_background_color()

var set_background_texture: bool = false: set = set_set_background_texture
func set_set_background_texture(value: bool) -> void:
	set_background_texture = value
	if not value:
		_set_background_texture(Sky3DConstants._background_texture)
	
	notify_property_list_changed()

func update_background_texture() -> void:
	if !is_scene_built:
		return

	sky_material.set_shader_parameter(Sky3DConstants.BG_TEXTURE_P, background_texture)

var background_texture: Texture2D = null: set = _set_background_texture
func _set_background_texture(value: Texture2D) -> void:
	if value == background_texture:
		return
	
	background_texture = value
	update_background_texture()

func update_stars_field_color() -> void:
	if !is_scene_built:
		return

	sky_material.set_shader_parameter(Sky3DConstants.STARS_COLOR_P, stars_field_color)

var stars_field_color:= Color.WHITE: set = set_stars_field_color
func set_stars_field_color(value: Color) -> void:
	if value == stars_field_color:
		return
	
	stars_field_color = value
	update_stars_field_color()

var set_stars_field_texture: bool = false: set = set_set_stars_field_texture
func set_set_stars_field_texture(value: bool) -> void:
	set_stars_field_texture = value
	if not value:
		_set_stars_field_texture(Sky3DConstants._stars_field_texture)
	
	notify_property_list_changed()

func update_stars_field_texture() -> void:
	if !is_scene_built:
		return

	sky_material.set_shader_parameter(Sky3DConstants.STARS_TEXTURE_P, stars_field_texture)

var stars_field_texture: Texture2D = null: set = _set_stars_field_texture
func _set_stars_field_texture(value: Texture2D) -> void:
	if value == stars_field_texture:
		return

	stars_field_texture = value
	update_stars_field_texture()

func update_stars_scintillation() -> void:
	if !is_scene_built:
		return

	sky_material.set_shader_parameter(Sky3DConstants.STARS_SC_P, stars_scintillation)

var stars_scintillation: float = 0.75: set = set_stars_scintillation
func set_stars_scintillation(value: float) -> void:
	if value == stars_scintillation:
		return

	stars_scintillation = value
	update_stars_scintillation()

func update_stars_scintillation_speed() -> void:
	if !is_scene_built:
		return

	sky_material.set_shader_parameter(Sky3DConstants.STARS_SC_SPEED_P, stars_scintillation_speed)

var stars_scintillation_speed: float = 0.01: set = set_stars_scintillation_speed
func set_stars_scintillation_speed(value: float) -> void:
	if value == stars_scintillation_speed:
		return
	
	stars_scintillation_speed = value
	update_stars_scintillation_speed()

func update_clouds_thickness() -> void:
	if !is_scene_built:
		return

	sky_material.set_shader_parameter(Sky3DConstants.CLOUDS_THICKNESS, clouds_thickness)

var clouds_thickness: float = 1.7: set = set_clouds_thickness
func set_clouds_thickness(value: float) -> void:
	if value == clouds_thickness:
		return

	clouds_thickness = value
	update_clouds_thickness()

func update_clouds_coverage() -> void:
	if !is_scene_built:
		return

	sky_material.set_shader_parameter(Sky3DConstants.CLOUDS_COVERAGE, clouds_coverage)

var clouds_coverage: float = 0.5: set = set_clouds_coverage
func set_clouds_coverage(value: float) -> void:
	if value == clouds_coverage:
		return

	clouds_coverage = value
	update_clouds_coverage()

func update_clouds_absorption() -> void:
	if !is_scene_built:
		return

	sky_material.set_shader_parameter(Sky3DConstants.CLOUDS_ABSORPTION, clouds_absorption)

var clouds_absorption: float = 2.0: set = set_clouds_absorption
func set_clouds_absorption(value: float) -> void:
	if value == clouds_absorption:
		return

	clouds_absorption = value
	update_clouds_absorption()

func update_clouds_sky_tint_fade() -> void:
	if !is_scene_built:
		return

	sky_material.set_shader_parameter(Sky3DConstants.CLOUDS_SKY_TINT_FADE, clouds_sky_tint_fade)

var clouds_sky_tint_fade: float = 0.5: set = set_clouds_sky_tint_fade
func set_clouds_sky_tint_fade(value: float) -> void:
	if value == clouds_sky_tint_fade:
		return

	clouds_sky_tint_fade = value
	update_clouds_sky_tint_fade()

func update_clouds_intensity() -> void:
	if !is_scene_built:
		return

	sky_material.set_shader_parameter(Sky3DConstants.CLOUDS_INTENSITY, clouds_intensity)

var clouds_intensity: float = 10.0: set = set_clouds_intensity
func set_clouds_intensity(value: float) -> void:
	if value == clouds_intensity:
		return
	
	clouds_intensity = value
	update_clouds_intensity()

func update_clouds_size() -> void:
	if !is_scene_built:
		return

	sky_material.set_shader_parameter(Sky3DConstants.CLOUDS_SIZE, clouds_size)

var clouds_size: float = 2.0: set = set_clouds_size
func set_clouds_size(value: float) -> void:
	if value == clouds_size:
		return
	
	clouds_size = value
	update_clouds_size()

func update_clouds_uv() -> void:
	if !is_scene_built:
		return

	sky_material.set_shader_parameter(Sky3DConstants.CLOUDS_UV, clouds_uv)

var clouds_uv:= Vector2(0.16, 0.11): set = set_clouds_uv
func set_clouds_uv(value: Vector2) -> void:
	if value == clouds_uv:
		return

	clouds_uv = value
	update_clouds_uv()

func update_clouds_offset() -> void:
	if !is_scene_built:
		return

	sky_material.set_shader_parameter(Sky3DConstants.CLOUDS_OFFSET, clouds_offset)

var clouds_offset:= Vector2(0.21, 0.175): set = set_clouds_offset
func set_clouds_offset(value: Vector2) -> void:
	if value == clouds_offset:
		return
	
	clouds_offset = value
	update_clouds_offset()

func update_clouds_offset_speed() -> void:
	if !is_scene_built:
		return

	sky_material.set_shader_parameter(Sky3DConstants.CLOUDS_OFFSET_SPEED, clouds_offset_speed)

var clouds_offset_speed: float = 0.01: set = set_clouds_offset_speed
func set_clouds_offset_speed(value: float) -> void:
	if value == clouds_offset_speed:
		return
	
	clouds_offset_speed = value
	update_clouds_offset_speed()

var set_clouds_texture: bool = false: set = set_set_clouds_texture
func set_set_clouds_texture(value: bool) -> void:
	set_clouds_texture = value
	if not value:
		_set_clouds_texture(Sky3DConstants._clouds_texture)
	
	notify_property_list_changed()

func update_clouds_texture() -> void:
	if !is_scene_built:
		return

	sky_material.set_shader_parameter(Sky3DConstants.CLOUDS_TEXTURE, clouds_texture)

var clouds_texture: Texture2D = null: set = _set_clouds_texture
func _set_clouds_texture(value: Texture2D) -> void:
	if value == clouds_texture:
		return

	clouds_texture = value
	update_clouds_texture()

func update_clouds_cumulus_visible() -> void:
	if !is_scene_built:
		return

	clouds_cumulus_mesh.visible = clouds_cumulus_visible

var clouds_cumulus_visible: bool = true: set = set_clouds_cumulus_visible
func set_clouds_cumulus_visible(value: bool) -> void:
	if value == clouds_cumulus_visible:
		return
	
	clouds_cumulus_visible = value
	update_clouds_cumulus_visible()

func update_clouds_cumulus_day_color() -> void:
	if !is_scene_built:
		return

	clouds_cumulus_material.set_shader_parameter(Sky3DConstants.CLOUDS_DAY_COLOR, clouds_cumulus_day_color)

var clouds_cumulus_day_color:= Color(0.823529, 0.87451, 1.0, 1.0): set = set_clouds_cumulus_day_color
func set_clouds_cumulus_day_color(value: Color) -> void:
	if value == clouds_cumulus_day_color:
		return
	
	clouds_cumulus_day_color = value
	update_clouds_cumulus_day_color()

func update_clouds_cumulus_horizon_light_color() -> void:
	if !is_scene_built:
		return

	clouds_cumulus_material.set_shader_parameter(Sky3DConstants.CLOUDS_HORIZON_LIGHT_COLOR, clouds_cumulus_horizon_light_color)

var clouds_cumulus_horizon_light_color:= Color(1.0, 0.333333, 0.152941, 1.0): set = set_clouds_cumulus_horizon_light_color
func set_clouds_cumulus_horizon_light_color(value: Color) -> void:
	if value == clouds_cumulus_horizon_light_color:
		return

	clouds_cumulus_horizon_light_color = value
	update_clouds_cumulus_horizon_light_color()

func update_clouds_cumulus_night_color() -> void:
	if !is_scene_built:
		return

	clouds_cumulus_material.set_shader_parameter(Sky3DConstants.CLOUDS_NIGHT_COLOR, clouds_cumulus_night_color)

var clouds_cumulus_night_color:= Color(0.090196, 0.094118, 0.129412, 1.0): set = set_clouds_cumulus_night_color
func set_clouds_cumulus_night_color(value: Color) -> void:
	if value == clouds_cumulus_night_color:
		return

	clouds_cumulus_night_color = value
	update_clouds_cumulus_night_color()

func update_clouds_cumulus_thickness() -> void:
	if !is_scene_built:
		return

	clouds_cumulus_material.set_shader_parameter(Sky3DConstants.CLOUDS_THICKNESS, clouds_cumulus_thickness)

var clouds_cumulus_thickness: float = 0.0243: set = set_clouds_cumulus_thickness
func set_clouds_cumulus_thickness(value: float) -> void:
	if value == clouds_cumulus_thickness:
		return

	clouds_cumulus_thickness = value
	update_clouds_cumulus_thickness()

func update_clouds_cumulus_coverage() -> void:
	if !is_scene_built:
		return

	clouds_cumulus_material.set_shader_parameter(Sky3DConstants.CLOUDS_COVERAGE, clouds_cumulus_coverage)

var clouds_cumulus_coverage: float = 0.55: set = set_clouds_cumulus_coverage
func set_clouds_cumulus_coverage(value: float) -> void:
	if value == clouds_cumulus_coverage:
		return

	clouds_cumulus_coverage = value
	update_clouds_cumulus_coverage()

func update_clouds_cumulus_absorption() -> void:
	if !is_scene_built:
		return

	clouds_cumulus_material.set_shader_parameter(Sky3DConstants.CLOUDS_ABSORPTION, clouds_cumulus_absorption)

var clouds_cumulus_absorption: float = 2.0: set = set_clouds_cumulus_absorption
func set_clouds_cumulus_absorption(value: float) -> void:
	if value == clouds_cumulus_absorption:
		return

	clouds_cumulus_absorption = value
	update_clouds_cumulus_absorption()

func update_clouds_cumulus_noise_freq() -> void:
	if !is_scene_built:
		return

	clouds_cumulus_material.set_shader_parameter(Sky3DConstants.CLOUDS_NOISE_FREQ, clouds_cumulus_noise_freq)

var clouds_cumulus_noise_freq: float = 2.7: set = set_clouds_cumulus_noise_freq
func set_clouds_cumulus_noise_freq(value: float) -> void:
	if value == clouds_cumulus_noise_freq:
		return

	clouds_cumulus_noise_freq = value
	update_clouds_cumulus_noise_freq()

func update_clouds_cumulus_intensity() -> void:
	if !is_scene_built:
		return

	clouds_cumulus_material.set_shader_parameter(Sky3DConstants.CLOUDS_INTENSITY, clouds_cumulus_intensity)

var clouds_cumulus_intensity: float = 1.0: set = set_clouds_cumulus_intensity
func set_clouds_cumulus_intensity(value: float) -> void:
	if value == clouds_cumulus_intensity:
		return

	clouds_cumulus_intensity = value
	update_clouds_cumulus_intensity()

func update_clouds_cumulus_mie_intensity() -> void:
	if !is_scene_built:
		return

	clouds_cumulus_material.set_shader_parameter(Sky3DConstants.CLOUDS_MIE_INTENSITY, clouds_cumulus_mie_intensity)

var clouds_cumulus_mie_intensity: float = 1.0: set = set_clouds_cumulus_mie_intensity
func set_clouds_cumulus_mie_intensity(value: float) -> void:
	if value == clouds_cumulus_mie_intensity:
		return

	clouds_cumulus_mie_intensity = value
	update_clouds_cumulus_mie_intensity()

func update_clouds_cumulus_mie_anisotropy() -> void:
	if !is_scene_built:
		return

	var partial = ScatterLib.get_partial_mie_phase(clouds_cumulus_mie_anisotropy)
	clouds_cumulus_material.set_shader_parameter(Sky3DConstants.CLOUDS_PARTIAL_MIE_PHASE, partial)

var clouds_cumulus_mie_anisotropy: float = 0.206: set = set_clouds_cumulus_mie_anisotropy
func set_clouds_cumulus_mie_anisotropy(value: float) -> void:
	if value == clouds_cumulus_mie_anisotropy:
		return

	clouds_cumulus_mie_anisotropy = value
	update_clouds_cumulus_mie_anisotropy()

func update_clouds_cumulus_size() -> void:
	if !is_scene_built:
		return

	clouds_cumulus_material.set_shader_parameter(Sky3DConstants.CLOUDS_SIZE, clouds_cumulus_size)

var clouds_cumulus_size: float = 0.5: set = set_clouds_cumulus_size
func set_clouds_cumulus_size(value: float) -> void:
	if value == clouds_cumulus_size:
		return

	clouds_cumulus_size = value
	update_clouds_cumulus_size()

func update_clouds_cumulus_offset() -> void:
	if !is_scene_built:
		return

	clouds_cumulus_material.set_shader_parameter(Sky3DConstants.CLOUDS_OFFSET, clouds_cumulus_offset)

var clouds_cumulus_offset:= Vector3(0.64, 0.522, 0.128): set = set_clouds_cumulus_offset
func set_clouds_cumulus_offset(value: Vector3) -> void:
	if value == clouds_cumulus_offset:
		return

	clouds_cumulus_offset = value
	update_clouds_cumulus_offset()

func update_clouds_cumulus_offset_speed() -> void:
	if !is_scene_built:
		return

	clouds_cumulus_material.set_shader_parameter(Sky3DConstants.CLOUDS_OFFSET_SPEED, clouds_cumulus_offset_speed)

var clouds_cumulus_offset_speed: float = 0.005: set = set_clouds_cumulus_offset_speed
func set_clouds_cumulus_offset_speed(value: float) -> void:
	if value == clouds_cumulus_offset_speed:
		return

	clouds_cumulus_offset_speed = value
	update_clouds_cumulus_offset_speed()

var set_clouds_cumulus_texture: bool = false: set = set_set_clouds_cumulus_texture
func set_set_clouds_cumulus_texture(value: bool) -> void:
	set_clouds_cumulus_texture = value
	if not value:
		_set_clouds_cumulus_texture(Sky3DConstants._clouds_cumulus_texture)
	
	notify_property_list_changed()

func update_clouds_cumulus_texture() -> void:
	if !is_scene_built:
		return

	clouds_cumulus_material.set_shader_parameter(Sky3DConstants.CLOUDS_TEXTURE, clouds_cumulus_texture)

var clouds_cumulus_texture: Texture2D = null: set = _set_clouds_cumulus_texture
func _set_clouds_cumulus_texture(value: Texture2D) -> void:
	if value == clouds_cumulus_texture:
		return
	
	clouds_cumulus_texture = value
	update_clouds_cumulus_texture()

## Enviro.
var __enable_enviro: bool = false
var enviro: Environment = null: set = set_enviro
func set_enviro(value: Environment) -> void:
	enviro = value
	__enable_enviro = true if enviro != null else false
	
	if __enable_enviro:
		__update_enviro()

## Build in
func _ready() -> void:
	build_scene()

	# Update properties	
	# General
	update_sky_visible()
	update_dome_radius()
	update_color_correction_params()
	update_ground_color()
	update_sky_layers()
	update_sky_render_priority()
	update_horizon_level()
	
	# Coords
	update_sun_coords()
	update_moon_coords()
	
	# Atmosphere
	update_atm_quality()
	update_beta_ray()
	update_atm_darkness()
	update_atm_sun_intensity()
	update_atm_day_tint()
	update_atm_horizon_light_tint()
	update_night_intensity()
	update_atm_level_params()
	update_atm_thickness()
	update_beta_mie()
	update_atm_sun_mie_tint()
	update_atm_sun_mie_intensity()
	update_atm_sun_mie_anisotropy()
	update_atm_moon_mie_tint()
	update_atm_moon_mie_intensity()
	update_atm_moon_mie_anisotropy()
	
	# Fog
	update_fog_visible()
	update_fog_atm_level_params_offset()
	update_fog_density()
	update_fog_start()
	update_fog_end()
	update_fog_rayleigh_depth()
	update_fog_mie_depth()
	update_fog_falloff()
	update_fog_layers()
	update_fog_render_priority()
	
	# Near space
	update_sun_light_path()
	update_sun_disk_color()
	update_sun_disk_intensity()
	update_sun_disk_size()
	update_moon_color()
	update_moon_light_path()
	update_moon_size()
	set_enable_set_moon_texture(enable_set_moon_texture)
	update_moon_texture()
	update_moon_resolution()

	# Near space lighting
	update_sun_light_color()
	update_sun_light_energy()
	update_moon_light_color()
	update_moon_light_energy()
	
	# Deep space
	update_deep_space_basis()
	set_set_background_texture(set_background_texture)
	update_background_color()
	update_background_texture()
	update_stars_field_color()
	set_set_stars_field_texture(set_stars_field_texture)
	update_stars_field_texture()
	update_stars_scintillation()
	update_stars_scintillation_speed()
	
	# Clouds
	update_clouds_thickness()
	update_clouds_coverage()
	update_clouds_absorption()
	update_clouds_sky_tint_fade()
	update_clouds_intensity()
	update_clouds_size()
	update_clouds_uv()
	update_clouds_offset()
	update_clouds_offset_speed()
	set_set_clouds_texture(set_clouds_texture)
	update_clouds_texture()
	
	# Clouds cumulus
	update_clouds_cumulus_visible()
	update_clouds_cumulus_day_color()
	update_clouds_cumulus_horizon_light_color()
	update_clouds_cumulus_night_color()
	update_clouds_cumulus_thickness()
	update_clouds_cumulus_coverage()
	update_clouds_cumulus_absorption()
	update_clouds_cumulus_noise_freq()
	update_clouds_cumulus_intensity()
	update_clouds_cumulus_mie_intensity()
	update_clouds_cumulus_mie_anisotropy()
	update_clouds_cumulus_size()
	update_clouds_cumulus_offset()
	update_clouds_cumulus_offset_speed()
	set_set_clouds_cumulus_texture(set_clouds_cumulus_texture)
	update_clouds_cumulus_texture()
	
	# Environment
	__update_enviro()

## Coords.
func update_sun_coords() -> void:
	if !is_scene_built:
		return
		
	var azimuth: float = sun_azimuth * TOD_Math.DEG_TO_RAD
	var altitude: float = sun_altitude * TOD_Math.DEG_TO_RAD
	
	__finish_set_sun_pos = false
	if not __finish_set_sun_pos:
		__sun_transform.origin = TOD_Math.to_orbit(altitude, azimuth)
		__finish_set_sun_pos = true
	
	if __finish_set_sun_pos:
		__sun_transform = __sun_transform.looking_at(Sky3DConstants.DEFAULT_POSITION, Vector3.LEFT)
	
	__set_day_state(altitude)
	emit_signal("sun_transform_changed", __sun_transform)
	emit_signal("sun_transform_changed", sun_direction())
	
	sky_material.set_shader_parameter(Sky3DConstants.SUN_DIR_P, sun_direction())
	fog_material.set_shader_parameter(Sky3DConstants.SUN_DIR_P, sun_direction())
	moon_material.set_shader_parameter(Sky3DConstants.SUN_DIR_P, sun_direction())
	clouds_cumulus_material.set_shader_parameter(Sky3DConstants.SUN_DIR_P, sun_direction())
	
	if __sun_light_node != null:
		#if __sun_light_node.light_energy > 0.0 && (abs(sun_altitude) < 90.0
		if __sun_light_node.light_energy > 0.0:
			__sun_light_node.transform = __sun_transform
	
	update_night_intensity()
	update_sun_light_color()
	update_sun_light_energy()
	update_moon_light_energy()
	__update_enviro()


func update_moon_coords() -> void:
	if !is_scene_built:
		return
		
	var azimuth: float = moon_azimuth * TOD_Math.DEG_TO_RAD
	var altitude: float = moon_altitude * TOD_Math.DEG_TO_RAD
	
	__finish_set_moon_pos = false
	if not __finish_set_moon_pos:
		__moon_transform.origin = TOD_Math.to_orbit(altitude, azimuth)
		__finish_set_moon_pos = true
	
	if __finish_set_moon_pos:
		__moon_transform = __moon_transform.looking_at(Sky3DConstants.DEFAULT_POSITION, Vector3.LEFT)
	
	emit_signal("moon_transform_changed", __moon_transform)
	emit_signal("moon_direction_changed", moon_direction())
	
	sky_material.set_shader_parameter(Sky3DConstants.MOON_DIR_P, moon_direction())
	fog_material.set_shader_parameter(Sky3DConstants.MOON_DIR_P, moon_direction())
	moon_material.set_shader_parameter(Sky3DConstants.MOON_DIR_P, moon_direction())
	clouds_cumulus_material.set_shader_parameter(Sky3DConstants.MOON_DIR_P, moon_direction())
	sky_material.set_shader_parameter(Sky3DConstants.MOON_MATRIX, __moon_transform.basis.inverse())
	
	var moon_instance_transform = moon_render.get_node("MoonTransform") as Node3D
	moon_instance_transform.transform = __moon_transform
	
	if __moon_light_node != null:
		#if __moon_light_node.light_energy > 0.0 && (abs(moon_altitude) < 90.0):
		if __moon_light_node.light_energy > 0.0:
			__moon_light_node.transform = __moon_transform
	
	__moon_light_altitude_mult = TOD_Math.saturate(moon_direction().y)
	
	update_night_intensity()
	set_moon_light_color(moon_light_color)
	update_moon_light_energy()
	__update_enviro()

## Atmosphere.
func update_beta_ray() -> void:
	if !is_scene_built:
		return

	var wll = ScatterLib.compute_wavelenghts_lambda(atm_wavelenghts)
	var wls = ScatterLib.compute_wavlenghts(wll)
	var betaRay = ScatterLib.compute_beta_ray(wls)
	sky_material.set_shader_parameter(Sky3DConstants.ATM_BETA_RAY_P, betaRay)
	fog_material.set_shader_parameter(Sky3DConstants.ATM_BETA_RAY_P, betaRay)

func update_beta_mie() -> void:
	if !is_scene_built:
		return

	var bm = ScatterLib.compute_beta_mie(atm_mie, atm_turbidity)
	sky_material.set_shader_parameter(Sky3DConstants.ATM_BETA_MIE_P, bm)
	fog_material.set_shader_parameter(Sky3DConstants.ATM_BETA_MIE_P, bm)

func update_night_intensity() -> void:
	if !is_scene_built:
		return

	var tint: Color = atm_night_tint * atm_night_intensity()
	sky_material.set_shader_parameter(Sky3DConstants.ATM_NIGHT_TINT_P, tint)
	fog_material.set_shader_parameter(Sky3DConstants.ATM_NIGHT_TINT_P, atm_night_tint * fog_atm_night_intensity())
	
	set_atm_moon_mie_intensity(atm_moon_mie_intensity)

## Lighting
signal is_day(value)
func __set_day_state(v: float, threshold: float = 1.80) -> void:
	if abs(v) > threshold:
		emit_signal("is_day", false)
	else:
		emit_signal("is_day", true)
	
	__evaluate_light_enable()

var __light_enable: bool
func __evaluate_light_enable() -> void:
	if __sun_light_node != null:
		__light_enable = true if __sun_light_node.light_energy > 0.0 else false
		__sun_light_node.visible = __light_enable
	if __moon_light_node != null:
		__moon_light_node.visible = !__light_enable

func update_sun_light_energy() -> void:
	if __sun_light_node != null:
		# Light energy should depend on how much of the sun disk is visible
		var y = sun_direction().y
		var sun_light_factor: float = TOD_Math.saturate((y + sun_disk_size) / (2 * sun_disk_size));
		__sun_light_node.light_energy = TOD_Math.lerp_f(0.0, sun_light_energy, sun_light_factor)

func update_moon_light_energy() -> void:
	if __moon_light_node == null:
		return
	
	var l: float = TOD_Math.lerp_f(0.0, moon_light_energy, __moon_light_altitude_mult)
	l*= atm_moon_phases_mult()
	
	var fade = (1.0 - sun_direction().y) * 0.5
	__moon_light_node.light_energy = l * Sky3DConstants._sun_moon_curve_fade.sample_baked(fade)

func __update_enviro() -> void:
	if not __enable_enviro:
		return
	
	var a = TOD_Math.saturate(1.0 - sun_direction().y)
	var b = TOD_Math.saturate(-sun_direction().y + 0.60)
	
	var colA = TOD_Math.plerp_color(atm_day_tint * 0.5, atm_horizon_light_tint, a)
	var colB = TOD_Math.plerp_color(colA, atm_night_tint * atm_night_intensity(), b)
	
	enviro.ambient_light_color = colB
	enviro.background_energy_multiplier = colB.get_luminance()
	enviro.ambient_light_sky_contribution = 1 - enviro.background_energy_multiplier


func _get_property_list() -> Array:
	var ret:= Array() 
	ret.push_back({name = "Skydome", type = TYPE_NIL, usage = PROPERTY_USAGE_CATEGORY})
	
	# Global.
	ret.push_back({name = "Global", type = TYPE_NIL, usage = PROPERTY_USAGE_GROUP})
	ret.push_back({name = "sky_visible", type = TYPE_BOOL})
	ret.push_back({name = "dome_radius", type = TYPE_FLOAT})
	ret.push_back({name = "tonemap_level", type = TYPE_FLOAT, hint = PROPERTY_HINT_RANGE, hint_string = "0.0, 1.0"})
	ret.push_back({name = "exposure", type = TYPE_FLOAT})
	ret.push_back({name = "ground_color", type = TYPE_COLOR})
	ret.push_back({name = "sky_layers", type = TYPE_INT, hint = PROPERTY_HINT_LAYERS_3D_RENDER})
	ret.push_back({name = "sky_render_priority", type = TYPE_INT, hint = PROPERTY_HINT_RANGE, hint_string = "-128, 127"})
	ret.push_back({name = "horizon_level", type = TYPE_FLOAT})
	
	# Sun.
	ret.push_back({name = "Sun", type = TYPE_NIL, usage = PROPERTY_USAGE_GROUP})
	ret.push_back({name = "sun_altitude", type = TYPE_FLOAT, hint = PROPERTY_HINT_RANGE, hint_string = "-180.0, 180.0"})
	ret.push_back({name = "sun_azimuth", type = TYPE_FLOAT, hint = PROPERTY_HINT_RANGE, hint_string = "-180.0, 180.0"})
	ret.push_back({name = "sun_disk_color", type = TYPE_COLOR})
	ret.push_back({name = "sun_disk_intensity", type = TYPE_FLOAT, hint = PROPERTY_HINT_RANGE, hint_string = "0.0, 2.0"}) # Clamped 2.0 for prevent reflection probe artifacts.
	ret.push_back({name = "sun_disk_size", type = TYPE_FLOAT, hint = PROPERTY_HINT_RANGE, hint_string = "0.0, 0.5"})
	ret.push_back({name = "sun_light_path", type = TYPE_NODE_PATH})
	ret.push_back({name = "sun_light_color", type = TYPE_COLOR})
	ret.push_back({name = "sun_horizon_light_color", type = TYPE_COLOR})
	ret.push_back({name = "sun_light_energy", type = TYPE_FLOAT})
	
	# Moon.
	ret.push_back({name = "Moon", type = TYPE_NIL, usage = PROPERTY_USAGE_GROUP})
	ret.push_back({name = "moon_altitude", type = TYPE_FLOAT, hint = PROPERTY_HINT_RANGE, hint_string = "-180.0, 180.0"})
	ret.push_back({name = "moon_azimuth", type = TYPE_FLOAT, hint = PROPERTY_HINT_RANGE, hint_string = "-180.0, 180.0"})
	ret.push_back({name = "moon_color", type = TYPE_COLOR})
	ret.push_back({name = "moon_size", type = TYPE_FLOAT})
	ret.push_back({name = "enable_set_moon_texture", type = TYPE_BOOL})
	
	if enable_set_moon_texture:
		ret.push_back({name = "moon_texture", type = TYPE_OBJECT, hint = PROPERTY_HINT_FILE, hint_string = "Texture2D"})
	
	ret.push_back({name = "moon_resolution", type = TYPE_INT, hint = PROPERTY_HINT_ENUM, hint_string = "64, 128, 256, 512, 1024"})
	ret.push_back({name = "moon_light_path", type = TYPE_NODE_PATH})
	
	ret.push_back({name = "moon_light_color", type = TYPE_COLOR})
	ret.push_back({name = "moon_light_energy", type = TYPE_FLOAT})
	
	# Deep space
	ret.push_back({name = "DeepSpace", type = TYPE_NIL, usage = PROPERTY_USAGE_GROUP})
	ret.push_back({name = "deep_space_euler", type = TYPE_VECTOR3})
	ret.push_back({name = "background_color", type = TYPE_COLOR})
	ret.push_back({name = "set_background_texture", type = TYPE_BOOL})
	
	if set_background_texture:
		ret.push_back({name = "background_texture", type = TYPE_OBJECT, hint = PROPERTY_HINT_GLOBAL_FILE, hint_string = "Texture2D"})
	
	ret.push_back({name = "stars_field_color", type = TYPE_COLOR})
	ret.push_back({name = "set_stars_field_texture", type = TYPE_BOOL})
	
	if set_stars_field_texture:
		ret.push_back({name = "stats_field_texture", type = TYPE_OBJECT, hint = PROPERTY_HINT_FILE, hint_string = "Texture2D"})
	
	ret.push_back({name = "stars_scintillation", type = TYPE_FLOAT, hint = PROPERTY_HINT_RANGE, hint_string = "0.0, 1.0"})
	ret.push_back({name = "stars_scintillation_speed", type = TYPE_FLOAT})
	
	# Atmosphere.
	ret.push_back({name = "Atmosphere", type = TYPE_NIL, usage = PROPERTY_USAGE_GROUP, hint_string = "atm_"})
	ret.push_back({name = "atm_quality", type = TYPE_INT, hint = PROPERTY_HINT_ENUM, hint_string = "PerPixel,PerVertex"})
	ret.push_back({name = "atm_wavelenghts", type = TYPE_VECTOR3})
	ret.push_back({name = "atm_darkness", type = TYPE_FLOAT, hint = PROPERTY_HINT_RANGE, hint_string = "0.0, 1.0"})
	ret.push_back({name = "atm_sun_intensity", type = TYPE_FLOAT})
	ret.push_back({name = "atm_day_tint", type = TYPE_COLOR})
	ret.push_back({name = "atm_horizon_light_tint", type = TYPE_COLOR})
	ret.push_back({name = "atm_enable_moon_scatter_mode", type = TYPE_BOOL})
	ret.push_back({name = "atm_night_tint", type = TYPE_COLOR})
	ret.push_back({name = "atm_level_params", type = TYPE_VECTOR3})
	ret.push_back({name = "atm_thickness", type = TYPE_FLOAT, hint = PROPERTY_HINT_RANGE, hint_string = "0.0, 100.0"})
	ret.push_back({name = "atm_mie", type = TYPE_FLOAT})
	ret.push_back({name = "atm_turbidity", type = TYPE_FLOAT})
	ret.push_back({name = "atm_sun_mie_tint", type = TYPE_COLOR})
	ret.push_back({name = "atm_sun_mie_intensity", type = TYPE_FLOAT})
	ret.push_back({name = "atm_sun_mie_anisotropy", type = TYPE_FLOAT, hint = PROPERTY_HINT_RANGE, hint_string = "0.0, 0.9999999"})
	
	ret.push_back({name = "atm_moon_mie_tint", type = TYPE_COLOR})
	ret.push_back({name = "atm_moon_mie_intensity", type = TYPE_FLOAT})
	ret.push_back({name = "atm_moon_mie_anisotropy", type = TYPE_FLOAT, hint = PROPERTY_HINT_RANGE, hint_string = "0.0, 0.9999999"})
	
	# Fog.
	ret.push_back({name = "Fog", type = TYPE_NIL, usage = PROPERTY_USAGE_GROUP, hint_string = "fog_"})
	ret.push_back({name = "fog_visible", type = TYPE_BOOL})
	ret.push_back({name = "fog_atm_level_params_offset", type = TYPE_VECTOR3})
	ret.push_back({name = "fog_density", type = TYPE_FLOAT, hint = PROPERTY_HINT_EXP_EASING, hint_string = "0.0, 1.0"})
	ret.push_back({name = "fog_rayleigh_depth", type = TYPE_FLOAT, hint = PROPERTY_HINT_EXP_EASING, hint_string = "0.0, 1.0"})
	ret.push_back({name = "fog_mie_depth", type = TYPE_FLOAT, hint = PROPERTY_HINT_EXP_EASING, hint_string = "0.0, 1.0"})
	ret.push_back({name = "fog_falloff", type = TYPE_FLOAT, hint = PROPERTY_HINT_RANGE, hint_string = "0.0, 10.0"})
	ret.push_back({name = "fog_start", type = TYPE_FLOAT, hint = PROPERTY_HINT_RANGE, hint_string = "0.0, 5000.0"})
	ret.push_back({name = "fog_end", type = TYPE_FLOAT, hint = PROPERTY_HINT_RANGE, hint_string = "0.0, 5000.0"})
	ret.push_back({name = "fog_layers", type = TYPE_INT, hint = PROPERTY_HINT_LAYERS_3D_RENDER})
	ret.push_back({name = "fog_render_priority", type = TYPE_INT})
	
	# 2D Clouds.
	ret.push_back({name = "2D Clouds", type = TYPE_NIL, usage = PROPERTY_USAGE_GROUP})
	ret.push_back({name = "clouds_thickness", type = TYPE_FLOAT})
	ret.push_back({name = "clouds_coverage", type = TYPE_FLOAT, hint = PROPERTY_HINT_RANGE, hint_string = "0.0, 1.0"})
	ret.push_back({name = "clouds_absorption", type = TYPE_FLOAT})
	ret.push_back({name = "clouds_sky_tint_fade", type = TYPE_FLOAT, hint = PROPERTY_HINT_RANGE, hint_string = "0.0, 1.0"})
	ret.push_back({name = "clouds_intensity", type = TYPE_FLOAT})
	ret.push_back({name = "clouds_size", type = TYPE_FLOAT})
	ret.push_back({name = "clouds_uv", type = TYPE_VECTOR2})
	ret.push_back({name = "clouds_offset", type = TYPE_VECTOR2})
	ret.push_back({name = "clouds_offset_speed", type = TYPE_FLOAT})
	ret.push_back({name = "set_clouds_texture", type = TYPE_BOOL})
	
	if set_clouds_texture:
		ret.push_back({name = "clouds_texture", type = TYPE_OBJECT, hint = PROPERTY_HINT_FILE, hint_string = "Texture2D"})
	
	# Clouds cumulus.
	ret.push_back({name = "Clouds Cumulus", type = TYPE_NIL, usage = PROPERTY_USAGE_GROUP})
	ret.push_back({name = "clouds_cumulus_visible", type = TYPE_BOOL})
	ret.push_back({name = "clouds_cumulus_day_color", type = TYPE_COLOR})
	ret.push_back({name = "clouds_cumulus_horizon_light_color", type = TYPE_COLOR})
	ret.push_back({name = "clouds_cumulus_night_color", type = TYPE_COLOR})
	ret.push_back({name = "clouds_cumulus_thickness", type = TYPE_FLOAT})
	ret.push_back({name = "clouds_cumulus_coverage", type = TYPE_FLOAT, hint = PROPERTY_HINT_RANGE, hint_string = "0.0, 1.0"})
	ret.push_back({name = "clouds_cumulus_absorption", type = TYPE_FLOAT})
	ret.push_back({name = "clouds_cumulus_noise_freq", type = TYPE_FLOAT, hint = PROPERTY_HINT_RANGE, hint_string = "0.0, 3.0"})
	ret.push_back({name = "clouds_cumulus_intensity", type = TYPE_FLOAT})
	ret.push_back({name = "clouds_cumulus_mie_intensity", type = TYPE_FLOAT})
	ret.push_back({name = "clouds_cumulus_mie_anisotropy", type = TYPE_FLOAT, hint = PROPERTY_HINT_RANGE, hint_string = "0.0, 0.999999"})
	ret.push_back({name = "clouds_cumulus_size", type = TYPE_FLOAT})
	ret.push_back({name = "clouds_cumulus_offset", type = TYPE_VECTOR3})
	ret.push_back({name = "clouds_cumulus_offset_speed", type = TYPE_FLOAT})
	ret.push_back({name = "set_clouds_cumulus_texture", type = TYPE_BOOL})
	
	if set_clouds_cumulus_texture:
		ret.push_back({name = "clouds_cumulus_texture", type = TYPE_OBJECT, hint = PROPERTY_HINT_FILE, hint_string = "Texture2D"})
	
	# Lighting
	ret.push_back({name = "Lighting", type = TYPE_NIL, usage = PROPERTY_USAGE_GROUP})
	ret.push_back({name = "enviro", type = TYPE_OBJECT, hint = PROPERTY_HINT_RESOURCE_TYPE, hint_string = "Resource"})
	
	return ret
