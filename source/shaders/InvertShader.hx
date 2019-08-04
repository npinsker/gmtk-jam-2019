package shaders;

import flixel.system.FlxAssets.FlxShader;

class InvertShader extends FlxShader {
	@:glFragmentSource('
		#pragma header
		
		uniform bool active;

		void main() {
			vec2 xy = openfl_TextureCoordv;
			vec4 cx = texture2D(bitmap, xy);
	if (active) gl_FragColor = vec4(cx.a * cx.g, cx.a * cx.r, cx.a * cx.b, cx.a);
			else gl_FragColor = cx;
		}
	')
	
	public function new() {
		super();
	}
}
