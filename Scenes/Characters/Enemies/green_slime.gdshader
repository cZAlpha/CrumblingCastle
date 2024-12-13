shader_type canvas_item;

uniform vec4 flash_color = vec4(1.0, 1.0, 1.0, 1.0); // Default to white
uniform float flash_strength = 0.0; // Controls flash intensity

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	// Apply the flash color only to the opaque areas of the sprite
	COLOR = mix(tex_color, flash_color * tex_color.a, flash_strength) * tex_color.a;
}
