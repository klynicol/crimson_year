shader_type canvas_item;

// Optional: leave empty to use procedural noise only
uniform sampler2D noise_texture : hint_default_white;
uniform bool use_noise_texture = false;

// Spray shape: cone is narrow at nozzle (UV x=0), widens toward end (UV x=1)
uniform float cone_softness = 2.5;      // How soft the cone edges are (higher = wider, softer)
uniform float cone_center = 0.5;       // Center of spray across UV (0.5 = middle)
uniform float density = 1.2;           // Overall spray density
uniform float mist_scale = 80.0;       // Fine droplet/mist grain size (higher = finer)
uniform float mist_strength = 0.4;     // How visible the mist grain is
uniform float falloff = 0.3;           // Fade spray toward far end (0 = none, 1 = strong)
uniform float scroll_speed = 1.0;      // How fast the noise scrolls (0 = still)
uniform vec2 scroll_direction = vec2(0.0, 1.0); // Direction only (normalized in shader). e.g. (0,1)=up, (1,0)=right

// Procedural noise for mist (used when no texture or layered with texture)
float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

// Simple noise
float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	float a = hash(i);
	float b = hash(i + vec2(1.0, 0.0));
	float c = hash(i + vec2(0.0, 1.0));
	float d = hash(i + vec2(1.0, 1.0));
	return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

// Fractal Brownian Motion
float fbm(vec2 p) {
	float v = 0.0;
	float a = 0.5;
	p *= 4.0;
	v += a * noise(p); p *= 2.0; a *= 0.5;
	v += a * noise(p); p *= 2.0; a *= 0.5;
	v += a * noise(p);
	return v;
}

void fragment() {
	// UV: assume x = along spray (0 = nozzle, 1 = far), y = across spray (0.5 = center)
	vec2 uv = UV;

	// Cone: spray is concentrated along center (y=0.5), falls off toward top/bottom
	float dist_from_center = abs(uv.y - cone_center) * 2.0; // 0 at center, 1 at edges
	float cone = 1.0 - pow(dist_from_center, cone_softness);
	cone = max(0.0, cone);

	// Optional: fade toward far end of spray
	float along = uv.x;
	float distance_falloff = 1.0 - falloff * along;
	cone *= distance_falloff;

	// Mist / droplet grain: scroll offset = direction (normalized) * speed * time (direction only, no texture modulation)
	vec2 dir = length(scroll_direction) > 0.001 ? normalize(scroll_direction) : vec2(0.0, 1.0);
	vec2 scroll_offset = dir * scroll_speed * TIME;

	vec2 mist_uv = uv * mist_scale + scroll_offset;
	float mist = fbm(mist_uv);
	if (use_noise_texture) {
		float tex_noise = texture(noise_texture, uv * 8.0 + scroll_offset).r;
		mist = mix(mist, tex_noise, 0.5);
	}
	mist = mist * mist_strength + (1.0 - mist_strength);

	// Combine: cone shape modulated by mist (breaks up solid cone into spray look)
	float spray = cone * mist * density;
	spray = clamp(spray, 0.0, 1.0);

	// Slight blue-white tint for water
	vec3 water_color = vec3(0.92, 0.96, 1.0);
	COLOR = vec4(water_color, spray);
}
