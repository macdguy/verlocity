/*
 * ---------------------------------------------------------------
 * Verlocity
 * http://www.verlocityengine.com
 * 
 * This file is subject to the terms and conditions defined in
 * 'license.txt', which is part of this source code package.
 * ---------------------------------------------------------------
*/
package verlocity.settings 
{
	import flash.display.Stage;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.display.StageDisplayState;
	import flash.text.TextFormat;

	import flash.geom.Point;
	import flash.display.MovieClip;

	import verlocity.lang.LanguageData;
	import verlocity.input.KeyData;

	/**
	 * This class holds all the settings data.
	 * If you do not override them, they will default to these.
	*/
	public class SettingsData extends Object
	{
		/**
		 * Enabling DEBUG will turn on Debug mode.
		 * Debug modes should NOT be in your finished product.
		 * While debug mode is enabled you can use
		 * verConsole, among various other tools.
		 * To activate the console press ~ on your keyboard.
		 */
		public function get DEBUG():Boolean { return _DEBUG; }
		public function set DEBUG( bool:Boolean ):void { _DEBUG = bool }
		private var _DEBUG:Boolean = false;

		/**
		 * This debug mode will draw useful red dots and boxes for collision detection.
		 * Debug modes should NOT be in your finished product.
		 */
		public function get DEBUG_COLLISION():Boolean { return _DEBUG_COLLISION; }
		public function set DEBUG_COLLISION( bool:Boolean ):void { _DEBUG_COLLISION = bool }
		private var _DEBUG_COLLISION:Boolean = false;
		
		/**
		 * This debug mode will draw boxes for UI elements.
		 * Debug modes should NOT be in your finished product.
		 */
		public function get DEBUG_UI():Boolean { return _DEBUG_UI; }
		public function set DEBUG_UI( bool:Boolean ):void { _DEBUG_UI = bool }
		private var _DEBUG_UI:Boolean = false;
		
		/**
		 * This debug mode will draw 3D axises and other Away 3D debugging tools
		 * Debug modes should NOT be in your finished product.
		 */
		public function get DEBUG_A3D():Boolean { return _DEBUG_A3D; }
		public function set DEBUG_A3D( bool:Boolean ):void { _DEBUG_A3D = bool }
		private var _DEBUG_A3D:Boolean = false;

		/**
		 * Please support Verlocity with this splash intro. :)
		 * When splash is enabled, your product will show the
		 * Verlocity logo then instantly begin your first state.
		*/
		public function get SHOW_SPLASH():Boolean { return _SHOW_SPLASH; }
		public function set SHOW_SPLASH( bool:Boolean ):void { _SHOW_SPLASH = bool }
		private var _SHOW_SPLASH:Boolean = true;
		
		/**
		 * BGCOLOR sets the background color of your project.
		 * This is required and is different from Flash's background.
		*/
		public function get BGCOLOR():uint { return _BGCOLOR; }
		public function set BGCOLOR( val:uint ):void { _BGCOLOR = val }
		private var _BGCOLOR:uint = 0x14141F;
		
		/**
		 * FRAMERATE sets the framerate of the engine loop.
		 * This will also set the frame rate of the Flash application.
		*/
		public function get FRAMERATE():int { return _FRAMERATE; }
		public function set FRAMERATE( val:int ):void { _FRAMERATE = val }
		private var _FRAMERATE:int = 60;

		/**
		 * Enables/disables automatically adjusting quality based on average FPS.
		 * This is useful to turn down quality when the FPS is going down, 
		 * and turning it up when there's an increase in FPS.
		 */
		public function get FPS_ADJUST_QUALITY():Boolean { return _FPS_ADJUST_QUALITY; }
		public function set FPS_ADJUST_QUALITY( bool:Boolean ):void { _FPS_ADJUST_QUALITY = bool }
		private var _FPS_ADJUST_QUALITY:Boolean = true;
		
		/**
		 * Sets the default language of the translation system.
		 */
		public function get DEFAULT_LANGUAGE():LanguageData { return _DEFAULT_LANGUAGE; }
		public function set DEFAULT_LANGUAGE( lang:LanguageData ):void { _DEFAULT_LANGUAGE = lang }
		private var _DEFAULT_LANGUAGE:LanguageData = new LanguageData();
		
		/**
		 * Sets the default key list.
		 */
		public function get DEFAULT_KEYLIST():KeyData { return _DEFAULT_KEYLIST; }
		public function set DEFAULT_KEYLIST( keys:KeyData ):void { _DEFAULT_KEYLIST = keys }
		private var _DEFAULT_KEYLIST:KeyData = new KeyData();
		
		/**
		 * CONTENT_FOLDER is a helper setting designed to keep assets organized.
		*/
		public function get CONTENT_FOLDER():String { return _CONTENT_FOLDER; }
		public function set CONTENT_FOLDER( string:String ):void { _CONTENT_FOLDER = string }
		private var _CONTENT_FOLDER:String = "content/";
		
		/**
		 * STATE_TRANSITION_IN defines the transition MovieClip that occurs
		 * when a state is first appearing (fading in).  Leave blank if you don't want the transition.
		 */
		public function get STATE_TRANSITION_IN():MovieClip { return _STATE_TRANSITION_IN; }
		public function set STATE_TRANSITION_IN( trans:MovieClip ):void { _STATE_TRANSITION_IN = trans }
		private var _STATE_TRANSITION_IN:MovieClip;

		/**
		 * STATE_TRANSITION_OUT defines the transition MovieClip that occurs
		 * when a state is being removed (fading out).  Leave blank if you don't want the transition.
		 */
		public function get STATE_TRANSITION_OUT():MovieClip { return _STATE_TRANSITION_OUT; }
		public function set STATE_TRANSITION_OUT( trans:MovieClip ):void { _STATE_TRANSITION_OUT = trans }
		private var _STATE_TRANSITION_OUT:MovieClip;


		/**
		 * START_VOLUME is the starting volume of your project.
		 * This is to prevent games from starting out EAR BLASTINGLY loud.
		*/
		public function get START_VOLUME():Number { return _START_VOLUME; }
		public function set START_VOLUME( val:Number ):void { _START_VOLUME = val }
		private var _START_VOLUME:Number = 1.0;
		
		/**
		 * GUI_SCALE sets the scale factor of all Verlocity GUI.
		 * This is useful if you have smaller resolutions
		*/
		public function get GUI_SCALE():Number { return _GUI_SCALE; }
		public function set GUI_SCALE( val:Number ):void { _GUI_SCALE = val }
		private var _GUI_SCALE:Number = 1.0;
		
		/**
		 * SHOW_MESSAGES enables/disables VerlocityMessages.
		 * They are small text messages notifying the user
		 * of any changes to the game engine.  Stuff like pausing,
		 * volume changes, saving, etc.
		 * They are displayed in the top right hand corner.
		*/
		public function get SHOW_MESSAGES():Boolean { return _SHOW_MESSAGES; }
		public function set SHOW_MESSAGES( bool:Boolean ):void { _SHOW_MESSAGES = bool }
		private var _SHOW_MESSAGES:Boolean = true;
		
		/**
		 * Sets the default GUI message text format.
		 * Messages will only display if SHOW_MESSAGES is on.
		*/
		public function get GUI_MESSAGE_FORMAT():TextFormat { return _GUI_MESSAGE_FORMAT; }
		public function set GUI_MESSAGE_FORMAT( fmt:TextFormat ):void { _GUI_MESSAGE_FORMAT = fmt }
		private var _GUI_MESSAGE_FORMAT:TextFormat = new TextFormat( "_sans", 24, 0xFFFFFF );
			
		/**
		 * PAUSABLE is the overall setting that completely
		 * disables pausing.  Disabling this will disable
		 * pausing completely.
		 * It is recommended to leave this enabled.
		*/
		public function get PAUSEABLE():Boolean { return _PAUSEABLE; }
		public function set PAUSEABLE( bool:Boolean ):void { _PAUSEABLE = bool }
		private var _PAUSEABLE:Boolean = true;
			
		/*
		 * PAUSE_ONFOCUSLOST defines wheater you verPause
		 * should automatically pause the game when it looses
		 * window focus.
		*/
		public function get PAUSE_ONFOCUSLOST():Boolean { return _PAUSE_ONFOCUSLOST; }
		public function set PAUSE_ONFOCUSLOST( bool:Boolean ):void { _PAUSE_ONFOCUSLOST = bool }
		private var _PAUSE_ONFOCUSLOST:Boolean = true;
			
		/**
		 * SHOW_PAUSEMENU enables/disables the built-in pause
		 * menu GUI.  You can disable this and use your own pause menu
		 * if you specify the pause menu class in the setting
		 * PAUSEMENU_GUI, below this setting.
		*/
		public function get SHOW_PAUSEMENU():Boolean { return _SHOW_PAUSEMENU; }
		public function set SHOW_PAUSEMENU( bool:Boolean ):void { _SHOW_PAUSEMENU = bool }
		private var _SHOW_PAUSEMENU:Boolean = true;

		/**
		 * With SHOW_PAUSEMENU disabled, you can specify
		 * your own pause menu GUI with this setting.
		 */
		public function get PAUSEMENU_GUI():Class { return _PAUSEMENU_GUI; }
		public function set PAUSEMENU_GUI( cClass:Class ):void { _PAUSEMENU_GUI = cClass }
		private var _PAUSEMENU_GUI:Class;		

		/**
		 * Set if you want a promotional link to your website on the right click menu.
		*/
		public function get RIGHTCLICK_PROMOTE():Boolean { return _RIGHTCLICK_PROMOTE; }
		public function set RIGHTCLICK_PROMOTE( bool:Boolean ):void { _RIGHTCLICK_PROMOTE = bool }
		private var _RIGHTCLICK_PROMOTE:Boolean = true;

		/**
		 * Sets the right click promo text.
		 */
		public function get RIGHTCLICK_PROMOTETEXT():String { return _RIGHTCLICK_PROMOTETEXT; }
		public function set RIGHTCLICK_PROMOTETEXT( string:String ):void { _RIGHTCLICK_PROMOTETEXT = string }
		private var _RIGHTCLICK_PROMOTETEXT:String = "Powered by VerlocityEngine.com";
		
		/**
		 * Sets the right click promo website.
		 */
		public function get RIGHTCLICK_PROMOTEURL():String { return _RIGHTCLICK_PROMOTEURL; }
		public function set RIGHTCLICK_PROMOTEURL( string:String ):void { _RIGHTCLICK_PROMOTEURL = string }
		private var _RIGHTCLICK_PROMOTEURL:String = "http://www.verlocityengine.com";


		/**
		 * DISABLE_TAB turns off the focus rectangle that occurs
		 * when you press tab. 
		 * It is recommended you keep this setting enabled to 
		 * prevent users from bypassing different input behaviors
		 * (such as locating hidden buttons).
		*/
		public function get DISABLE_TAB():Boolean { return _DISABLE_TAB; }
		public function set DISABLE_TAB( bool:Boolean ):void { _DISABLE_TAB = bool }
		private var _DISABLE_TAB:Boolean = true;

		/**
		 * The max amount of keys to store in history.
		 * This is the longest amount of keys you can compare for verInput.KeyCombo.
		 * This also affects the verInput.KeyIsDoubleTapped function.
		 */
		public function get KEY_HISTORY_AMOUNT():int { return _KEY_HISTORY_AMOUNT; }
		public function set KEY_HISTORY_AMOUNT( val:int ):void { _KEY_HISTORY_AMOUNT = val }
		private var _KEY_HISTORY_AMOUNT:int = 5;
		
		/**
		 * How long can we wait between key presses to check if they've been
		 * double tapped? See verInput.KeyIsDoubleTapped.
		 * Less time means less time to double tap.
		*/
		public function get KEY_DOUBLETAP_TIME():uint { return _KEY_DOUBLETAP_TIME; }
		public function set KEY_DOUBLETAP_TIME( val:uint ):void { _KEY_DOUBLETAP_TIME = val }
		private var _KEY_DOUBLETAP_TIME:uint = 800;


		/**
		 * The default gravity to apply on all physics objects if they have gravity enabled.
		 * Note: This can be bypassed by any physics object
		 */
		public function get PHYS_GRAVITY():Point { return _PHYS_GRAVITY; }
		public function set PHYS_GRAVITY( point:Point ):void { _PHYS_GRAVITY = point }
		private var _PHYS_GRAVITY:Point = new Point( 0, -9.8 );


		/**
		 * Determines if blur, color, pixel bender transformations can be done to verBitmap.
		 * This can be taxing on lower-end machines.
		 * Bitmap effects are automatically turned off when the flash quality is set to low.
		 */
		public function get BITMAP_EFFECTS():Boolean { return _BITMAP_EFFECTS; }
		public function set BITMAP_EFFECTS( bool:Boolean ):void { _BITMAP_EFFECTS = bool }
		private var _BITMAP_EFFECTS:Boolean = false;



		/**
		 * Flash scalemode.
		 * http://help.adobe.com/en_US/AS2LCR/Flash_10.0/help.html?content=00001543.html
		*/
		public function get FLASH_SCALEMODE():String { return _FLASH_SCALEMODE; }
		public function set FLASH_SCALEMODE( scale:String ):void { _FLASH_SCALEMODE = scale }
		private var _FLASH_SCALEMODE:String = StageScaleMode.SHOW_ALL;

		/**
		 * Default render quality.
		 * To change during runtime use Verlocity.display.SetQualty( 1/2/3 );
		*/
		public function get FLASH_QUALITY():String { return _FLASH_QUALITY; }
		public function set FLASH_QUALITY( quality:String ):void { _FLASH_QUALITY = quality }
		private var _FLASH_QUALITY:String = StageQuality.HIGH;
			
		/**
		 * Flash display state.
		 * Enable/disable full screen on start.
		 * To change during runtime use Verlocity.display.EnableFullscreen( true/false );
		*/
		public function get FLASH_DISPLAYSTATE():String { return _FLASH_DISPLAYSTATE; }
		public function set FLASH_DISPLAYSTATE( displayState:String ):void { _FLASH_DISPLAYSTATE = displayState }
		private var _FLASH_DISPLAYSTATE:String = StageDisplayState.NORMAL;
		
		/**
		 * Enable/disable the default right click context menu.
		*/
		public function get FLASH_SHOW_DEFAULTCONTEXT():Boolean { return _FLASH_SHOW_DEFAULTCONTEXT; }
		public function set FLASH_SHOW_DEFAULTCONTEXT( bool:Boolean ):void { _FLASH_SHOW_DEFAULTCONTEXT = bool }
		private var _FLASH_SHOW_DEFAULTCONTEXT:Boolean = false;
	}
}