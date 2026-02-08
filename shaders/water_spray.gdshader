shader_type canvas_item;

// Optional: leave empty to use procedural noise only
uniform sampler2D noise_texture : hint_default_white;
uniform bool use_noise_texture = false;

// Spray shape: cone is narrow at nozzle (UV x=0), widens toward end (UV x=1)
uniform float cone_softness = 2.5;      // Base softness at nozzle (higher = wider, softer)
uniform float cone_softness_spread = 3.0; // How much the cone spreads out at far end (adds to base)
uniform float cone_center = 0.5;       // Center of spray across UV (0.5 = middle)
uniform float density = 1.2;           // Overall spray density
uniform float mist_scale = 80.0;       // Fine droplet/mist grain size (higher = finer)
uniform float mist_strength = 0.4;     // How visible the mist grain is
uniform float falloff = 0.3;           // Cone falloff along spray: fades at both start and end (0 = none, 1 = full cone)
uniform float scroll_speed = 1.0;      // How fast the noise scrolls (0 = still)
uniform vec2 scroll_direction = vec2(0.0, 1.0); // Direction only (normalized in shader). e.g. (0,1)=up, (1,0)=right
uniform float color_variance_strength = 0.15; // How much blue color varies (0 = none, 1 = full variance)
uniform float base_color_r = 0.85;      // Base water color red component (0-1)
uniform float base_color_g = 0.92;      // Base water color green component (0-1)
uniform float base_color_b = 0.98;      // Base water color blue component (0-1)

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

// Fractal Brownian Motion - modified for droplet-like pattern instead of wispy flames
float fbm(vec2 p) {
	float v = 0.0;
	float a = 0.5;
	p *= 4.0;
	v += a * noise(p); p *= 2.0; a *= 0.5;
	v += a * noise(p); p *= 2.0; a *= 0.5;
	v += a * noise(p);
	return v;
}

// Droplet pattern - creates more circular, droplet-like noise instead of wispy patterns
float droplet_noise(vec2 p) {
	// Create a more uniform, granular pattern
	float n1 = noise(p);
	float n2 = noise(p * 1.7 + vec2(11.3, 7.1));
	// Combine with multiplication to create more defined droplets
	float droplets = n1 * n2;
	// Add some fine detail
	float fine = noise(p * 3.5 + vec2(23.7, 19.3)) * 0.3;
	return clamp(droplets + fine, 0.0, 1.0);
}

void fragment() {
	// UV: assume x = along spray (0 = nozzle, 1 = far), y = across spray (0.5 = center)
	vec2 uv = UV;

	// Cone softness increases along the spray to make it spread out more as it decays
	// At nozzle (x=0): uses base cone_softness
	// At far end (x=1): uses cone_softness + cone_softness_spread
	float dynamic_cone_softness = cone_softness + (cone_softness_spread * uv.x);
	
	// Cone: spray is concentrated along center (y=0.5), falls off toward top/bottom
	float dist_from_center = abs(uv.y - cone_center) * 2.0; // 0 at center, 1 at edges
	float cone = 1.0 - pow(dist_from_center, dynamic_cone_softness);
	cone = max(0.0, cone);

	// Cone along spray: strong in middle (x=0.5), fades at both nozzle (x=0) and far end (x=1)
	float along = uv.x;
	float cone_along = 4.0 * along * (1.0 - along); // 0 at start/end, 1 at center
	float distance_falloff = mix(1.0, cone_along, falloff);
	cone *= distance_falloff;

	// Mist / droplet grain: scroll offset = direction (normalized) * speed * time (direction only, no texture modulation)
	vec2 dir = length(scroll_direction) > 0.001 ? normalize(scroll_direction) : vec2(0.0, 1.0);
	vec2 scroll_offset = dir * scroll_speed * TIME;

	vec2 mist_uv = uv * mist_scale + scroll_offset;
	// Use droplet_noise instead of fbm for more water-like, less flame-like pattern
	float mist = droplet_noise(mist_uv);
	if (use_noise_texture) {
		float tex_noise = texture(noise_texture, uv * 8.0 + scroll_offset).r;
		// Reduce texture noise influence to avoid flame-like patterns
		mist = mix(mist, tex_noise, 0.3);
	}
	// Make the pattern more uniform and less wispy
	mist = pow(mist, 1.2); // Slightly sharpen the pattern
	mist = mist * mist_strength + (1.0 - mist_strength);

	// Combine: cone shape modulated by mist (breaks up solid cone into spray look)
	float spray = cone * mist * density;
	spray = clamp(spray, 0.0, 1.0);

	// Base water color (pastel blue - soft and muted)
	vec3 base_water_color = vec3(base_color_r, base_color_g, base_color_b);
	
	// Add blue color variance using mist pattern for more realistic water appearance
	// Use a different noise sample for color variation (offset to avoid correlation with mist)
	// Reduced scroll influence to avoid wispy flame-like patterns
	vec2 color_noise_uv = uv * mist_scale * 0.7 + scroll_offset * 0.2 + vec2(17.3, 23.7);
	float color_noise = droplet_noise(color_noise_uv);
	
	// Create blue variance: more blue in some areas, less in others
	// Variance ranges from -color_variance_strength to +color_variance_strength
	float blue_variance = (color_noise - 0.5) * 2.0 * color_variance_strength;
	
	// Apply variance: subtle pastel blue variation
	vec3 water_color = base_water_color;
	water_color.b = clamp(water_color.b + blue_variance * 0.5, 0.9, 1.0);
	water_color.g = clamp(water_color.g - blue_variance * 0.2, 0.88, 0.95);
	water_color.r = clamp(water_color.r - blue_variance * 0.15, 0.82, 0.9);
	
	COLOR = vec4(water_color, spray);
}