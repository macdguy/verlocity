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
	verStates.as
	-----------------------------------------
	This class manages the current state.
	States are specific classes that handle
	each level or UI gameplay state.

	Usable functions:
		Set, Get
*/

package VerlocityEngine.components
{
	import flash.display.MovieClip;
	import VerlocityEngine.Verlocity;
	import VerlocityEngine.VerlocityUtil;
	import VerlocityEngine.VerlocityLanguage;
	import VerlocityEngine.VerlocitySettings;
	import VerlocityEngine.VerlocityMessages;

	import VerlocityEngine.base.verBState;
	import VerlocityEngine.base.verBLayer;
	
	import flash.display.Sprite;
	import flash.utils.setTimeout;
	
	import flash.media.SoundMixer;
	import VerlocityEngine.util.mathHelper;

	public final class verStates extends Object
	{
		//********* VERLOCITY COMPONENT HEADER *********//
		/************************************************/
		public function IsValid():Boolean { return wasCreated; }
		private var wasCreated:Boolean;
		
		public function verStates():void
		{
			if ( wasCreated ) { throw new Error( VerlocityLanguage.T( "ComponentLoadFail" ) ); return; } wasCreated = true;
			Concommands();
		}
		/************************************************/
		/************************************************/

		/*
		 *****************EMBEDED ASSETS******************
		*/
		[Embed(source = "../VerlocityContent.swf", symbol = "Splash")] private var VerlocitySplash:Class;


		/*
		 ****************COMPONENT VARS******************
		*/
		private var CurrentState:verBState;
		private var NextState:Array;

		// Splash
		private var mcSplash:MovieClip;
		private var bSplashed:Boolean;
		
		// Transitions
		private var bDisableTransitions:Boolean;
		private var bTransIn:Boolean;
		private var bTransOut:Boolean;
		private var bMouseEnabled:Boolean;
		private var bKeyEnabled:Boolean;

		private var mcTrans:MovieClip;


		/*
		 *************COMPONENT CONCOMMANDS**************
		*/
		private function Concommands():void
		{
			if ( !Verlocity.console ) { return; }

			Verlocity.console.Register( "endstate", function():void
			{
				End();
			}, "Ends the current state.  If NextState is available, it will go to that state." );

			Verlocity.console.Register( "restart", function():void
			{
				Restart();
			}, "Restarts the current state." );
		}


		/*
		 ****************COMPONENT LOOP******************
		*/
		public function Think():void
		{
			// Splash screen
			if ( mcSplash )
			{
				if ( ( mcSplash.currentFrame + 1 ) >= mcSplash.totalFrames )
				{
					EndSplash();
				}

				return;
			}


			// Transitions
			if ( !bDisableTransitions )
			{
				if ( bTransIn )
				{
					if ( mcTrans && ( mcTrans.currentFrame + 1 ) >= mcTrans.totalFrames )
					{
						EndTransIn();
					}
				}

				if ( bTransOut )
				{
					if ( mcTrans && ( mcTrans.currentFrame + 1 ) >= mcTrans.totalFrames )
					{
						EndTransOut();
					}
				}
			}


			// Current state think
			if ( CurrentState && !IsTransitioning )
			{
				if ( CurrentState.bIsCutscene && ( CurrentState.currentFrame + 1 ) >= CurrentState.totalFrames )
				{
					StartTransOut();
					return;
				}

				if ( CurrentState.ShouldEnd() )
				{
					StartTransOut();
					return;
				}

				CurrentState.Think();
			}		
		}
		
		
		/*
		 *************COMPONENT FUNCTIONS***************
		*/
		
		/*------------------ PRIVATE ------------------*/
		private function RemoveCurrentState( bSetNext:Boolean = true ):void
		{
			if ( !CurrentState ) { return; }

			var prevState:verBState = CurrentState;
			CurrentState = null;

			if ( prevState.enabled )
			{
				prevState.EndState();
				prevState.enabled = false;
				prevState.stop();
				
				if ( bSetNext && prevState.cNextState )
				{
					Set( new prevState.cNextState() );
				}
			}

			if ( prevState.parent )
			{
				prevState.parent.removeChild( prevState );
			}

			Verlocity.Trace( "States", "=====Ended current state, " + prevState + "=====" );

			setTimeout( VerlocityUtil.GC, 50 ); // HACK: Force the garbage collection after.
		}
		

		// ==== SPLASH ====
		private function DoSplash( state:verBState, bAdd:Boolean, layer:verBLayer ):void
		{
			Verlocity.Trace( "States", "Playing Verlocity splash.  Thanks for your support!" );

			bSplashed = true; // we've played the splash, don't do it again.

			// Add the splash animation to screen.
			mcSplash = new VerlocitySplash();
				mcSplash.x = Verlocity.ScrW / 2;
				mcSplash.y = Verlocity.ScrH / 2;

				mcSplash.scaleX = Verlocity.ScrH / 400;
				mcSplash.scaleY = Verlocity.ScrH / 400;
			Verlocity.layers.layerVerlocity.addChild( mcSplash );

			// Hold the first state for a bit.
			NextState = new Array( state, bAdd, layer );
			state = null;
		}
		
		internal function SkipSplash():void
		{
			if ( mcSplash )
			{
				mcSplash.gotoAndPlay( mathHelper.Clamp( mcSplash.currentFrame + 4, 1, mcSplash.totalFrames - 1 ) );
			}
		}
		
		internal function EndSplash():void
		{
			// Stop the sound
			SoundMixer.stopAll();

			// Remove the splash.
			Verlocity.layers.layerVerlocity.removeChild( mcSplash );
			mcSplash.stop(); mcSplash = null;
			
			// Garbage collect.
			VerlocityUtil.GC();

			// Set the first state now.
			if ( NextState )
			{
				Set( NextState[0], NextState[1], NextState[2] );
				NextState = null;
			}
		}
		// ==== END SPLASH ====
		
		

		// ==== TRANSITIONS ====
		private function AddTransEffect():void
		{
			mcTrans.x = 0; mcTrans.y = 0;

			mcTrans.width = Verlocity.ScrW;
			mcTrans.height = Verlocity.ScrH;
			
			mcTrans.gotoAndPlay( 1 );
			Verlocity.layers.layerVerlocity.addChild( mcTrans );
			
			//Disable		
			if ( Verlocity.input ) 
			{	
				bMouseEnabled = Verlocity.input.HasMouseControl;
				bKeyEnabled = Verlocity.input.HasKeyControl;

				Verlocity.input.KeyDisable();
				Verlocity.input.MouseDisable();	
			}			
		}
		
		private function RemoveTransEffect():void
		{
			Verlocity.layers.layerVerlocity.removeChild( mcTrans );
			mcTrans.stop();
			mcTrans = null;
			
			//Re enable input when the state is finished transitioning.
			if ( Verlocity.input ) 
			{
				if ( bMouseEnabled ) { Verlocity.input.MouseEnable(); }
				if ( bKeyEnabled ) { Verlocity.input.KeyEnable(); }	
			}
		}
		
		private function StartTransIn():void
		{
			if ( !VerlocitySettings.STATE_TRANSITION_IN || bDisableTransitions ) { EndTransIn(); return; }

			bTransIn = true;
			
			mcTrans = new VerlocitySettings.STATE_TRANSITION_IN();
			AddTransEffect();
		}
		
		private function EndTransIn():void
		{
			bTransIn = false;
			
			CurrentState.BeginState();
			CurrentState.play();
			
			if ( mcTrans )
			{
				RemoveTransEffect();
			}
		}
		
		private function StartTransOut():void
		{
			if ( !VerlocitySettings.STATE_TRANSITION_OUT || bDisableTransitions ) { EndTransOut(); return; }

			bTransOut = true;
			
			mcTrans = new VerlocitySettings.STATE_TRANSITION_OUT();
			AddTransEffect();
		}
		
		private function EndTransOut():void
		{
			bTransOut = false;

			if ( mcTrans ) 
			{
				RemoveTransEffect();
			}

			if ( NextState )
			{
				RemoveCurrentState( false );

				Set( NextState[0], NextState[1], NextState[2] );
				NextState = null;
			}
			else
			{
				RemoveCurrentState();
			}
		}
		// ==== END TRANSITIONS ====


		/*------------------ PUBLIC -------------------*/
		public function Set( newState:verBState, bAdd:Boolean = false, layer:verBLayer = null ):void
		{
			// Make sure we have keyboard controls.
			Verlocity.input.ForceFocus();

			// Handle splash
			if ( VerlocitySettings.SHOW_SPLASH )
			{
				if ( mcSplash ) { return; }
				if ( !bSplashed ) { DoSplash( newState, bAdd, layer ); return; }
			}

			if ( CurrentState && newState.GetClass() == CurrentState.GetClass() )
			{
				Restart();
				Verlocity.Trace( "States", "Tried to set state to the same state, restarting instead." );
				return;
			}

			// Resume the engine if it was paused when we end the state.
			// This solves a lot of issues and ultimately is required.
			// You should not have an issue with this fix due to the fact that only the game can set states, not the user.
			if ( Verlocity.pause ) { Verlocity.pause.Resume(); }
			
			if ( CurrentState )
			{
				NextState = new Array( newState, bAdd, layer );
				StartTransOut();

				return;
			}

			newState.SetupState();
			newState.stop();

			if ( bAdd || newState.bAddToStage )
			{
				if ( layer )
				{
					layer.addChildAt( newState, 0 );
				}
				else if ( newState.sLayer )
				{
					Verlocity.layers.Insert( newState, newState.sLayer );
				}				
				else
				{
					Verlocity.layers.layerState.addChildAt( newState, 0 );
				}
			}
			
			CurrentState = newState;
			StartTransIn();

			Verlocity.Trace( "States", "====Set state to " + newState + "====" );
		}
		
		public function Restart():void
		{
			if ( !CurrentState ) { return; }
			
			if ( Verlocity.pause ) { Verlocity.pause.Resume(); }

			CurrentState.EndState();

			CurrentState.SetupState();
			CurrentState.BeginState();

			Verlocity.Trace( "States", "Restarting state... " + CurrentState );
		}
		
		public function End():void
		{
			// Resume the engine if it was paused when we end the state.
			// This solves a lot of issues and ultimately is required.
			// You should not have an issue with this fix due to the fact that only the game can set states, not the user.
			if ( Verlocity.pause ) { Verlocity.pause.Resume(); }

			if ( CurrentState )
			{
				StartTransOut();
			}
		}

		public function Get():verBState
		{
			return CurrentState;
		}
		
		public function GetName():String
		{
			if ( mcSplash ) { return "VerSplash"; }
			if ( CurrentState ) { return CurrentState.toString() }

			return "No State";
		}
		
		public function EnableTransitions():void
		{
			bDisableTransitions = false;
		}
		
		public function DisableTransitions():void
		{
			bDisableTransitions = true;
		}
		
		public function get IsTransitioning():Boolean
		{
			return bTransIn || bTransOut || mcSplash;
		}
		
	}

}