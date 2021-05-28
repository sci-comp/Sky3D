tool
class_name Skydome extends Node
"""========================================================
°                         TimeOfDay.
°                   ======================
°
°   Category: Sky.
°   -----------------------------------------------------
°   Description:
°       Math for ToD.
°   -----------------------------------------------------
°   Copyright:
°               J. Cuellar 2021. MIT License.
°                   See: LICENSE Archive.
========================================================"""

var sun_altitude: float 
var sun_azimuth: float

var moon_altitude: float 
var moon_azimuth: float


## Resources and instances.

# Resources.
var __resources:= SkydomeResources.new()

# Instances.
var __sky_instance: MeshInstance = null
var __fog_instance: MeshInstance = null
var __moon_instance: Viewport = null
var __moon_rt: ViewportTexture = null
var __moon_instance_transform: Spatial = null
var __moon_instance_mesh: MeshInstance = null
var __clouds_cumulus_instance: MeshInstance = null

func __check_instances() -> bool:
	__sky_instance = get_node_or_null(SkyConst.SKY_INSTANCE)
	__moon_instance = get_node_or_null(SkyConst.MOON_INSTANCE)
	__fog_instance = get_node_or_null(SkyConst.FOG_INSTANCE)
	__clouds_cumulus_instance = get_node_or_null(SkyConst.CLOUDS_C_INSTANCE)
	
	if __sky_instance == null: return false
	if __moon_instance == null: return false
	if __fog_instance == null: return false
	if __clouds_cumulus_instance == null: return false
	
	return true

"""
"""
