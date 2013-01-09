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

	internal class AchievementButton extends Button
	{
		private var iWidth:int;

		public function AchievementButton( sText:String, tfFormat:TextFormat, iPosX:int, iPosY:int, fButton:Function, iSetWidth:int ):void
		{
			SetText( sText, tfFormat );
			SetButton( fButton );
			SetOriginPos( iPosX, iPosY );
			
			iWidth = iSetWidth;
			SetWidth( iWidth );
			
			tfTextField.y = .5;

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
			DrawRect( 0xFFFFFF, 0, iWidth, 20, true, 2, 0xFFFFFF );
			ResetPos();
		}	
	}
}