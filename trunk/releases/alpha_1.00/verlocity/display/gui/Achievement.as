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

	import verlocity.display.ui.UIElement;
	import verlocity.display.ui.Bar;
	import verlocity.display.ui.Scroll;
	import verlocity.display.ui.Text;

	public class Achievement extends UIElement
	{
		/* Font Formats */
		internal static const nameFormat:TextFormat = new TextFormat( "_sans", 20, 0xFFFFFF, true );
		internal static const descFormat:TextFormat = new TextFormat( "_sans", 14, 0xFFFFFF );

		/* Sizing */
		internal static const achiWidth:int = 255;
		internal static const achiHeight:int = 75;

		public function Achievement( sName:String, sDesc:String ):void
		{
			// BG
			DrawRect( 0x333333, .5, achiWidth, achiHeight );
			
			// Inside
			DrawRect( 0x222222, 1, achiWidth - 12, achiHeight - 12, true, 3, 0xE68C32, 1, false, NaN, 6, 6 );
			
			var achName:Text = new Text( sName, nameFormat );
				achName.SetPos( 6, 8 );
				achName.SetWidth( achiWidth - 12 );
			addChild( achName );
			
			var achDesc:Text = new Text( sDesc, descFormat );
				achDesc.SetPos( 24, 36 );
				achDesc.SetWidth( achiWidth - 48 );
				achDesc.SetHeight( achiHeight - 18 );
			addChild( achDesc );
		}

		public override function Dispose():void
		{
			for ( var i:int = 0; i < numChildren; i++ )
			{
				var child:UIElement = UIElement( getChildAt( i ) );
				child.Dispose();

				removeChildAt( i );
				i--;
			}
			
			Clear();
		}
	}
}