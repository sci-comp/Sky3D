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

namespace JC.TimeOfDay
{
    [Tool]
    public partial class Skydome : Node
    {

    /*========================
    enviar parametros generales. *
    añadir coordenadas de sol. *
    aladir coordendas de luna.*
    añadir atmosfera. -> Añadir al editor -> Reparar noche.*
    añadir niebla atmosferica.*

    limpiar codigo.
    
    añadir luna.
    añadir espacio exterior.
    añadir nubes simples.
    añadir cumulus.
    añadir controlador de enviro.
    ========================*/

    #region Properties

        private bool _InitPropertiesOk = false;

        #region General.
        
        bool _SkyVisible = true;
        
        public bool SkyVisible 
        {
            get => _SkyVisible;
            set 
            {
                _SkyVisible = value;

                if(!_InitPropertiesOk) 
                    return;

                if(_SkyInstance == null)
                    throw new Exception("Sky instance not found");
                
                _SkyInstance.Visible = value;
            }
        } 

        float _DomeRadius = 10.0f; 
        
        public float DomeRadius
        {
            get => _DomeRadius;
            set 
            {
                _DomeRadius = value;

                if(!_InitPropertiesOk)
                    return;
                
                if(_SkyInstance == null)
                    throw new Exception("Sky instance not found");
                
                _SkyInstance.Scale = value * Vector3.One;
               // _SkyInstance.SetNewScale(value * Vector3.One);
            }
        }


        private float _TonemapLevel = 0.0f;
        public float TonemapLevel 
        {
            get => _TonemapLevel;
            set 
            {
                _TonemapLevel = value;
                SetColorCorrectionParams(value, _Exposure);
            }
        }

        private float _Exposure = 1.3f;
        public float Exposure 
        {
            get => _Exposure;
            set 
            {
                _Exposure = value;
                SetColorCorrectionParams(_TonemapLevel, value);
            }
        }

        private Color _GroundColor = new Color(0.3f, 0.3f, 0.3f, 1.0f);
        public Color GroundColor 
        {
            get => _GroundColor;
            set 
            {
                _GroundColor = value;
                _Resources.SkyMaterial.SetShaderParam(SkyConst.kGroundColor, value);
            }
        }

        private uint _SkyLayers = 4;
        public uint SkyLayers 
        {
            get => _SkyLayers;
            set 
            {
                _SkyLayers = value;
                if(!_InitPropertiesOk)
                    return;
                
                if(_SkyInstance == null)
                    throw new Exception("Sky instance not found");
                
                _SkyInstance.Layers = value;
            }
        }

        private int _SkyRenderPriority = -128;
        public int SkyRenderPriority 
        {
            get => _SkyRenderPriority;
            set 
            {
                _SkyRenderPriority = value;
                _Resources.SetupSkyResources(value);
            }
        }

        #endregion

        #region Sun Coords. 

        private float _SunAzimuth = 0.0f;
        public float SunAzimuth 
        {
            get => _SunAzimuth;
            set 
            {
                _SunAzimuth = value;
                SetSunCoords();
            }
        }

        private float _SunAltitude = -27.387f;
        public float SunAltitude 
        {
            get => _SunAltitude;
            set 
            {
                _SunAltitude = value;
                SetSunCoords();
            }
        }

        bool _FinishSetSunPos = false;

        private Transform _SunTransform = new Transform();
        public Transform SunTransform => _SunTransform;
        public Vector3 SunDirection => _SunTransform.origin - SkyConst.kDefaultPosition;
 
        [Signal]
        public delegate void SunDirectionChanged(Vector3 value);

        [Signal]
        public delegate void SunTransformChanged(Transform value);

        #endregion

        #region Moon Coords.

        private float _MoonAzimuth = 5.0f;
        public float MoonAzimuth 
        {
            get => _MoonAzimuth;
            set 
            {
                _MoonAzimuth = value;
                SetMoonCoords();
            }
        }

        private float _MoonAltitude = -80.0f;
        public float MoonAltitude 
        {
            get => _MoonAltitude;
            set 
            {
                _MoonAltitude = value;
                SetMoonCoords();
            }
        }

