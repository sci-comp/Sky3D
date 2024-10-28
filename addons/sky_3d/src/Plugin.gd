# Copyright (c) 2023-2024 Cory Petkovsek and Contributors
# Copyright (c) 2021 J. Cuellar

@tool
extends EditorPlugin


const __skydome_script: Script = preload("res://addons/sky_3d/src/Skydome.gd")
const __skydome_icon: Texture2D = preload("res://addons/sky_3d/assets/textures/SkyIcon.png")

const __time_of_day_script: Script = preload("res://addons/sky_3d/src/TimeOfDay.gd")
const __time_of_day_icon: Texture2D = preload("res://addons/sky_3d/assets/textures/SkyIcon.png")

func _enter_tree() -> void:
	add_custom_type("Skydome", "Node", __skydome_script, __skydome_icon)
	add_custom_type("TimeOfDay", "Node", __time_of_day_script, __time_of_day_icon)

func _exit_tree() -> void:
	remove_custom_type("Skydome")
	remove_custom_type("TimeOfDay")
