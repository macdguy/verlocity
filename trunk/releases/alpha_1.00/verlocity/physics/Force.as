/*
 * ---------------------------------------------------------------
 * Verlocity
 * http://www.verlocityengine.com
 * 
 * This file is subject to the terms and conditions defined in
 * 'license.txt', which is part of this source code package.
 * ---------------------------------------------------------------
*/
package verlocity.physics
{
	import flash.geom.Point;
	import verlocity.Verlocity;

	public final class Force extends Point
	{
		private var pDirection:Point;
		private var nMagnitude:Number;
		private var nLifeTime:Number;

		public function Force( pSetDirection:Point, nSetMagnitude:Number = 0, nSetLifeTime:Number = NaN ):void
		{
			pDirection = pSetDirection;
			pDirection.normalize( 1 );

			nMagnitude = nSetMagnitude;
			
			if ( !isNaN( nSetLifeTime ) )
			{
				nLifeTime = Verlocity.CurTime() + nSetLifeTime;
			}
		}

		/**
		 * Returns a normalized vector that describes the direction of the force.
		 */
		public function get direction():Point
		{
			return pDirection;
		}
		
		/**
		 * Returns the current magnitude (speed)
		 */
		public function get magnitude():Number
		{
			return nMagnitude;
		}
		
		/**
		 * Returns the lifetime of the force
		 */
		public function get lifetime():Number
		{
			return nLifeTime;
		}
		
		/**
		 * Returns the life time of the force (subtracted by the engine's current time)
		 */
		public function get initialLifeTime():Number
		{
			return nLifeTime - Verlocity.CurTime();
		}
	}
}