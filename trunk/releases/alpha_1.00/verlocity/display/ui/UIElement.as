/*
 * ---------------------------------------------------------------
 * Verlocity
 * http://www.verlocityengine.com
 * 
 * This file is subject to the terms and conditions defined in
 * 'license.txt', which is part of this source code package.
 * ---------------------------------------------------------------
*/
package verlocity.display.ui
{
	import flash.display.Sprite;

	public class UIElement extends Sprite
	{
		public var originX:Number;
		public var originY:Number;
		protected var nScale:Number;

		/**
		 * Sets the X and Y position of the UI element.
		 * @param	nPosX The X position to set the UI element to.
		 * @param	nPosY The Y position to set the UI element to.
		 * @usage	Example usage: ui.SetPos( 125, 25 );
		*/
		public function SetPos( nPosX:Number, nPosY:Number ):void
		{
			x = nPosX; y = nPosY;
			
			if ( !originX ) { originX = nPosX; }
			if ( !originY ) { originY = nPosY; }
		}

		/**
		 * Resets the X and Y position of the UI element to its original spawn position.
		 * @usage	Example usage: ui.ResetPos();
		*/
		public function ResetPos():void
		{
			if ( originX ) { x = originX; }
			if ( originY ) { y = originY; }
		}
		
		/**
		 * Overrides origin position
		 * @param	nPosX
		 * @param	nPosY
		 */
		public function SetOriginPos( nPosX:Number, nPosY:Number ):void
		{
			originX = nPosX;
			originY = nPosY;
		}


		/**
		 * Sets the scale of the UI element.
		 * @param	nScale The scale to scale the UI element to (this effects both X and Y scales).
		 * @usage	Example usage: ui.SetScale( 2 );
		*/
		public function SetScale( nSetScale:Number ):void
		{
			nScale = nSetScale;

			scaleX = nScale; scaleY = nScale;
		}
		
		/**
		 * Returns the scale of the UI element.
		 * @return
		 */
		public function GetScale():Number
		{
			if ( isNaN( nScale ) ) { return 1; }

			return nScale;
		}

		/**
		 * Draws a rectangle onto the UI element.
		 * This is the easiest way to create custom buttons.
		 * @param	uiColor The color of the rect
		 * @param	nAlpha The alpha of the rect
		 * @param	iWidth The width of the rect
		 * @param	iHeight The height of the rect
		 * @param	bLine Should there be a line surrounding it?
		 * @param	iLineThickness How thick the line is
		 * @param	uiLineColor The color of the line
		 * @param	nLineAlpha The alpha of the line
		 * @param	bRounded Is the rect rounded?
		 * @param	iRoundness How much should the rect be rounded by?
		 * @param	iOffsetX The X offset of the rect
		 * @param	iOffsetY The Y offset of the rect
		 */
		public function DrawRect( uiColor:uint = 0xFFFFFF, nAlpha:Number = 1, iWidth:int = 0, iHeight:int = 0,
								  bLine:Boolean = false, iLineThickness:int = 1, uiLineColor:uint = 0xFFFFFF, nLineAlpha:Number = 1,
								  bRounded:Boolean = false, iRoundness:int = 10,
								  iOffsetX:int = 0, iOffsetY:int = 1 ):void
		{

			graphics.beginFill( uiColor, nAlpha );
				if ( bLine ) { graphics.lineStyle( iLineThickness, uiLineColor, nLineAlpha ); }

				if ( bRounded )
				{
					graphics.drawRoundRect( iOffsetX, iOffsetY, iWidth, iHeight, iRoundness, iRoundness );
				}
				else
				{
					graphics.drawRect( iOffsetX, iOffsetY, iWidth, iHeight );
				}
			graphics.endFill();
		}

		/**
		 * Clears all graphics drawn on the UI element.
		 */
		public function Clear():void
		{
			graphics.clear();
		}
		
		/**
		 * Destroys the UI element.
		 */
		public function Dispose():void
		{
			nScale = NaN;
			Clear();

			delete this;
		}
	}
}