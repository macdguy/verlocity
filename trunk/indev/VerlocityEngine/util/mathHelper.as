/*
	This file is subject to the terms and conditions defined in
    file 'license.txt', which is part of this source code package.
*/

package VerlocityEngine.util
{
	import flash.geom.Point;

	public final class mathHelper
	{

		public static function Ease( nOrigin:Number, nNew:Number, nSpeed:Number ):Number
		{
			return ( nOrigin - nNew ) / nSpeed;
		}

		public static function Dist1D( nStartPos:Number, nEndPos:Number ):Number
		{
			return Math.sqrt( Math.abs( nStartPos - nEndPos ) );
		}
		
		public static function Dist2D( iStartPosX:int, iStartPosY:int, iEndPosX:int, iEndPosY:int ):Number
		{
			var nDirX:Number = iStartPosX - iEndPosX;
			var nDirY:Number = iStartPosY - iEndPosY;

			return Math.sqrt( nDirX * nDirX + nDirY * nDirY );
		}

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

		public static function SmoothAverage( nNum:Number, nNum2:Number, nSpeed:Number = 0.5 ):Number
		{
			var nSinSpeed:Number = Math.sin( nNum ) * ( nSpeed );
			var nCosSpeed:Number = Math.cos( nNum ) * ( nSpeed );

			var nSin:Number = Math.sin( nNum2 ) * ( 1 - nSpeed );
			var nCos:Number = Math.sin( nNum2 ) * ( 1 - nSpeed );

			return Math.atan2( nSinSpeed + nSin, nCosSpeed + nCos );
		}

		public static function Lerp( nDelta:Number, iFrom:int, iTo:int ):int
		{
			if ( nDelta > 1 ) { return iTo; }
			if ( nDelta < 0 ) { return iFrom; }

			return iFrom + ( iTo - iFrom ) * nDelta;
		}


		public static function Clamp( nVal:Number, nMin:Number, nMax:Number ):Number
		{
			return Math.max( nMin, Math.min( nMax, nVal ) );
		}


		public static function ClampNum( nVal:Number ):Number
		{
			return Clamp( nVal, 0, 1 );
		}


		public static function Rand( min:Number, max:Number ):Number
		{
     		return min + ( max - min ) * Math.random();
		}


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


		public static function IsBetween( nNum:Number, nMin:Number, nMax:Number ):Boolean
		{
			return nNum >= nMin && nNum <= nMax;
		}


		public static function VectorRand():Point
		{
			return new Point( Rand( -1, 1 ), Rand( -1, 1 ) );
		}
		
		public static function Fit( nVal:Number, nValMin:Number, nValMax:Number, nOutMin:Number, nOutMax:Number ):Number
        {
			return ( nVal - nValMin ) * ( nOutMax - nOutMin ) / ( nValMax - nValMin ) + nOutMin;
        }
		
		public static function ToFixed( nVal:Number, iFactor:int ):Number
		{
			return Math.round( nVal * iFactor ) / iFactor;
		}

	}

}