        bool _FinishSetMoonPos = false;
        private Transform _MoonTransform = new Transform();
        public Transform MoonTransform => _MoonTransform;
        public Vector3 MoonDirection => _MoonTransform.origin - SkyConst.kDefaultPosition;

        [Signal]
        public delegate void MoonDirectionChanged(Vector3 value);

        [Signal]
        public delegate void MoonTransformChanged(Transform value);

        #endregion

        #region Atmosphere.
        
        private SkyShaderQuality _AtmQuality = SkyShaderQuality.PerPixel;
        public SkyShaderQuality AtmQuality 
        { 
            get => _AtmQuality;
            set 
            {
                _AtmQuality = value;
                _Resources.SetupSkyResources(value);
            }
        }

        private Vector3 _AtmWavelenghts = new Vector3(680.0f, 550.0f, 440.0f);
        public Vector3 AtmWavelenghts 
        {
            get => _AtmWavelenghts;
            set 
            {
                _AtmWavelenghts = value;
                SetBetaRay();
            }
        }

        private float _AtmDarkness = 0.5f;
        public float AtmDarkness 
        {
            get => _AtmDarkness;
            set 
            {
                _AtmDarkness = value;
                _Resources.SkyMaterial.SetShaderParam(SkyConst.kAtmDarkness, value);
                _Resources.FogMaterial.SetShaderParam(SkyConst.kAtmDarkness, value);
            }
        }

        private float _AtmSunIntensity = 30.0f;
        public float AtmSunIntensity 
        {
            get => _AtmSunIntensity;
            set 
            {
                _AtmSunIntensity = value;
                _Resources.SkyMaterial.SetShaderParam(SkyConst.kAtmSunIntensity, value);
                _Resources.FogMaterial.SetShaderParam(SkyConst.kAtmSunIntensity, value);
            }
        }

        private Color _AtmDayTint = new Color(0.784314f, 0.85492f, 0.988235f);
        public Color AtmDayTint 
        {
            get => _AtmDayTint;
            set 
            {
                _AtmDayTint = value;
                _Resources.SkyMaterial.SetShaderParam(SkyConst.kAtmDayTint, value);
                _Resources.FogMaterial.SetShaderParam(SkyConst.kAtmDayTint, value);
            }
        }

        private Color _AtmHorizonLightTint = new Color(0.988235f, 0.698039f, 0.505882f);
        public Color AtmHorizonLightTint 
        {
            get => _AtmHorizonLightTint;
            set 
            {
                _AtmHorizonLightTint = value;
                _Resources.SkyMaterial.SetShaderParam(SkyConst.kAtmHorizonLightTint, value);
                _Resources.FogMaterial.SetShaderParam(SkyConst.kAtmHorizonLightTint, value);
            }
        }

        private bool _AtmEnableMoonScatterMode = false;
        public bool AtmEnableMoonScatterMode 
        {
            get => _AtmEnableMoonScatterMode;
            set 
            {
                _AtmEnableMoonScatterMode = value;
                SetNightIntensity();
            }
        }

        public float AtmNightIntensity
        {
            get 
            {
                if(!AtmEnableMoonScatterMode)
                    return TOD_Math.Saturate(-SunDirection.y + 0.30f);
                
                return TOD_Math.Saturate(MoonDirection.y) * AtmMoonPhasesMult;
            }
        }

        public float AtmMoonPhasesMult 
        {
            get 
            {
                if(!AtmEnableMoonScatterMode)
                    return AtmNightIntensity;
                
                return TOD_Math.Saturate(-SunDirection.Dot(MoonDirection) + 0.60f);
            }
        }

        private Color _AtmNightTint = new Color(0.168627f, 0.2f, 0.25098f);
        public Color AtmNightTint 
        {
            get => _AtmNightTint;
            set 
            {
                _AtmNightTint = value;
                SetNightIntensity();
            }
        }

