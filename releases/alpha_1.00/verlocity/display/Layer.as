/*
 * ---------------------------------------------------------------
 * Verlocity
 * http://www.verlocityengine.com
 * 
 * This file is subject to the terms and conditions defined in
 * 'license.txt', which is part of this source code package.
 * ---------------------------------------------------------------
*/
package verlocity.display
{
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.geom.Point;

	import verlocity.Verlocity;
	import verlocity.utils.DisplayUtil;

	public final class Layer extends Sprite
	{
		private var iOriginX:int;
		private var iOriginY:int;

		/**
		 * Creates a layer
		 * @param	iPosX The spawn x position
		 * @param	iPosY The spawn y position
		 * @param	sName The name of the layer
		 */
		public function Layer( sName:String = "", iPosX:int = 0, iPosY:int = 0 ):void
		{
			name = sName;

			x = iPosX; y = iPosY;
			iOriginX = iPosX; iOriginY = iPosY;
		}

		/**
		 * Resets the layer to its original position and scale.
		 */
		public function Reset():void
		{
			x = iOriginX;
			y = iOriginY;
			
			scaleX = 1;
			scaleY = 1;
		}
		
		/**
		 * Fills the entire layer with a color.
		 * @param	uiColor The color to fill with.
		 * @param	nAlpha The alpha of the color.
		 */
		public function Fill( uiColor:uint, nAlpha:Number ):void
		{
			graphics.beginFill( uiColor, nAlpha );
			graphics.drawRect( 0, 0, Verlocity.ScrW, Verlocity.ScrH );
			graphics.endFill();
		}

		/**
		 * Removes all display objects in the layer.
		 */
		public function RemoveAllDisplayObjects():void
		{
			DisplayUtil.RemoveAllChildren( this );
		}

		/**
		 * Disposes all layer info.
		 */
		public function _Dispose():void
		{
			RemoveAllDisplayObjects();
			DisplayUtil.RemoveFromParent( this );
		}
	}
}