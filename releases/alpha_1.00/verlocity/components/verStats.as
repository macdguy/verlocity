/*
 * ---------------------------------------------------------------
 * Verlocity
 * http://www.verlocityengine.com
 * 
 * This file is subject to the terms and conditions defined in
 * 'license.txt', which is part of this source code package.
 * ---------------------------------------------------------------
 * Component: verStats
 * Author: Macklin Guy
 * ---------------------------------------------------------------
*/
package verlocity.components
{
	import flash.display.Stage;
	import flash.events.Event;
	import flash.utils.getTimer;
	import flash.system.System;

	import verlocity.core.Component;

	/**
	 * Calculates and holds many useful performance stats.
	 */
	public final class verStats extends Component
	{
		private var iNow:int
		private var iDelta:int
		private var iLast:int

		private var iTicks:int;
		private var iMS:int

		private var iCurFPS:int;
		private var iCurMS:int;

		private var nMemory:Number;

		/**
		 * Constructor of the component.
		 * @param	sStage
		 */
		public function verStats( sStage:Stage ):void
		{
			// Setup component
			super( sStage );
			
			// Component-specific construction
			nMemory = 0;
			stage.addEventListener( Event.ENTER_FRAME, UpdateStats );
		}

		private final function UpdateStats( e:Event ):void
		{
			iTicks++;
		
			iNow = getTimer();
			iDelta = iNow - iLast;
			
			if( iDelta >= 1000 )
			{
				nMemory = Number( ( System.totalMemory * 0.000000954 ).toFixed( 3 ) );

				iCurFPS = iTicks / iDelta * 1000;
				iTicks = 0;

				iLast = iNow;
			}

			iCurMS = iNow - iMS;
			iMS = iNow;
		}

		/**
		 * Destructor of the component.
		 */
		public override function _Destruct():void
		{
			// Component-specific destruction
			stage.removeEventListener( Event.ENTER_FRAME, UpdateStats );
			
			iNow = NaN;
			iDelta = NaN;
			iLast = NaN;

			iTicks = NaN;
			iMS = NaN;
			
			iCurFPS = NaN;
			iCurMS = NaN;
			nMemory = NaN

			// Destroy component
			super._Destruct();
		}

		/*================== COMPONENT ==================*/

		/*------------------- PRIVATE -------------------*/

		/*===============================================*/
		
		/*------------------- PUBLIC --------------------*/
		/**
		 * Returns the current frames per second.
		 */
		public final function get FPS():int { return iCurFPS; }
		
		/**
		 * Returns the curret memory usage.
		 */
		public final function get Memory():Number { return nMemory; }
		
		/**
		 * Returns the MS (script execution time)
		 */
		public final function get MS():int { return iCurMS; }
	}
}