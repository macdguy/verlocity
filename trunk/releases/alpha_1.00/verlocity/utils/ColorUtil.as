/*
 * ---------------------------------------------------------------
 * Verlocity
 * http://www.verlocityengine.com
 * 
 * This file is subject to the terms and conditions defined in
 * 'license.txt', which is part of this source code package.
 * ---------------------------------------------------------------
*/
package verlocity.utils 
{
	public final class ColorUtil
	{
		/**
		 * Returns a hexidecimal color value based on RGB
		 * @param	r Red (0-255)
		 * @param	g Green (0-255)
		 * @param	b Blue (0-255)
		 * @param	a Alpha (0-255)
		 * @return
		 */
		public static function RGBtoHEX( r:uint, g:uint, b:uint, a:uint = 255 ):uint
		{
			// Clamp values
			r = MathUtil.Clamp( r, 0, 255 );
			g = MathUtil.Clamp( g, 0, 255 );
			b = MathUtil.Clamp( b, 0, 255 );
			a = MathUtil.Clamp( a, 0, 255 );

			return a << 24 | r << 16 | g << 8 | b;
		}

		/**
		 * Returns a hexidecimal color value based on hue, saturation, and value given.
		 * Based on: http://www.cs.rit.edu/~ncs/color/t_convert.html
		 * AS3 from: https://gist.github.com/638271
		 * @param	h Hue
		 * @param	s Saturation
		 * @param	v Value
		 * @return
		 */
		public static function HSVtoHex( h:Number, s:Number, v:Number ):uint
		{
			var r: Number = 0, g: Number = 0, b: Number = 0;
			var i: Number, x: Number, y: Number, z: Number;

			if (s <0) s = 0; if (s> 1) s = 1; if (v <0) v = 0; if (v> 1) v = 1;
			h %= 360; if (h < 0 ) h += 360; h /= 60;
			i = h>> 0;
			x = v * (1 - s); y = v * (1 - s * (h - i)); z = v * (1 - s * (1 - h + i));

			switch ( i )
			{
				case 0: r = v; g = z; b = x; break;
				case 1: r = y; g = v; b = x; break;
				case 2: r = x; g = v; b = z; break;
				case 3: r = x; g = y; b = v; break;
				case 4: r = z; g = x; b = v; break;
				case 5: r = v; g = x; b = y; break;
			}

			return RGBtoHEX( r * 255>> 0, g * 255>> 0, b * 255>> 0 );
		}

		/**
		 * Finds the complimentary hue based on the hue given.
		 * Idea from: http://codecanyon.net/forums/thread/as3-help-needed-calculate-complementary-opposite-hex-color-value/31176?page=2#292970
		 * @param	hue Hue
		 * @return
		 */
		public static function FindComplimentaryHue( hue:Number ):Number
		{
			hue += 180;
			if ( hue > 360 ) { hue - 360; }

			return hue;
		}

		/**
		 * Returns a random color (specific in RGB) in hex.
		 * @param	r1 First red value.
		 * @param	r2 Second red value.
		 * @param	g1 First green value.
		 * @param	g2 Second green value.
		 * @param	b1 First blue value.
		 * @param	b2 Second blue value.
		 * @param	a1 First alpha value.
		 * @param	a2 Second alpha value.
		 * @return
		 */
		public static function RandColor( r1:int, r2:int, g1:int, g2:int, b1:int, b2:int, a1:int = 255, a2:int = 255 ):uint
		{
			return RGBtoHEX( MathUtil.Rand( r1, r2 ), MathUtil.Rand( g1, g2 ), MathUtil.Rand( b1, b2 ), MathUtil.Rand( a1, a2 ) );
		}

		/**
		 * Returns a random color between two colors (in hex).
		 * @param	uiColor1 The first color
		 * @param	uiColor2 The second color
		 * @return
		 */
		public static function RandColorHex( uiColor1:uint, uiColor2:uint ):uint
		{
			// First set
			var iAlpha1:int = uiColor1 >> 24;
			var iRed1:int = uiColor1 >> 16;
			var iGreen1:int = uiColor1 >> 8 & 0xFF;
			var iBlue1:int = uiColor1 & 0xFF;

			// Second set
			var iAlpha2:int = uiColor2 >> 24;
			var iRed2:int = uiColor2 >> 16;
			var iGreen2:int = uiColor2 >> 8 & 0xFF;
			var iBlue2:int = uiColor2 & 0xFF;

			return RandColor( iRed1, iRed2, iGreen1, iGreen2, iBlue1, iBlue2, iAlpha1, iAlpha2 );
		}

	}

}