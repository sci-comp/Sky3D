/*========================================================
°                       TimeOfDay.
°                   ======================
°
°   Category: DateTime.
°   -----------------------------------------------------
°   Description:
°       TimeOFDayManager.
°   -----------------------------------------------------
°   Copyright:
°               J. Cuellar 2021. MIT License.
°                   See: LICENSE Archive.
========================================================*/
using Godot;
using System;
using GodotArray = Godot.Collections.Array;
using PropElement = Godot.Collections.Dictionary<object, object>;

namespace JC.TimeOfDay
{

    public enum CelestialCalculationMode
    {
        Simple = 0,
        Realictic
    }

    public class OrbitalElements : Godot.Object // .l. godot .l. unmarshable error
    {

        /// <summary>
        /// Longitude of the ascending node </summary>
        public float N; 

        /// <summary> 
        /// The Inclination to the ecliptic </summary>
        public float i;

        /// <summary>
        /// Argument of perihelion </summary>
        public float w;

        /// <summary>
        /// Semi-major axis, or mean distance from sun </summary>
        public float a;

        /// <summary>
        /// Eccentricity </summary>
        public float e;

        /// <summary>
        /// Mean anomaly </summary>
        public float M;

      /*  public OrbitalElements(float _N, float _i, float _w, float _a, float _e, float _M)
        {
            this.N = _N;
            this.i = _i;
            this.w = _w;
            this.a = _a;
            this.e = _e;
            this.M = _M;
        }*/

        public void GetOrbitalElements(int index, float timeScale)
        {
            if(index == 0) // Sun.
            {
                N = 0.0f;
                i = 0.0f;
                w = 282.9404f + 4.70935e-5f * timeScale;
                a = 0.0f;
                e = 0.016709f - 1.151e-9f * timeScale;
                M = 356.0470f + 0.9856002585f * timeScale;
            }
            else // Moon.
            {
                N = 125.1228f - 0.0529538083f * timeScale;
                i = 5.1454f;
                w = 318.0634f + 0.1643573223f * timeScale;
                a = 60.2666f;
                e = 0.054900f;
                M = 115.3654f + 13.0649929509f * timeScale;
            }
        }
    }

    [Tool]
    public class TimeOfDay : Node
    {
    #region Properties

        #region Target

        Skydome _Dome = null;
        bool _DomeFound = false;

        NodePath _DomePath = null;
        public NodePath DomePath 
        {
            get => _DomePath;
            set 
            {
                _DomePath = value;

                if(value != null)
                    _Dome = GetNodeOrNull<Skydome>(value);
                
                _DomeFound = _Dome == null ? false : true;

                SetCelestialCoords();
            }

        }

        #endregion

        #region DateTime

        public bool SystemSync{ get; set; } = false;
        public float TotalCycleInMinutes{ get; set; } = 15.0f;

        float _TotalHours = 7.0f;
        public float TotalHours 
        {
            get => _TotalHours;
            set 
            {
                _TotalHours = value;
                EmitSignal(nameof(TotalHoursChanged), value);

                if(Engine.EditorHint)
                    SetCelestialCoords();
            }
        }

        int _Day = 12;
        public int Day 
        {
            get => _Day;
            set 
            {
                _Day = value;
                EmitSignal(nameof(DayChanged), value);

                if(Engine.EditorHint)
                    SetCelestialCoords();
            }
        }

        int _Month = 2;
        public int Month 
        {
            get => _Month;
            set 
            {
                _Month = value;
                EmitSignal(nameof(MonthChanged), value);

                if(Engine.EditorHint)
                    SetCelestialCoords();
            }
        }

        int _Year = 2021;
        public int Year 
        {
            get => _Year;
            set
            {
                _Year = value;
                EmitSignal(nameof(YearChanged), value);

                if(Engine.EditorHint)
                    SetCelestialCoords();
            }
        }

        public bool IsLeapYear => DateTimeUtil.ComputeLeapYear(_Year);

        public int MaxDaysPerMonth 
        {
            get 
            {
                switch(_Month)
                {
                    case 1: case 3: case 5: case 7: case 8: case 10: case 12:
                        return 31;
                    case 2:
                        return IsLeapYear ? 29 : 28;
                }
                return 30;
            }
        }

