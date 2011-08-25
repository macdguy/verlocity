/*
	=========================================
			   Verlocity Engine
	=========================================
	|	Developed by Macklin Guy, 2011.		|
	|										|
	|										|
	-----------------------------------------
	Verlocity.as
	-----------------------------------------
	This is the core class that sets up the engine
	and its components.
*/

package VerlocityEngine
{
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.display.StageQuality;
	import flash.display.StageDisplayState;

	import flash.events.Event;

	import VerlocityEngine.components.*;

	public final class Verlocity extends Object
	{
		/************************************************/
		/************************************************/
		public static function IsValid():Boolean { return wasCreated; }
		private static var wasCreated:Boolean;
		
		public function Verlocity( sTheStage:Stage ):void
		{
			if ( wasCreated ) { throw new Error( VerlocityLanguage.T( "VerlocityLoadFail" ) ); return; } wasCreated = true;

			sStage = sTheStage;
			Construct();
		}
		/************************************************/
		/************************************************/

		/*
		 **********************VARS***********************
		*/
		private static var sStage:Stage;
		
		
		/*
		 ********************CREATION*********************
		*/
		private function Construct():void
		{
			VerlocitySettings.ApplyFlashSettings( sStage );
			VerlocityHotkeys.Setup( sStage );
			
			if ( VerlocitySettings.SHOW_MESSAGES )
			{
				var verMessages:VerlocityMessages = new VerlocityMessages();
			}
			
			if ( VerlocitySettings.DEBUG )
			{
				Trace( "Verlocity", "Debug mode enabled." );
				VerlocityComponents.Register( "verConsole", verConsole );
			}

			RegisterComponents();
		}

		private function RegisterComponents():void
		{
			// Core components
			VerlocityComponents.Register( "verEngine", verEngine );
			VerlocityComponents.Register( "verCamera", verCamera ); // requires verEngine
			VerlocityComponents.Register( "verLayers", verLayers ); // requires verCamera
			VerlocityComponents.Register( "verEnts", verEnts ); // requires verEngine
			VerlocityComponents.Register( "verStates", verStates ); // requires verEngine, verLayers
			VerlocityComponents.Register( "verInput", verInput );
			VerlocityComponents.Register( "verSound", verSound ); // requires verEngine

			// Additional components
			VerlocityComponents.Register( "verSave", verSave );
			VerlocityComponents.Register( "verVariables", verVariables ); // requires verSave
			VerlocityComponents.Register( "verStats", verStats );
			VerlocityComponents.Register( "verUI", verUI );
			VerlocityComponents.Register( "verPause", verPause );
			VerlocityComponents.Register( "verSoundAnalyzer", verSoundAnalyzer ); // requires verEngine
			VerlocityComponents.Register( "verAchievements", verAchievements ); // requires verEngine, verLayers
			VerlocityComponents.Register( "verScrFX", verScreenFX ); // requires verEngine, verLayers
			VerlocityComponents.Register( "verSoundscape", verSoundscape );
			VerlocityComponents.Register( "ver3D", ver3D ); // requires verEngine, verLayers
		}		
		
		/*
		 *************EASY ACCESS GETTERS***************
		 * NOTE: Developers, please create your own getter with your components.
		 * This makes it easier to access.
		*/
		public static function get stage():Stage { return sStage; }
		public static function get ScrW():int { return sStage.stageWidth; }
		public static function get ScrH():int { return sStage.stageHeight; }

		// Debug components
		public static function get console():verConsole { return VerlocityComponents.Get( "verConsole" ); }

		// Core components
		public static function get engine():verEngine { return VerlocityComponents.Get( "verEngine" ); }
		public static function get camera():verCamera { return VerlocityComponents.Get( "verCamera" ); }
		public static function get layers():verLayers { return VerlocityComponents.Get( "verLayers" ); }
		public static function get ents():verEnts { return VerlocityComponents.Get( "verEnts" ); }
		public static function get state():verStates { return VerlocityComponents.Get( "verStates" ); }
		public static function get input():verInput { return VerlocityComponents.Get( "verInput" ); }
		public static function get sound():verSound { return VerlocityComponents.Get( "verSound" ); }

		// Additional components
		public static function get save():verSave { return VerlocityComponents.Get( "verSave" ); }
		public static function get vars():verVariables { return VerlocityComponents.Get( "verVariables" ); }
		public static function get stats():verStats { return VerlocityComponents.Get( "verStats" ); }
		public static function get ui():verUI { return VerlocityComponents.Get( "verUI" ); }
		public static function get pause():verPause { return VerlocityComponents.Get( "verPause" ); }
		public static function get analyzer():verSoundAnalyzer { return VerlocityComponents.Get( "verSoundAnalyzer" ); }
		public static function get achievements():verAchievements { return VerlocityComponents.Get( "verAchievements" ); }
		public static function get scrFX():verScreenFX { return VerlocityComponents.Get( "verScrFX" ); }
		public static function get soundscape():verSoundscape { return VerlocityComponents.Get( "verSoundscape" ); }

		// Togglable components
		public static function get a3D():ver3D { return VerlocityComponents.Get( "ver3D" ); }

		
		/*
		 ******************FUNCTIONS********************
		*/
		
		/*------------------ PRIVATE ------------------*/
		/*------------------ PUBLIC -------------------*/	
		public static function Trace( sCaller:String, sTrace:String ):void
		{
			if ( !VerlocitySettings.DEBUG ) { return; }

			if ( console )
			{
				console.Output( sTrace, sCaller );
			}
			else
			{
				trace( "[" + sCaller + "] " + sTrace );
			}
		}

		public static function SetQuality( iQuality:int = 3 ):void
		{
			switch( iQuality )
			{
				case 1:
					sStage.quality = StageQuality.LOW;
					VerlocityMessages.Create( VerlocityLanguage.T( "VerlocityQuality" ) + VerlocityLanguage.T( "VerlocityQualityL" ) );
				break;
				case 2:
					sStage.quality = StageQuality.MEDIUM;
					VerlocityMessages.Create( VerlocityLanguage.T( "VerlocityQuality" ) + VerlocityLanguage.T( "VerlocityQualityM" ) );
				break;
				case 3:
					sStage.quality = StageQuality.HIGH;
					VerlocityMessages.Create( VerlocityLanguage.T( "VerlocityQuality" ) + VerlocityLanguage.T( "VerlocityQualityH" ) );
				break;
			}
		}

		public static function SetFullscreen( bEnable:Boolean ):void
		{
			if ( bEnable )
			{
				sStage.displayState = StageDisplayState.FULL_SCREEN;
				VerlocityMessages.Create( VerlocityLanguage.T( "VerlocityFullscreenOn" ) );
			}
			else
			{
				sStage.displayState = StageDisplayState.NORMAL;
				VerlocityMessages.Create( VerlocityLanguage.T( "VerlocityFullscreenOff" ) );
			}
		}
		public static function get IsFullscreen():Boolean { return sStage.displayState == StageDisplayState.FULL_SCREEN; }
		
		public static function CleanSlate():void
		{
			sound.StopAll();
			ents.RemoveAll();
			camera.ResetPos();
			layers.RemoveAll();
			ui.RemoveAll();
		}

	}
}