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
	import verlocity.Verlocity;
	import verlocity.utils.SysUtil;
	import flash.display.Graphics;

	public final class GraphicsUtil
	{
		/**
		 * Draws a rectangle across the entire screen.
		 * @param	graphics The graphics to draw the rectangle in.
		 */
		public static function DrawScreenRect( graphics:Graphics ):void
		{
			if ( !SysUtil.IsVerlocityLoaded() ) { return; }

			graphics.drawRect( Verlocity.display.GetScreenRect().x,
							   Verlocity.display.GetScreenRect().y,
							   Verlocity.display.GetScreenRect().width,
							   Verlocity.display.GetScreenRect().height );
		}
	}
}