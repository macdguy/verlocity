/*
 * ---------------------------------------------------------------
 * Verlocity
 * http://www.verlocityengine.com
 * 
 * This file is subject to the terms and conditions defined in
 * 'license.txt', which is part of this source code package.
 * ---------------------------------------------------------------
 * Component: verEngine
 * Author: Macklin Guy
 * ---------------------------------------------------------------
*/
package verlocity.components
{
	import flash.display.Stage;
	import flash.utils.Dictionary;

	import verlocity.Verlocity;
	import verlocity.core.Ticker;
	import verlocity.events.TickerEvent;
	import verlocity.core.Component;
	import verlocity.core.ComponentManager;

	/**
	 * The main control loop of the engine.
	 * Contains timescale functions and loop hooks.
	 */
	public final class verEngine extends Component
	{
		private var vHooks:Vector.<Object>;

		private var engineTimer:Ticker;
		private var clockTimer:Ticker;

		private var uiCurTime:uint;
		private var nTimeScale:Number;
		
		private var nDeltaTime:Number;

		/**
		 * Constructor of the component.
		 * @param	sStage
		 */
		public function verEngine( sStage:Stage ):void
		{
			// Setup component
			super( sStage );
			
			// Component-specific construction

			// Create vector for hooks
			vHooks = new Vector.<Object>();

			// Default timescale/time
			nTimeScale = 1;
			uiCurTime = 0;
			nDeltaTime = 1000 / Verlocity.settings.FRAMERATE;

			// Create the engine tick
			engineTimer = new Ticker( nDeltaTime );
			engineTimer.addEventListener( TickerEvent.TICK, TickUpdate );
			engineTimer.start();

			// Create the clock tick
			clockTimer = new Ticker( 1 );
			clockTimer.addEventListener( TickerEvent.TICK, ClockUpdate );
			clockTimer.start();
		}

		/**
		 * Concommands of the component.
		 */
		protected override function _Concommands():void 
		{
			Verlocity.console.Register( "timescale", function( scale:String ):void
			{
				SetTimeScale( Number( scale ) );
			}, "Alters the timescale.  Less than 1 to make it run slower, more than 1 to make it run faster." );

			Verlocity.console.Register( "curtime", function():void
			{
				Verlocity.console.Output( "CurTime: " + CurTime() );
			}, "Outputs the current time." );
		}
		
		/**
		 * Destructor of the component.
		 */
		public override function _Destruct():void
		{
			// Destroy component
			super._Destruct();
			
			// Component-specific destruction

			// Remove engine timer
			engineTimer.stop();
			engineTimer.removeEventListener( TickerEvent.TICK, TickUpdate );
			engineTimer = null;

			// Remove clock timer
			clockTimer.stop();
			clockTimer.removeEventListener( TickerEvent.TICK, ClockUpdate );
			clockTimer = null;

			// Remove object hooks
			vHooks.length = 0;
			vHooks = null;

			nTimeScale = NaN;
			uiCurTime = NaN;
		}
		
		/*================== COMPONENT ==================*/

		/*------------------- PRIVATE -------------------*/
		/**
		 * This is the main game loop.
		 * It calls all the referenced engine objects and runs their Update functions.
		*/
		private final function TickUpdate( e:TickerEvent ):void
		{
			if ( Verlocity.IsQuitting() ) { return; }

			// Update all the components
			ComponentManager._UpdateAll();

			// Update all hooks
			HookUpdate();

			// Update bitmap renderer
			if ( Verlocity.bitmap )
			{
				Verlocity.bitmap._Render();
			}
		}

		/**
		 * Updates the current time every milisecond.
		 */
		private final function ClockUpdate( e:TickerEvent ):void
		{
			uiCurTime++;
		}

		/**
		 * Loops through all the hooked objects, updating their Update function.
		 */
		private final function HookUpdate():void
		{
			// Check if valid
			if ( !vHooks ) { return; }

			// Get length and return if zero
			var iLength:int = vHooks.length;
			if ( iLength <= 0 ) { return; }

			// Loop through all of the hooks
			var hook:Object;
			for ( var i:int = iLength - 1; i >= 0; i-- )
			{
				hook = vHooks[i];

				// Check if valid
				if ( hook )
				{
					// Update
					hook.Update();
				}
				else
				{
					// Remove, no longer valid
					vHooks.splice( i, 1 );
				}

				hook = null;
			}
		}

		/*===============================================*/
		
		/*------------------- PUBLIC --------------------*/
		/**
		 * Returns the current time (in miliseconds).
		 * @return
		 */
		public final function CurTime():uint
		{
			return uiCurTime;
		}
		
		/**
		 * Returns the delta time
		 */
		public final function get DT():Number
		{
			return nDeltaTime / 1000;
		}

		/**
		 * Sets the timescale of the engine.
		 * Lower than 1 will result in slowed down time.
		 * @param	nNewTimeScale The new timescale to set to (min = 0, max = 5 ).
		 */
		public final function SetTimeScale( nNewTimeScale:Number, bAdjustFramerate:Boolean = false ):void
		{
			// Limit the timescale
			if ( nNewTimeScale <= 0 || nNewTimeScale > 5 ) { return; }

			// Set the timescale
			nTimeScale = nNewTimeScale;
			engineTimer.delay = ( nDeltaTime ) / nTimeScale;

			// Set the framerate
			if ( bAdjustFramerate )
			{
				stage.frameRate = Verlocity.settings.FRAMERATE * nNewTimeScale;
			}

			// Notify
			Verlocity.Trace( "Timescale altered. Now: " + nNewTimeScale, "Engine" );
		}
		/**
		 * Hooks an object to the game loop.  It will not add duplicates.
		 * Note: Requires a public function named 'Update' in the object.
		 * @param	newObj The object you want to hook into the main game loop.
		*/
		public final function Hook( newObj:Object ):void
		{
			// Check for duplicates
			if ( -1 != vHooks.indexOf( newObj ) )
			{
				Verlocity.Trace( newObj + Verlocity.lang.T( "GenericDuplicate" ), "Engine" );
				return;
			}

			// Add hook, was successful
			if ( "Update" in newObj )
			{
				vHooks[ vHooks.length ] = newObj;
				Verlocity.Trace( newObj + Verlocity.lang.T( "GenericAddSuccess" ), "Engine" );
				return;
			}

			// Add failed
			Verlocity.Trace( Verlocity.lang.T( "GenericAddFail" ), "Engine" );
		}

		/**
		 * Removes an object from the engine hook.
		 * MAKE SURE TO DO THIS BEFORE YOU REMOVE ANY HOOKED OBJECTS!
		 * @param	objToRemove The object you want to remove from the main game loop.
		*/
		public final function UnHook( objToRemove:Object ):void
		{
			// Check if there's hooks
			if ( vHooks.length <= 0 ) { return; }

			// Get the hook and check if it exists
			var i:int = vHooks.indexOf( objToRemove );
			if ( i == -1 ) { Verlocity.Trace( Verlocity.lang.T( "GenericMissing" ), "Engine" ); return; }

			// Remove the hook
			vHooks.splice( i, 1 );
			Verlocity.Trace( Verlocity.lang.T( "GenericRemove" ) + objToRemove, "Engine" );
		}
		
		/**
		 * Removes all current hooked objects in the engine.  Very useful for state changes.
		*/
		public final function RemoveAllHooks():void
		{
			// Reset the hook vector
			vHooks = new Vector.<Object>();
			Verlocity.Trace( Verlocity.lang.T( "GenericRemoveAll" ), "Engine" );
		}

		/**
		 * Pauses the main game loop.
		*/
		public final function Pause():void
		{
			if ( IsPaused() ) { return; }

			// Pause the timers
			engineTimer.stop();
			clockTimer.stop();

			Verlocity.Trace( "Paused engine.", "Engine" );
		}

		/**
		 * Resumes the main game loop.
		*/
		public final function Resume():void
		{
			if ( !IsPaused() ) { return; }

			// Resume the timers
			engineTimer.start();
			clockTimer.start();

			Verlocity.Trace( "Resumed engine.", "Engine" );
		}
		
		/**
		 * Returns if the engine ticks are paused.
		 * @return
		 */
		public final function IsPaused():Boolean
		{
			return !engineTimer.running;
		}
	}
}