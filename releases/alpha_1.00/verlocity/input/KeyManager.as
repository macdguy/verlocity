/*
 * ---------------------------------------------------------------
 * Verlocity
 * http://www.verlocityengine.com
 * 
 * This file is subject to the terms and conditions defined in
 * 'license.txt', which is part of this source code package.
 * ---------------------------------------------------------------
 * Description:
 * 		This class handles all the language used within the engine/game.
 *		Designed to be easily expanded on later with localization.
 * ---------------------------------------------------------------
*/	
package verlocity.input 
{
	import verlocity.core.Singleton;
	import verlocity.Verlocity;

	public final class KeyManager extends Singleton
	{
		// Holds the current key data.
		private var curKeys:KeyData;
		private var bDisableHotkeys:Boolean;
		
		public function KeyManager( defaultKeys:KeyData ):void
		{
			// Make sure this is a singleton
			super();
			
			// Set default language
			curKeys = defaultKeys;
		}

		/**
		 * Returns a uint or Array of uint key based on string found in key data.
		 * @param	sHotKey The key data string reference.
		 * @return
		 */
		public function Get( sKey:String ):uint
		{
			if ( !curKeys || !curKeys[sKey] ) { return 0; }

			return curKeys[sKey];
		}
		
		/**
		 * Sets a key data string reference with given uint key code
		 * @param	sKey The key data string reference name.
		 * @param	keyCode The key code
		 */
		public function Set( sKey:String, keyCode:uint ):void
		{
			if ( !curKeys || !curKeys[sKey] ) { return; }

			curKeys[sKey] = keyCode;
		}
		
		/**
		 * Finds and returns the first keyCode in an array of keys, if possible
		 * @param	sKey The key data string reference name.
		 * @param	keyCode The keyCode to search for.
		 * @return
		 */
		/*public function _FindKey( sKey:String, keyCode:uint ):uint
		{
			if ( !curKeys || !curKeys[sKey] ) { return 0; }

			if ( curKeys[sKey] is Array ) 
			{
				var KeyArray:Array = curKeys[sKey];

				for ( var i:int; i < KeyArray.length; i++ )
				{
					// Find the first pressed key
					if ( keyCode == KeyArray[i] )
					{
						return keyCode;
					}
				}
			}
			else if ( curKeys[sKey] is uint )
			{
				return curKeys[sKey];
			}

			return 0;
		}*/
		
		/**
		 * Enables/disables hot keys.
		 * @param	bEnabled
		 */
		public function EnableHotkeys( bEnabled:Boolean = true ):void
		{
			bDisableHotkeys = !bEnabled;
		}

		/**
		 * Handles hot keys.
		 * @param	key
		 */
		public function _HandleHotKeys( key:uint ):void
		{
			if ( bDisableHotkeys || Verlocity.IsQuitting() ) { return; }

			// Disable when console is focused
			if ( Verlocity.IsValid( Verlocity.console ) )
			{
				if ( Verlocity.console.IsFocused() )
				{
					return;
				}
			}

			// Fullscreen toggle
			if ( Verlocity.IsValid( Verlocity.display ) )
			{
				if ( Get( "VerlocityFullscreen" ) == key )
				{
					Verlocity.display.ToggleFullscreen();
				}
			}
			
			// Sound toggles
			if ( Verlocity.IsValid( Verlocity.sound ) )
			{
				if ( Get( "VerlocityVolumeDown" ) == key )
				{
					Verlocity.sound.VolumeDown();
				}

				if ( Get( "VerlocityVolumeUp" ) == key )
				{
					Verlocity.sound.VolumeUp();
				}

				if ( Get( "VerlocityVolumeMute" ) == key )
				{
					Verlocity.sound.ToggleMute();
				}
			}
			
			// UI keys
			if ( Verlocity.IsValid( Verlocity.ui ) )
			{
				if ( Get( "VerlocityNextUI" ) == key )
				{
					Verlocity.ui.HighlightNextButton();
				}

				if ( Get( "VerlocityPreviousUI" ) == key )
				{
					Verlocity.ui.HighlightPreviousButton();
				}

				if ( Get( "VerlocityEnterUI" ) == key )
				{
					Verlocity.ui.EnterHighlightedButton();
				}			
			}
		}
		
		/**
		 * Removes the current key data.
		 */
		public override function _Destruct():void 
		{
			super._Destruct();
			curKeys = null;
		}
	}
}