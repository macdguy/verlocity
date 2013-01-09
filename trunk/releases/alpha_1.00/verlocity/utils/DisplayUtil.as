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
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.geom.Point;
	import flash.geom.Matrix;
	import flash.geom.Point;

	public final class DisplayUtil
	{
		/*
		 * ScaleAround and RotateAround are credited to Tim Whitlock
		 * http://timwhitlock.info/blog/2008/04/13/scale-rotate-around-an-arbitrary-centre/
		*/

		/**
		 * Scales a display object around a specific point.
		 * @param	disp The display object
		 * @param	offsetX The x position to scale around
		 * @param	offsetY The y position to scale around
		 * @param	absScaleX The x scale amount
		 * @param	absScaleY The y scale amount
		 */
		public static function ScaleAround( disp:DisplayObject, offsetX:int, offsetY:int, absScaleX:Number, absScaleY:Number ):void
		{ 
			// scaling will be done relatively 
			var relScaleX:Number = absScaleX / disp.scaleX;
			var relScaleY:Number = absScaleY / disp.scaleY;

			// map vector to centre point within parent scope 
			var AC:Point = new Point( offsetX, offsetY );
			AC = disp.localToGlobal( AC );
			AC = disp.parent.globalToLocal( AC );

			// current registered postion AB 
			var AB:Point = new Point( disp.x, disp.y );

			// CB = AB - AC, this vector that will scale as it runs from the centre 
			var CB:Point = AB.subtract( AC );
			CB.x *= relScaleX;
			CB.y *= relScaleY;

			// recaulate AB, this will be the adjusted position for the clip 
			AB = AC.add( CB );

			// set actual properties 
			disp.scaleX *= relScaleX;
			disp.scaleY *= relScaleY;
			disp.x = AB.x;
			disp.y = AB.y;
		}

		/**
		 * Rotates a display object around a specific point.
		 * @param	disp The display object
		 * @param	offsetX The x position to rotate around
		 * @param	offsetY The x position to rotate around
		 * @param	toDegrees The rotation amount
		 */
		public static function RotateAround( disp:DisplayObject, offsetX:int, offsetY:int, toDegrees:Number ):void
		{ 
			var relDegrees:Number = toDegrees - ( disp.rotation % 360 ); 
			var relRadians:Number = Math.PI * relDegrees / 180; 

			var M:Matrix = new Matrix( 1, 0, 0, 1, 0, 0 );
			M.rotate( relRadians ); 

			// map vector to centre point within parent scope 
			var AC:Point = new Point( offsetX, offsetY ); 
			AC = disp.localToGlobal( AC ); 
			AC = disp.parent.globalToLocal( AC ); 

			// current registered postion AB 
			var AB:Point = new Point( disp.x, disp.y ); 

			// point to rotate, offset position from virtual centre
			var CB:Point = AB.subtract( AC ); 

			// rotate CB around imaginary centre  
			// then get new AB = AC + CB 
			CB = M.transformPoint( CB ); 
			AB = AC.add( CB ); 

			// set real values on clip 
			disp.rotation = toDegrees; 
			disp.x = AB.x; 
			disp.y = AB.y; 
		}
		
		/**
		 * Removes a display object from its own parent display container.
		 * @param	disp The display object
		 */
		public static function RemoveFromParent( disp:DisplayObject ):void
		{
			if ( !disp.parent ) { return; }
			
			disp.parent.removeChild( disp );
		}

		/**
		 * Removes all children of a display object container (Sprite, MovieClip, etc.)
		 * @param	disp The display object container
		 */
		public static function RemoveAllChildren( disp:DisplayObjectContainer ):void
		{
			if ( disp.numChildren == 0 ) { return; }

			var i:int = disp.numChildren;
				
			while ( i-- )
			{
				disp.removeChildAt( i );
			}
		}
		
		/**
		 * Returns if a MovieClip has reached the end of its timeline.
		 * @param	mc The movieclip
		 * @return
		 */
		public static function HasEnded( mc:MovieClip ):Boolean
		{
			return mc.currentFrame >= mc.totalFrames - 1;
		}
		
		/**
		 * Increases the speed of a MovieClip by skipping frames incrementally.
		 * @param	mc The movieclip
		 * @param	iIncrement The amount of frames to skip
		 * @param	bLoops Should we loop the movieclip?
		 */
		public static function SpeedUp( mc:MovieClip, iIncrement:int, bLoops:Boolean = false ):void
		{
			var iFrame:int = mc.currentFrame + iIncrement;

			if ( !bLoops )
			{
				iFrame = MathUtil.Clamp( iFrame, 1, mc.totalFrames - 1 )
			}

			mc.gotoAndPlay( iFrame );
		}
		
		/**
		 * Returns the absolute point of an display object.
		 * @param	disp The display object
		 * @return
		 */
		public static function Absolute( disp:DisplayObject, parent:DisplayObjectContainer ):Point
		{
			var pPoint:Point = new Point( disp.x, disp.y );

			if ( parent )
			{
				return parent.localToGlobal( pPoint );
			}

			return pPoint;
		}
	}
}