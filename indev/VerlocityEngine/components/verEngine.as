/*
	=========================================
			   Verlocity Engine
	=========================================
	|	Developed by Macklin Guy, 2011.		|
	|										|
	|										|
	-----------------------------------------
	verEngine.as
	-----------------------------------------
	This class manages the game loop.

	Usable functions:
		Hook( class ) - Hooks a class to the game loop.
						Note: Requires a public function named 'Think' in the class.

		UnHook( class ) - Unhooks a class from the game loop.
		
		RemoveAllHooks() - Removes all hooks from the game loop.

		Pause() - Pauses the game loop.

		Resume() - Resumes the game loop.
*/

package VerlocityEngine.components
{
	import flash.events.Event;
	
	import VerlocityEngine.Verlocity;
	import VerlocityEngine.VerlocityLanguage;
	import VerlocityEngine.VerlocitySettings;

	import VerlocityEngine.libraries.Ticker.Ticker;
	import VerlocityEngine.libraries.Ticker.TickerEvent;

	public final class verEngine extends Object
	{
		//********* VERLOCITY COMPONENT HEADER *********//
		/************************************************/
		public function IsValid():Boolean { return wasCreated; }
		private var wasCreated:Boolean;
		
		public function verEngine():void
		{
			if ( wasCreated ) { throw new Error( VerlocityLanguage.T( "ComponentLoadFail" ) ); return; } wasCreated = true;
			Construct();
			Concommands();
		}
		/************************************************/
		/************************************************/
		
		/*
		 ****************COMPONENT VARS******************
		*/
		private var bIsPaused:Boolean;

		private var vComponents:Vector.<Object>;
		private var vHooks:Vector.<Object>;

		private var engineTimer:Ticker;

		private var clockTimer:Ticker;
		private var iCurrentTime:int;

		private var nTimeScale:Number;


		/*
		 **************COMPONENT CREATION****************
		*/
		private function Construct():void
		{
			vComponents = new Vector.<Object>();
			vHooks = new Vector.<Object>();

			nTimeScale = 1;

			engineTimer = new Ticker( ( 1000 / VerlocitySettings.FRAMERATE ) );
			engineTimer.addEventListener( TickerEvent.TICK, Think );
			engineTimer.start();

			clockTimer = new Ticker( 1 );
			clockTimer.addEventListener( TickerEvent.TICK, ClockThink );
			clockTimer.start();		
		}

		/*
		 *************COMPONENT CONCOMMANDS**************
		*/
		private function Concommands():void
		{
			if ( !Verlocity.console ) { return; }

			Verlocity.console.Register( "timescale", function( scale:String )
			{
				TimeScale( Number( scale ) );
			}, "Alters the timescale.  Less than 1 to make it run slower, more than 1 to make it run faster." );

			Verlocity.console.Register( "curtime", function()
			{
				Verlocity.console.Output( "CurTime: " + CurTime() );
			}, "Outputs the current time." );
		}


		/*
		 ****************COMPONENT LOOP******************
		*/
		/**
		 * This is the main game loop.
		 * It calls all the referenced engine objects and run their 'Think' funcitons.
		*/
		private function Think( e:TickerEvent ):void
		{
			ComponentThink();
			HookThink();
		}
		
		
		/*
		 *************COMPONENT FUNCTIONS***************
		*/
		
		/*------------------ PRIVATE ------------------*/

		private function ComponentThink():void
		{
			var iLength:int = vComponents.length;

			if ( iLength <= 0 ) { return; }

			var refCurrent:Object;

			for ( var i:int = 0; i < iLength; i++ )
			{
				refCurrent = vComponents[i];
				
				if ( refCurrent && refCurrent.IsValid() )
				{
					refCurrent.Think();
				}
				else
				{
					vComponents.splice( i, 1 );
				}

				refCurrent = null;
			}
		}
		
		private function HookThink():void
		{
			var iLength:int = vHooks.length;

			if ( iLength <= 0 ) { return; }

			var refCurrent:Object;

			for ( var i:int = 0; i < iLength; i++ )
			{
				refCurrent = vHooks[i];
				
				if ( refCurrent )
				{
					refCurrent.Think();
				}
				else
				{
					vHooks.splice( i, 1 );
				}

				refCurrent = null;
			}
		}
		
		private function ClockThink( e:TickerEvent ):void
		{
			iCurrentTime++;
		}
		

		/*------------------ PUBLIC -------------------*/
		public function CurTime():int
		{
			return iCurrentTime;
		}
		
		public function TimeScale( nNewTimeScale:Number ):void
		{
			if ( nNewTimeScale <= 0 || nNewTimeScale > 5 ) { return; }

			nTimeScale = nNewTimeScale;
			engineTimer.delay = ( 1000 / VerlocitySettings.FRAMERATE ) / nTimeScale;
			
			Verlocity.stage.frameRate = VerlocitySettings.FRAMERATE * nNewTimeScale;

			Verlocity.Trace( "Engine", "Timescale altered. Now: " + nNewTimeScale );
		}


		/**
		 * Hooks an object to the game loop.  It will not add duplicates.
		 * Note: Requires a public function named 'Think' in the object.
		 * @param	newObj The object you want to hook into the main game loop.
		 * @usage	Example usage: verEngine.Hook( this );
		*/
		public function Hook( newObj:Object ):void
		{
			if ( -1 != vHooks.indexOf( newObj ) )
			{
				Verlocity.Trace( "Engine", newObj + VerlocityLanguage.T( "GenericDuplicate" ) );
				return;
			}

			if ( "Think" in newObj )
			{
				vHooks[ vHooks.length ] = newObj;
				Verlocity.Trace( "Engine", newObj + VerlocityLanguage.T( "GenericAddSuccess" ) );
				return;
			}

			Verlocity.Trace( "Engine", VerlocityLanguage.T( "GenericAddFail" ) );
		}
		
		
		public function RegisterComponent( component:Object ):void
		{
			if ( -1 != vComponents.indexOf( component ) )
			{
				Verlocity.Trace( "Engine", component + VerlocityLanguage.T( "GenericDuplicate" ) );
				return;
			}

			vComponents[ vComponents.length ] = component;
			Verlocity.Trace( "Engine", component + " " + VerlocityLanguage.T( "GenericAddSuccess" ) );
		}


		/**
		 * Removes an object from the engine hook.
		 * MAKE SURE TO DO THIS BEFORE YOU REMOVE ANY HOOKED OBJECTS!
		 * @param	objToRemove The object you want to remove from the main game loop.
		 * @usage	Example usage: verEngine.UnHook( this );
		*/
		public function UnHook( objToRemove:Object ):void
		{
			if ( vHooks.length <= 0 ) { return; }

			var i:int = vHooks.indexOf( objToRemove );

			if ( i == -1 ) { Verlocity.Trace( "Engine", VerlocityLanguage.T( "GenericMissing" ) ); return; }

			vHooks.splice( i, 1 );

			Verlocity.Trace( "Engine", VerlocityLanguage.T( "GenericRemove" ) + objToRemove );
		}
		

		/**
		 * Removes all current hooked objects in the engine.  Very useful for state changes.
		 * @usage	Example usage: verEngine.RemoveAllHooks();
		*/
		public function RemoveAllHooks():void
		{
			vHooks = new Vector.<Object>();

			Verlocity.Trace( "Engine", VerlocityLanguage.T( "GenericRemoveAll" ) );
		}


		/**
		 * Pauses the main game loop.
		 * @usage	Example usage: verEngine.Pause();
		*/
		public function Pause():void
		{
			if ( bIsPaused ) { return; }

			bIsPaused = true;

			engineTimer.stop();
			clockTimer.stop();

			Verlocity.Trace( "Engine", "Paused engine." );
		}

		/**
		 * Resumes the main game loop.
		 * @usage	Example usage: verEngine.Resume();
		*/
		public function Resume():void
		{
			if ( !bIsPaused ) { return; }

			bIsPaused = false;

			engineTimer.start();
			clockTimer.start();

			Verlocity.Trace( "Engine", "Resumed engine." );
		}

		public function get IsPaused():Boolean { return bIsPaused; }
	}
}