        public float TimeCycleDuration => TotalCycleInMinutes * 60.0f;

        public bool IsBeginOfTime => _Year == 1 && _Month == 1 && _Day == 1;
        public bool IsEndOfTime => _Year == 9999 && _Month == 12 && _Day == 31;

        public DateTime DateTimeOs{ get; private set; }

        [Signal]
        public delegate void TotalHoursChanged(float value);

        [Signal]
        public delegate void DayChanged(int value);

        [Signal]
        public delegate void MonthChanged(int value);

        [Signal]
        public delegate void YearChanged(int value);

        #endregion

        #region Planetary

        CelestialCalculationMode _CelestialsCalculations = CelestialCalculationMode.Simple;
        public CelestialCalculationMode CelestialsCalculations 
        {
            get => _CelestialsCalculations;
            set 
            {
                _CelestialsCalculations = value;

                if(Engine.EditorHint)
                    SetCelestialCoords();

                PropertyListChangedNotify();
            }
        }

        // Location.
        float _Latitude = 42.0f;
        public float Latitude 
        {
            get => _Latitude;
            set 
            {
                _Latitude = value;

                if(Engine.EditorHint)
                    SetCelestialCoords();
            }
        }

        float _Longitude = 0.0f;
        public float Longitude 
        {
            get => _Longitude;
            set 
            {
                _Longitude = value;

                if(Engine.EditorHint)
                    SetCelestialCoords();
            }
        }

        float _UTC = 0.0f;
        public float UTC 
        {
            get => _UTC;
            set 
            {
                _UTC = value;
                
                if(Engine.EditorHint)
                    SetCelestialCoords();
            }
        }

        // Celestials.
        public float CelestialUpdateTime{ get; set; } = 0.0f;
        float _CelestialUpdateTimer = 0.0f;

        bool _ComputeMoonCoords = false;
        public bool ComputeMoonCoords 
        {
            get => _ComputeMoonCoords;
            set 
            {
                _ComputeMoonCoords = value;

                if(Engine.EditorHint)
                    SetCelestialCoords();
                
                PropertyListChangedNotify();
            }
        }

        Vector2 _MoonCoordsOffset = Vector2.Zero;
        public Vector2 MoonCoordsOffset
        {
            get => _MoonCoordsOffset;
            set 
            {
                _MoonCoordsOffset = value;

                if(Engine.EditorHint)
                    SetCelestialCoords();
            }
        }

        private float LatitudeRad => _Latitude * TOD_Math.kDegToRad;
        private float TotalHoursUTC => _TotalHours - _UTC;

        private float TimeScale => (367.0f * _Year - (7.0f * (_Year + ((_Month + 9.0f) / 12.0f))) / 4.0f + (275.0f * _Month) / 9.0f + _Day - 730530.0f) + _TotalHours / 24.0f;
        
        private float Oblecl => (23.4393f - 3.563e-7f * TimeScale) * TOD_Math.kDegToRad;

        private Vector2 _SunCoords, _MoonCoords;

        private float _SunDistance;
        private float _TrueSunLongitude;
        private float _MeanSunLongitude;
        private float _SideralTime;
        private float _LocalSideralTime;

        private OrbitalElements _SunOrbitalElements = new OrbitalElements();
        private OrbitalElements _MoonOrbitalElements = new OrbitalElements();

        #endregion

    #endregion

    #region Override

        public TimeOfDay()
        {
            TotalHours = TotalHours;
            Day = Day;
            Month = Month;
            Year = Year;
            Latitude = Latitude;
            Longitude = Longitude;
            UTC = UTC;
        }

        public override void _Ready()
        {
            DomePath = DomePath;
        }

        public override void _Process(float delta)
        {
            if(Engine.EditorHint)
                return;
            
            if(!SystemSync)
            {
                TimeProcess(delta);
                RepeatFullCycle();
                CheckCycle();
            }
            else 
            {
                GetDateTimeOs();
            }

            _CelestialUpdateTimer += delta;
            if(_CelestialUpdateTimer > CelestialUpdateTime)
                SetCelestialCoords();
                _CelestialUpdateTimer = 0.0f;
        }


    #endregion


    #region DateTime

