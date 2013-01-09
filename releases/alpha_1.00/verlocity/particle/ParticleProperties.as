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
	import flash.geom.Point;

	public final class ParticleProperties extends Object
	{
		// Color variables
		public var uiColorStart:uint;
		public var uiColorEnd:uint;

		// Lifetime
		public var iLifeTime:int;

		// Physics
		public var pStartVel:Point;
		public var pStartAccel:Point;

		/**
		 * Creates an instance of the particle properties
		 * @param	uiSetColorStart The starting color of the particle
		 * @param	uiSetColorEnd The ending color of the particle
		 * @param	iSetLifeTime The life time of the particle
		 * @param	pStartSetVel The velocity of the particle
		 * @param	pStartSetAccel The acceleration of the particle
		 */
		public function ParticleProperties( uiSetColorStart:uint, uiSetColorEnd:uint = 1, iSetLifeTime:int = -1, 
											pStartSetVel:Point = null, pStartSetAccel:Point = null ):void
		{
			// Set the starting color
			uiColorStart = uiSetColorStart;

			// If there's a set end color, set it.
			// Otherwise default to color start.
			if ( uiSetColorEnd == 1 )
			{
				uiColorEnd = uiSetColorStart;
			}
			else
			{
				uiColorEnd = uiSetColorEnd;
			}

			// Set the life time
			iLifeTime = iSetLifeTime;

			// Set physics values
			pStartVel = pStartSetVel;
			pStartAccel = pStartSetAccel;
		}

		/**
		 * Deletes any data assoc. with the particle properties.
		 */
		public function Dispose():void
		{
			uiColorStart = NaN;
			uiColorEnd = NaN;
			iLifeTime = NaN;
			pStartVel = null;
			pStartAccel = null;
		}
	}
}