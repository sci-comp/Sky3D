# Copyright (c) 2023-2024 Cory Petkovsek and Contributors
# Copyright (c) 2021 J. Cuellar

@tool
class_name Sky3D
extends WorldEnvironment

signal environment_changed

@export var enable_sky3d: bool = true : set = set_sky3d_enabled
@export var enable_sky: bool = true : set = set_sky_enabled
@export var enable_fog: bool = true : set = set_fog_enabled

@export_category("Time")
@export var enable_time: bool = true : set = set_time_enabled
@export_range(0.0, 24.0) var current_time: float = 8.0 : set = set_current_time
@export_range(0.016, 10.0) var update_interval: float = 0.1 : set = set_update_interval
@export_range(-1440,1440,1) var minutes_per_day: float = 15.0 : set = set_minutes_per_day

var sun: DirectionalLight3D
var moon: DirectionalLight3D
var tod: TimeOfDay
var skydome: Skydome
var _initial_environment: Environment


func _enter_tree() -> void:
	initialize()


func _ready() -> void:
	tod.time_changed.connect(_on_timeofday_updated)


func set_sky3d_enabled(value: bool) -> void:
	enable_sky3d = value
	enable_sky = value
	enable_fog = value
	if value:
		resume()
	else:
		pause()


func set_sky_enabled(value: bool) -> void:
	if not skydome:
		return
	enable_sky = value
	skydome.sky_visible = value
	skydome.clouds_cumulus_visible = value
	skydome.sun_light_energy = 1 if value else 0
	skydome.moon_light_energy = 0.3 if value else 0
	skydome.environment = _initial_environment if value else null
	emit_signal("environment_changed", environment)


func set_fog_enabled(value: bool) -> void:
	if skydome:
		enable_fog = value
		skydome.fog_visible = value


func set_time_enabled(value:bool) -> void:
	if tod:
		enable_time = value
		if value:
			tod.resume()
		else:
			tod.pause()


func pause() -> void:
	enable_time = false


func resume() -> void:
	enable_time = true


func set_current_time(value:float) -> void:
	if value != current_time:
		current_time = value 
		if has_node("TimeOfDay"):
			$TimeOfDay.total_hours = value


func set_minutes_per_day(value):
	if value != minutes_per_day: 
		minutes_per_day = value 
		if has_node("TimeOfDay"):
			$TimeOfDay.total_cycle_in_minutes = value


func set_update_interval(value:float) -> void:
	if value != update_interval:
		update_interval = value 
		if has_node("TimeOfDay"):
			$TimeOfDay.update_interval = value


func _on_timeofday_updated(time: float) -> void:
	if Engine.is_editor_hint() and tod:
		minutes_per_day = tod.total_cycle_in_minutes
		current_time = tod.total_hours
		update_interval = tod.update_interval


func initialize() -> void:
	if environment == null:
		environment = Environment.new()
		environment.tonemap_mode = Environment.TONE_MAPPER_ACES
		environment.tonemap_white = 6
		environment.background_mode = Environment.BG_SKY
		environment.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
		environment.ambient_light_sky_contribution = 0.7
		_initial_environment = environment
		emit_signal("environment_changed", environment)

	if get_child_count() > 0:
		tod = $TimeOfDay
		skydome = $Skydome
		skydome.environment = environment
		sun = $SunLight
		moon = $MoonLight
		return
	
	sun = DirectionalLight3D.new()
	sun.name = "SunLight"
	add_child(sun, true)
	sun.owner = get_tree().edited_scene_root
	sun.shadow_enabled = true

	moon = DirectionalLight3D.new()
	moon.name = "MoonLight"
	add_child(moon, true)
	moon.owner = get_tree().edited_scene_root
	moon.shadow_enabled = true

	tod = TimeOfDay.new()
	tod.name = "TimeOfDay"
	add_child(tod, true)
	tod.owner = get_tree().edited_scene_root
	tod.dome_path = "../Skydome"
	
	skydome = Skydome.new()
	skydome.name = "Skydome"
	add_child(skydome, true)
	skydome.owner = get_tree().edited_scene_root
	skydome.sun_light_path = "../SunLight"
	skydome.moon_light_path = "../MoonLight"
	skydome.environment = environment
	
	
func _set(property: StringName, value: Variant) -> bool:
	if property == "environment":
		environment = value
		_initial_environment = value
		if skydome:
			skydome.environment = value
		emit_signal("environment_changed", environment)
		return true
	return false


### Constants

# Node names
const SKY_INSTANCE:= "_SkyMeshI"
const FOG_INSTANCE:= "_FogMeshI"
const MOON_INSTANCE:= "MoonRender"
const CLOUDS_C_INSTANCE:= "_CloudsCumulusI"

# Shaders
const _sky_shader: Shader = preload("res://addons/sky_3d/shaders/Sky.gdshader")
const _pv_sky_shader: Shader = preload("res://addons/sky_3d/shaders/PerVertexSky.gdshader")
const _clouds_cumulus_shader: Shader = preload("res://addons/sky_3d/shaders/CloudsCumulus.gdshader")
const _fog_shader: Shader = preload("res://addons/sky_3d/shaders/AtmFog.gdshader")

# Scenes
const _moon_render: PackedScene = preload("res://addons/sky_3d/assets/resources/MoonRender.tscn")