    public void SetTime(int hour, int minute, int second)
    {
        TotalHours = DateTimeUtil.ToTotalHours(hour, minute, second);
    }

    void TimeProcess(float delta)
    {
        if(TimeCycleDuration != 0.0f)
            TotalHours += delta / TimeCycleDuration * DateTimeUtil.kTotalHours;
    }

    void GetDateTimeOs()
    {
        DateTimeOs = DateTime.Now;
        SetTime(DateTimeOs.Hour, DateTimeOs.Minute, DateTimeOs.Second);
        Day   = DateTimeOs.Day;
        Month = DateTimeOs.Month;
        Year  = DateTimeOs.Year;
    }

    void RepeatFullCycle()
    {
        if(IsEndOfTime && TotalHours >= 23.9999)
        {
            Year = 1; Month = 1; Day = 1;
            TotalHours = 0.0f;
        }
        
        if(IsBeginOfTime && TotalHours < 0.0f)
        {
            Year = 9999; Month = 12; Day = 31;
            TotalHours = 23.9999f;
        }
    }

    void CheckCycle()
    {
        if(_TotalHours > 23.9999)
        {
            Day += 1;
            TotalHours = 0.0f;
        }

        if(_TotalHours < 0.0000f)
        {
            Day -= 1;
            TotalHours = 23.9999f;
        }

        if(_Day > MaxDaysPerMonth)
        {
            Month += 1;
            Day = 1;
        }

        if(_Day < 1)
        {
            Month -= 1;
            Day = 31;
        }

        if(_Month > 12)
        {
            Year += 1;
            Month = 1;
        }

        if(_Month < 1)
        {
            Year -= 1;
            Month = 12;
        }
    }

    #endregion

    #region Planetary


        void SetCelestialCoords()
        {
            if(!_DomeFound)
                return;
            
            switch(_CelestialsCalculations)
            {
                case CelestialCalculationMode.Simple:
                    ComputeSimpleSunCoords();
                    _Dome.SunAltitude = _SunCoords.y;
                    _Dome.SunAzimuth = _SunCoords.x;

                    if(_ComputeMoonCoords)
                    {
                        ComputeSimpleMoonCoords();
                        _Dome.MoonAltitude = _MoonCoords.y;
                        _Dome.MoonAzimuth = _MoonCoords.x;
                    }

                break;

                case CelestialCalculationMode.Realictic:

                    ComputeRealisticSunCoords();
                    _Dome.SunAltitude = _SunCoords.y * TOD_Math.kRadToDeg;
                    _Dome.SunAzimuth = _SunCoords.x * TOD_Math.kRadToDeg;
                    if(_ComputeMoonCoords)
                    {
                        ComputeRealisticMoonCoords();
                        _Dome.MoonAltitude = _MoonCoords.y * TOD_Math.kRadToDeg;
                        _Dome.MoonAzimuth = _MoonCoords.x * TOD_Math.kRadToDeg;
                    }

                break;
            }
   
        }

        void ComputeSimpleSunCoords()
        {
            var altitude = (TotalHoursUTC + (TOD_Math.kDegToRad * _Longitude)) * (360/24);
            _SunCoords.y = (180.0f - altitude);
            _SunCoords.x = _Latitude;
        }

        void ComputeSimpleMoonCoords()
        {
            _MoonCoords.y = (180.0f - _SunCoords.y) + _MoonCoordsOffset.y;
            _MoonCoords.x = (180.0f + _SunCoords.x) + _MoonCoordsOffset.x;
        }

