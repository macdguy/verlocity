/*
	This file is subject to the terms and conditions defined in
    file 'license.txt', which is part of this source code package.
*/

package verlocity.sound
{
	public final class SoundGroupSettings extends Object
	{
		private var nVolMin:Number;
		private var nVolMax:Number;
		
		private var iPitchMin:Number;
		private var iPitchMax:Number;
		
		private var iTimeMin:Number;
		private var iTimeMax:Number;
		
		private var bLoops:Boolean;
		
		
		/**
		 * Creates settings for a sound group
		 * @param	iSetTimeMin Minimum time delay between sounds
		 * @param	iSetTimeMax Maximum time delay between sounds
		 * @param	nSetVolMin Minimum volume range
		 * @param	nSetVolMax Maximum volume range
		 * @param	iSetPitchMin Minimum pitch range
		 * @param	iSetPitchMax Maximum pitch range
		 * @param	bShouldLoop Should the sound loop?
		 */
		public function SoundGroupSettings( iSetTimeMin:int, iSetTimeMax:int,
											nSetVolMin:Number = 1, nSetVolMax:Number = 1, 
											iSetPitchMin:int = 1, iSetPitchMax:int = 1, 
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