        private Vector3 _AtmLevelParams = new Vector3(1.0f, 0.0f, 0.0f);
        public Vector3 AtmLevelParams 
        {
            get => _AtmLevelParams;
            set 
            {
                _AtmLevelParams = value;
                _Resources.SkyMaterial.SetShaderParam(SkyConst.kAtmLevelParams, value);
                _Resources.FogMaterial.SetShaderParam(SkyConst.kAtmLevelParams, value);
            }
        }

        private float _AtmThickness = 1.0f;
        public float AtmThickness 
        {
            get => _AtmThickness;
            set 
            {
                _AtmThickness = value;
                _Resources.SkyMaterial.SetShaderParam("_atm_thickness", value);
                _Resources.FogMaterial.SetShaderParam("_atm_thickness", value);
                //SetBetaRay();
            }
        }

        private float _AtmMie = 0.07f;
        public float AtmMie 
        {
            get => _AtmMie;
            set 
            {
                _AtmMie = value;
                SetBetaMie();
            }
        }

        private float _AtmTurbidity = 0.001f;
        public float AtmTurbidity 
        {
            get => _AtmTurbidity;
            set 
            {
                _AtmTurbidity = value;
                SetBetaMie();
            }
        }

        private Color _AtmSunMieTint = new Color(1.0f, 1.0f, 1.0f, 1.0f);
        public Color AtmSunMieTint 
        {
            get => _AtmSunMieTint;
            set 
            {
                _AtmSunMieTint = value;
                _Resources.SkyMaterial.SetShaderParam(SkyConst.kAtmSunMieTint, value);
                _Resources.FogMaterial.SetShaderParam(SkyConst.kAtmSunMieTint, value);
            }
        }

        private float _AtmSunMieIntensity = 1.0f;
        public float AtmSunMieIntensity 
        {
            get => _AtmSunMieIntensity;
            set 
            {
                _AtmSunMieIntensity = value;
                _Resources.SkyMaterial.SetShaderParam(SkyConst.kAtmSunMieIntensity, value);
                _Resources.FogMaterial.SetShaderParam(SkyConst.kAtmSunMieIntensity, value);
            }
        }

        private float _AtmSunMieAnisotropy = 0.8f;
        public float AtmSunMieAnisotropy 
        {
            get => _AtmSunMieAnisotropy;
            set 
            {
                _AtmSunMieAnisotropy = value;
                var partial = ScatterLib.GetPartialMiePhase(value);
                _Resources.SkyMaterial.SetShaderParam(SkyConst.KAtmSunPartialMiePhase, partial);
                _Resources.FogMaterial.SetShaderParam(SkyConst.KAtmSunPartialMiePhase, partial);
            }
        }

        private Color _AtmMoonMieTint = new Color(0.137255f, 0.184314f, 0.290196f);
        public Color AtmMoonMieTint 
        {
            get => _AtmMoonMieTint;
            set 
            {
                _AtmMoonMieTint = value;
                _Resources.SkyMaterial.SetShaderParam(SkyConst.kAtmMoonMieTint, value);
                _Resources.FogMaterial.SetShaderParam(SkyConst.kAtmMoonMieTint, value);
            }
        }

        private float _AtmMoonMieIntensity = 0.7f;
        public float AtmMoonMieIntensity 
        {
            get => _AtmMoonMieIntensity;
            set 
            {
                _AtmMoonMieIntensity = value;
                _Resources.SkyMaterial.SetShaderParam(SkyConst.kAtmMoonMieIntensity, value * AtmMoonPhasesMult);
                _Resources.FogMaterial.SetShaderParam(SkyConst.kAtmMoonMieIntensity, value * AtmMoonPhasesMult);
            }
        }

        private float _AtmMoonMieAnisotropy = 0.8f;
        public float AtmMoonMieAnisotropy 
        {
            get => _AtmMoonMieAnisotropy;
            set 
            {
                _AtmMoonMieAnisotropy = value;
                var partial = ScatterLib.GetPartialMiePhase(value);
                _Resources.SkyMaterial.SetShaderParam(SkyConst.kAtmMoonPartialMiePhase, partial);
                _Resources.FogMaterial.SetShaderParam(SkyConst.kAtmMoonPartialMiePhase, partial);
            }
        }

