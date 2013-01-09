package game.effects 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import fl.motion.Color;
	import flash.geom.Rectangle;
	import verlocity.utils.ColorUtil;
	
	import verlocity.Verlocity;
	import verlocity.ents.effects.ScreenEffect;
	import verlocity.utils.MathUtil;

	public class SFX_BeatBorder extends ScreenEffect
	{
		private var nBorderAlpha:Number;
		private var iMaxThickness:int = 10;

		public override function Construct():void
		{
			//CreateDrawableBitmap( Verlocity.ScrW, Verlocity.ScrH, true );

			nBorderAlpha = 0;
		}

		public override function Update():void
		{
			if ( Verlocity.analyzer.AverageBass > Verlocity.analyzer.CutOff )
			{
				nBorderAlpha = Verlocity.analyzer.AverageBass;
			}

			if ( nAlpha > 0 )
			{
				nBorderAlpha -= 0.1 * ( 1 - Verlocity.analyzer.AverageBass );
			}

			nBorderAlpha = MathUtil.ClampNum( nBorderAlpha );

			Draw();
		}

		private function Draw():void
		{
			//Clear();
			
			// Begin draw...
			var color:uint = ColorUtil.RGBtoHEX( 255, 255, 255, 255 * nBorderAlpha );
			var thickness:Number = iMaxThickness * nBorderAlpha;
			
			// Top
			BitmapDrawRect( thickness, 0, Verlocity.ScrW - ( thickness * 2 ), thickness, color );
			
			// Bottom
			BitmapDrawRect( thickness, Verlocity.ScrH - thickness, Verlocity.ScrW - ( thickness * 2 ), thickness, color );
			
			// Right
			BitmapDrawRect( Verlocity.ScrW - thickness, 0, thickness, Verlocity.ScrH, color );
			
			// Left
			BitmapDrawRect( 0, 0, thickness, Verlocity.ScrH, color );
		}
	}
}