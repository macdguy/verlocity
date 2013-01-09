/*
 * ---------------------------------------------------------------
 * Verlocity
 * http://www.verlocityengine.com
 * 
 * This file is subject to the terms and conditions defined in
 * 'license.txt', which is part of this source code package.
 * ---------------------------------------------------------------
*/
package verlocity.display.gui
{
	import flash.text.TextFormat;
	import verlocity.display.ui.Button;

	public class PauseButton extends Button
	{
		private var iWidth:int;

		public function PauseButton( sText:String, 
									 iPosX:int, iPosY:int, 
									 fButton:Function, 
									 fCondition:Function = null, fDisableCondition:Function = null, 
									 iSetWidth:int = 20 ):void
		{
			SetText( sText, PauseMenu.pauseMenuFormat );
			SetButton( fButton, fCondition, fDisableCondition );
			SetPos( iPosX, iPosY );
			
			iWidth = iSetWidth;
			SetWidth( iWidth );
			
			tfTextField.y = .5;

			if ( iWidth == 20 ) { tfTextField.x = 2; }
			if ( tfTextField.text == "M" ) { tfTextField.x = 1.5; }
			
			DrawBG();
		}

		protected override function DrawBG():void
		{
			Clear();
			DrawRect( 0xFFFFFF, 0, iWidth, 20, true, 2, 0xFFFFFF );
		}

		protected override function Down():void
		{
			Clear();
			DrawRect( 0xCA7900, 1, iWidth, 20, true, 2, 0xFFFFFF );
			SetPos( originX, originY + 2 );
		}

		protected override function Up():void { Over(); }
		protected override function Over():void
		{
			Clear();
			DrawRect( 0xFF9900, 1, iWidth, 20, true, 2, 0xFFFFFF );
			ResetPos();
		}

		protected override function Out():void
		{
			Clear();
			SetTextColor( 0xFFFFFF );
			DrawRect( 0xFFFFFF, 0, iWidth, 20, true, 2, 0xFFFFFF );
			ResetPos();
		}
		
		protected override function Disabled():void
		{
			Clear();
			SetTextColor( 0x444444 );
			DrawRect( 0xCCCCCC, .2, iWidth, 20, true, 2, 0x444444 );
			ResetPos();
		}
		
		protected override function Selected():void
		{
			Clear();
			DrawRect( 0xFF9900, 1, iWidth, 20, true, 2, 0xFFFFFF );
			ResetPos();
		}
	}
}