        void ComputeRealisticSunCoords()
        {
            #region Orbital Elements

            // Get orbital elements.
            _SunOrbitalElements.GetOrbitalElements(0, TimeScale);
            _SunOrbitalElements.M = TOD_Math.Rev(_SunOrbitalElements.M);

            GD.Print(_SunOrbitalElements.M);

            // Mean anomaly in radiants.
            float MRad = TOD_Math.kDegToRad * _SunOrbitalElements.M;

            #endregion

            #region Eccentric Anomaly

            float E = _SunOrbitalElements.M + TOD_Math.kRadToDeg * _SunOrbitalElements.e * 
                Mathf.Sin(MRad) * (1 + _SunOrbitalElements.e * Mathf.Cos(MRad));
            
            float ERad = TOD_Math.kDegToRad * E;

            #endregion

            #region Rectangular coordinates

            // Rectangular coordinates of the sun in the plane of the ecliptic.
            float xv = Mathf.Cos(ERad) - _SunOrbitalElements.e;
            float yv = Mathf.Sin(ERad) * Mathf.Sqrt(1 - _SunOrbitalElements.e * _SunOrbitalElements.e);

            #endregion

            #region Distance and True anomaly

            // Convert to distance and true anomaly(r = radians, v = degrees).
            float r = Mathf.Sqrt(xv * xv + yv * yv);
            float v = TOD_Math.kRadToDeg * Mathf.Atan2(yv, xv);
            _SunDistance = r;

            #endregion

            #region True Longitude 

            float lonSun = v + _SunOrbitalElements.w;
            lonSun = TOD_Math.Rev(lonSun);

            float lonSunRad = TOD_Math.kDegToRad * lonSun;
            _TrueSunLongitude = lonSunRad;

            #endregion

            #region Ecliptic and Ecuatorial Coods

            // Ecliptic rectangular coordinates
            float xs = r * Mathf.Cos(lonSunRad);
            float ys = r * Mathf.Sin(lonSunRad);

            // Ecliptic rectangular coordinates rotate these to equatorial coordinates
            float obleclCos = Mathf.Cos(Oblecl);
            float obleclSin = Mathf.Sin(Oblecl);

            float xe = xs;
            float ye = ys * obleclCos - 0.0f * obleclSin;
            float ze = ys * obleclSin + 0.0f * obleclCos;

            #endregion

            #region Ascension and Declination

            float RA = TOD_Math.kRadToDeg * Mathf.Atan2(ye, xe) / 15; // Right ascension.
            float decl = Mathf.Atan2(ze, Mathf.Sqrt(xe * xe + ye * ye)); // Declination.

            // Mean longitude.
            float L = _SunOrbitalElements.w + _SunOrbitalElements.M;
            L = TOD_Math.Rev(L);

            _MeanSunLongitude = L;

            #endregion

            #region Sideral Time and Hour Angle

            float GMST0 = ((L/15) + 12);
            _SideralTime = GMST0 + TotalHoursUTC + _Longitude / 15; // + 15/15
            _LocalSideralTime = TOD_Math.kDegToRad * _SideralTime * 15;

            float HA = (_SideralTime - RA) * 15;
            float HARAD = TOD_Math.kDegToRad * HA;

            #endregion

            #region Hour angle and declination in rectangular coords

            // HA and Decl in rectangular coords.
            float declCos = Mathf.Cos(decl);
            float x = Mathf.Cos(HARAD) * declCos; // X Axis points to the celestial equator in the south.
            float y = Mathf.Sin(HARAD) * declCos; // Y axis points to the horizon in the west.
            float z = Mathf.Sin(decl); // Z axis points to the north celestial pole.

            // Rotate the rectangualar coordinates system along of the Y axis.
            float sinLat = Mathf.Sin(_Latitude * TOD_Math.kDegToRad);
            float cosLat = Mathf.Cos(_Latitude * TOD_Math.kDegToRad);
            float xhor = x * sinLat - z * cosLat;
            float yhor = y;
            float zhor = x * cosLat + z * sinLat;

            #endregion

            #region Azimuth and Altitude 

            _SunCoords.x = Mathf.Atan2(yhor, xhor) + Mathf.Pi;
            _SunCoords.y = (Mathf.Pi * 0.5f) - Mathf.Asin(zhor); // atan2(zhor, sqrt(xhor * xhor + yhor * yhor))

            #endregion
        }

