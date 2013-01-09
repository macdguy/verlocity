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
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFormat;

	import verlocity.display.ui.UIElement;
	import verlocity.display.ui.Text;
	import verlocity.display.ui.Button;
	import verlocity.display.ui.Scroll;

	import verlocity.Verlocity;

	public class PauseMenu extends UIElement
	{
		/* Font Formats */
		internal static const pauseFormat:TextFormat = new TextFormat( "_sans", 30, 0xFFFFFF );
		internal static const pauseResumeFormat:TextFormat = new TextFormat( "_sans", 20, 0xFFFFFF, true );
		internal static const pauseTagFormat:TextFormat = new TextFormat( "_sans", 12, 0xFFFFFF, true );
		internal static const pauseMenuFormat:TextFormat = new TextFormat( "_sans", 16, 0xFFFFFF, true );

		/* Sizing */
		internal static var menuWidth:int = 200;
		internal static var menuHeight:int = 200;

		private var puiLowQ:PauseButton;
		private var puiMedQ:PauseButton;
		private var puiHighQ:PauseButton;
		
		public function PauseMenu( iPosX:int, iPosY:int ):void
		{
			// Pause Text
			var pauseText:Text = new Text();
				pauseText.SetText( Verlocity.lang.T( "verPauseTitle" ), pauseFormat );
				pauseText.SetWidth( menuWidth );
			addChild( pauseText );	

			// Pause Menu
			//======================
			var puiResume:PauseMenuButton = new PauseMenuButton( Verlocity.lang.T( "verPauseResume" ), 5, 40,
				function():void {
					Verlocity.pause.Resume();
				} );
			addChild( puiResume );
			
			var iLength:int = Verlocity.pause.MenuList.length;
			var iPosYLast:int = ( puiResume.y + puiResume.height );
			if ( iLength > 0 )
			{
				for ( var i:int = 0; i < iLength; i++ )
				{
					var puiMenuItem:PauseMenuButton = new PauseMenuButton( Verlocity.pause.MenuList[i][0], 
																		   5, 75 + ( i * 25 ),
																		   Verlocity.pause.MenuList[i][1] );
					addChild( puiMenuItem );

					if ( i + 1 == iLength ) { iPosYLast = puiMenuItem.y + puiMenuItem.height; }
				}
			}
			
			// Pause Menu Height Calc
			//=======================
			menuHeight = iPosYLast + 105;

			// Pause Menu BG
			// ======================
			graphics.beginFill( 0x000000, .25 );
				//graphics.lineStyle( 1, 0xFF9900 );
				graphics.drawRect( 0, 0, menuWidth, menuHeight );
			graphics.endFill();
			
			graphics.beginFill( 0x000000, .75 );
				graphics.drawRect( 0, 0, menuWidth, 35 );
				graphics.drawRect( 0, iPosYLast + 10, menuWidth, 105 );

				graphics.lineStyle( 1, 0xFF9900 );
				graphics.drawRect( 0, 35, menuWidth, 1 );
				graphics.drawRect( 0, iPosYLast + 10, menuWidth, 1 );
			graphics.endFill();
			
			x = iPosX - ( menuWidth / 2 ) * Verlocity.settings.GUI_SCALE; y = iPosY - ( menuHeight / 2 ) * Verlocity.settings.GUI_SCALE;
			
			

			// Small Settings
			//======================
			var iSettingsY:int = iPosYLast + 30;

			// QUALITY
			var qualityText:Text = new Text();
				qualityText.SetText( Verlocity.lang.T( "verPauseQuality" ), pauseTagFormat );
				qualityText.SetPos( 15, iPosYLast + 12 );
				qualityText.SetWidth( 70 );
			addChild( qualityText );

			puiLowQ = new PauseButton( Verlocity.lang.T( "verPauseQualityLow" ), 15, iSettingsY,
				function():void {
					Verlocity.display.SetQuality( Verlocity.display.QUALITY_LOW );
				},
				function():Boolean {
					return Verlocity.display.IsQualityLow()|| Verlocity.display.IsQualityNetbook();
				}
			);
			addChild( puiLowQ );

			puiMedQ = new PauseButton( Verlocity.lang.T( "verPauseQualityMedium" ), 40, iSettingsY,
				function():void {
					Verlocity.display.SetQuality( Verlocity.display.QUALITY_MEDIUM );
				},
				function():Boolean {
					return Verlocity.display.IsQualityMedium();
				}
			);
			addChild( puiMedQ );

			puiHighQ = new PauseButton( Verlocity.lang.T( "verPauseQualityHigh" ), 65, iSettingsY,
				function():void {
					Verlocity.display.SetQuality( Verlocity.display.QUALITY_HIGH );
				},
				function():Boolean {
					return Verlocity.display.IsQualityHigh();
				}
			);
			addChild( puiHighQ );

			// SOUND
			var soundText:Text = new Text();
				soundText.SetText( Verlocity.lang.T( "verPauseVolume" ), pauseTagFormat );
				soundText.SetPos( 115, iPosYLast + 12 );
				soundText.SetWidth( 70 );
			addChild( soundText );

			var puiSndDown:PauseButton = new PauseButton( "-", 115, iSettingsY,
				function():void {
					Verlocity.sound.VolumeDown();
				}
			);
			addChild( puiSndDown );

			var puiSndMute:PauseButton = new PauseButton( "M", 140, iSettingsY,
				function():void {
					Verlocity.sound.ToggleMute();
				}
			);
			addChild( puiSndMute );

			var puiSndUp:PauseButton = new PauseButton( "+", 165, iSettingsY,
				function():void {
					Verlocity.sound.VolumeUp();
				}
			);
			addChild( puiSndUp );


			// MISC
			var puiAchievements:PauseButton = new PauseButton( Verlocity.lang.T( "verPauseAchievements" ), 15, iSettingsY + 30,
				function():void {
					Verlocity.achievements.OpenGUI();
				}, null, null, 170 );
			addChild( puiAchievements );

			var puiFullscreen:PauseButton = new PauseButton( Verlocity.lang.T( "verPauseFullscreen" ), 15, iSettingsY + 55,
				function():void {
					Verlocity.display.ToggleFullscreen();
				}, null,
				function():void {
					Verlocity.display.CanFullscreen();
				}, 170 );
			addChild( puiFullscreen );

			if ( !Verlocity.display.CanFullscreen() )
			{
				puiFullscreen.SetEnabled( false );
			}
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
		
		public function ToggleButtons( bEnable:Boolean ):void
		{
			for ( var i:int = 0; i < numChildren; i++ )
			{
				var child:UIElement = UIElement( getChildAt( i ) );
				
				if ( child is Button )
				{
					Button( child ).SetEnabled( bEnable );
				}
			}
		}
	}
}