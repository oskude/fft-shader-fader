#version 410 core

uniform vec2 v2Resolution;
uniform sampler1D texFFTSmoothed;

uniform float midiFreqMin;
uniform float midiFreqMax;
uniform float midiFadePower;

layout(location = 0) out vec4 out_color;

// https://www.shadertoy.com/view/MsS3Wc
vec3 hsv2rgb (in vec3 c) {
	vec3 rgb = clamp(abs(mod(c.x*6.0+vec3(0.0,4.0,2.0),6.0)-3.0)-1.0, 0.0, 1.0);
	rgb = rgb*rgb*(3.0-2.0*rgb); // cubic smoothing
	return c.z * mix(vec3(1.0), rgb, c.y);
}

// https://stackoverflow.com/a/3451607
float remap (
	in float input,   // your input value
	in float in_min,  // has minimum value of
	in float in_max,  // has maximum value of
	in float out_min, // will be minimum value of
	in float out_max  // will be maximum value of
) {
	return out_min + (input - in_min) * (out_max - out_min) / (in_max - in_min);
}

void main(void)
{
	float line_end_fade_power = midiFadePower * 3.0;
	float limit_freq_min = midiFreqMin;
	float limit_freg_max = midiFreqMax;

	vec2 uv = gl_FragCoord.xy / v2Resolution;

	float p = remap(uv.y, 0.0, 1.0, limit_freq_min, limit_freg_max);
	float fft = texture(texFFTSmoothed, p).r * 100;

	float fade = uv.x; // fadeout "line" edges from middle
	if (fade > 0.5) {
		fade = 1.0 - fade;
	}
	fade = pow(fade, line_end_fade_power); // fadeout faster, or is it slower?

	vec3 color = hsv2rgb(vec3(
		uv.y,
		1.0 - (fft / 250), // over saturate with white
		fft * fade
	));

	out_color = vec4(color, 1.0);
}
