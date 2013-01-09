/*
 * ---------------------------------------------------------------
 * Verlocity
 * http://www.verlocityengine.com
 * 
 * This file is subject to the terms and conditions defined in
 * 'license.txt', which is part of this source code package.
 * ---------------------------------------------------------------
*/
package verlocity.core 
{
	import verlocity.logic.State;
	import verlocity.Verlocity;

	public final class Game extends Object
	{
		private var main:Object;
		private var mainClass:Class;
		private var sFirstState:State;

		private var sGameName:String;
		private var sGameAuthor:String;
		private var sGameDescription:String;

		/**
		 * Starts the game.
		 */
		public function Game( initClass:Class, firstState:State, sSetGameName:String = null, sSetGameAuthor:String = null, sSetGameDescription:String = null ):void
		{
			// Store the main class
			mainClass = initClass;

			// Store the first state
			sFirstState = firstState;

			// Set game details
			sGameName = sSetGameName;
			sGameAuthor = sSetGameAuthor;
			sGameDescription = sSetGameDescription;
		}
		
		/**
		 * Called when the game is constructed.
		 */
		public function _Construct():void
		{
			main = new mainClass();

			// Set the first state
			if ( Verlocity.IsValid( Verlocity.state ) )
			{
				Verlocity.state.Set( sFirstState );
			}
		}

		/**
		 * Called when the game is removed.
		 */
		public function _Destruct():void
		{
			// End the current state
			if ( Verlocity.IsValid( Verlocity.state ) )
			{
				Verlocity.state._DestroyCurrentState();
			}
			
			main = null;
			mainClass = null;
		}
		
		/**
		 * Returns the main class of the game.
		 */
		public function get MainClass():Class { return mainClass; }
		
		/**
		 * Returns the first state of the game.
		 */
		public function get FirstState():State { return sFirstState; }
		
		/**
		 * Returns the game name.
		 */
		public function get GameName():String { return sGameName; }

		/**
		 * Returns the game author.
		 */
		public function get GameAuthor():String { return sGameAuthor; }
		
		/**
		 * Returns the game description.
		 */
		public function get GameDescription():String { return sGameDescription; }
	}
}