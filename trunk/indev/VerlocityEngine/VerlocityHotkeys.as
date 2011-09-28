/*
	=========================================
			   Verlocity Engine
	=========================================
	|	Developed by Macklin Guy, 2011.		|
	|										|
	|										|
	-----------------------------------------
	VerlocityHotkeys.as
	-----------------------------------------
	This holds all the hot keys relating to
	both Verlocity and your project.
*/
package VerlocityEngine 
{
	import flash.ui.Keyboard;
	import flash.events.KeyboardEvent;

	import flash.display.Stage;
	import VerlocityEngine.Verlocity;
	import VerlocityEngine.VerlocityLanguage;

	public final class VerlocityHotkeys
	{
		private static var objKeys:Object = new Object();

		/*
		 *************CUSTOMIZATION***************
		*/
		objKeys["VerlocityVolumeDown"] = 189; // _-
		objKeys["VerlocityVolumeUp"] = 187; // =+
		objKeys["VerlocityVolumeMute"] = 77; //Keyboard.M
		objKeys["VerlocityPause"] = 80; //Keyboard.P
		objKeys["VerlocityFullscreen"] = 70; //Keyboard.F

		objKeys["VerlocityNextUI"] = Keyboard.DOWN;
		objKeys["VerlocityPreviousUI"] = Keyboard.UP;
		objKeys["VerlocityEnterUI"] = Keyboard.ENTER;

		objKeys["Left"] = Keyboard.LEFT;
		objKeys["Right"] = Keyboard.RIGHT;
		objKeys["Up"] = Keyboard.UP;
		objKeys["Down"] = Keyboard.DOWN;

		objKeys["Shoot"] = Keyboard.SPACE;
		objKeys["Bomb"] = Keyboard.SHIFT;

		objKeys["Jump"] = Keyboard.A;
		objKeys["Attack"] = Keyboard.S;
		



		/*
		 *************CREATION***************
		*/
		internal static function Setup( sStage:Stage ):void
		{
			sStage.addEventListener( KeyboardEvent.KEY_DOWN, HandleKeys );
		}		
		
		/*
		 *************FUNCTIONS***************
		*/
		/*------------------ PRIVATE -------------------*/
		private static function HandleKeys( ke:KeyboardEvent ):void
		{
			if ( Verlocity.console && Verlocity.console.IsEnabled ) { return; }

			if ( Get( "VerlocityFullscreen" ) == ke.keyCode )
			{
				Verlocity.SetFullscreen( !Verlocity.IsFullscreen );
			}
			
			if ( Verlocity.sound )
			{
				if ( Get( "VerlocityVolumeDown" ) == ke.keyCode )
				{
					Verlocity.sound.VolumeDown();
				}

				if ( Get( "VerlocityVolumeUp" ) == ke.keyCode )
				{
					Verlocity.sound.VolumeUp();
				}

				if ( Get( "VerlocityVolumeMute" ) == ke.keyCode )
				{
					if ( Verlocity.sound.IsMuted )
					{
						Verlocity.sound.UnMute();
					}
					else
					{
						Verlocity.sound.Mute();
					}
				}
			}
			
			if ( Verlocity.ui )
			{
				if ( Get( "VerlocityNextUI" ) == ke.keyCode )
				{
					Verlocity.ui.NextUIButton();
				}

				if ( Get( "VerlocityPreviousUI" ) == ke.keyCode )
				{
					Verlocity.ui.PreviousUIButton();
				}

				if ( Get( "VerlocityEnterUI" ) == ke.keyCode )
				{
					Verlocity.ui.EnterUIButton();
				}			
			}
		}
		
		
		/*------------------ PUBLIC -------------------*/
		public static function Get( sName:String ):uint
		{
			return objKeys[sName];
		}
	}
}