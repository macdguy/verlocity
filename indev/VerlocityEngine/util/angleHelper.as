/*
	This file is subject to the terms and conditions defined in
    file 'license.txt', which is part of this source code package.
*/

package VerlocityEngine.util
{
	import flash.geom.Point;

	public final class angleHelper 
	{

		private static const nRadDegree:Number = 180 / Math.PI;
		private static const nDegreeRad:Number = Math.PI / 180;
		
		public static function RadToDegree( nRad:Number ):Number
		{
			return nRad * nRadDegree;
		}

		public static function DegreeToRad( nDegree:Number ):Number
		{
			return nDegree * nDegreeRad;
		}

		public static function Angle( nStartPosX:Number, nStartPosY:Number, nEndPosX:Number, nEndPosY:Number ):Point
		{
			var nDirX:Number = nEndPosX - nStartPosX;
			var nDirY:Number = nEndPosY - nStartPosY;

			var nNorm:Number = Math.sqrt( nDirX * nDirX + nDirY * nDirY );

			nDirX = nDirX / nNorm;
			nDirY = nDirY / nNorm;
			
			return new Point( nDirX, nDirY );
		}
		
		public static function GetRads( nStartPosX:Number, nStartPosY:Number, nEndPosX:Number, nEndPosY:Number ):Number
		{
			var nDirX:Number = nEndPosX - nStartPosX;
			var nDirY:Number = nEndPosY - nStartPosY;

			return Math.atan2( nDirY, nDirX );	
		}
		
		public static function Rotation( nStartPosX:Number, nStartPosY:Number, nEndPosX:Number, nEndPosY:Number ):Number
		{
			var nRadians:Number = GetRads( nStartPosX, nStartPosY, nEndPosX, nEndPosY );
			return RadToDegree( nRadians );
		}
		
		public static function AngleOfRotation( nRot:Number ):Point
		{
			var nDegree:Number = angleHelper.DegreeToRad( nRot );
			var nAngX:Number = Math.cos( nDegree );
			var nAngY:Number = Math.sin( nDegree );
			
			return new Point( nAngX, nAngY );
		}
		
		public static function SlowRotation( nOriginalRot:Number, nAngle:Number, nSpeed:Number = 0.9 ):Number
		{
			return mathHelper.SmoothAverage( nOriginalRot / 180 * Math.PI, nAngle, nSpeed ) * nRadDegree;
		}

	}

}