        void ComputeRealisticMoonCoords()
        {
            /*
_set_latitude_rad(); _set_total_hours_utc(); _set_time_scale()
	_set_oblecl()
	
	# Get orbital elements.
	_sun_orbital_elements.get_orbital_elements(0, _time_scale) 
	_sun_orbital_elements.M = SkyMath.rev(_sun_orbital_elements.M)
	
	# Mean Anomaly in radians.
	var MRad: float = SkyMath.DEG_2_RAD * _sun_orbital_elements.M
	
	# Eccentric anomaly.
	#E = M + (180/pi) * e * sin(M) * (1 + e * cos(M))
	var E: float = _sun_orbital_elements.M + SkyMath.RAD_2_DEG * _sun_orbital_elements.e * sin(MRad) * (1 + _sun_orbital_elements.e * cos(MRad))
	
	var ERad = SkyMath.DEG_2_RAD * E
	
	# Rectangular coordinates.
	# Rectangular coordinates of the sun in the plane of the ecliptic.
	var xv: float = cos(ERad) - _sun_orbital_elements.e
	var yv: float = sin(ERad) * sqrt(1 - _sun_orbital_elements.e * _sun_orbital_elements.e)
	
	# Convert to distance and true anomaly(r = radians, v = degrees).
	var r: float = sqrt(xv * xv + yv * yv)
	var v: float = SkyMath.RAD_2_DEG * atan2(yv, xv)
	_sun_distance = r # Set sun distance.

	# True longitude.
	var lonSun: float = v + _sun_orbital_elements.w
	lonSun = SkyMath.rev(lonSun) # Normalize.
	var lonSunRad: float = SkyMath.DEG_2_RAD * lonSun # To radians.
	_true_sun_longitude = lonSunRad # Set sun longitude
	
	# Ecliptic and Ecuatorial coords.
	# Ecliptic rectangular coordinates
	var xs: float = r * cos(lonSunRad)
	var ys: float = r * sin(lonSunRad)
	
	# Ecliptic rectangular coordinates rotate these to equatorial coordinates
	var oblecCos: float = cos(_oblecl)
	var oblecSin: float = sin(_oblecl)
	var xe: float = xs
	var ye: float = ys * oblecCos - 0.0 * oblecSin
	var ze: float = ys * oblecSin + 0.0 * oblecCos

	# ascension and declination.
	var RA: float = SkyMath.RAD_2_DEG * atan2(ye, xe) / 15 # Right ascension.
	
	# Decl =  atan2( zequat, sqrt( xequat*xequat + yequat*yequat) )
	var decl = atan2(ze, sqrt(xe * xe + ye * ye)) # Declination.
	
	# Mean longitude.
	var L: float = _sun_orbital_elements.w + _sun_orbital_elements.M
	L = SkyMath.rev(L)
	
	# Set mean sun longitude.
	_mean_sun_longitude = L
	
	# Sideral time.
	var GMST0 = ((L/15) + 12)
	
	_sideral_time = GMST0 + _total_hours_utc + longitude / 15 # + 15 / 15
	_local_sideral_time =  SkyMath.DEG_2_RAD * _sideral_time * 15
	
	# Hour angle.
	var HA: float = (_sideral_time - RA) * 15
	
	# Hour angle in radians.
	var HARAD: float = SkyMath.DEG_2_RAD * HA
	
	# Hour angle and declination in rectangular coords.
	# HA anf Decl in rectangular coordinates.
	var declCos: float = cos(decl)
	var x: float = cos(HARAD) * declCos # X Axis points to the celestial equator in the south.
	var y: float = sin(HARAD) * declCos # Y axis points to the horizon in the west.
	var z: float = sin(decl) # Z axis points to the north celestial pole.
	
	# Rotate the rectangualar coordinates system along of the Y axis.
	var sinLat: float = sin(latitude * SkyMath.DEG_2_RAD)
	var cosLat: float = cos(latitude * SkyMath.DEG_2_RAD)
	var xhor: float = x * sinLat - z * cosLat
	var yhor: float = y
	var zhor: float = x * cosLat + z * sinLat
	
	# Return azimtuh and altitude.
	_sun_coords.x = atan2(yhor, xhor) + PI
	_sun_coords.y =(PI * 0.5) - asin(zhor) # atan2(zhor, sqrt(xhor * xhor + yhor * yhor)) 
    */
        }

        #endregion

    #region Properties 

