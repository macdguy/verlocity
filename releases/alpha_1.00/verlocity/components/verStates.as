/*
 * ---------------------------------------------------------------
 * Verlocity
 * http://www.verlocityengine.com
 * 
 * This file is subject to the terms and conditions defined in
 * 'license.txt', which is part of this source code package.
 * ---------------------------------------------------------------
 * Component: verStates
 * Author: Macklin Guy
 * ---------------------------------------------------------------
*/
package verlocity.components
{
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;

	import verlocity.Verlocity;
	import verlocity.logic.State;
	import verlocity.core.Component;
	import verlocity.utils.DisplayUtil;
	import verlocity.utils.SysUtil;

	/**
	 * Manages the current state.
	 * States are specific classes that handle each level
	 * or gameplay state the game is currently in.
	 */
	public final class verStates extends Component
	{
		[Embed(source = "../VerlocityContent.swf", symbol = "Splash")]
		private var VerlocitySplash:Class;
		
		private var CurrentState:State;
		private var NextState:State;
		
		private var bTransitionsDisabled:Boolean;
		private var bTransitioning:Boolean;
		private var bTransIn:Boolean;
		private var bTransOut:Boolean;
		private var mcTransition:MovieClip;
		
		private var bSplashing:Boolean;
		private var bSplashed:Boolean;
		private var mcSplash:MovieClip;

		/**
		 * Constructor of the component.
		 * @param	sStage
		 */
		public function verStates( sStage:Stage ):void
		{
			// Setup component
			super( sStage, true, true );

			// Component-specific construction
		}
		
		/**
		 * Updates the current state and handles transitions
		 */
		protected override function _Update():void
		{
			// Splash
			if ( bSplashing )
			{
				UpdateSplash();
				return;
			}

			// Transitions
			if ( bTransitioning )
			{
				UpdateTransitions();
				return;
			}

			// Current state update
			if ( CurrentState )
			{
				if ( CurrentState.ShouldEnd() )
				{
					End();
					return;
				}

				CurrentState.Update();
				
				if ( Verlocity.IsValid( Verlocity.input ) )
				{
					CurrentState.UpdateInput();
				}
			}
		}
		
		/**
		 * Destructor of the component.
		 */
		public override function _Destruct():void
		{
			// Component-specific destruction
			RemoveSplash();
			RemoveTransition();

			bSplashing = false;
			bTransitioning = false;
			bTransIn = false;
			bTransOut = false;
			
			NextState = null;
			_DestroyCurrentState();

			// Destroy component
			super._Destruct();
		}

		/**
		 * Concommands of the component.
		 */
		protected override function _Concommands():void 
		{
			Verlocity.console.Register( "endstate", function():void
			{
				End();
			}, "Ends the current state.  If NextState is available, it will go to that state." );

			Verlocity.console.Register( "restart", function():void
			{
				Restart();
			}, "Restarts the current state." );
		}
		
		/*================== COMPONENT ==================*/

		/*------------------- PRIVATE -------------------*/
		private final function UpdateSplash():void
		{
			if ( DisplayUtil.HasEnded( mcSplash ) )
			{
				Splash( true );
			}
		}
		
		/**
		 * Handles splash screen.
		 * @param	bFinished Is the splash finished?
		 */
		private final function Splash( bIsFinished:Boolean ):void
		{
			// Start splash
			if ( !bIsFinished )
			{
				Verlocity.Trace( "Playing Verlocity splash.  Thanks for your support!", "States" );
				bSplashing = true;
				bSplashed = true;
				
				// Create splash
				mcSplash = new VerlocitySplash();
				mcSplash.gotoAndPlay( 1 );
				
				// Center
				mcSplash.x = Verlocity.ScrCenter.x;
				mcSplash.y = Verlocity.ScrCenter.y;

				// Fit to the screen resolution
				mcSplash.scaleX = Verlocity.ScrH / 400;
				mcSplash.scaleY = Verlocity.ScrH / 400;
					
				// Add to the screen
				if ( Verlocity.IsValid( Verlocity.layers ) )
				{
					// Add to layer manager
					Verlocity.layers.layerVerlocity.addChild( mcSplash );
				}
				else
				{
					// Add to stage
					stage.addChild( mcSplash );
				}
				
				stage.addEventListener( KeyboardEvent.KEY_DOWN, SplashKey );
			}
			else // Splash finished
			{
				bSplashing = false;

				// Remove splash
				RemoveSplash();
				
				SysUtil.GC();
				
				// Set next state
				Set( NextState );
			}
		}

		/**
		 * Removes the splash graphic.
		 */
		private final function RemoveSplash():void
		{
			if ( !mcSplash ) { return; }

			DisplayUtil.RemoveFromParent( mcSplash );
			mcSplash.stop();
			mcSplash = null;

			if ( stage.hasEventListener( KeyboardEvent.KEY_DOWN ) )
			{
				stage.removeEventListener( KeyboardEvent.KEY_DOWN, SplashKey );
			}
		}
		
		/**
		 * Speeds up the splash when a key is pressed.
		 * @param	ke Keyboard event
		 */
		private final function SplashKey( ke:KeyboardEvent ):void
		{
			if ( !mcSplash ) { return; }

			if ( !DisplayUtil.HasEnded( mcSplash ) )
			{
				DisplayUtil.SpeedUp( mcSplash, 3 );
			}
		}
		
		/**
		 * Returns if we can preform the splash screen.
		 * @return
		 */
		private final function CanSplash():Boolean
		{
			return !bSplashed && Verlocity.settings.SHOW_SPLASH && !bSplashing;
		}

		/**
		 * Creates the transition effect and adds it to the display.
		 * @param	mcTransitionEffect The transition effect to set
		 */
		private final function CreateTranisition( mcTransitionEffect:MovieClip ):void
		{
			if ( !mcTransitionEffect ) { return; }

			mcTransition = mcTransitionEffect;

			// Fill the entire screen
			mcTransition.width = Verlocity.ScrW;
			mcTransition.height = Verlocity.ScrH;

			// Add to the screen
			if ( Verlocity.IsValid( Verlocity.layers ) )
			{
				// Add to layer manager
				Verlocity.layers.layerVerlocity.addChild( mcTransition );
			}
			else
			{
				// Add to stage
				stage.addChild( mcTransition );
			}

			// Play the effect
			mcTransition.gotoAndPlay( 1 );	
		}
		
		/**
		 * Removes the transition effect.
		 */
		private final function RemoveTransition():void
		{
			if ( !mcTransition ) { return; }
			
			// Remove from the parent display
			DisplayUtil.RemoveFromParent( mcTransition );
			
			// Stop and remove
			mcTransition.stop();
			mcTransition = null;
		}
		
		/**
		 * Updates transitions and their effects.
		 */
		private final function UpdateTransitions():void
		{
			if ( !mcTransition ) { return; }

			if ( DisplayUtil.HasEnded( mcTransition ) )
			{
				// Transition in ended
				if ( bTransIn )
				{
					TransitionIn( true );
				}
				else if ( bTransOut ) // Transition out ended
				{
					TransitionOut( true );
				}
			}
		}
		
		/**
		 * Handles transitioning in.
		 * @param	bIsFinished Is the transition finished?
		 */
		private final function TransitionIn( bIsFinished:Boolean ):void
		{
			// Start transition
			if ( !bIsFinished )
			{
				Verlocity.Trace( "Preforming state transition in...", "States" );
				bTransitioning = true;
				bTransIn = true;

				// Create effect
				CreateTranisition( Verlocity.settings.STATE_TRANSITION_IN );
			}
			else // Transition finished
			{
				bTransitioning = false;
				bTransIn = false;

				// Remove effect
				RemoveTransition();
				
				// Set next state
				SetNextState();
			}
		}
		
		/**
		 * Returns if we can preform a transition in.
		 * @return
		 */
		private final function CanTransitionIn():Boolean
		{
			return Verlocity.settings.STATE_TRANSITION_IN && !bTransitionsDisabled && !bTransitioning;
		}
		
		/**
		 * Handles transitioning out.
		 * @param	bIsFinished Is the transition finished?
		 */
		private final function TransitionOut( bIsFinished:Boolean ):void
		{
			// Start transition
			if ( !bIsFinished )
			{
				Verlocity.Trace( "Preforming state transition out...", "States" );
				bTransitioning = true;
				bTransOut = true;

				// Create effect
				CreateTranisition( Verlocity.settings.STATE_TRANSITION_OUT );
			}
			else // Transition finished
			{
				bTransitioning = false;
				bTransOut = false;

				// Remove effect
				RemoveTransition();
				
				// Remove the current state
				EndCurrentState();
			}
		}

		/**
		 * Returns if we can preform a transition out.
		 * @return
		 */
		private final function CanTransitionOut():Boolean
		{
			return Verlocity.settings.STATE_TRANSITION_OUT && !bTransitionsDisabled && !bTransitioning;
		}
		
		/**
		 * Sets the next state to the current state.
		 */
		private final function SetNextState():void
		{
			if ( !NextState ) { return; }

			// Set the next state
			CurrentState = NextState;
			CurrentState.Init();

			// Remove the reference
			NextState = null;
			
			Verlocity.Trace( "State set to " + CurrentState.ToString(), "States" );
		}
		
		/**
		 * Ends/removes the current state.
		 */
		private final function EndCurrentState():void
		{
			if ( !CurrentState ) { return; }
			
			// Store a reference
			var PreviousState:State = CurrentState;
			CurrentState = null;

			if ( !PreviousState._disabled )
			{
				// End the state
				PreviousState.DeInit();
				PreviousState.Destruct();
				PreviousState._disabled = true;

				SysUtil.GC();

				// Switch to next
				if ( NextState )
				{
					Verlocity.Trace( "Automatically switching to next state " + NextState.ToString(), "States" );
					Set( NextState );
				}
			}
			
			Verlocity.Trace( "Ended state " + PreviousState.ToString(), "States" );

			// Clear reference
			PreviousState = null;
		}

		/*===============================================*/
		
		/*------------------- PUBLIC --------------------*/
		/**
		 * Sets the state.  Removes current state, if available.
		 * @param	newState The new state to set to.
		 * @param	bTransition Preform a state transition (VerlocitySettings.STATE_TRANSITION_IN)
		 */
		public final function Set( newState:State, bTransition:Boolean = true ):void
		{
			// Show splash screen
			if ( CanSplash() )
			{
				Splash( false );
				NextState = newState;
				return;
			}
			
			// Resume, if paused
			if ( Verlocity.IsValid( Verlocity.pause ) )
			{
				Verlocity.pause.Resume();
			}

			// Restart the state if it's the same
			if ( CurrentState && newState.className == CurrentState.className )
			{
				Restart( true );
				return;
			}
			
			// End the current state, if there is one
			End( false, bTransition );

			Verlocity.Trace( "Setting state set to " + newState.ToString() + "...", "States" );
			
			// Temp store the next state
			NextState = newState;

			// Construct it
			NextState.Construct();
			
			// Handle transition in
			if ( bTransition && CanTransitionIn() )
			{
				TransitionIn( false );
				return;
			}

			// Set the state
			SetNextState();
		}

		/**
		 * Restarts the current state.
		 * @param	bHardRestart Set to call Destruct/Construct instead of DeInit/Init.  This will completely destroy and recreate the state.
		 */
		public final function Restart( bHardRestart:Boolean = false ):void
		{
			if ( !CurrentState ) { return; }

			// Resume, if paused
			if ( Verlocity.IsValid( Verlocity.pause ) )
			{
				Verlocity.pause.Resume();
			}

			// Hard restart
			if ( bHardRestart )
			{
				Verlocity.Trace( "Hard restarting state " + CurrentState.ToString() + "...", "States" );

				// Remove all data
				CurrentState.DeInit();
				CurrentState.Destruct();

				// Completely recreate the state.
				CurrentState.Construct();
				CurrentState.Init();
				
				Verlocity.Trace( "Hard restarted state " + CurrentState.ToString(), "States" );
				
				return;
			}

			Verlocity.Trace( "Soft restarting state " + CurrentState.ToString() + "...", "States" );

			// Soft restart
			CurrentState.DeInit();
			CurrentState.Init();

			// Init all ents
			if ( Verlocity.IsValid( Verlocity.ents ) )
			{
				Verlocity.ents.ResetAll();
			}

			Verlocity.Trace( "Soft restarted state " + CurrentState.ToString(), "States" );
		}

		/**
		 * Ends the current state.
		 * @param	bSetNextState Automatically set to the next state? (uses State.NextState)
		 * @param	bTransition Preform a state transition (VerlocitySettings.STATE_TRANSITION_OUT)
		 */
		public final function End( bSetNextState:Boolean = true, bTransition:Boolean = true ):void
		{
			if ( !CurrentState ) { return; }

			Verlocity.Trace( "Ending state " + CurrentState.ToString() + "...", "States" );
			
			// Store next
			if ( bSetNextState && CurrentState.NextState )
			{
				NextState = new CurrentState.NextState();
			}

			// Handle transition out
			if ( bTransition && CanTransitionOut() )
			{
				TransitionOut( false );
				return;
			}
			
			// End the current state
			EndCurrentState();
		}
		
		/**
		 * Completely destroys the current state.
		 */
		public final function _DestroyCurrentState():void
		{
			if ( CurrentState )
			{
				CurrentState.DeInit();
				CurrentState.Destruct();
			}

			CurrentState = null;
		}

		/**
		 * Returns the string name of the state.
		 * @return
		 */
		public final function GetName():String
		{
			if ( bSplashing ) { return "Verlocity Splash"; }
			if ( CurrentState ) { return CurrentState.ToString() }

			return "No State";
		}

		/**
		 * Sets if transitions should be enabled.
		 * @param	bEnabled
		 */
		public final function EnableTransitions( bEnabled:Boolean = true ):void
		{
			bTransitionsDisabled = !bEnabled;
		}
		
		/**
		 * Returns if the is a state transition going on.
		 * @return
		 */
		public final function IsTransitioning():Boolean
		{
			return bTransitioning;
		}
		
		/**
		 * Returns if we're preforming the splash screen.
		 * @return
		 */
		public final function IsSplashing():Boolean
		{
			return bSplashing;
		}
	}
}