        #endregion

        #region Atmospheric Fog
        
        private bool _FogVisible = true;
        public bool FogVisible 
        {
            get => _FogVisible;
            set 
            {
                _FogVisible = value;

                if(!_InitPropertiesOk)
                    return;
                
                if(_FogInstance == null)
                    throw new Exception("Fog instance not found");
                
                _FogInstance.Visible = value;
            }
        }

        private float _FogDensity = 0.000735f;
        public float FogDensity
        {
            get => _FogDensity;
            set 
            {
                _FogDensity = value;
                _Resources.FogMaterial.SetShaderParam(SkyConst.kFogDensityP, value);
            }
        }

        private float _FogRayleighDepth = 0.0031f;
        public float FogRayleighDepth
        {
            get => _FogRayleighDepth;
            set 
            {
                _FogRayleighDepth = value;
                _Resources.FogMaterial.SetShaderParam(SkyConst.kFogRayleighDepthP, value);
            }
        }

        private float _FogMieDepth = 0.0001f;
        public float FogMieDepth 
        {
            get => _FogMieDepth;
            set 
            {
                _FogMieDepth = value;
                _Resources.FogMaterial.SetShaderParam(SkyConst.kFogMieDepthP, value);
            }
        }

        private uint _FogLayers = 524288;
        public uint FogLayers 
        {
            get => _FogLayers;
            set 
            {
                _FogLayers = value;

                if(!_InitPropertiesOk)
                    return;
                
                if(_FogInstance == null)
                    throw new Exception("Fog instance not found");
                
                _FogInstance.Layers = value;
            }
        }

        private int _FogRenderPriority = 123;
        public int FogRenderPriority 
        {
            get => _FogRenderPriority;
            set 
            {
                _FogRenderPriority = value;
                _Resources.SetupFogResources(value);
            }
        }

        #endregion

    #endregion

    #region Resources And Instances

        private SkyDomeResources _Resources = new SkyDomeResources();
    
        // Instances.
        private MeshInstance _SkyInstance = null;
        private MeshInstance _FogInstance = null;

        private Viewport _MoonInstance = null;
        private ViewportTexture _MoonRT = null;
        private Spatial _MoonInstanceTransform = null;
        private MeshInstance _MoonInstanceMesh = null;

        private bool CheckInstances
        {
            get 
            {
                _SkyInstance  = GetNodeOrNull<MeshInstance>(SkyConst.kSkyInstance);
                _MoonInstance = GetNodeOrNull<Viewport>(SkyConst.kMoonInstance);
                _FogInstance  = GetNodeOrNull<MeshInstance>(SkyConst.kFogInstance);

                if(_SkyInstance == null)  return false;
                if(_MoonInstance == null) return false;
                if(_FogInstance == null)  return false;

                return true;
            }
        }
    
    #endregion

    #region Build in

        public Skydome() 
        {
            _Resources.SetupSkyResources(_AtmQuality, -128);
            _Resources.SetupMoonResources();
            _Resources.SetupFogResources();

            ForceSetupInstances();

            //  _skypass_material.set_shader_param("_noise_tex", _DEFAULT_STARS_FIELD_NOISE_TEXTURE)
        }

        public override void _EnterTree()
        {

            BuildDome();
            InitProperties();
        }

        public override void _Ready()
        {
            SetSunCoords();
            SetMoonCoords();
        }

    #endregion

    #region Setup

