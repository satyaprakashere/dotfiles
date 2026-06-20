// Ghostty GLSL Shader: Subtle Paper Texture / Grain
// Adapted for terminal backgrounds

// Simple pseudo-random hash function
float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

// 2D Noise function for organic paper grain
float noise(vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);

    // Four corners in 2D of a tile
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));

    // Smooth interpolation
    vec2 u = f * f * (3.0 - 2.0 * f);

    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    // Fetch the original terminal background color
    vec4 terminalColor = texture(iChannel0, fragCoord / iResolution.xy);

    // Scale coordinates to control grain size (higher multiplier = finer grain)
    vec2 uv = fragCoord * 1.5;

    // Generate multi-octave noise for a fibrous paper feel
    float n = noise(uv) * 0.5 + noise(uv * 2.0) * 0.25;

    // Convert noise into a very subtle brightness offset (adjust strength here)
    float grainStrength = 0.04; 
    float grain = (n - 0.5) * grainStrength;

    // Apply grain modifier to the terminal's background
    vec3 paperColor = terminalColor.rgb + vec3(grain);

    fragColor = vec4(paperColor, terminalColor.a);
}
