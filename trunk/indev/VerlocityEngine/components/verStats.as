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
	verStats.as
	-----------------------------------------
	This class calculates and holds many useful preformance stats.
	Some calculations are based off code from "Hi-ReS! Stats" by Mr.doob.
*/

package VerlocityEngine.components
{
	import flash.utils.getTimer;
	import flash.system.System;
	import flash.events.Event;
	
	import VerlocityEngine.Verlocity;
	import VerlocityEngine.VerlocityLanguage;

	public final class verStats extends Object
	{
		//********* VERLOCITY COMPONENT HEADER *********//
		/************************************************/
		public function IsValid():Boolean { return wasCreated; }
		private var wasCreated:Boolean;
		
		public function verStats():void
		{
			if ( wasCreated ) { throw new Error( VerlocityLanguage.T( "ComponentLoadFail" ) ); return; } wasCreated = true;
			Construct();
		}
		/************************************************/
		/************************************************/
		
		/*
		 ****************COMPONENT VARS******************
		*/
		private var iTimer:int

		private var iFPS:int, iCurFPS:int
		private var iCurMS:int, iMS:int, iMSPrev:int = 0;
		private var nMemory:Number = 0;
		
		/*
		 **************COMPONENT CREATION****************
		*/
		private function Construct():void
		{
			// We want to override the main loop for these stats as they're calculated a little differently.
			Verlocity.stage.addEventListener( Event.ENTER_FRAME, Update );
		}

		/*
		 *************COMPONENT FUNCTIONS***************
		*/

		/*------------------ PRIVATE ------------------*/
		private function Update( e:Event ):void
		{
			iTimer = getTimer();
			iFPS++;
			
			if( iTimer - 1000 > iMSPrev )
			{
				iMSPrev = iTimer;
				nMemory = Number( ( System.totalMemory * 0.000000954 ).toFixed( 3 ) );

				iCurFPS = iFPS;
				iFPS = 0;
			}

			iCurMS = iTimer - iMS;
			iMS = iTimer;
		}

		/*------------------ PUBLIC -------------------*/
		public function get FPS():int { return iCurFPS; }
		public function get Memory():Number { return nMemory; }
		public function get MS():int { return iCurMS; }

	}
}