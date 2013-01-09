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

	internal class PauseMenuButton extends Button
	{
		private var iWidth:int = 190;

		public function PauseMenuButton( sText:String, iPosX:int, iPosY:int, fButton:Function ):void
		{
			SetText( sText, PauseMenu.pauseMenuFormat );
			SetButton( fButton );
			SetPos( iPosX, iPosY );
			SetWidth( iWidth );

			DrawBG();
		}

		protected override function DrawBG():void
		{
			Clear();
			DrawRect( 0xFFFFFF, 0, iWidth, tfTextField.height );
		}

		protected override function Down():void
		{
			Clear();
			DrawRect( 0xCA7900, .25, iWidth, tfTextField.height );
			SetTextColor( 0xFF9900 );
		}

		protected override function Up():void { Over(); }
		protected override function Over():void
		{
			Clear();
			DrawRect( 0xFF9900, .75, iWidth, tfTextField.height );
			SetTextColor( 0xFFFFFF );
		}

		protected override function Out():void
		{
			Clear();
			DrawRect( 0xFFFFFF, 0, iWidth, tfTextField.height );
			SetTextColor( 0xFFFFFF );
		}
		
		protected override function Disabled():void
		{
			Clear();
			SetTextColor( 0x444444 );
		}	
	}
}