        private void InitProperties()
        {
            _InitPropertiesOk = true;

            // Globals.
            SkyVisible = SkyVisible;
            DomeRadius = DomeRadius;
            TonemapLevel = TonemapLevel;
            Exposure = Exposure;
            GroundColor = GroundColor;
            SkyLayers = SkyLayers;
            SkyRenderPriority = SkyRenderPriority;

            SunAzimuth = SunAzimuth;
            SunAltitude = SunAltitude;

            MoonAzimuth = MoonAzimuth;
            MoonAltitude = MoonAltitude;
            
            // Atmosphere.
            AtmQuality = AtmQuality;
            AtmWavelenghts = AtmWavelenghts;
            AtmDarkness = AtmDarkness;
            AtmSunIntensity = AtmSunIntensity;
            AtmDayTint = AtmDayTint;
            AtmHorizonLightTint = AtmHorizonLightTint;
            AtmEnableMoonScatterMode = AtmEnableMoonScatterMode;
            AtmNightTint = AtmNightTint;
            AtmLevelParams = AtmLevelParams;
            AtmThickness = AtmThickness;
            AtmMie = AtmMie;
            AtmTurbidity = AtmTurbidity;
            AtmSunMieTint = AtmSunMieTint;
            AtmSunMieIntensity = AtmSunMieIntensity;
            AtmSunMieAnisotropy = AtmSunMieAnisotropy;
            AtmMoonMieTint = AtmMoonMieTint;
            AtmMoonMieIntensity = AtmMoonMieIntensity;
            AtmMoonMieAnisotropy = AtmMoonMieAnisotropy;

            FogVisible = FogVisible;
            FogDensity = FogDensity;
            FogRayleighDepth = FogRayleighDepth;
            FogMieDepth = FogMieDepth;
            FogLayers = FogLayers;
            FogRenderPriority = FogRenderPriority;
        }

        private void BuildDome()
        {
            // Sky.
            _SkyInstance = this.GetOrCreate<MeshInstance>(this, SkyConst.kSkyInstance, true);

            // Moon.
            _MoonInstance = GetNodeOrNull<Viewport>(SkyConst.kMoonInstance);
            if(_MoonInstance == null)
            {
       
                _MoonInstance = _Resources.MoonRender.Instance() as Viewport;
                this.AddChild(_MoonInstance);

                _MoonInstance.Owner = this.GetTree().EditedSceneRoot;
            }

            // Fog.
            _FogInstance = this.GetOrCreate<MeshInstance>(this, SkyConst.kFogInstance, true);
            SetupInstances();
        }

        // Prevents save scene erros.
        private void ForceSetupInstances()
        {       
            if(CheckInstances)
            {
                _InitPropertiesOk = true;
                SetupInstances();
            }
        }

        private void SetupInstances()
        {
            if(_SkyInstance == null)
                throw new Exception("Sky instance not found");

            SetupMeshInstance(_SkyInstance, _Resources.SkydomeMesh, _Resources.SkyMaterial, SkyConst.kDefaultPosition);

            if(_MoonInstance == null)
                throw new Exception("Moon instance not found");
            
            _MoonInstanceTransform = _MoonInstance.GetNodeOrNull<Spatial>("MoonTransform");
            _MoonInstanceMesh = _MoonInstanceTransform.GetNodeOrNull<MeshInstance>("Camera/Mesh");
            _MoonInstanceMesh.MaterialOverride = _Resources.MoonMaterial;
            
            if(_FogInstance == null)
                throw new Exception("Fog instance not found");
            
            SetupMeshInstance(_FogInstance, _Resources.FullScreenQuad, _Resources.FogMaterial, Vector3.Zero);
        }

        private void SetupMeshInstance(MeshInstance target, Mesh mesh, Material mat,  Vector3 origin)
        {
            var tmpTransform = target.Transform;
            tmpTransform.origin = origin;
            target.Transform = tmpTransform;
            target.Mesh = mesh;
            target.ExtraCullMargin = SkyConst.kMaxExtraCullMargin;
            target.CastShadow = GeometryInstance.ShadowCastingSetting.Off;
            target.MaterialOverride = mat;
        }

    #endregion


        private void SetColorCorrectionParams(float tonemap, float exposure)
        {
            Vector2 p;
            p.x = tonemap;
            p.y = exposure;
            _Resources.SkyMaterial.SetShaderParam(SkyConst.kColorCorrectionP, p);
            _Resources.FogMaterial.SetShaderParam(SkyConst.kColorCorrectionP, p);
        }

