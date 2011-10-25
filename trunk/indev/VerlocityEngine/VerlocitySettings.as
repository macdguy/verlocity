/*
	This file is subject to the terms and conditions defined in
    file 'license.txt', which is part of this source code package.
*/

/*
	=========================================
			   Verlocity Engine
	=========================================
	|	Developed by Macklin Guy, 2011.		|
	|										|
	|										|
	-----------------------------------------
	verSettings.as
	-----------------------------------------
	This class holds all the settings.
*/
package VerlocityEngine
{
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.display.StageScaleMode;
	import flash.display.StageQuality;
	import flash.display.StageDisplayState;

	/*
	 * The width/height of the application.
	 * The IDE will overwrite this, this is mainly for Flex users.
	*/
	[SWF(width = "1280", height = "720" )];

	public final class VerlocitySettings
	{
		/*
		 * Enabling DEBUG will turn on Debug mode.
		 * Debug mode should NOT be in your finished product.
		 * While debug mode is enabled you can use
		 * verConsole, among various other tools.
		 * To activate the console press ~ on your keyboard.
		*/
		public static const DEBUG:Boolean = false; // overall debug mode - enables verConsole
		public static const COLLISION_DEBUG:Boolean = false; // debug that draws useful red dots and boxes for collision detection
		public static const UI_DEBUG:Boolean = false; // debug specifically for UI - draws boxes where appropriate
		public static const A3D_DEBUG:Boolean = false; // debug specifically for 3D - draws the 3D axises

		/*
		 * Please support Verlocity with this splash intro. :)
		 * When splash is enabled, your product will show the
		 * Verlocity logo then instantly begin your first state.
		*/
		public static const SHOW_SPLASH:Boolean = true;
		
		/*
		 * BGCOLOR sets the background color of your project.
		 * This is required and is different from Flash's background.
		*/
		public static const BGCOLOR:uint = 0x14141F;
		
		/*
		 * FRAMERATE sets the framerate of the engine loop.
		 * This will also set the frame rate of the Flash application.
		*/
		public static const	FRAMERATE:int = 60;
		
		/*
		 * CONTENT_FOLDER is a helper setting designed to keep
		 * assets organized.
		*/
		public static const CONTENT_FOLDER:String = "content/";
		

		/*
		 * These are the MovieClip classes you want to use for your
		 * state transitions.
		 * Leave them blank if you do not want transitions between states.
		 * You can set these during runtime!
		 * 
		 * STATE_TRANSITION_IN defines the transition effect that occurs
		 * when a state is first appearing (fading in).
		 *
		 * STATE_TRANSITION_OUT defines the transition effect that occurs
		 * when a state is being removed (fading out).
		*/
		public static var STATE_TRANSITION_IN:Class;
		public static var STATE_TRANSITION_OUT:Class;

		
		/*
		 * START_VOLUME is the starting volume of your project.
		 * This is to prevent games from starting out 
		 * EAR BLASTINGLY loud.  If you wish to prevent this, you can.
		*/
		public static const START_VOLUME:Number = 1.0;
		
		/*
		 * GUI_SCALE sets the scale factor of all Verlocity GUI.
		 * This is useful if you have smaller resolutions
		*/
		public static const GUI_SCALE:Number = 1.0;
		
		/*
		 * SHOW_MESSAGES enables/disables VerlocityMessages.
		 * They are small text messages notifying the user
		 * of any changes to the game engine.  Stuff like pausing,
		 * volume changes, saving, etc.
		 * They are displayed in the top right hand corner.
		*/
		public static const SHOW_MESSAGES:Boolean = true;
		
		/*
		 * PAUSABLE is the overall setting that completely
		 * disables pausing.  Disabling this will disable
		 * pausing completely.
		 * It is recommended to leave this enabled.
		*/
		public static const PAUSEABLE:Boolean = true;
		
		/*
		 * PAUSE_ONFOCUSLOST defines wheater you verPause
		 * should automatically pause the game when it looses
		 * window focus.
		*/
		public static const PAUSE_ONFOCUSLOST:Boolean = true;
		
		/*
		 * SHOW_PAUSEMENU enables/disables the built-in pause
		 * menu GUI.  You can disable this and use your own pause menu
		 * if you specify the pause menu class in the setting
		 * PAUSEMENU_GUI, below this setting.
		 * 
		 * With SHOW_PAUSEMENU disabled, you can specify
		 * your own pause menu GUI with this setting.
		*/
		public static const SHOW_PAUSEMENU:Boolean = true;
		public static var PAUSEMENU_GUI:Class;		
		
		/*
		 * These are here to add a promotional link to your website
		 * on the right click menu.
		 * If you wish to not have this, simply set RIGHTCLICK_PROMOTE to false.
		*/
		public static const RIGHTCLICK_PROMOTE:Boolean = true;
		public static const RIGHTCLICK_PROMOTETEXT:String = "Powered by VerlocityEngine.com";
		public static const RIGHTCLICK_PROMOTEURL:String = "http://www.verlocityengine.com";

		
		/*
		 * DISABLE_TAB turns off the focus rectangle that occurs
		 * when you press tab. 
		 * It is recommended you keep this setting enabled to 
		 * prevent users from bypassing different input behaviors
		 * (such as locating hidden buttons).
		*/
		public static const DISABLE_TAB:Boolean = true;
		
		
		/*
		 * KEY_MAXCOMBO represents the longest amount of key combos to compare
		 * For example, if it's set to 5 you can only compare 5 keys with the
		 * verInput.KeyCombo function.
		*/
		public static const KEY_MAXCOMBO:int = 5;
		

		/*
		 * How long can we wait between key presses to check if they've been
		 * double tapped? See verInput.KeyIsDoubleTapped.
		 * Less time means less time to double tap.
		*/
		public static const KEY_DOUBLETAP_TIME:int = 800;

		
		/*
		 * FLASH SETTINGS
		 ******************
		*/
		public static function ApplyFlashSettings( sStage:Stage ):void
		{
			/*
			 * Flash framerate.
			 * It is recommended to match this with Verlocity's frame rate.
			*/
			sStage.frameRate = FRAMERATE;

			/*
			 * Flash scalemode.
			 * http://help.adobe.com/en_US/AS2LCR/Flash_10.0/help.html?content=00001543.html
			*/
			sStage.scaleMode = StageScaleMode.SHOW_ALL;
			
			/*
			 * Default render quality.
			 * To change during runtime use Verlocity.camera.SetQualty( 1/2/3 );
			*/
			sStage.quality = StageQuality.HIGH;

			/*
			 * Flash display state.
			 * Enable/disable full screen on start.
			 * To change during runtime use Verlocity.camera.SetFullscreen( true/false );
			*/
			sStage.displayState = StageDisplayState.NORMAL;
			
			/*
			 * Enable/disable the right click context menu.
			*/
			sStage.showDefaultContextMenu = false;
		}
	}
}