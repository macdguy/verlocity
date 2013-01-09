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
	import flash.utils.getTimer;
	import verlocity.Verlocity;

	public final class MathUtil
	{
		/**
		 * Returns an eased value between two numbers.
		 * @param	nOrigin The original number
		 * @param	nNew The new number
		 * @param	nSpeed The speed to ease to
		 * @return
		 */
		public static function Ease( nOrigin:Number, nNew:Number, nSpeed:Number ):Number
		{
			return ( nOrigin - nNew ) / nSpeed;
		}

		/**
		 * Returns the distance (in one dimension) between two positions.
		 * @param	nStartPos The first position
		 * @param	nEndPos The second position
		 * @return
		 */
		public static function Dist1D( nStartPos:Number, nEndPos:Number ):Number
		{
			return Math.sqrt( Math.abs( nStartPos - nEndPos ) );
		}
		
		/**
		 * Returns the distance between two points.
		 * @param	pStartPos The first point
		 * @param	pEndPos The second point
		 * @return
		 */
		public static function Dist2D( pStartPos:Point, pEndPos:Point ):Number
		{
			var nDirX:Number = pStartPos.x - pEndPos.x;
			var nDirY:Number = pStartPos.y - pEndPos.y;

			return Math.sqrt( nDirX * nDirX + nDirY * nDirY );
		}

		/**
		 * Returns the average of any amount of numbers.
		 * @param	... nums The numbers to average
		 * @return
		 */
		public static function Average( ... nums ):Number
		{
			var iTotal:int = nums.length;
			var nSum:Number = 0;

			var i:int = 0;
			while( i < iTotal )
			{
				nSum += nums[i];
				i++;
			}
			
			return nSum / iTotal;			
		}

		/**
		 * Returns the smoothed average of two numbers.
		 * @param	nNum The first number
		 * @param	nNum2 The second number
		 * @param	nSpeed The rate of average
		 * @return
		 */
		public static function SmoothAverage( nNum:Number, nNum2:Number, nSpeed:Number = 0.5 ):Number
		{
			var nSinSpeed:Number = Math.sin( nNum ) * ( nSpeed );
			var nCosSpeed:Number = Math.cos( nNum ) * ( nSpeed );

			var nSin:Number = Math.sin( nNum2 ) * ( 1 - nSpeed );
			var nCos:Number = Math.sin( nNum2 ) * ( 1 - nSpeed );

			return Math.atan2( nSinSpeed + nSin, nCosSpeed + nCos );
		}

		/**
		 * Returns the appoximate linear interpolated value between two numbers.
		 * http://en.wikipedia.org/wiki/Lerp_(computing)
		 * @param	nDelta The delta
		 * @param	nFrom The first number
		 * @param	nTo The second number
		 * @return
		 */
		public static function Lerp( nDelta:Number, nFrom:Number, nTo:Number ):Number
		{
			if ( nDelta > 1 ) { return nTo; }
			if ( nDelta < 0 ) { return nFrom; }

			return nFrom + ( nTo - nFrom ) * nDelta;
		}

		/**
		 * Returns the clamped value of a number.
		 * @param	nVal The number to clamp
		 * @param	nMin The minimum value the number can be
		 * @param	nMax The maximum value the number can be
		 * @return
		 */
		public static function Clamp( nVal:Number, nMin:Number, nMax:Number ):Number
		{
			return Math.max( nMin, Math.min( nMax, nVal ) );
		}

		/**
		 * Returns the 0-1 clamped value of a number.
		 * @param	nVal The number to clamp between 0 and 1
		 * @return
		 */
		public static function ClampNum( nVal:Number ):Number
		{
			return Clamp( nVal, 0, 1 );
		}

		/**
		 * Returns a random number between two numbers.
		 * @param	min The minimum number
		 * @param	max The maximum number
		 * @return
		 */
		public static function Rand( nMin:Number, nMax:Number ):Number
		{
     		return nMin + ( nMax - nMin ) * Math.random();
		}

		/**
		 * Returns an approached (incremental) value between two numbers.
		 * @param	nCurrent The current number
		 * @param	nTarget The target number
		 * @param	nIncrement The amount to increment until target reached
		 * @return
		 */
		public static function Approach( nCurrent:Number, nTarget:Number, nIncrement:Number ):Number
		{
			nIncrement = Math.abs( nIncrement );

			if ( nCurrent < nTarget )
			{
				return Clamp( nCurrent + nIncrement, nCurrent, nTarget );

			}
			else if ( nCurrent > nTarget )
			{
				return Clamp( nCurrent - nIncrement, nTarget, nCurrent );
			}

			return nTarget;
		}

		/**
		 * Returns if a number is between two numbers.
		 * @param	nNum The number
		 * @param	nMin The minimum number
		 * @param	nMax The maximum number
		 * @return
		 */
		public static function IsBetween( nNum:Number, nMin:Number, nMax:Number ):Boolean
		{
			return nNum >= nMin && nNum <= nMax;
		}

		/**
		 * Returns a random normalized vector.
		 * @return
		 */
		public static function VectorRand():Point
		{
			return new Point( Rand( -1, 1 ), Rand( -1, 1 ) );
		}
		
		/**
		 * Returns the approximate "fitted" number based on linear regression.
		 * @param	nVal The number to fit
		 * @param	nValMin The minimum of the value
		 * @param	nValMax The maximum of the value
		 * @param	nOutMin The output minimum
		 * @param	nOutMax The output maximum
		 * @return
		 */
		public static function Fit( nVal:Number, nValMin:Number, nValMax:Number, nOutMin:Number, nOutMax:Number ):Number
        {
			return ( nVal - nValMin ) * ( nOutMax - nOutMin ) / ( nValMax - nValMin ) + nOutMin;
        }
		
		/**
		 * Returns a rounded fixed value based on a factor.
		 * @param	nVal The value
		 * @param	nFactor The factor to get to
		 * @return
		 */
		public static function ToFixed( nVal:Number, nFactor:Number ):Number
		{
			return Math.round( nVal * nFactor ) / nFactor;
		}
		
		/**
		 * Returns if a value has gone beyond the maximum value.
		 * @param	nVal The value
		 * @param	nMax The maximum value
		 * @return
		 */
		public static function IsBeyond( nVal:Number, nMax:Number ):Boolean
		{
			return ( nVal % nMax ) == 0;
		}
		
		/**
		 * Returns the percentage value (0-1) of two numbers ( val / max ).
		 * @param	nVal The value
		 * @param	nMax The maximum value
		 * @return
		 */
		public static function Percent( nVal:Number, nMax:Number ):Number
		{
			return ClampNum( nVal / nMax );
		}
		
		/**
		 * Returns a frmae-based sin expression, sin( time / divider ) * mul
		 * @param	nDivider
		 * @param	nMul
		 * @return
		 */
		public static function SinTime( nDivider:Number = 500, nMul:Number = 25 ):Number
		{
			if ( !SysUtil.IsVerlocityLoaded() )
			{
				return Math.sin( getTimer() / nDivider ) * nMul;
			}
			else
			{
				return Math.sin( Verlocity.CurTime() / nDivider ) * nMul;
			}
		}
	}
}