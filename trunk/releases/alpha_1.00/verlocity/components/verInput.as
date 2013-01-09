/*
 * ---------------------------------------------------------------
 * Verlocity
 * http://www.verlocityengine.com
 * 
 * This file is subject to the terms and conditions defined in
 * 'license.txt', which is part of this source code package.
 * ---------------------------------------------------------------
 * Component: verInput
 * Author: Macklin Guy
 * ---------------------------------------------------------------
*/
package verlocity.components
{
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.display.Stage;
	import flash.ui.Keyboard;
	import flash.ui.Mouse;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.MouseCursor;
	import flash.utils.Dictionary;

	import verlocity.Verlocity;
	import verlocity.core.Component;
	import verlocity.input.KeyCode;
	import verlocity.utils.MathUtil;

	/**
	 * Keyboard and mouse input handling.
	 * Supports various useful features such as 
	 * force focusing, key combos, double tapping,
	 * key history, triggered, released, and more.
	 */
	public final class verInput extends Component
	{
		private var dictKeysDown:Dictionary;
		private var dictKeysWasDown:Dictionary;
		private var iNextClear:int;
		private var aKeyHistory:Array;
		
		private var bShiftMod:Boolean;
		private var bCtrlMod:Boolean;
		private var bAltMod:Boolean;

		private var bIsMouseDown:Boolean;
		private var iMx:int;
		private var iMy:int;
		private var nMouseWheelDelta:Number;

		private var bDisableKeyControls:Boolean;
		private var bDisableMouseControls:Boolean;
		
		private const HISTORY_KEY:int = 0;
		private const HISTORY_TIME:int = 1;
		private const HISTORY_USED_COMBO:int = 2;
		private const HISTORY_USED_DOUBLE:int = 3;
		
		public const CURSOR_ARROW:String = MouseCursor.ARROW;
		public const CURSOR_AUTO:String = MouseCursor.AUTO;
		public const CURSOR_BUTTON:String = MouseCursor.BUTTON;
		public const CURSOR_HAND:String = MouseCursor.HAND;
		public const CURSOR_IBEAM:String = MouseCursor.IBEAM;

		/**
		 * Constructor of the component.
		 * @param	sStage
		 */
		public function verInput( sStage:Stage ):void
		{
			// Setup component
			super( sStage, true, true );
			
			// Component-specific construction
			dictKeysDown = new Dictionary( true );
			dictKeysWasDown = new Dictionary( true );
			aKeyHistory = new Array();

			iMx = iMy = 0;

			stage.addEventListener( KeyboardEvent.KEY_DOWN, KeyPressed );
			stage.addEventListener( KeyboardEvent.KEY_UP, KeyReleased );

			stage.addEventListener( MouseEvent.MOUSE_MOVE, MouseMove );
			stage.addEventListener( MouseEvent.MOUSE_DOWN, MouseDown );
			stage.addEventListener( MouseEvent.MOUSE_UP, MouseUp );
			stage.addEventListener( MouseEvent.MOUSE_WHEEL, MouseWheelDelta );
		}

		/**
		 * Stores the last pressed keys for later reference.
		 */
		protected override function _Update():void
		{
			if ( bDisableKeyControls ) { return; }

			// Clear last pressed keys
			if ( Verlocity.engine.CurTime() > iNextClear )
			{
				for ( var lastKey:String in dictKeysWasDown )
				{
					delete dictKeysWasDown[ uint( lastKey ) ];
				}

				// Update last pressed
				for ( var key:String in dictKeysDown )
				{
					dictKeysWasDown[ uint( key ) ] = dictKeysDown[key];
				}
				
				iNextClear = Verlocity.engine.CurTime() + 50;
			}
		}

		/**
		 * Destructor of the component.
		 */
		public override function _Destruct():void
		{
			// Component-specific destruction
			dictKeysDown = null;
			dictKeysWasDown = null;
			aKeyHistory.length = 0;
			aKeyHistory = null;

			stage.removeEventListener( KeyboardEvent.KEY_DOWN, KeyPressed );
			stage.removeEventListener( KeyboardEvent.KEY_UP, KeyReleased );

			stage.addEventListener( MouseEvent.MOUSE_MOVE, MouseMove );
			stage.addEventListener( MouseEvent.MOUSE_DOWN, MouseDown );
			stage.addEventListener( MouseEvent.MOUSE_UP, MouseUp );
			stage.addEventListener( MouseEvent.MOUSE_WHEEL, MouseWheelDelta );

			// Destroy component
			super._Destruct();
		}

		/*================== COMPONENT ==================*/

		/*------------------- PRIVATE -------------------*/
		/**
		 * Hooks into the key down event.
		 * @param	KeyboardEvent.KEY_DOWN
		 */
		private final function KeyPressed( ke:KeyboardEvent ):void
		{
			// Send to hot key
			Verlocity.keys._HandleHotKeys( ke.keyCode );

			if ( bDisableKeyControls ) { return; }
			
			// Disable tab
			if ( Verlocity.settings.DISABLE_TAB )
			{
				if ( ke.keyCode == KeyCode.TAB )
				{
					ke.currentTarget.tabChildren = false;
				}
			}

			// Determine if the key is down
			dictKeysDown[ ke.keyCode ] = true;

			// Key history (keyCode, time, used)
			aKeyHistory.unshift( new Array( ke.keyCode, Verlocity.engine.CurTime(), false, false ) );
			aKeyHistory.length = Verlocity.settings.KEY_HISTORY_AMOUNT;

			// Check if modifiers changed
			bShiftMod = ke.shiftKey;
			bCtrlMod = ke.ctrlKey;
			bAltMod = ke.altKey;
		}

		/**
		 * Hooks into the key up event.
		 * @param	ke KeyboardEvent.KEY_UP
		 */
		private final function KeyReleased( ke:KeyboardEvent ):void
		{
			if ( bDisableKeyControls ) { return; }

			// Remove if the key is up
			delete dictKeysDown[ ke.keyCode ];

			// Check if modifiers changed
			bShiftMod = ke.shiftKey;
			bCtrlMod = ke.ctrlKey;
			bAltMod = ke.altKey;
		}

		/**
		 * Hooks into the mouse move event.
		 * @param	me MouseEvent.MOUSE_MOVE
		 */
		private final function MouseMove( me:MouseEvent ):void
		{
			if ( bDisableMouseControls ) { return; }

			iMx = me.stageX; iMy = me.stageY;
		}
		
		/**
		 * Hooks into the mouse down event.
		 * @param	me MouseEvent.MOUSE_DOWN
		 */
		private final function MouseDown( me:MouseEvent ):void
		{
			if ( bDisableMouseControls ) { return; }

			bIsMouseDown = true;
		}
		
		/**
		 * Hooks into the mouse up event.
		 * @param	me MouseEvent.MOUSE_UP
		 */
		private final function MouseUp( me:MouseEvent ):void
		{
			if ( bDisableMouseControls ) { return; }

			bIsMouseDown = false;
		}

		/**
		 * Hooks into the mouse wheel event.
		 * @param	me MouseEvent.MOUSE_WHEEL
		 */
		private final function MouseWheelDelta( me:MouseEvent ):void
		{
			if ( bDisableMouseControls ) { return; }
			
			nMouseWheelDelta = me.delta;
		}

		/*===============================================*/
		
		/*------------------- PUBLIC --------------------*/
		/**
		 * Returns if a key is currently down/pressed.
		 * @param	keyCode The key either uint keyCode or String (for registered hotkeys)
		 * @return
		 */
		public final function KeyIsDown( keyCode:* ):Boolean
		{
			if ( bDisableKeyControls ) { return false; }

			// Get key code
			var key:uint;

			if ( keyCode is uint ) { key = keyCode; }
			else if ( keyCode is String ) { key = Verlocity.Key( keyCode ); }
			else { return false; }
	

			return Boolean( key in dictKeysDown );
		}
		
		/**
		 * Returns if a key was triggered (pressed once, not held).
		 * @param	keyCode The key either uint keyCode or String (for registered hotkeys)
		 * @return
		 */
		public final function KeyIsTriggered( keyCode:* ):Boolean
		{
			if ( bDisableKeyControls ) { return false; }

			// Get key code
			var key:uint;

			if ( keyCode is uint ) { key = keyCode; }
			else if ( keyCode is String ) { key = Verlocity.Key( keyCode ); }
			else { return false; }
			

			return Boolean( key in dictKeysDown ) && !Boolean( key in dictKeysWasDown );
		}
		
		/**
		 * Returns if a key was released.
		 * @param	keyCode The key either uint keyCode or String (for registered hotkeys)
		 */
		public final function KeyIsReleased( keyCode:* ):Boolean
		{
			if ( bDisableKeyControls ) { return false; }

			// Get key code
			var key:uint;

			if ( keyCode is uint ) { key = keyCode; }
			else if ( keyCode is String ) { key = Verlocity.Key( keyCode ); }
			else { return false; }
			
			
			return !Boolean( key in dictKeysDown ) && Boolean( key in dictKeysWasDown );
		}
		
		/**
		 * Returns if a key was double tapped.
		 * @param	keyCode The key either uint keyCode or String (for registered hotkeys)
		 * @return
		 */
		public final function KeyIsDoubleTapped( keyCode:* ):Boolean
		{
			if ( bDisableKeyControls ) { return false; }

			// Get key code
			var key:uint;

			if ( keyCode is uint ) { key = keyCode; }
			else if ( keyCode is String ) { key = Verlocity.Key( keyCode ); }
			else { return false; }


			// Store times to compare
			var iKeyTimeRecent:int;
			var iKeyTimeOld:int;

			// Loop through history and get the times
			for ( var i:int = 0; i < aKeyHistory.length; i++ )
			{
				if ( aKeyHistory[i] )
				{
					if ( aKeyHistory[i][HISTORY_KEY] == key && !aKeyHistory[i][HISTORY_USED_DOUBLE] )
					{
						// First key press
						if ( iKeyTimeRecent == 0 )
						{
							iKeyTimeRecent = aKeyHistory[i][HISTORY_TIME];
						} // Second key press
						else if ( iKeyTimeOld == 0 )
						{
							iKeyTimeOld = aKeyHistory[i][HISTORY_TIME];	
						}
					}
				}
			}

			// Make sure there was actually a double press or press at all
			if ( iKeyTimeRecent <= 0 || iKeyTimeOld <= 0 )
			{
				return false;
			}

			// Compare times
			if ( ( iKeyTimeRecent - iKeyTimeOld ) <= Verlocity.settings.KEY_DOUBLETAP_TIME )
			{
				// Set to used
				for ( i = 0; i < aKeyHistory.length; i++ )
				{
					if ( aKeyHistory[i][HISTORY_KEY] == key )
					{
						// Recent
						if ( aKeyHistory[i][HISTORY_TIME] == iKeyTimeRecent )
						{
							aKeyHistory[i][HISTORY_USED_DOUBLE] = true;
						}

						// Old
						if ( aKeyHistory[i][HISTORY_TIME] == iKeyTimeOld )
						{
							aKeyHistory[i][HISTORY_USED_DOUBLE] = true;								
						}
					}
				}

				// Key was double tapped!
				return true;
			}
			
			return false;
		}

		/**
		 * Returns if a sequential key combo was pressed.
		 * Array must be a list of uint keyCodes!
		 * Must be in the order the combo should be pressed in.
		 * @param	aKeyCombo The array containing the key combo.
		 * @return
		 */
		public final function KeyCombo( aKeyCombo:Array ):Boolean
		{
			if ( bDisableKeyControls ) { return false; }

			// Array inserted too long
			if ( aKeyCombo.length > aKeyHistory.length )
			{
				return false;
			}

			// Reverse it
			aKeyCombo.reverse();

			// Loop through and compare
			for ( var i:int; i < aKeyCombo.length; i++ )
			{
				// If it doesn't match a single one, return
				if ( aKeyCombo[i] != aKeyHistory[i][HISTORY_KEY] )
				{
					return false;
				}
				else
				{
					// If used, return
					if ( aKeyHistory[i][HISTORY_USED_COMBO] )
					{
						return false;
					}
				}
			}

			// Set keys to used
			for ( i = 0; i < aKeyCombo.length; i++ )
			{
				if ( aKeyCombo[i] == aKeyHistory[i][HISTORY_KEY] )
				{
					aKeyHistory[i][HISTORY_USED_COMBO] = true;
				}
			}
			
			return true;
		}

		/**
		 * Clears the entire key history.
		 */
		public final function ClearKeyHistory():void
		{
			dictKeysDown = new Dictionary( true );
			dictKeysWasDown = new Dictionary( true );
			aKeyHistory.length = 0;
		}
		
		/**
		 * Returns the key history array.
		 * @return
		 */
		public final function GetKeyHistory():Array
		{
			return aKeyHistory;
		}
		
		/**
		 * Returns if the left mouse button is down.
		 * @return
		 */
		public final function MouseIsDown():Boolean
		{
			return bIsMouseDown;
		}
		
		/**
		 * Returns the current mouse wheel delta.
		 * @return
		 */
		public final function MouseWheel():Number
		{
			return nMouseWheelDelta;
		}

		/**
		 * Returns the current mouse x position.
		 */
		public final function get Mx():int { return iMx; }
		
		/**
		 * Returns the current mouse y position.
		 */
		public final function get My():int { return iMy; }

		/**
		 * Returns if the mouse is inside a dispay object.
		 * @param	disp The display object
		 * @return
		 */
		public final function MouseIsInside( disp:DisplayObject ):Boolean
		{
			return iMx >= disp.x && iMx < disp.width && iMy < disp.y && iMy >= disp.height;
		}
		
		/**
		 * Sets the mouse cursor to a specific type.
		 * @param	cursor The string cursor (use CURSOR_*)
		 */
		public final function SetCursor( cursor:String ):void
		{
			Mouse.cursor = cursor;
		}
		
		/**
		 * Enables/disables the keyboard input.
		 * @param	bEnabled Should the key input be enabled?
		 */
		public final function EnableKeys( bEnabled:Boolean = true ):void
		{
			bDisableKeyControls = !bEnabled;
			
			if ( bDisableKeyControls )
			{
				ClearKeyHistory();
			}
		}

		/**
		 * Enables/disables the mouse input.
		 * @param	bEnabled Should the mouse input be enabled?
		 */
		public final function EnableMouse( bEnabled:Boolean = true ):void
		{
			bDisableMouseControls = !bEnabled;
		}
		
		/**
		 * Shows/hides the mouse cursor.
		 * @param	bShow Should the mouse cursor be visible?
		 */
		public final function ShowMouse( bShow:Boolean = true ):void
		{
			if ( bShow )
			{
				Mouse.show();
			}
			else
			{
				Mouse.hide();	
			}			
		}

		/**
		 * Forces keyboard focus on the stage.
		 * This occurs each state change.
		 */
		public final function ForceFocus():void
		{
			stage.focus = stage;
		}
		
		/**
		 * Forces keyboard focus on a specific nteractive object.
		 * @param	disp The interactive object
		 */
		public final function Focus( inter:InteractiveObject ):void
		{
			stage.focus = inter;
		}

		/**
		 * Returns if the key input is enabled.
		 * @return
		 */
		public final function IsKeyEnabled():Boolean { return !bDisableKeyControls; }
		
		/**
		 * Returns if the mouse input is enabled.
		 * @return
		 */
		public final function IsMouseEnabled():Boolean { return !bDisableMouseControls; }
		
		/**
		 * Returns if the shift key is held down.
		 * @return
		 */
		public final function IsShiftDown():Boolean { return bShiftMod; }
		
		/**
		 * Returns if the control key is held down.
		 * @return
		 */
		public final function IsControlDown():Boolean { return bCtrlMod; }
		
		/**
		 * Returns if the alt key is held down.
		 * @return
		 */
		public final function IsAltDown():Boolean { return bAltMod; }
	}
}