shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, unshaded, specular_schlick_ggx;

uniform vec4 outer_color : source_color = vec4(0.0);
uniform vec4 inner_color : source_color = vec4(1.0);
uniform float fresnel_amount = 0.0;
instance uniform float flash_amount : hint_range(0.0, 1.0, 0.001) = 0.0;


float fresnel(float amount, vec3 normal, vec3 view)
{
	return pow((1.0 - clamp(dot(normalize(normal), normalize(view)), 0.0, 1.0)), amount);
}

void fragment()
{
	float basic_fresnel = fresnel(fresnel_amount, NORMAL, VIEW);
	vec4 color = mix(inner_color, outer_color, basic_fresnel) * flash_amount;
	ALBEDO = color.rgb;
	ALPHA = color.a;
}