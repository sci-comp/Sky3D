shader_type spatial;
render_mode unshaded, blend_mix, depth_draw_never, cull_front, skip_vertex_transform;

uniform vec3 _sun_direction;
uniform vec3 _moon_direction;
uniform float _clouds_coverage;
uniform float _clouds_thickness;
uniform float _clouds_absorption;
uniform float _clouds_noise_freq;
uniform float _clouds_sky_tint_fade;
uniform float _clouds_intensity;
uniform float _clouds_size;
uniform float _clouds_offset_speed;
uniform vec3 _clouds_offset;
uniform sampler2D _clouds_texture;
const int kCLOUDS_STEP = 8;

uniform vec4 _atm_horizon_light_tint: hint_color;
uniform vec4 _atm_night_tint: hint_color;

const float kPI          = 3.1415927f;
const float kINV_PI      = 0.3183098f;
const float kHALF_PI     = 1.5707963f;
const float kINV_HALF_PI = 0.6366198f;
const float kQRT_PI      = 0.7853982f;
const float kINV_QRT_PI  = 1.2732395f;
const float kPI4         = 12.5663706f;
const float kINV_PI4     = 0.0795775f;
const float k3PI16       = 0.1193662f;
const float kTAU         = 6.2831853f;
const float kINV_TAU     = 0.1591549f;
const float kE           = 2.7182818f;

float saturate(float value){
	return clamp(value, 0.0, 1.0);
}

vec3 saturateRGB(vec3 value){
	return clamp(value.rgb, 0.0, 1.0);
}

vec3 mul(mat3 mat, vec3 vec){
	vec3 ret;
	ret.x = dot(mat[0].xyz, vec.xyz);
	ret.y = dot(mat[1].xyz, vec.xyz);
	ret.z = dot(mat[2].xyz, vec.xyz);
	return ret;
}

vec2 equirectUV(vec3 norm){
	vec2 ret;
	ret.x = (atan(norm.x, norm.z) + kPI) * kINV_TAU;
	ret.y = acos(norm.y) * kINV_PI;
	return ret;
}

float random(vec2 uv){
	float ret = dot(uv, vec2(12.9898, 78.233));
	return fract(43758.5453 * sin(ret));
}

//==============================================================================
// Clouds based in Danil work.
// MIT License.
// See: https://github.com/danilw/godot-utils-and-other/tree/master/Dynamic%20sky%20and%20reflection.
float noiseClouds(vec3 p){
	vec3 pos = vec3(p * 0.01);
	pos.z *= 256.0;
	vec2 offset = vec2(0.317, 0.123);
	vec4 uv= vec4(0.0);
	uv.xy = pos.xy + offset * floor(pos.z);
	uv.zw = uv.xy + offset;
	float x1 = textureLod(_clouds_texture, uv.xy, 0.0).r;
	float x2 = textureLod(_clouds_texture, uv.zw, 0.0).r;
	return mix(x1, x2, fract(pos.z));
}

float cloudsFBM(vec3 p, float l){
	float ret;
	ret = 0.51749673 * noiseClouds(p);  
	p *= l;
	ret += 0.25584929 * noiseClouds(p); 
	p *= l; 
	ret += 0.12527603 * noiseClouds(p); 
	p *= l;
	ret += 0.06255931 * noiseClouds(p);
	return ret;
}


float noiseCloudsFBM(vec3 p){
	float freq = _clouds_noise_freq; //2.76434;
	return cloudsFBM(p, freq);
}

float cloudsDensity(vec3 p, vec3 offset, float t){
	vec3 pos = p * 0.0212242 + offset;
	float dens = noiseCloudsFBM(pos);
	float cov = 1.0 - _clouds_coverage;
	dens *= smoothstep(cov, cov + t, dens);
	return saturate(dens);
}

vec4 renderClouds(vec3 pos, float tm){
	vec4 ret;
	pos.xy = pos.xz / pos.y;
	//pos *= _clouds_size;
	vec3 wind = _clouds_offset * (tm * _clouds_offset_speed);
	
	float marchStep = float(kCLOUDS_STEP) * _clouds_thickness;
	vec3 dirStep = pos * marchStep;
	pos *= _clouds_size;
	
	float t = 1.0; float a = 0.0;
	for(int i = 0; i < kCLOUDS_STEP; i++){
		float h = float(i) / float(kCLOUDS_STEP);
		float density = cloudsDensity(pos, wind, h);
		float sh = saturate(exp2(-_clouds_absorption * density * marchStep));
		t *= sh;
		ret += (t * (exp(h) * 0.571428571) * density * marchStep);
		a += (1.0 - sh) * (1.0 - a);
		pos += dirStep;
	}
	return vec4(ret.rgb * _clouds_intensity, a);
}


varying vec4 world_pos;
varying vec4 moon_coords;
varying vec3 deep_space_coords;
varying vec4 angle_mult;

void vertex(){
	world_pos = (WORLD_MATRIX * vec4(VERTEX, 1e-5));
	angle_mult.x = saturate(1.0 - _sun_direction.y);
	angle_mult.y = saturate(_sun_direction.y + 0.45);
	angle_mult.z = saturate(-_sun_direction.y + 0.30);
	angle_mult.w = saturate(-_sun_direction.y + 0.60);
	VERTEX = (MODELVIEW_MATRIX * vec4(VERTEX, 1e-5)).xyz;
}

void fragment(){
	//vec3 col = vec3(0.0);
	vec3 ray = normalize(world_pos).xyz;
	float horizonBlend = saturate((ray.y - 0.03) * 10.0);
	vec4 clouds = renderClouds(ray, TIME);
	clouds.a = saturate(clouds.a);
	clouds.rgb *= mix(mix(vec3(1.0), _atm_horizon_light_tint.rgb, angle_mult.x), 
		_atm_night_tint.rgb, angle_mult.w);
	clouds.a = mix(0.0, clouds.a, horizonBlend);
	ALBEDO = clouds.rgb;
	ALPHA = clouds.a;
	DEPTH = 1.0;
}