        private void SetSunCoords()
        {
            if(!_InitPropertiesOk)
                return;

            if(_SkyInstance == null)
                throw new Exception("Sky instance not found");
            
            float azimuth = SunAzimuth * TOD_Math.kDegToRad;
            float altitude = SunAltitude * TOD_Math.kDegToRad;

            _FinishSetSunPos = false;
            if(!_FinishSetSunPos)
            {
                _SunTransform.origin = TOD_Math.ToOrbit(altitude, azimuth);
                _FinishSetSunPos = true;
            }

            if(_FinishSetSunPos)
            {
                _SunTransform = _SunTransform.LookingAt(SkyConst.kDefaultPosition, Vector3.Left);
            }

            SetDayState(altitude);
            EmitSignal(nameof(SunTransformChanged), _SunTransform);
            EmitSignal(nameof(SunDirectionChanged), SunDirection);

            // Set Sun Direction.
            _Resources.SkyMaterial.SetShaderParam(SkyConst.kSunDirP, SunDirection);
            _Resources.FogMaterial.SetShaderParam(SkyConst.kSunDirP, SunDirection);
            _Resources.MoonMaterial.SetShaderParam(SkyConst.kSunDirP, SunDirection);

            SetNightIntensity();
        }

        private void SetMoonCoords()
        {
            if(!_InitPropertiesOk)
                return;

            if(_SkyInstance == null)
                throw new Exception("Sky instance not found");

            float azimuth = _MoonAzimuth * TOD_Math.kDegToRad;
            float altitude = _MoonAltitude * TOD_Math.kDegToRad;

            _FinishSetMoonPos = false;
            if(!_FinishSetMoonPos)
            {
                _MoonTransform.origin = TOD_Math.ToOrbit(altitude, azimuth);
                _FinishSetMoonPos = true;
            }

            if(_FinishSetMoonPos)
            {
                _MoonTransform = _MoonTransform.LookingAt(SkyConst.kDefaultPosition, Vector3.Left);
            }

            EmitSignal(nameof(MoonDirectionChanged), MoonDirection);
            EmitSignal(nameof(MoonTransformChanged), _MoonTransform);

            _Resources.SkyMaterial.SetShaderParam(SkyConst.kMoonDirP, MoonDirection);
            _Resources.FogMaterial.SetShaderParam(SkyConst.kMoonDirP, MoonDirection);
            _Resources.SkyMaterial.SetShaderParam(SkyConst.kMoonMatrix, _MoonTransform.basis.Inverse());
            _Resources.MoonMaterial.SetShaderParam(SkyConst.kSunDirP, SunDirection);

            if(_MoonInstanceTransform == null)
                throw new Exception("Moon instance transform not found");
            
            _MoonInstanceTransform.Transform = _MoonTransform;

            SetNightIntensity();
        }

        private void SetBetaRay()
        {
            var wll = ScatterLib.ComputeWavelenghtsLambda(_AtmWavelenghts);
            var wls = ScatterLib.ComputeWavelenghts(wll);
            var betaRay = ScatterLib.ComputeBetaRay(wls);
            _Resources.SkyMaterial.SetShaderParam(SkyConst.kAtmBetaRay, betaRay);
            _Resources.FogMaterial.SetShaderParam(SkyConst.kAtmBetaRay, betaRay);
        }

        private void SetBetaMie()
        {
            var bM = ScatterLib.ComputeBetaMie(_AtmMie, _AtmTurbidity);
            _Resources.SkyMaterial.SetShaderParam(SkyConst.kAtmBetaMie, bM);
            _Resources.FogMaterial.SetShaderParam(SkyConst.kAtmBetaMie, bM);
        }
 
        private void SetNightIntensity()
        {
            Color tint = _AtmNightTint * AtmNightIntensity;
            _Resources.SkyMaterial.SetShaderParam(SkyConst.kAtmNightTint, tint);
            _Resources.FogMaterial.SetShaderParam(SkyConst.kAtmNightTint, tint);

            AtmMoonMieIntensity = AtmMoonMieIntensity;
        }

        private void SetDayState(float v){}
    }
}
