shader_type spatial;
render_mode unshaded;

uniform sampler2D gradient: source_color;
uniform float fog_intensity:  hint_range(0.0, 1.0);
uniform float fog_amount: hint_range(0.0, 1.0);
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;

void vertex() {
	POSITION = vec4(VERTEX,	1.0);
}

void fragment() {
	vec4 original = texture(SCREEN_TEXTURE, SCREEN_UV);
	
	float depthr = textureLod(DEPTH_TEXTURE, SCREEN_UV,0.0).r;
	
	float A = PROJECTION_MATRIX[2].z;
	float B = PROJECTION_MATRIX[3].z;
	float near = B / (1.0 - A);
	float far = B / (1.0 + A);
	
	
	
	vec3 ndc= vec3(SCREEN_UV, depthr) * 2.0 - 1.0;
	vec4 view = INV_PROJECTION_MATRIX* vec4(ndc, 1.0);
	view.xyz /= view.w;
	//view.xyz = normalize(view).xyz;
	float depth = -view.z;
	
	//float depth = (1.0 / (far * (depthR) + near));
	
	float fog = depth * fog_amount;
	
	vec4 fog_color = texture(gradient, vec2(fog, 0.0));
	if (depth > 1.0)
		ALBEDO =  mix(original.rgb, fog_color.rgb, fog_color.a * fog_intensity);
	else
		ALBEDO = fog_color.rgb;

	//ALBEDO = vec3(far);
	
	float surface_dist = PROJECTION_MATRIX[3][2] / ((depthr * 2.0 -1.0 )+ PROJECTION_MATRIX[2][2]);
	float water_depth = surface_dist ;

	ALBEDO =  mix(original.rgb, vec3(surface_dist* fog_intensity).rgb, fog_color.a);
	
	if(surface_dist >= 1.0)
	{
		//ALBEDO = vec3(1e-20);
		ALBEDO = original.rgb;
	}
}