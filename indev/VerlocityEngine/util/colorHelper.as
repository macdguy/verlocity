package VerlocityEngine.util 
{
	public final class colorHelper 
	{

		public static function RGBtoHEX( r:int, g:int, b:int ):uint
		{
			return r << 16 | g << 8 | b;
		}

		/*
			Based on: http://www.cs.rit.edu/~ncs/color/t_convert.html
			AS3 from: https://gist.github.com/638271
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
		
		/*
			Idea from: http://codecanyon.net/forums/thread/as3-help-needed-calculate-complementary-opposite-hex-color-value/31176?page=2#292970
		*/
		public static function FindComplimentaryHue( hue:Number ):Number
		{
			var compHue:Number = hue + 180;
			if ( compHue > 360 ) { compHue - 360; }

			return compHue;
		}

	}

}