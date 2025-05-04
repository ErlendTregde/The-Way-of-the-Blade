shader_type spatial;
render_mode specular_toon,diffuse_toon,cull_disabled;

group_uniforms ANIMATION;
uniform float progress : hint_range(0.0, 1.0, 0.01) = 0.0;
// This value animates this shader when DERIVE_PROGRESS is set to 0.0

uniform float derive_progress : hint_range(-1.0, 1.0, 1.0) = 0.0;
// 0.0 Use PROGRESS (Change value in code or animation player)
// -1.0 Use TIME (Idle Loop)
// 1.0 use LIFETIME (Particle)

uniform float ease_progress : hint_range(-1.0, 1.0, 1.0) = 0.0;
// 0.0 No easing
// -1.0 Ease : Expo In
// 1.0 Ease : Expo Out

uniform float time_scale : hint_range(0.0, 8.0, 0.01) = 1.0;
uniform float anim_rot_amt : hint_range(0.0, 1.0, 0.01) = 1.0;
// ^^^
// The shader is setup to rotate the main image as it progresses, 
// set this to 0 to disable that behaviour
group_uniforms;

group_uniforms SHAPE;
uniform sampler2D base_noise : hint_default_white, filter_linear_mipmap;
// ^^^ 
// This is the basis of the main rough looking shape, It's width should be 
// stretched but that's up to you.

// these should be GradientTexture1Ds
uniform sampler2D width_gradient_mask : hint_default_transparent;
// ^^^ 
// This clips the slashes width, use white for what you want to clip, and 
// black for what you want to keep.
uniform sampler2D length_gradient_mask : hint_default_transparent;
// ^^^ 
// This clips the slashes "length" and controls how it animates... uh try 
// using a gradient that progresses 'white -> black -> white'
uniform sampler2D highlight : source_color,hint_default_transparent;
// ^^^ 
// This will be overlayed ontop of the main shape, it will get masked by 
// LENGTH_GRADIENT_MASK so it animates in sync with the main shape.

uniform float zoom : hint_range(0.0, 2.0, 0.01) = 0.6; // Scales the final image, Inverted (smaller means bigger)
uniform float rotate_all : hint_range(0.0, 360.0, 0.1) = 0.0; // Rotates the final image by x degrees
group_uniforms;

group_uniforms COLORING;
uniform float emission_strength : hint_range(0.0, 1.0, 0.1) = 1.0;
// ^^^
// Makes it glow

uniform float mix_strength : hint_range(0.0, 2.0, 0.01) = 1.0; 
// ^^^
// Controls how COLOR_LOOKUP is applied, less will move it closer to black if
// COLOR_LOOKUP isn't empty

// this should be a GradientTexture1D
uniform sampler2D color_lookup : source_color,hint_default_white;

varying float LIFETIME;
varying float INDEX;

vec2 polar_coordinates(vec2 uv, vec2 center, float zoomm, float repeat) {
	vec2 dir = uv - center;
	float radius = length(dir) * 2.0;
	float angle = atan(dir.y, dir.x) * 1.0/(3.1416 * 2.0);
	return mod(vec2(radius * zoomm, angle * repeat), 1.0);
}

vec2 rotate(vec2 uv, vec2 pivot, float angle) {
	mat2 rotation = mat2(vec2(sin(angle), -cos(angle)),
						vec2(cos(angle), sin(angle)));
	uv -= pivot;
	uv = uv * rotation;
	uv += pivot;
	return uv;
}

// Easing Functions Adapted From https://easings.net/

float easeOutExpo(float x) {
	return 1.0 - pow(2.0, -10.0 * x);
}

float easeInExpo(float x) {
	return pow(2.0, 10.0 * x - 10.0);
}

//Circ
float easeInOut(float x) {
	float result;
	if (x < 0.5) {result = (1.0 - sqrt(1.0 - pow(2.0 * x, 2.0))) / 2.0;}
	else {result =(sqrt(1.0 - pow(-2.0 * x + 2.0, 2.0)) + 1.0) / 2.0;}
	return result;
}

void vertex() {
	LIFETIME = INSTANCE_CUSTOM.y;
	INDEX = float(INSTANCE_ID);
}

float get_progress() {
	float p;
	float final;
	if (derive_progress > 0.0) {p = LIFETIME;}
	else if (derive_progress < 0.0) {p = mod(TIME * time_scale,1.0);}
	// You can change out what p is equal to here to tweak the idle loop behaviour
	// abs(sin(TIME * time_scale)) [Back and Forth]
	// mod(TIME * time_scale,1.0) [Over and Over]
	else {p = progress;}
	
	if (ease_progress > 0.0) {final = easeOutExpo(p);}
	else if (ease_progress < 0.0) {final = easeInExpo(p);}
	else {final = p;}
	
	return final;
}

void fragment() {
	// Get Values
	float p = get_progress();
	vec2 aUV = polar_coordinates(rotate(UV,vec2(0.5),radians(rotate_all)),vec2(0.5),zoom,1.0);
	vec4 b = texture(base_noise,aUV - vec2(0.0,p));
	vec4 wm = texture(width_gradient_mask,aUV);
	vec4 lm = texture(length_gradient_mask,rotate(aUV-vec2(0.0,easeInOut(p * anim_rot_amt)),vec2(0.5),radians(180.0)));
	
	// Combine Them
	vec4 prefinal = (b-wm) - lm;
	vec3 albe = vec3(1.0)*(texture(color_lookup,vec2(clamp(prefinal.r * UV.x,0.0,1.0),0.0)).rgb*mix_strength);
	vec4 high = clamp(texture(highlight,aUV) - (lm),0.0,1.0);
	
	// Apply Them
	ALBEDO = clamp(albe + high.rgb,0.0,1.0);
	EMISSION = clamp(albe + high.rgb,0.0,1.0) * (3.0 * emission_strength);
	
	float start = abs(cos(p * PI));
	float end = abs(cos(p * PI));
	ALPHA *= clamp(smoothstep(start,end,prefinal.r) + smoothstep(clamp(start,0.0,0.2),clamp(end,0.0,0.2),(high.r * 0.2)),0.0,1.0) * COLOR.a;
}
