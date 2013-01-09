/*
 * ---------------------------------------------------------------
 * Verlocity
 * http://www.verlocityengine.com
 * 
 * This file is subject to the terms and conditions defined in
 * 'license.txt', which is part of this source code package.
 * ---------------------------------------------------------------
 * Component: verPause
 * Author: Macklin Guy
 * ---------------------------------------------------------------
*/
package verlocity.components
{
	import flash.display.Stage;

	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.utils.getTimer;

	import verlocity.Verlocity;
	import verlocity.core.Component;
	import verlocity.input.KeyCode;
	import verlocity.display.gui.PauseMenu;
	import verlocity.utils.GraphicsUtil;

	/**
	 * Handles pausing and unpausing.
	 * Monitors if the user pressed the hotkey (default 'P')
	 * or when the user clicks out of the game.
	 * It also provides a customizable pause menu with quick settings.
	 */
	public final class verPause extends Component
	{
		private var bPauseEnabled:Boolean;
		private var iPauseDelay:int;

		private var bHadKeyInput:Boolean;
		private var bHadMouseInput:Boolean;
		
		private var guiPauseMenu:DisplayObject;
		private var sPauseBG:Shape;

		private var vPauseMenu:Vector.<Array>;

		/**
		 * Constructor of the component.
		 * @param	sStage
		 */
		public function verPause( sStage:Stage ):void
		{
			// Setup component
			super( sStage, false );
			
			// Component-specific construction
			bPauseEnabled = true;
			vPauseMenu = new Vector.<Array>();

			stage.addEventListener( KeyboardEvent.KEY_DOWN, PauseKeyHandle );
			stage.addEventListener( Event.DEACTIVATE, PauseLostFocusHandle );
		}

		/**
		 * Concommands of the component.
		 */
		protected override function _Concommands():void 
		{
			Verlocity.console.Register( "pause", function():void
			{
				Pause();
			}, "Pauses the engine." );

			Verlocity.console.Register( "resume", function():void
			{
				Resume();
			}, "Resumes the engine." );
		}

		/**
		 * Destructor of the component.
		 */
		public override function _Destruct():void
		{	
			// Component-specific destruction
			bPauseEnabled = false;
			vPauseMenu = null;

			stage.removeEventListener( KeyboardEvent.KEY_DOWN, PauseKeyHandle );
			stage.removeEventListener( Event.DEACTIVATE, PauseLostFocusHandle );
			
			// Destroy component
			super._Destruct();
		}

		/*================== COMPONENT ==================*/

		/*------------------- PRIVATE -------------------*/
		/**
		 * Handles the key input of pausing/resuming
		 * @param	ke
		 */
		private final function PauseKeyHandle( ke:KeyboardEvent ):void
		{
			if ( !CanPause() ) { return; }

			// Disable if console is displayed
			if ( Verlocity.IsValid( Verlocity.console ) )
			{
				if ( Verlocity.console.IsFocused() )
				{
					return;
				}
			}

			if ( ke.keyCode == Verlocity.keys.Get( "VerlocityPause" ) )
			{
				PauseToggle();
			}
		}
		
		private final function PauseLostFocusHandle( e:Event ):void
		{
			if ( !Verlocity.settings.PAUSE_ONFOCUSLOST ) { return; }
			
			if ( IsPaused() || !CanPause() ) { return; }

			Pause();
		}
		
		private final function PauseToggle():void
		{
			if ( IsPaused() )
			{
				Resume();
			}
			else
			{
				Pause();
			}
		}

		/*===============================================*/
		
		/*------------------- PUBLIC --------------------*/
		/**
		 * Pauses everything and displays a pause GUI.
		 */
		public final function Pause():void
		{
			if ( IsPauseDisabled() || IsPaused() || !CanPause() ) { return; }

			iPauseDelay = getTimer() + 500;

			//Pause engine, sounds, animations
			Verlocity.engine.Pause();
			Verlocity.sound.PauseAll();
			Verlocity.ents.PauseAllAnimations();

			// Disable in-game input
			bHadKeyInput = Verlocity.input.IsKeyEnabled();
			bHadMouseInput = Verlocity.input.IsMouseEnabled();
			Verlocity.input.EnableKeys( false );
			Verlocity.input.EnableMouse( false );


			// Fade out content with background
			sPauseBG = new Shape();
				sPauseBG.graphics.beginFill( 0x000000, .75 );
					GraphicsUtil.DrawScreenRect( sPauseBG.graphics );
				sPauseBG.graphics.endFill();
			Verlocity.layers.layerUI.addChild( sPauseBG );
			
			// Add the pause menu
			if ( guiPauseMenu ) { return; } // already have a pause menu, don't add another

			if ( Verlocity.settings.SHOW_PAUSEMENU )
			{
				guiPauseMenu = new PauseMenu( Verlocity.ScrCenter.x, Verlocity.ScrCenter.y );
				guiPauseMenu.scaleX = Verlocity.settings.GUI_SCALE;
				guiPauseMenu.scaleY = Verlocity.settings.GUI_SCALE;
			}
			else
			{
				if ( Verlocity.settings.PAUSEMENU_GUI )
				{
					guiPauseMenu = new Verlocity.settings.PAUSEMENU_GUI();
				}
			}

			if ( guiPauseMenu )
			{
				Verlocity.layers.layerUI.addChild( guiPauseMenu );
			}

			Verlocity.message.Create( Verlocity.lang.T( "VerlocityPause" ) );
		}

		/**
		 * Resumes everything and removes the pause GUI.
		 */
		public final function Resume():void
		{
			if ( IsPauseDisabled() || !IsPaused() ) { return; }
			
			if ( iPauseDelay > getTimer() ) { return; }

			// Remove the pause menu
			if ( guiPauseMenu )
			{
				Verlocity.layers.layerUI.removeChild( guiPauseMenu );
				if ( !Verlocity.settings.PAUSEMENU_GUI ) { PauseMenu( guiPauseMenu ).Dispose(); }
				guiPauseMenu = null;
			}
			
			// Remove the BG
			if ( sPauseBG )
			{
				Verlocity.layers.layerUI.removeChild( sPauseBG );
				sPauseBG = null;
			}

			if ( !IsPaused() ) { return; }

			// Resume engine, sound, animations
			Verlocity.engine.Resume();
			Verlocity.sound.ResumeAll();
			Verlocity.ents.ResumeAllAnimations();

			// Enable input again
			Verlocity.input.EnableKeys( bHadKeyInput );
			Verlocity.input.EnableMouse( bHadMouseInput );
			Verlocity.input.ForceFocus();

			Verlocity.message.Create( Verlocity.lang.T( "VerlocityUnpause" ) );
		}
		
		/**
		 * Returns if you can actually pause.
		 * @return
		 */
		public final function CanPause():Boolean
		{
			if ( IsPauseDisabled() ) { return false; }
			
			if ( iPauseDelay > getTimer() ) { return false; }

			// Disable during state transitions
			if ( Verlocity.IsValid( Verlocity.state ) )
			{
				if ( Verlocity.state.IsTransitioning() || Verlocity.state.IsSplashing() )
				{
					return false;
				}
			}
			
			return true;
		}

		/**
		 * Enables pausing.
		 */
		public final function Enable():void
		{
			bPauseEnabled = true;
		}

		/**
		 * Disables pausing.
		 */
		public final function Disable():void
		{
			bPauseEnabled = false;
		}
		
		/**
		 * Adds a pause menu item.
		 * @param	sName Item name
		 * @param	fFunction Function the button preforms
		 */
		public final function AddPauseMenuItem( sName:String, fFunction:Function ):void
		{
			if ( !sName || fFunction == null ) { return; }

			vPauseMenu.push( new Array( sName, fFunction ) );
		}
		
		/**
		 * Removes a pause menu item.
		 * @param	sName Item name
		 */
		public final function RemovePauseMenuItem( sName:String ):void
		{
			if ( !sName ) { return; }

			var iLength:int = vPauseMenu.length;
			if ( iLength == 0 ) { return; }

			for ( var i:int = 0; i < iLength; i++ )
			{
				if ( vPauseMenu[i][0] == sName )
				{
					delete vPauseMenu[i];
					vPauseMenu[i] = null;
					vPauseMenu.splice( i, 1 );				
				}
			}
		}
		
		/**
		 * Clears all pause menu items.
		 */
		public final function ClearPauseMenuItems():void
		{
			vPauseMenu.length = 0;
		}
		
		/**
		 * Returns if pause was disabled.
		 * @return
		 */
		public final function IsPauseDisabled():Boolean { return !bPauseEnabled; }
		
		/**
		 * Returns if the engine is paused.
		 * @return
		 */
		public final function IsPaused():Boolean { return Verlocity.engine.IsPaused(); }

		/**
		 * Returns the list of pause menu items.
		 */
		public final function get MenuList():Vector.<Array> { return vPauseMenu; }
		
		/**
		 * Returns the display object of the pause menu.
		 */
		public final function get MenuDisp():DisplayObject { return guiPauseMenu; }
		
		/**
		 * Returns the pause menu gui element.
		 */
		public final function get MenuGUI():PauseMenu { return PauseMenu( guiPauseMenu ); }
	}
}