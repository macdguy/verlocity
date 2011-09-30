/*
	This file is subject to the terms and conditions defined in
    file 'license.txt', which is part of this source code package.
*/

package VerlocityEngine.base.ui
{
	import flash.display.Sprite;

	public class verBUI extends Sprite
	{
		public var originX:int;
		public var originY:int;
		
		public function verBUI():void
		{
			originX = x; originY = y;
		}
		
		public function Dispose():void {}

		/**
		 * Sets the X and Y position of the UI element.
		 * @param	iPosX The X position to set the UI element to.
		 * @param	iPosY The Y position to set the UI element to.
		 * @usage	Example usage: ui.SetPos( 125, 25 );
		*/
		public function SetPos( iPosX:int, iPosY:int ):void
		{
			x = iPosX; y = iPosY;
		}
		
		public function SetOriginPos( iPosX:int, iPosY:int ):void
		{
			originX = iPosX; originY = iPosY;
			SetPos( iPosX, iPosY );
		}

		/**
		 * Resets the X and Y position of the UI element to its original spawn position.
		 * @usage	Example usage: ui.ResetPos();
		*/
		public function ResetPos():void
		{
			x = originX; y = originY;
		}

		/**
		 * Sets the scale of the UI element.
		 * @param	nScale The scale to scale the UI element to (this effects both X and Y scales).
		 * @usage	Example usage: ui.SetScale( 2 );
		*/
		protected var nScale:Number = 1;

		public function SetScale( nSetScale:Number ):void
		{
			nScale = nSetScale;

			scaleX = nScale; scaleY = nScale;
		}
		
		public function GetScale():Number
		{
			return nScale;
		}

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
		
		public function Clear():void
		{
			graphics.clear();
		}
	}
}