/*========================================================
°                       TimeOfDay.
°                   ======================
°
°   Category: Sky.
°   -----------------------------------------------------
°   Description:
°       Skydome Resources..
°   -----------------------------------------------------
°   Copyright:
°               J. Cuellar 2021. MIT License.
°                   See: LICENSE Archive.
========================================================*/
using Godot;
using System;

namespace JC.TimeOfDay
{

    public enum SkydomeMeshQuality 
    {
        Low = 0,
        High
    }

    public enum SkyShaderQuality 
    {
        PerPixel = 0,
        PerVertex
    }

    public class SkyDomeResources : Godot.Object
    {

        // Meshs.
        public SphereMesh SkydomeMesh{ get; private set; } = new SphereMesh();
        //public SphereMesh MoonMesh{ get; private set; } = new SphereMesh{ RadialSegments = 8, Rings = 4, };
        public QuadMesh FullScreenQuad{ get; private set; } = new QuadMesh();

        // Materials.
        public ShaderMaterial SkyMaterial{ get; set; } = new ShaderMaterial();
        public ShaderMaterial FogMaterial{ get; set; } = new ShaderMaterial();
        public ShaderMaterial MoonMaterial{ get; set; } = new ShaderMaterial();

        // Shaders.
        Shader _SkyShader    = GD.Load<Shader>("res://addons/jc.godot.time-of-day-common/Shaders/Sky.shader");
        Shader _PVSkyShader  = GD.Load<Shader>("res://addons/jc.godot.time-of-day-common/Shaders/PerVertexSky.shader");
        Shader _AtmFogShader = GD.Load<Shader>("res://addons/jc.godot.time-of-day-common/Shaders/AtmFog.shader");
        Shader _MoonShader   = GD.Load<Shader>("res://addons/jc.godot.time-of-day-common/Shaders/SimpleMoon.shader");

        // Scenes. 
        public PackedScene MoonRender{ get; private set; } = 
            GD.Load<PackedScene>("res://addons/jc.godot.time-of-day-common/Scenes/Moon/MoonRender.tscn");


        // Sky.
        //===============
        void ChangeSkydomeMeshQuality(SkydomeMeshQuality quality)
        {
       
            if(quality == 0)
            {
                SkydomeMesh.RadialSegments = 16;
                SkydomeMesh.Rings = 8;
            }
            else 
            {
                SkydomeMesh.RadialSegments = 64;
                SkydomeMesh.Rings = 64;
            }
        }

        void SetSkyQuality(SkyShaderQuality quality)
        {

            if(quality == 0)
            {
                SkyMaterial.Shader = _SkyShader;
                ChangeSkydomeMeshQuality(SkydomeMeshQuality.Low);
            }
            else
            { 
                SkyMaterial.Shader = _PVSkyShader;
                ChangeSkydomeMeshQuality(SkydomeMeshQuality.High);
            }
        }

        public void SetupSkyResources(SkyShaderQuality quality)
        {
            SetSkyQuality(quality);
        }

        public void SetupSkyResources(int renderPriority)
        {
            SkyMaterial.RenderPriority = renderPriority;
        }

        public void SetupSkyResources(SkyShaderQuality quality, int renderPriority)
        {
            SetSkyQuality(quality);
            SetupSkyResources(renderPriority);
        }

        // Moon.
        //===============

        public void SetupMoonResources()
        {
            MoonMaterial.Shader = _MoonShader;
            MoonMaterial.SetupLocalToScene();
        }

        // Fog.
        //===============

        public void SetupFogResources()
        {
            Vector2 size;
            size.x = 2.0f;
            size.y = 2.0f;
            FullScreenQuad.Size = size;
            FogMaterial.Shader = _AtmFogShader;
            SetupFogResources(127); // default.
        }

        public void SetupFogResources(int renderPriority)
        {
            FogMaterial.RenderPriority = renderPriority;
        }
    }
}
