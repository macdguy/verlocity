package VerlocityEngine.base.ui
{
	import flash.display.Sprite;

	public class verBUIBar extends verBUI
	{
		private var sBar:verBUI;
		private var iWidth:int;
		
		public function CreateBar( iWidth:int, iHeight:int, nStartPercent:Number = 0, 
								   uiColor:uint = 0xFFFFFF, nAlpha:Number = 1, uiFillColor:uint = 0xFFFFFF, nFillAlpha:Number = 1,
								   bLine:Boolean = false, iLineThickness:int = 0, uiLineColor:uint = 0xFFFFFF, nLineAlpha:Number = 1 ):void
		{
			// BG Rect
			DrawRect( uiColor, nAlpha, iWidth, iHeight, bLine, iLineThickness, uiLineColor, nLineAlpha );
			
			// Fill Rect
			sBar = new verBUI();
				sBar.DrawRect( uiFillColor, nFillAlpha, iWidth - iLineThickness, iHeight - iLineThickness, false, NaN, NaN, NaN, false, NaN, iLineThickness + 1, iLineThickness + 1 );
				sBar.width = iWidth * nStartPercent;
			addChild( sBar );
		}
		
		public function SetPercent( nSetPercent:Number ):void
		{
			if ( !sBar ) { return; }

			sBar.width = iWidth * nSetPercent;
		}
		
		public override function Dispose():void
		{
			if ( sBar )
			{
				removeChild( sBar );
				sBar = null;
			}
			
			iWidth = NaN;
			Clear();
		}
	}
}