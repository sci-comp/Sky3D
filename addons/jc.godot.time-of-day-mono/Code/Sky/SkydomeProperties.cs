/*========================================================
°                       TimeOfDay.
°                   ======================
°
°   Category: Sky.
°   -----------------------------------------------------
°   Description:
°       Skydome Base.
°   -----------------------------------------------------
°   Copyright:
°               J. Cuellar 2021. MIT License.
°                   See: LICENSE Archive.
========================================================*/
using Godot;
using System;
using GDA = Godot.Collections.Array;
using GDD = Godot.Collections.Dictionary<object, object>;

namespace JC.TimeOfDay
{

    public partial class Skydome : Node
    {

        public override GDA _GetPropertyList()
        {
            GDA ret = new GDA();
            GDD pTitle = new GDD 
            { 
                {"name", "Skydome"},
                {"type", Variant.Type.Nil},
                {"usage", PropertyUsageFlags.Category}
            };
            ret.Add(pTitle);

        #region Global

            GDD pGlobalGroup = new GDD 
            { 
                {"name", "Global"},
                {"type", Variant.Type.Nil},
                {"usage", PropertyUsageFlags.Group}
            };
            ret.Add(pGlobalGroup);
                        
            GDD pSkyVisible = new GDD 
            { 
                {"name", "SkyVisible"},
                {"type", Variant.Type.Bool}
            };
            ret.Add(pSkyVisible);
                        
            GDD pDomeRadius = new GDD 
            {
                {"name", "DomeRadius"},
                {"type", Variant.Type.Real},
            };
            ret.Add(pDomeRadius);

            GDD pTonemapLevel = new GDD 
            {
                {"name", "TonemapLevel"},
                {"type", Variant.Type.Real},
                {"hint", PropertyHint.Range},
                {"hint_string", "0.0, 1.0"}
            };
            ret.Add(pTonemapLevel);

            GDD pExposure = new GDD
            {
                {"name", "Exposure"},
                {"type", Variant.Type.Real}

            };
            ret.Add(pExposure);

            GDD pGroundColor = new GDD 
            {
                {"name", "GroundColor"},
                {"type", Variant.Type.Color}
            };
            ret.Add(pGroundColor);

            GDD pSkyLayers = new GDD 
            {
                {"name", "SkyLayers"},
                {"type", Variant.Type.Int},
                {"hint", PropertyHint.Layers3dRender}
            };
            ret.Add(pSkyLayers);

            GDD pSkyRenderPriority = new GDD
            {
                {"name", "SkyRenderPriority"},
                {"type", Variant.Type.Int},
                {"hint", PropertyHint.Range},
                {"hint_string", "-128, 128"}
            };
            ret.Add(pSkyRenderPriority);

        #endregion


        #region Sun

            GDD pSunGroup = new GDD 
            { 
                {"name", "Sun"},
                {"type", Variant.Type.Nil},
                {"usage", PropertyUsageFlags.Group}
            };
            ret.Add(pSunGroup);

            GDD pSunAltitude = new GDD 
            {
                {"name", "SunAltitude"},
                {"type", Variant.Type.Real},
                {"hint", PropertyHint.Range},
                {"hint_string", "-180.0, 180.0"}
            };
            ret.Add(pSunAltitude);

            GDD pSunAzimuth = new GDD 
            { 
                {"name", "SunAzimuth"}, 
                {"type", Variant.Type.Real},
                {"hint", PropertyHint.Range}, 
                {"hint_string", "-180.0, 180.0"}

            };
            ret.Add(pSunAzimuth);

        #endregion

        #region Moon

            GDD pMoonGroup = new GDD 
            { 
                {"name", "Moon"},
                {"type", Variant.Type.Nil},
                {"usage", PropertyUsageFlags.Group}
            };
            ret.Add(pMoonGroup);

            GDD pMoonAltitude = new GDD 
            {
                {"name", "MoonAltitude"},
                {"type", Variant.Type.Real},
                {"hint", PropertyHint.Range},
                {"hint_string", "-180.0, 180.0"}
            };
            ret.Add(pMoonAltitude);

            GDD pMoonAzimuth = new GDD 
            {
                {"name", "MoonAzimuth"},
                {"type", Variant.Type.Real},
                {"hint", PropertyHint.Range},
                {"hint_string", "-180.0, 180.0"}
            };
            ret.Add(pMoonAzimuth);

        #endregion

        #region Atmosphere 

            GDD pAtmosphereGroup = new GDD 
            { 
                {"name", "Atmosphere"},
                {"type", Variant.Type.Nil},
                {"usage", PropertyUsageFlags.Group},
                {"hint_string", "Atm"}
            };
            ret.Add(pAtmosphereGroup);

            GDD pAtmQuality = new GDD 
            {
                {"name", "AtmQuality"},
                {"type", Variant.Type.Int},
                {"hint", PropertyHint.Enum},
                {"hint_string", "PerPixel, PerVertex"}
            };
            ret.Add(pAtmQuality);

            GDD pAtmWavelenghts = new GDD 
            {
                {"name", "AtmWavelenghts"},
                {"type", Variant.Type.Vector3}
            };
            ret.Add(pAtmWavelenghts);

            GDD pAtmDarkness = new GDD 
            {
                {"name", "AtmDarkness"},
                {"type", Variant.Type.Real},
                {"hint", PropertyHint.Range},
                {"hint_string", "0.0, 1.0"}
            };
            ret.Add(pAtmDarkness);

            GDD pAtmSunIntensity = new GDD 
            {
                {"name", "AtmSunIntensity"},
                {"type", Variant.Type.Real}
            };
            ret.Add(pAtmSunIntensity);

            GDD pAtmDayTint = new GDD
            {
                {"name", "AtmDayTint"},
                {"type", Variant.Type.Color}
            };
            ret.Add(pAtmDayTint);

            GDD pAtmHorizonLightTint = new GDD
            {
                {"name", "AtmHorizonLightTint"},
                {"type", Variant.Type.Color}
            };
            ret.Add(pAtmHorizonLightTint);

            GDD pAtmEnableMoonScatterMode = new GDD 
            {
                {"name", "AtmEnableMoonScatterMode"},
                {"type", Variant.Type.Bool}
            };
            ret.Add(pAtmEnableMoonScatterMode);

            GDD pAtmNightTint = new GDD
            {
                {"name", "AtmNightTint"},
                {"type", Variant.Type.Color}
            };
            ret.Add(pAtmNightTint);

            GDD pAtmLevelParams = new GDD 
            {
                {"name", "AtmLevelParams"},
                {"type", Variant.Type.Vector3}
            };
            ret.Add(pAtmLevelParams);

            GDD pAtmThickness = new GDD 
            {
                {"name", "AtmThickness"},
                {"type", Variant.Type.Real},
                {"hint", PropertyHint.Range},
                {"hint_string", "0.0, 100.0"}
            };
            ret.Add(pAtmThickness);
            GDD pAtmMie = new GDD 
            {
                {"name", "AtmMie"},
                {"type", Variant.Type.Real}
            };
            ret.Add(pAtmMie);

            GDD pAtmTurbidity = new GDD 
            {
                {"name", "AtmTurbidity"},
                {"type", Variant.Type.Real}
            };
            ret.Add(pAtmTurbidity);

            GDD pAtmSunMieTint = new GDD 
            {
                {"name", "AtmSunMieTint"},
                {"type", Variant.Type.Color}
            };
            ret.Add(pAtmSunMieTint);

            GDD pAtmSunMieIntensity = new GDD 
            {
                {"name", "AtmSunMieIntensity"},
                {"type", Variant.Type.Real}
            };
            ret.Add(pAtmSunMieIntensity);

            GDD pAtmSunMieAnisotropy = new GDD 
            {
                {"name", "AtmSunMieAnisotropy"},
                {"type", Variant.Type.Real},
                {"hint", PropertyHint.Range},
                {"hint_string", "0.0, 0.9999999"}
            };
            ret.Add(pAtmSunMieAnisotropy);

            GDD pAtmMoonMieTint = new GDD 
            {
                {"name", "AtmMoonMieTint"},
                {"type", Variant.Type.Color}
            };
            ret.Add(pAtmMoonMieTint);

            GDD pAtmMoonMieIntensity = new GDD 
            {
                {"name", "AtmMoonMieIntensity"},
                {"type", Variant.Type.Real}
            };
            ret.Add(pAtmMoonMieIntensity);

            GDD pAtmMoonMieAnisotropy = new GDD 
            {
                {"name", "AtmMoonMieAnisotropy"},
                {"type", Variant.Type.Real},
                {"hint", PropertyHint.Range},
                {"hint_string", "0.0, 0.9999999"}
            };
            ret.Add(pAtmMoonMieAnisotropy);

            GDD pFogGroup = new GDD 
            { 
                {"name", "Fog"},
                {"type", Variant.Type.Nil},
                {"usage", PropertyUsageFlags.Group},
                {"hint_string", "Fog"}
            };
            ret.Add(pFogGroup);

            GDD pFogVisible = new GDD 
            {
                {"name", "FogVisible"},
                {"type", Variant.Type.Bool}
            };
            ret.Add(pFogVisible);

            GDD pFogDensity = new GDD 
            {
                {"name", "FogDensity"},
                {"type", Variant.Type.Real},
                {"hint", PropertyHint.ExpEasing},
                {"hint_string", "0.0, 1.0"}
            };
            ret.Add(pFogDensity);

            GDD pFogRayleighDepth = new GDD 
            {
                {"name", "FogRayleighDepth"},
                {"type", Variant.Type.Real},
                {"hint", PropertyHint.ExpEasing},
                {"hint_string", "0.0, 1.0"}
            };
            ret.Add(pFogRayleighDepth);

            GDD pFogMieDepth = new GDD 
            {
                {"name", "FogMieDepth"},
                {"type", Variant.Type.Real},
                {"hint", PropertyHint.ExpEasing},
                {"hint_string", "0.0, 1.0"}
            };
            ret.Add(pFogMieDepth);

            GDD pFogLayers = new GDD 
            {
                {"name", "FogLayers"},
                {"type", Variant.Type.Int},
                {"hint", PropertyHint.Layers3dRender}
            };
            ret.Add(pFogLayers);

            GDD pFogRenderPriority = new GDD 
            {
                {"name", "FogRenderPriority"},
                {"type", Variant.Type.Int}
            };
            ret.Add(pFogRenderPriority);

        #endregion

            return ret;
        }
    }
}
