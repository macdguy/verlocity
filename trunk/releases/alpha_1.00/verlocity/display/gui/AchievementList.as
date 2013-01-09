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
	import flash.display.Stage;
	import flash.text.TextFormat;

	import verlocity.Verlocity;
	import verlocity.display.ui.UIElement;
	import verlocity.display.ui.Button;
	import verlocity.display.ui.Text;
	import verlocity.display.ui.Scroll;

	public class AchievementList extends UIElement
	{
		/* Font Formats */
		internal static const achiFormat:TextFormat = new TextFormat( "_sans", 30, 0xFFFFFF );
		internal static const achiMenuFormat:TextFormat = new TextFormat( "_sans", 16, 0xFFFFFF, true );

		/* Sizing */
		internal static var menuWidth:int = 300;
		internal static var menuHeight:int = 400;

		public function AchievementList( iPosX:int, iPosY:int, sStage:Stage ):void
		{
			// Achi Text
			var achiText:Text = new Text( Verlocity.lang.T( "verAchievementsTitle" ), achiFormat );
				achiText.SetWidth( menuWidth );
			addChild( achiText );

			// Achi List
			//======================
			var iPosYLast:int = ( achiText.y + achiText.height );
			var iCount:int = 0;
			
			// Scroll UI (incase the achievements are bigger)
			var iScrollHeight:int = 250 * Verlocity.settings.GUI_SCALE;
			
			var achiScroll:Scroll = new Scroll( sStage );
				achiScroll.SetPos( 0, iPosYLast );
				achiScroll.SetSize( menuWidth, iScrollHeight );
			addChild( achiScroll );

			// Display all achievements
			for ( var sAchievement:String in Verlocity.achievements.GetAll() )
			{
				var achi:AchievementProgress = new AchievementProgress( Verlocity.achievements.Get( sAchievement ) );
					achi.SetPos( 10, ( Achievement.achiHeight + 4 ) * iCount );
				achiScroll.Insert( achi );

				iCount++;
			}

			// Check if we have achievements
			if ( iCount == 0 )
			{
				// No achievements
				var achiTextErr:Text = new Text( Verlocity.lang.T( "verAchievementsNone" ), achiMenuFormat );
					achiTextErr.SetPos( 0, iPosYLast + 2 );
					achiTextErr.SetWidth( menuWidth );
				addChild( achiTextErr );
				
				achiScroll.SetSize( menuWidth, achiTextErr.GetHeight() );
			}
			else
			{
				// Resize based on list amount if it's smaller
				var iAchieveListHeight:int = ( Achievement.achiHeight + 4 ) * iCount;
				if ( iAchieveListHeight < iScrollHeight )
				{ 
					achiScroll.SetSize( menuWidth, iAchieveListHeight );
				}
			}

			// Resize menu height based on this
			iPosYLast = achiScroll.y + achiScroll.GetHeight();
			menuHeight = iPosYLast + 50;

			// Achi Menu BG
			// ======================
			DrawRect( 0x000000, 1, menuWidth, menuHeight );
			
			graphics.beginFill( 0x000000, 1 );
				graphics.drawRect( 0, 0, menuWidth, 35 );
				graphics.drawRect( 0, iPosYLast + 3, menuWidth, menuHeight - iPosYLast - 2 );

				graphics.lineStyle( 1, 0xFF9900 );
				graphics.drawRect( 0, 35, menuWidth, 1 );
				graphics.drawRect( 0, iPosYLast + 3, menuWidth, 1 );
			graphics.endFill();
			
			x = iPosX - ( menuWidth / 2 ) * Verlocity.settings.GUI_SCALE;
			y = iPosY - ( menuHeight / 2 ) * Verlocity.settings.GUI_SCALE;

			var achiClose:AchievementButton = new AchievementButton( Verlocity.lang.T( "verAchievementsExit" ), achiMenuFormat, ( menuWidth / 2 ) - ( 170 / 2 ), menuHeight - 35,
				function():void {
					Verlocity.achievements.CloseGUI();
				}, 170 );
			addChild( achiClose );
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
		}
	}
}