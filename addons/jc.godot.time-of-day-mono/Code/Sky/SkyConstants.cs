/*========================================================
°                       TimeOfDay.
°                   ======================
°
°   Category: Sky.
°   -----------------------------------------------------
°   Description:
°      Constants for sky.
°   -----------------------------------------------------
°   Copyright:
°               J. Cuellar 2021. MIT License.
°                   See: LICENSE Archive.
========================================================*/
using Godot;
using System;

namespace JC.TimeOfDay
{
    public partial struct SkyConst // TODO: Renombrar parametros k
    {
        // Skydome.
        public const String kSkyInstance = "_SkyMeshI";
        public const String kFogInstance = "_FogMeshI";
        public const String kMoonInstance  = "MoonRender";
        public const String kCloudsCInstance = "_CloudsCumulusI";
        
        public const float kMaxExtraCullMargin = 16384.0f;
        public static readonly Vector3 kDefaultPosition = new Vector3(0.0000001f, 0.0000001f, 0.0000001f);
        
        // Shader Params.
        public static readonly String kSunDirP = "_sun_direction";
        public static readonly  String kMoonDirP = "_moon_direction";
        public static readonly  String kMoonMatrix = "_moon_matrix";
        public static readonly  String kTexture = "_texture";

        public static readonly  String kColorCorrectionP = "_color_correction_params";
        public static readonly String kGroundColor = "_ground_color";

        public static readonly String kSunDiskColP = "_sun_disk_color";
        public static readonly String kSunDiskSizeP = "_sun_disk_size";

        public static readonly String kMoonColP = "_moon_color";
        public static readonly String kMoonSizeP = "_moon_size";

        public static readonly String kBGColP = "_background_color";
        public static readonly String kBGTextureP = "_background_texture";

        public static readonly String kStarsColorP = "_stats_field_color";
        public static readonly String kStarsTextureP = "_stars_field_texture";
        public static readonly String kStarsScP = "_stats_scintillation";
        public static readonly String kStarsScSpeedP = "_stats_scintillation_speed";

        public static readonly String kAtmDarkness = "_atm_darkness";
        public static readonly String kAtmBetaRay = "_atm_beta_ray";
        public static readonly String kAtmSunIntensity = "_atm_sun_intensity";
        public static readonly String kAtmDayTint = "_atm_day_tint";
        public static readonly String kAtmHorizonLightTint = "_atm_horizon_light_tint";

        public static readonly String kAtmNightTint = "_atm_night_tint";
        public static readonly String kAtmLevelParams = "_atm_level_params";
        public static readonly String kAtmBetaMie = "_atm_beta_mie";

        public static readonly String kAtmSunMieTint = "_atm_sun_mie_tint";
        public static readonly String kAtmSunMieIntensity = "_atm_sun_mie_intensity";
        public static readonly String KAtmSunPartialMiePhase = "_atm_sun_partial_mie_phase";

        public static readonly String kAtmMoonMieTint = "_atm_moon_mie_tint";
        public static readonly String kAtmMoonMieIntensity = "_atm_moon_mie_intensity";
        public static readonly String kAtmMoonPartialMiePhase = "_atm_moon_partial_mie_phase";
        public static readonly String kFogDensityP = "_fog_density";
        public static readonly String kFogRayleighDepthP = "_fog_rayleigh_depth";
        public static readonly String kFogMieDepthP = "_fog_mie_depth";

    }
}
