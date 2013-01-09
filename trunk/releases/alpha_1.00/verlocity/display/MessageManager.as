/*
 * ---------------------------------------------------------------
 * Verlocity
 * http://www.verlocityengine.com
 * 
 * This file is subject to the terms and conditions defined in
 * 'license.txt', which is part of this source code package.
 * ---------------------------------------------------------------
 * Description:
 * 		This class handles displaying of useful
 * 		information to the user.
 * 		Stuff like volume changed, saved game, etc.
 * 
 * 		If you wish to turn these off completely,
 * 		change VerlocitySettings "SHOW_MESSAGES" to
 * 		false.
 * ---------------------------------------------------------------
*/
package verlocity.display 
{
	import flash.events.Event;
	import flash.ui.Keyboard;
	import flash.events.KeyboardEvent;
	import verlocity.display.gui.Message;

	import flash.text.TextFormat;
	import flash.display.Stage;

	import verlocity.Verlocity;
	import verlocity.core.Singleton;

	import verlocity.display.ui.Text;
	import verlocity.utils.MathUtil;
	
	import flash.utils.getTimer;

	public final class MessageManager extends Singleton
	{
		private var stage:Stage;
		private var vMessages:Vector.<Array>;

		public function MessageManager( sStage:Stage ):void
		{
			super();
			
			stage = sStage;

			stage.addEventListener( Event.ENTER_FRAME, Update );
			vMessages = new Vector.<Array>();
		}
		
		/**
		 * Removes all message data.
		 */
		public override function _Destruct():void
		{
			super._Destruct();

			stage.removeEventListener( Event.ENTER_FRAME, Update );
			
			// Remove all messages
			var iLength:int = vMessages.length;
			if ( iLength > 0 )
			{
				var i:int = iLength - 1;
				var message:Array;

				while( i >= 0 )
				{
					message = vMessages[i];
					
					stage.removeChild( message[0] );
					
					message = null;
					i--;
				}
			}
			
			vMessages.length = 0;
			vMessages = null;

			stage = null;
		}

		/**
		 * Updates the HUD messages
		 * @param	e
		 */
		private function Update( e:Event ):void
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
					// Fade out
					if ( message[0].alpha > 0 )
					{
						message[0].alpha -= 0.025;
					}
					else // Remove
					{
						message[0].Dispose();
						stage.removeChild( message[0] );

						delete vMessages[i];
						vMessages[i] = null;
						vMessages.splice( i, 1 );
					}
				}
				
				// Ease to the correct spot
				if ( message )
				{
					var iYOffset:int = ( i * message[0].height ) + ( 20 * Verlocity.settings.GUI_SCALE );
					if ( iYOffset != message[0].y )
					{
						message[0].y -= MathUtil.Ease( message[0].y, iYOffset, 5 );
					}
				}

				message = null;
				i--;
			}
		}

		/**
		 * Creates a HUD message.
		 * @param	sMessage The message text
		 * @param	iTimeToDisplay The time to display the message
		 */
		public function Create( sMessage:String, iTimeToDisplay:int = 1500 ):void
		{
			if ( !Verlocity.settings.SHOW_MESSAGES || !sMessage || sMessage == "" ) { return; }

			var newMessage:Message = new Message( sMessage );
				newMessage.SetPos( Verlocity.ScrW - ( newMessage.GetWidth() * Verlocity.settings.GUI_SCALE ) - 10, ( vMessages.length * newMessage.height ) + ( 20 * Verlocity.settings.GUI_SCALE ) );
			stage.addChild( newMessage );

			vMessages.push( new Array( newMessage, getTimer() + iTimeToDisplay ) );
		}
	}
}