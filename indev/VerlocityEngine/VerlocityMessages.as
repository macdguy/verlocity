/*
	=========================================
			   Verlocity Engine
	=========================================
	|	Developed by Macklin Guy, 2011.		|
	|										|
	|										|
	-----------------------------------------
	VerlocityMessages.as
	-----------------------------------------
	This class handles displaying of useful
	information to the user.
	Stuff like volume changed, saved game, etc.

	If you wish to turn these off completely,
	change VerlocitySettings "SHOW_MESSAGES" to
	false.
*/
package VerlocityEngine 
{
	import flash.events.Event;
	import flash.ui.Keyboard;
	import flash.events.KeyboardEvent;

	import flash.text.TextFormat;
	import flash.display.Stage;

	import VerlocityEngine.Verlocity;
	import VerlocityEngine.VerlocityLanguage;

	import VerlocityEngine.base.ui.verBUIText;
	import VerlocityEngine.util.mathHelper;
	
	import flash.utils.getTimer;

	public final class VerlocityMessages
	{
		/*
		 *************VARIABLES***************
		*/
		private static var vMessages:Vector.<Array>;

		private static const messageFormat = new TextFormat( "_sans", 24, 0xFFFFFF );
		

		/*
		 *************CREATION***************
		*/
		private var wasCreated:Boolean;
		public function VerlocityMessages():void
		{
			if ( wasCreated ) { throw new Error( "VerlocityMessages can only be created once." ); return; } wasCreated = true;
			
			Verlocity.stage.addEventListener( Event.ENTER_FRAME, Think );
			vMessages = new Vector.<Array>();
		}


		/*
		 *************LOOP***************
		*/		
		public function Think( e:Event ):void
		{
			var iLength:int = vMessages.length;
			if ( iLength <= 0 ) { return; } 

			var i:int = iLength - 1;
			var message:Array;

			while( i >= 0 )
			{
				message = vMessages[i];

				if ( message[1] < getTimer() )
				{
					if ( message[0].alpha > 0 )
					{
						message[0].alpha -= 0.025;
					}
					else
					{
						message[0].Dispose();
						Verlocity.stage.removeChild( message[0] );

						delete vMessages[i];
						vMessages[i] = null;
						vMessages.splice( i, 1 );
					}
				}
				
				if ( message )
				{
					var iYOffset:int = ( i * 25 ) + 10;
					if ( iYOffset != message[0].y )
					{
						message[0].y -= mathHelper.Ease( message[0].y, iYOffset, 5 );
					}
				}

				message = null;
				i--;
			}
		}
		
		/*
		 *************FUNCTIONS***************
		*/
		/*------------------ PRIVATE -------------------*/
		/*------------------ PUBLIC -------------------*/
		public static function Create( sMessage:String, iTimeToDisplay:int = 1500 ):void
		{
			if ( !VerlocitySettings.SHOW_MESSAGES || !sMessage || sMessage == "" ) { return; }

			var iYOffset:int = ( vMessages.length * 25 ) + 10;
			
			var newMessage:verBUIText = new verBUIText();
				newMessage.SetText( sMessage, messageFormat );
				newMessage.SetPos( Verlocity.ScrW - newMessage.GetWidth() - 10, iYOffset );
				newMessage.DrawRect( 0x00000, 1, newMessage.GetWidth() + 5, 30, false, 0, 0, 0, true, 10, -2, 0 );
			Verlocity.stage.addChild( newMessage );

			vMessages.push( new Array( newMessage, getTimer() + iTimeToDisplay ) );
		}

	}
}