        public override GodotArray _GetPropertyList()
        {
            GodotArray ret = new GodotArray();

            PropElement pTitle = new PropElement
            {
                {"name", "TimeOfDay"},
                {"type", Variant.Type.Nil},
                {"usage", PropertyUsageFlags.Category}
            };
            ret.Add(pTitle);

        #region Target

            PropElement pTarget = new PropElement 
            {
                {"name", "Target"},
                {"type", Variant.Type.Nil},
                {"usage", PropertyUsageFlags.Group}
            };
            ret.Add(pTarget);
        
            PropElement pDomePath = new PropElement
            {
                {"name", "DomePath"},
                {"type", Variant.Type.NodePath}
            };
            ret.Add(pDomePath);
        
        #endregion

        #region DateTime

            PropElement pDateTimeGroup = new PropElement
            {
                {"name", "DateTime"},
                {"type", Variant.Type.Nil},
                {"usage", PropertyUsageFlags.Group}
            };
            ret.Add(pDateTimeGroup);

            PropElement pSystemSync = new PropElement
            {
                {"name", "SystemSync"},
                {"type", Variant.Type.Bool}
            };
            ret.Add(pSystemSync);

            PropElement pTotalCycleInMinutes = new PropElement
            {
                {"name", "TotalCycleInMinutes"},
                {"type", Variant.Type.Real}
            };
            ret.Add(pTotalCycleInMinutes);

            PropElement pTotalHours = new PropElement
            {
                {"name", "TotalHours"},
                {"type", Variant.Type.Real},
                {"hint", PropertyHint.Range},
                {"hint_string", "0.0, 24.0"}
            };
            ret.Add(pTotalHours);

            PropElement pDay = new PropElement
            {
                {"name", "Day"},
                {"type", Variant.Type.Int},
                {"hint", PropertyHint.Range},
                {"hint_string", "1, 31"}
            };
            ret.Add(pDay);

            PropElement pMonth = new PropElement
            {
                {"name", "Month"},
                {"type", Variant.Type.Int},
                {"hint", PropertyHint.Range},
                {"hint_string", "1, 12"}

            };
            ret.Add(pMonth);

            PropElement pYear = new PropElement
            {
                {"name", "Year"},
                {"type", Variant.Type.Int},
                {"hint", PropertyHint.Range},
                {"hint_string", "1, 9999"}
            };
            ret.Add(pYear);

        #endregion

        #region Planetary

            PropElement pPlanetaryGroup = new PropElement
            {
                {"name", "Planetary And Location"},
                {"type", Variant.Type.Nil},
                {"usage", PropertyUsageFlags.Group}
            };
            ret.Add(pPlanetaryGroup);

            PropElement pCelestialCalculation = new PropElement
            {
                {"name", "CelestialsCalculations"},
                {"type", Variant.Type.Int},
                {"hint", PropertyHint.Enum},
                {"hint_string", "Simple, Realistic"}
            };
            ret.Add(pCelestialCalculation);

            PropElement pComputeMoonCoords = new PropElement
            {
                {"name", "ComputeMoonCoords"},
                {"type", Variant.Type.Bool}
            };
            ret.Add(pComputeMoonCoords);

            if(CelestialsCalculations == 0 && ComputeMoonCoords)
            {
                PropElement  pMoonOffset = new PropElement
                {
                    {"name", "MoonCoordsOffset"},
                    {"type", Variant.Type.Vector2}
                };
                ret.Add(pMoonOffset);
            }

            PropElement pLatitude = new PropElement
            {
                {"name", "Latitude"},
                {"type", Variant.Type.Real},
                {"hint", PropertyHint.Range},
                {"hint_string", "-90.0, 90.0"}
            };
            ret.Add(pLatitude);

            PropElement pLongitude = new PropElement 
            {
                {"name", "Longitude"},
                {"type", Variant.Type.Real},
                {"hint", PropertyHint.Range},
                {"hint_string", "-180.0, 180.0"}
            };
            ret.Add(pLongitude);


            PropElement pUTC = new PropElement 
            {
                {"name", "UTC"},
                {"type", Variant.Type.Real},
                {"hint", PropertyHint.Range},
                {"hint_string", "-12.0, 12.0"}
            };
            ret.Add(pUTC);

            PropElement pCelestialsUpdateTime = new PropElement
            {
                {"name", "CelestialsUpdateTime"},
                {"type", Variant.Type.Real}
            };
            ret.Add(pCelestialsUpdateTime);

        #endregion


            return ret;
        }


    #endregion

    }
}