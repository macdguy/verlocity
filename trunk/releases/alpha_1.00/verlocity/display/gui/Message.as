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
	import verlocity.Verlocity;
	import verlocity.display.ui.Text;

	public class Message extends Text
	{
		public function Message( sMessage:String ):void
		{
			SetText( sMessage, Verlocity.settings.GUI_MESSAGE_FORMAT );
			DrawRect( 0x00000, 1, GetWidth() + 5, 30, false, 0, 0, 0, true, 10, -2, 0 );

			SetScale( Verlocity.settings.GUI_SCALE );
		}
	}
}