/*
 * ---------------------------------------------------------------
 * Verlocity
 * http://www.verlocityengine.com
 * 
 * This file is subject to the terms and conditions defined in
 * 'license.txt', which is part of this source code package.
 * ---------------------------------------------------------------
*/
package verlocity.display 
{
	import flash.display.Stage;
	import flash.display.StageQuality;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.geom.Rectangle;
	import verlocity.utils.MathUtil;

	import verlocity.Verlocity;
	import verlocity.core.Singleton;

	/**
	 * Handles the display functions such as quality, fullscreen, and screen rectangle.
	 */
	public final class DisplayManager extends Singleton
	{
		private var stage:Stage;
		private var bFullscreenAllowed:Boolean = true;
		private var rectScreen:Rectangle;

		private var iQuality:int;
		private var iQualityAdjustDelay:int;

		/**
		 * Quality constant that represents the lowest quality setting.
		 * No particles.
		 */
		public const QUALITY_NETBOOK:int = 0;
		
		/**
		 * Quality constant that represents the low quality setting.
		 * Particles without effects.
		 */
		public const QUALITY_LOW:int = 1;
		
		/**
		 * Quality constant that represents the medium quality setting.
		 * Particles with minimal effects.
		 */
		public const QUALITY_MEDIUM:int = 2;
		
		/**
		 * Quality constant that represents the high quality setting.
		 * Particles with post-effects.
		 */
		public const QUALITY_HIGH:int = 3;

		/**
		 * Creates the display manager.
		 * @param	sStage
		 */
		public function DisplayManager( sStage:Stage ):void
		{
			super();
			
			stage = sStage;
			UpdateScreenRect();
			
			iQuality = GetQuality();
			
			stage.addEventListener( Event.RESIZE, OnResize );
		
			if ( Verlocity.settings.FPS_ADJUST_QUALITY )
			{
				stage.addEventListener( Event.ENTER_FRAME, UpdateQuality );
			}
		}
		
		/**
		 * Removes all display management data.
		 */
		public override function _Destruct():void
		{
			super._Destruct();

			stage.removeEventListener( Event.RESIZE, OnResize );

			if ( stage.hasEventListener( Event.ENTER_FRAME ) )
			{
				stage.removeEventListener( Event.ENTER_FRAME, UpdateQuality );
			}

			rectScreen = null;

			stage = null;
		}
		
		/**
		 * Automatically adjusts quality based on average FPS.
		 * @param	e
		 */
		private function UpdateQuality( e:Event ):void
		{
			if ( !Verlocity.stats ) { return; }

			if ( Verlocity.stats.FPS == ( Verlocity.settings.FRAMERATE ) )
			{
				if ( !iQualityAdjustDelay )
				{
					iQualityAdjustDelay = Verlocity.CurTime() + 1000;
				}

				if ( Verlocity.CurTime() > iQualityAdjustDelay )
				{
					iQualityAdjustDelay = 0;
					SetQuality( GetQuality() + 1, false );
				}
			} 
			else if ( Verlocity.stats.FPS < ( Verlocity.settings.FRAMERATE - 10 ) )
			{
				if ( !iQualityAdjustDelay )
				{
					iQualityAdjustDelay = Verlocity.CurTime() + 10000;
				}

				if ( Verlocity.CurTime() > iQualityAdjustDelay )
				{
					iQualityAdjustDelay = 0;
					SetQuality( GetQuality() - 1, false );
				}
			}
			else
			{
				iQualityAdjustDelay = 0;
			}
		}		

		/**
		 * Handles resizing of the screen.
		 * @param	e
		 */
		private function OnResize( e:Event ):void
		{
			UpdateScreenRect();
		}

		/**
		 * Updates the screen rectangle
		 */
		private function UpdateScreenRect():void
		{
			rectScreen = new Rectangle( 0, 0, stage.stageWidth, stage.stageHeight );
		}
		
		/**
		 * Applies the flash settings to the display.
		 */
		public function _ApplyFlashSettings():void
		{
			if ( !Verlocity.IsValid( Verlocity.settings ) ) { return; }

			stage.frameRate = Verlocity.settings.FRAMERATE;
			stage.scaleMode = Verlocity.settings.FLASH_SCALEMODE;
			stage.quality = Verlocity.settings.FLASH_QUALITY;
			stage.displayState = Verlocity.settings.FLASH_DISPLAYSTATE;
			stage.showDefaultContextMenu = Verlocity.settings.FLASH_SHOW_DEFAULTCONTEXT;
		}

		/**
		 * Sets the stage quality and displays a GUI message (if available).
		 * @param	iSetQuality The quality to set to (0-3, Netbook-High).
		 * @param	bShowMessage Should we display a message about the change?
		 */
		public function SetQuality( iSetQuality:int, bShowMessage:Boolean = true ):void
		{
			iSetQuality = MathUtil.Clamp( iSetQuality, 0, 3 );

			if ( iSetQuality == GetQuality() ) { return; }

			switch( iSetQuality )
			{
				case QUALITY_NETBOOK:
					stage.quality = StageQuality.LOW;
					iQuality = QUALITY_NETBOOK;
				break;
				
				case QUALITY_LOW:
					stage.quality = StageQuality.LOW;
					iQuality = QUALITY_LOW;
				break;
				
				case QUALITY_MEDIUM:
					stage.quality = StageQuality.MEDIUM;
					iQuality = QUALITY_MEDIUM;
				break;
				
				case QUALITY_HIGH:
					stage.quality = StageQuality.HIGH;
					iQuality = QUALITY_HIGH;
				break;
			}
			
			if ( bShowMessage )
			{
				Verlocity.message.Create( Verlocity.lang.T( "VerlocityQuality" ) + Verlocity.lang.T( "VerlocityQuality" + String( iQuality ) ) );
			}
		}

		/**
		 * Returns the stage quality integer (0-3, Netbook-High).
		 * @param	bStageQuality Returns the absolute stage quality.
		 * @return
		 */
		public function GetQuality( bStageQuality:Boolean = false ):int
		{
			if ( bStageQuality )
			{
				switch( stage.quality )
				{
					case "LOW": return QUALITY_LOW; break;
					case "MEDIUM": return QUALITY_MEDIUM; break;
					case "HIGH": return QUALITY_HIGH; break;
				}
			}

			return iQuality;
		}

		/**
		 * Returns if the quality is set to netbook (lowest).
		 */
		public function IsQualityNetbook():Boolean { return GetQuality() == QUALITY_NETBOOK; }
		
		/**
		 * Returns if the quality is set to low.
		 */
		public function IsQualityLow():Boolean { return GetQuality() == QUALITY_LOW; }
		
		/**
		 * Returns if the quality is set to medium.
		 */
		public function IsQualityMedium():Boolean { return GetQuality() == QUALITY_MEDIUM; }
		
		/**
		 * Returns if the quality is set to high.
		 */
		public function IsQualityHigh():Boolean { return GetQuality() == QUALITY_HIGH; }
		
		/**
		 * Enables/disables fullscreen mode.
		 * @param	bEnable
		 */
		public function SetFullscreen( bEnable:Boolean ):void
		{
			if ( bEnable )
			{
				try
				{
					stage.displayState = StageDisplayState.FULL_SCREEN;
					
					if ( IsFullscreen() )
					{
						Verlocity.message.Create( Verlocity.lang.T( "VerlocityFullscreenOn" ) );
					}
				}
				catch ( e:SecurityError )
				{
					bFullscreenAllowed = false;					
					Verlocity.message.Create( Verlocity.lang.T( "VerlocityFullscreenDisabled" ) );					
				}
			}
			else
			{
				stage.displayState = StageDisplayState.NORMAL;
				
				if ( !IsFullscreen() )
				{
					Verlocity.message.Create( Verlocity.lang.T( "VerlocityFullscreenOff" ) );
				}
			}
		}
		
		/**
		 * Toggles full screen off/on.
		 */
		public function ToggleFullscreen():void
		{
			SetFullscreen( !IsFullscreen() );
		}

		/**
		 * Returns if the display is running in full screen mode.
		 * @return
		 */
		public function IsFullscreen():Boolean { return stage.displayState == StageDisplayState.FULL_SCREEN; }
		
		/**
		 * Returns if the display can go fullscreen.
		 * @return
		 */
		public function CanFullscreen():Boolean { return bFullscreenAllowed; }
		
		/**
		 * Gets the screen rect
		 * @return
		 */
		public function GetScreenRect():Rectangle
		{
			return rectScreen;
		}
	}
}