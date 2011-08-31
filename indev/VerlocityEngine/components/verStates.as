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

		// Splash
		private var mcSplash:MovieClip;
		private var bSplashed:Boolean;
		private var FirstState:Array;


		/*
		 *************COMPONENT CONCOMMANDS**************
		*/
		private function Concommands():void
		{
			if ( !Verlocity.console ) { return; }

			Verlocity.console.Register( "endstate", function()
			{
				End();
			}, "Ends the current state.  If NextState is available, it will go to that state." );

			Verlocity.console.Register( "restart", function()
			{
				Restart();
			}, "Restarts the current state." );
		}


		/*
		 ****************COMPONENT LOOP******************
		*/
		public function Think():void
		{
			if ( mcSplash )
			{
				if ( ( mcSplash.currentFrame + 1 ) >= mcSplash.totalFrames )
				{
					EndSplash();
				}

				return;
			}

			if ( CurrentState )
			{
				if ( CurrentState.bIsCutscene && ( CurrentState.currentFrame + 1 ) >= CurrentState.totalFrames )
				{
					RemoveCurrentState();
					return;
				}

				if ( CurrentState.ShouldEnd() )
				{
					RemoveCurrentState();
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

			Verlocity.Trace( "States", "====Ended current state, " + prevState + "=====" );

			setTimeout( VerlocityUtil.GC, 50 ); // HACK: Force the garbage collection after.
		}
		
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
			FirstState = new Array();
			FirstState[0] = state; FirstState[1] = bAdd; FirstState[2] = layer;
			state = null;
			
			// Disable pausing
			Verlocity.pause.Disable();
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
			Set( FirstState[0], FirstState[1], FirstState[2] );
			FirstState[0].play(); FirstState.length = 0; FirstState = null;
			
			// Enable pausing.
			Verlocity.pause.Enable();
		}

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
			Verlocity.pause.Resume();

			if ( CurrentState )
			{
				RemoveCurrentState( false );
			}
			
			// TODO: Implement transition class.

			newState.SetupState();

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

			newState.BeginState();

			CurrentState = newState;

			Verlocity.Trace( "States", "====Set state to " + newState + "====" );
		}
		
		public function Restart():void
		{
			if ( !CurrentState ) { return; }
			
			Verlocity.pause.Resume();

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
			Verlocity.pause.Resume();

			if ( CurrentState )
			{
				RemoveCurrentState( true );
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
		
	}

}