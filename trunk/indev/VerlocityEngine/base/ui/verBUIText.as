package VerlocityEngine.base.ui
{
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFieldAutoSize;

	import VerlocityEngine.VerlocitySettings;

	public class verBUIText extends verBUI
	{
		protected var tfTextField:TextField;
		protected var tfTextFormat:TextFormat;

		public function SetText( sText:String, tfFormat:TextFormat = null ):void
		{
			if ( !tfTextField )
			{
				tfTextField = new TextField();
				tfTextField.selectable = false;
				addChild( tfTextField );
			}

			tfTextField.text = sText;

			if ( tfFormat ) { tfTextFormat = tfFormat; } else { tfTextFormat = new TextFormat(); }

			tfTextFormat.align = "center";		
			tfTextField.setTextFormat( tfTextFormat );
			if ( tfTextFormat.color ) { tfTextField.textColor = uint( tfTextFormat.color ); }
			
			tfTextField.width = tfTextField.textWidth + 5;
			tfTextField.height = tfTextField.textHeight + 5;

			tfTextField.autoSize = TextFieldAutoSize.CENTER;
		}
		
		public function SetTextColor( uiColor:uint ):void
		{
			if ( tfTextField.textColor != uiColor )
			{
				tfTextField.textColor = uiColor;
			}
		}
		
		public function SetWidth( iWidth:int ):void
		{
			tfTextField.width = iWidth;
			
			DrawDebugLines( iWidth );
		}
		
		public function GetWidth():int
		{
			return tfTextField.width;
		}
		
		public function SetHeight( iHeight:int ):void
		{
			tfTextField.height = iHeight;
		}
		
		public function GetHeight():int
		{
			return tfTextField.height;
		}
		
		private function DrawDebugLines( iWidth:int = 0 ):void
		{
			if ( !VerlocitySettings.UI_DEBUG ) { return; }

			graphics.beginFill( 0x000000, 0 );
				graphics.lineStyle( 1, 0xFFFF00 );
				graphics.drawRect( 0, 0, iWidth, tfTextField.height );
			graphics.endFill();
			
			graphics.beginFill( 0x000000, 0 );
				graphics.lineStyle( 1, 0xFF0000 );
				graphics.drawRect( tfTextField.x, tfTextField.y, tfTextField.width, tfTextField.height );
			graphics.endFill();
		}
		
		public override function DrawRect( uiColor:uint = 0xFFFFFF, nAlpha:Number = 1, iWidth:int = 0, iHeight:int = 0,
								  bLine:Boolean = false, iLineThickness:int = 1, uiLineColor:uint = 0xFFFFFF, nLineAlpha:Number = 1,
								  bRounded:Boolean = false, iRoundness:int = 10,
								  iOffsetX:int = 0, iOffsetY:int = 1 ):void
		{

			if ( iWidth == 0 ) { iWidth = tfTextField.width; }
			if ( iHeight == 0 ) { iHeight = tfTextField.height; }
			
			super.DrawRect( uiColor, nAlpha, iWidth, iHeight, bLine, iLineThickness, uiLineColor, nLineAlpha, bRounded, iRoundness, iOffsetX, iOffsetY );
		}
		
		public override function Dispose():void
		{
			if ( tfTextField ) { removeChild( tfTextField ); };
			
			tfTextField = null;
			tfTextFormat = null;
		}
	}
}