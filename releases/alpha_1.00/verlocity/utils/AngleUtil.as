/*
 * ---------------------------------------------------------------
 * Verlocity
 * http://www.verlocityengine.com
 * 
 * This file is subject to the terms and conditions defined in
 * 'license.txt', which is part of this source code package.
 * ---------------------------------------------------------------
*/
package verlocity.utils
{
	import flash.geom.Point;

	public final class AngleUtil
	{
		private static const nRadDegree:Number = 180 / Math.PI;
		private static const nDegreeRad:Number = Math.PI / 180;

		/**
		 * Converts a radian to degrees
		 * @param	nRad The radian
		 * @return
		 */
		public static function RadToDegree( nRad:Number ):Number
		{
			return nRad * nRadDegree;
		}

		/**
		 * Converts a degree to radians
		 * @param	nDegree The degree
		 * @return
		 */
		public static function DegreeToRad( nDegree:Number ):Number
		{
			return nDegree * nDegreeRad;
		}

		/**
		 * Returns a vector based on two points given
		 * @param	pStartPos The first point
		 * @param	pEndPos The second point
		 * @return
		 */
		public static function Angle( pStartPos:Point, pEndPos:Point ):Point
		{
			var nDirX:Number = pEndPos.x - pStartPos.x;
			var nDirY:Number = pEndPos.y - pStartPos.y;

			var nNorm:Number = Math.sqrt( nDirX * nDirX + nDirY * nDirY );

			nDirX = nDirX / nNorm;
			nDirY = nDirY / nNorm;

			return new Point( nDirX, nDirY );
		}
		
		/**
		 * Returns the radian based on two points given.
		 * @param	pStartPos The first point
		 * @param	pEndPos The second point
		 * @return
		 */
		public static function GetRad( pStartPos:Point, pEndPos:Point ):Number
		{
			var nDirX:Number = pEndPos.x - pStartPos.x;
			var nDirY:Number = pEndPos.y - pStartPos.y;

			return Math.atan2( nDirY, nDirX );	
		}
		
		/**
		 * Returns the degree (0-360) based on two points given.
		 * @param	pStartPos The first point
		 * @param	pEndPos The second point
		 * @return
		 */
		public static function Rotation( pStartPos:Point, pEndPos:Point ):Number
		{
			var iRadians:int = GetRad( pStartPos, pEndPos );
			return RadToDegree( iRadians );
		}
		
		/**
		 * Returns a vector based on a degree (0-360)
		 * @param	iRot The degree
		 * @return
		 */
		public static function AngleOfRotation( iRot:int ):Point
		{
			var iDegree:int = AngleUtil.DegreeToRad( iRot );
			var iAngX:int = Math.cos( iDegree );
			var iAngY:int = Math.sin( iDegree );

			return new Point( iAngX, iAngY );
		}
		
		/**
		 * Returns a degree (0-360) based on the original degree, a new degree, and the speed to rotate towards.
		 * @param	iOriginalRot The original degree
		 * @param	iAngle The degree to rotate to
		 * @param	nSpeed The speed of the rotation
		 * @return
		 */
		public static function SlowRotation( iOriginalRot:int, iAngle:int, nSpeed:Number = 0.9 ):int
		{
			return MathUtil.SmoothAverage( iOriginalRot / 180 * Math.PI, iAngle, nSpeed ) * nRadDegree;
		}

	}

}