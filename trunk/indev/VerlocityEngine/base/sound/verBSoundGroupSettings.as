/*
	This file is subject to the terms and conditions defined in
    file 'license.txt', which is part of this source code package.
*/

package VerlocityEngine.base.sound
{
	public class verBSoundGroupSettings extends Object
	{
		private var nVolMin:Number;
		private var nVolMax:Number;
		
		private var iPitchMin:Number;
		private var iPitchMax:Number;
		
		private var iTimeMin:Number;
		private var iTimeMax:Number;
		
		private var bLoops:Boolean;
		
		public function verBSoundGroupSettings( iSetTimeMax:int, iSetTimeMin:int, 
												nSetVolMax:Number = 1, nSetVolMin:Number = 1,
												iSetPitchMax:int = 1, iSetPitchMin:int = 1, 
												bShouldLoop:Boolean = false ):void
		{
			iTimeMax = iSetTimeMax;
			iTimeMin = iSetTimeMin;
			nVolMax = nSetVolMax;
			nVolMin = nSetVolMin;
			iPitchMax = iSetPitchMax;
			iPitchMin = iSetPitchMin;
			bLoops = bShouldLoop;
		}
		
		public function get TimeMax():int { return iTimeMax; }
		public function get TimeMin():int { return iTimeMin; }
		public function get VolMax():Number { return nVolMax; }
		public function get VolMin():Number { return nVolMin; }
		public function get PitchMax():int { return iPitchMax; }
		public function get PitchMin():int { return iPitchMin; }
		public function get Loops():Boolean { return bLoops; }
	}
}