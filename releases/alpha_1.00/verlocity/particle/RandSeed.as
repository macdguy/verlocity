/*
 * ---------------------------------------------------------------
 * Verlocity
 * http://www.verlocityengine.com
 * 
 * This file is subject to the terms and conditions defined in
 * 'license.txt', which is part of this source code package.
 * ---------------------------------------------------------------
*/
package verlocity.particle
{
	import verlocity.utils.MathUtil;

	public final class RandSeed extends Object
	{
		// The two number values
		private var nNumHigh:Number;
		private var nNumLow:Number;

		/**
		 * Creates a random seed (holds two numbers to return a random number between)
		 * @param	nSetNumLow The starting number for the random range
		 * @param	nSetNumHigh The ending number for the random range
		 */
		public function RandSeed( nSetNumLow:Number = NaN, nSetNumHigh:Number = NaN ):void
		{
			nNumLow = nSetNumLow;
			nNumHigh = nSetNumHigh;
		}

		/**
		 * Returns a random number between the two seeds.
		 * @return
		 */
		public function Get():Number
		{
			// If there's no low number, return 0.
			if ( isNaN( nNumLow ) ) { return 0; }
			
			// If there's no high number, return the low.
			if ( isNaN( nNumHigh ) ) { return nNumLow; }

			// If the two numbers are the same, return the low.
			if ( nNumLow == nNumHigh ) { return nNumLow; }

			// Get a random number between the low and high.
			return MathUtil.Rand( nNumLow, nNumHigh );
		}
	}
}