# Textures
const _moon_texture: Texture2D = preload("res://addons/sky_3d/assets/thirdparty/textures/moon/MoonMap.png")
const _background_texture: Texture2D = preload("res://addons/sky_3d/assets/thirdparty/textures/milkyway/Milkyway.jpg")
const _stars_field_texture: Texture2D = preload("res://addons/sky_3d/assets/thirdparty/textures/milkyway/StarField.jpg")
const _sun_moon_curve_fade: Curve = preload("res://addons/sky_3d/assets/resources/SunMoonLightFade.tres")
const _stars_field_noise: Texture2D = preload("res://addons/sky_3d/assets/textures/noise.jpg")
const _clouds_texture: Texture2D = preload("res://addons/sky_3d/assets/resources/SNoise.tres")
const _clouds_cumulus_texture: Texture2D = preload("res://addons/sky_3d/assets/textures/noiseClouds.png")

# Skydome
const MAX_EXTRA_CULL_MARGIN: float = 16384.0
const DEFAULT_POSITION:= Vector3(0.0000001, 0.0000001, 0.0000001)

# Coords
const SUN_DIR_P:= "_sun_direction"
const MOON_DIR_P:= "_moon_direction"
const MOON_MATRIX:= "_moon_matrix"

# General
const TEXTURE_P:= "_texture"
const COLOR_CORRECTION_P:= "_color_correction_params"
const GROUND_COLOR_P:= "_ground_color"
const NOISE_TEX:= "_noise_tex"
const HORIZON_LEVEL = "_horizon_level"

# Atmosphere
const ATM_DARKNESS_P:= "_atm_darkness"
const ATM_BETA_RAY_P:= "_atm_beta_ray"
const ATM_SUN_INTENSITY_P:= "_atm_sun_intensity"
const ATM_DAY_TINT_P:= "_atm_day_tint"
const ATM_HORIZON_LIGHT_TINT_P:= "_atm_horizon_light_tint"

const ATM_NIGHT_TINT_P:= "_atm_night_tint"
const ATM_LEVEL_PARAMS_P:= "_atm_level_params"
const ATM_THICKNESS_P:= "_atm_thickness"
const ATM_BETA_MIE_P:= "_atm_beta_mie"

const ATM_SUN_MIE_TINT_P:= "_atm_sun_mie_tint"
const ATM_SUN_MIE_INTENSITY_P:= "_atm_sun_mie_intensity"
const ATM_SUN_PARTIAL_MIE_PHASE_P:= "_atm_sun_partial_mie_phase"

const ATM_MOON_MIE_TINT_P:= "_atm_moon_mie_tint"
const ATM_MOON_MIE_INTENSITY_P:= "_atm_moon_mie_intensity"
const ATM_MOON_PARTIAL_MIE_PHASE_P:= "_atm_moon_partial_mie_phase"

# Fog
const ATM_FOG_DENSITY_P:= "_fog_density"
const ATM_FOG_RAYLEIGH_DEPTH_P:= "_fog_rayleigh_depth"
const ATM_FOG_MIE_DEPTH_P:= "_fog_mie_depth"
const ATM_FOG_FALLOFF:= "_fog_falloff"
const ATM_FOG_START:= "_fog_start"
const ATM_FOG_END:= "_fog_end"

# Near Space
const SUN_DISK_COLOR_P:= "_sun_disk_color"
const SUN_DISK_INTENSITY_P:= "_sun_disk_intensity"
const SUN_DISK_SIZE_P:= "_sun_disk_size"
const MOON_COLOR_P:= "_moon_color"
const MOON_SIZE_P:= "_moon_size"
const MOON_TEXTURE_P:= "_moon_texture"

# Deep Space
const DEEP_SPACE_MATRIX_P:= "_deep_space_matrix"
const BG_COL_P:= "_background_color"
const BG_TEXTURE_P:= "_background_texture"
const STARS_COLOR_P:= "_stars_field_color"
const STARS_TEXTURE_P:= "_stars_field_texture"
const STARS_SC_P:= "_stars_scintillation"
const STARS_SC_SPEED_P:= "_stars_scintillation_speed"

# Clouds
const CLOUDS_THICKNESS:= "_clouds_thickness"
const CLOUDS_COVERAGE:= "_clouds_coverage"
const CLOUDS_ABSORPTION:= "_clouds_absorption"
const CLOUDS_SKY_TINT_FADE:= "_clouds_sky_tint_fade"
const CLOUDS_INTENSITY:= "_clouds_intensity"
const CLOUDS_SIZE:= "_clouds_size"
const CLOUDS_NOISE_FREQ:= "_clouds_noise_freq"

const CLOUDS_UV:= "_clouds_uv"
const CLOUDS_OFFSET:= "_clouds_offset"
const CLOUDS_OFFSET_SPEED:= "_clouds_offset_speed"
const CLOUDS_TEXTURE:= "_clouds_texture"

const CLOUDS_DAY_COLOR:= "_clouds_day_color"
const CLOUDS_HORIZON_LIGHT_COLOR:= "_clouds_horizon_light_color"
const CLOUDS_NIGHT_COLOR:= "_clouds_night_color"
const CLOUDS_MIE_INTENSITY:= "_clouds_mie_intensity"
const CLOUDS_PARTIAL_MIE_PHASE:= "_clouds_partial_mie_phase"
