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
	public final class ArrayUtil
	{
		/**
		 * Returns the last index of an array.
		 * @param	aArray The array
		 * @return
		 */
		public static function LastIndex( aArray:Array ):int
		{
			if ( aArray.length == 0 ) { return -1; }

			return aArray.length - 1;
		}
		
		/**
		 * Returns if two arrays are equal to themselves.
		 * @param	aArray1 The first array
		 * @param	aArray2 The second array
		 * @return
		 */
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
		
		/**
		 * Completely removes all contents of an array and disposes all memory
		 * @param	aArray The array to empty
		 */
		public static function Empty( aArray:Array ):void
		{
			if ( !aArray ) { return; }
			
			for ( var i:int; i < aArray.length; i++ )
			{
				if ( "_Dispose" in aArray[i] )
				{
					aArray[i]._Dispose();
				}

				delete aArray[i];
			}
			
			aArray.length = 0;
		}
		
		/**
		 * Returns if an object exists in an array.
		 * @param	aArray The array to search through
		 * @param	obj The object to find if it exists
		 * @return
		 */
		public static function Contains( aArray:Array, obj:Object ):Boolean
		{
			if ( aArray.length <= 0 ) { return false; }

			for ( var i:int; i < aArray.length; i++ )
			{
				return aArray[i] == obj;
			}

			return false;
		}
		
		/**
		 * Finds and returns the index of an object in array.  If not found, returns -1
		 * @param	aArray The array to search through
		 * @param	obj The object to return index of
		 * @return
		 */
		public static function GetIndex( aArray:Array, obj:Object ):int
		{
			if ( aArray.length <= 0 ) { return -1; }

			for ( var i:int; i < aArray.length; i++ )
			{
				if ( aArray[i] == obj )
				{
					return i;
				}
			}

			return -1;
		}
		
		/**
		 * Returns if an index is within range of the array
		 * @param	aArray The array
		 * @param	i The index
		 * @return
		 */
		public static function IsInRange( aArray:Array, i:int ):Boolean
		{
			return i >= 0 && i < aArray.length;
		}
	}
}