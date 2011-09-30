/*
	This file is subject to the terms and conditions defined in
    file 'license.txt', which is part of this source code package.
*/

package VerlocityEngine.util
{
	public final class arrayHelper 
	{

		public static function LastIndex( aArray:Array ):int
		{
			return aArray.length - 1;
		}
		
		public static function Equals( aArray1:Array, aArray2:Array ):Boolean
		{
			var i:int = aArray1.length;

			if ( i > aArray2.length ) { return false; }

			while ( i-- )
			{
				if ( aArray1[i] != aArray2[1] ) { return false; }
			}

			return true;
		}

	}

}