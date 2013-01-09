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

	import verlocity.display.ui.UIElement;
	import verlocity.display.ui.Bar;
	import verlocity.display.ui.Text;

	public class AchievementProgress extends UIElement
	{
		private const achiProgressHeight:int = 75;

		public function AchievementProgress( aAchievement:Array ):void
		{
			// Highlight if achieved
			var achiColor:uint = 0xE68C32;
			
			if ( !aAchievement[ Verlocity.achievements.ACHI_UNLOCKED ] )
			{
				achiColor = 0xCCCCCC;
				alpha = .5;
			}
			
			var iWidth:int = AchievementList.menuWidth - 30;

			// BG
			DrawRect( 0x222222, 1, iWidth, achiProgressHeight, true, 2, achiColor );
			
			// Name
			var achName:Text = new Text( aAchievement[ Verlocity.achievements.ACHI_DISPNAME ], Achievement.nameFormat );
				achName.SetPos( 0, 0 );
				achName.SetWidth( iWidth );
			addChild( achName );
			
			// Description
			var achDesc:Text = new Text( aAchievement[ Verlocity.achievements.ACHI_DESC ], Achievement.descFormat );
				achDesc.SetPos( 0, 20 );
				achDesc.SetWidth( iWidth );
			addChild( achDesc );
			
			// Progress Bar
			var nCurrentPercent:Number = aAchievement[ Verlocity.achievements.ACHI_DATA ] / aAchievement[ Verlocity.achievements.ACHI_MAX ];
			var achProgress:Bar = new Bar();
				achProgress.SetPos( 20, 50 );
				achProgress.CreateBar( iWidth - 40, 20, nCurrentPercent, 0xCCCCCC, 1, 0xFFFFFF, 1 );
			addChild( achProgress );

			// Progress Text
			var sProgress:String = aAchievement[ Verlocity.achievements.ACHI_DATA ] + " / " + aAchievement[ Verlocity.achievements.ACHI_MAX ];
			if ( aAchievement[ Verlocity.achievements.ACHI_UNLOCKED ] ) { sProgress = "UNLOCKED"; }

			var achTextProgress:Text = new Text( sProgress, AchievementList.achiMenuFormat );
				if ( aAchievement[ Verlocity.achievements.ACHI_UNLOCKED ] ) { achTextProgress.SetTextColor( 0x00000 ); }
				achTextProgress.SetPos( achProgress.x, achProgress.y );
				achTextProgress.SetWidth( achProgress.width );
			addChild( achTextProgress );
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