/**
	Based on : https://godotshaders.com/shader/squish-sprite/
	Modified by Azeru (github.com/AzeruMaker)
*/
shader_type canvas_item;

/**
	Boolean : Check if you want to shader to work on vertical
*/
uniform bool vertical = false; 

/**
	Boolean : 	Check if you want to shader resize the whole image
*/
uniform bool resize_active = false;

/**
	Float : 	Resize X + Y
*/
uniform float resize_global : hint_range(0, 10) = 1;

/**
	Float : 	Resize X
*/
uniform float resize_x : hint_range(0, 10) = 1;

/**
	Float : 	Resize Y
*/
uniform float resize_y : hint_range(0, 10) = 1;


/**
	Boolean : Enable the rotation
	You can only use 1 "Active" for :
		- Rotation
		- Squeeze
		- Stretch
*/
uniform bool rotate_active = false;

/**
	Float : Rotate the picture
	1.0 : Left
	1.5 : Upside down
	2.0 : Right
	2.5 : Normal
*/
uniform float rotate : hint_range(1.0, 3.0, 0.1) = 2.5;

/**
	Boolean : Enable the squeeze
	You can only use 1 "Active" for :
		- Rotation
		- Squeeze
		- Stretch
*/
uniform bool stretch_ative = false;

/**
	Flaot : How much do you want squeeze (1 to 10 time)
*/
uniform float stretch : hint_range(0, 10);

/**
	Boolean : Enable the stretch
	You can only use 1 "Active" for :
		- Rotation
		- Squeeze
		- Pack
*/
uniform bool pack_active = false;

/**
	Float : Pack out the image
*/
uniform float pack_curved : hint_range(-1, 0) = 0;
/**
	Float : How much do you want to pack the image
*/
uniform float pack_center : hint_range(0, 1) = 1;
/**
	Float : Strech without curved (You can use redimension)
*/
uniform float pack_global : hint_range(0, 1.5) = 1;

void vertex()
{
	if (pack_active) {
		if(vertical) {
			VERTEX.y *=  1.0 * pack_global;		
		}
		else {
			VERTEX.x *=  1.0 * pack_global;		
		}
	}
	
	if (stretch_ative) {
		if (vertical) {
			VERTEX.y *= 1.0 + stretch;
		}
		else {
			VERTEX.x *= 1.0 + stretch;
		}
	}
	
	if (resize_active) {
		VERTEX.x *= 1.0 * resize_global * resize_x;	
		VERTEX.y *= 1.0 * resize_global * resize_y;	
	}	

}

float bulge_function(float y)
{
	return sqrt(1.0 - y*y);
}

vec2 rotateUVmatrinx(vec2 uv, vec2 pivot, float rotation)
{
	mat2 rotation_matrix=mat2(	vec2(sin(rotation),-cos(rotation)),
								vec2(cos(rotation),sin(rotation))
								);
    uv -= pivot;
    uv= uv*rotation_matrix;
    uv += pivot;
    return uv;
}
void fragment()
{
	vec2 uv;
	if (rotate_active) {
		if (rotate > 0.0) {
			uv = rotateUVmatrinx(UV, vec2(0.5), PI * rotate);
			COLOR = (uv.x *0.5 >= - 0.0 && uv.x <= 1.0 && uv.y >= 0.0 && uv.y <= 1.0)  ? texture(TEXTURE, uv) : vec4(vec3(0.0), 0.0) ;	
		} 
		else {
			uv = (UV * 2.0 - 1.0) ;	
		}
	}
	else {
		uv = (UV * 2.0 - 1.0) ;	
	}

	if (pack_active) {
				if (vertical) {
			uv.y *= (1.0 * pack_global) - pack_curved;
			float displacement = (1.0 * pack_global) + pack_curved  * (bulge_function(uv.x) * (- cos  (PI + pack_center)));
			uv.y /= displacement;
			uv = (uv + 1.0) / 2.0;
			COLOR = uv.y >= 0.0 && uv.y <= 1.0 ? texture(TEXTURE, uv) : vec4(vec3(0.0), 0.0);
		}
		else {
			uv.x *= (1.0 * pack_global) - pack_curved;
			float displacement = (1.0 * pack_global) + pack_curved  * (bulge_function(uv.y) * (- cos  (PI + pack_center)));
			uv.x /= displacement;
			uv = (uv + 1.0) / 2.0;
			COLOR = uv.x >= 0.0 && uv.x <= 1.0 ? texture(TEXTURE, uv) : vec4(vec3(0.0), 0.0);	
		}
		
	}
	
	if (stretch_ative) {
		if (vertical) {
			uv.y *= 1.0 + (stretch * 2.0);
			float displacement = 1.0 + stretch * bulge_function(uv.x);
			uv.y /= displacement;
			uv = ((uv + 1.0) / 2.0) ;
			COLOR = uv.y>= 0.0 && uv.y <= 1.0 ? texture(TEXTURE, uv) : vec4(vec3(0.0), 0.0);			
		}
		else {
			uv.x *= 1.0 + (stretch * 2.0);
			float displacement = 1.0 + stretch * bulge_function(uv.y);
			uv.x /= displacement;
			uv = ((uv + 1.0) / 2.0) ;
			COLOR = uv.x >= 0.0 && uv.x <= 1.0 ? texture(TEXTURE, uv) : vec4(vec3(0.0), 0.0);
		}
	}
}