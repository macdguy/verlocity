/*
 * ---------------------------------------------------------------
 * Verlocity
 * http://www.verlocityengine.com
 * 
 * This file is subject to the terms and conditions defined in
 * 'license.txt', which is part of this source code package.
 * ---------------------------------------------------------------
*/
package verlocity.core 
{
	/**
	 * Holds various objects in a key-string based memory storage.
	 */
	public dynamic class ObjectStorage extends Object
	{
		private var iLength:int;
		private var iMax:int;
		
		/**
		 * Creates a object storage which holds data accessed by string keys.
		 * @param	iMaxObjects The maximum amount of objects allowed to store. 0 means no limit.
		 */
		public function ObjectStorage( iMaxObjects:int = 0 ):void
		{
			iMax = iMaxObjects;
		}

		/**
		 * Adds an object to the storage.
		 * @param	key The string key for object reference.
		 * @param	obj The object to store.
		 * @return
		 */
		public function add( key:String, obj:Object ):Object
		{
			if ( iMax > 0 && iLength >= iMax ) { return null; }

			this[key] = obj;

			iLength++;

			return obj;
		}

		/**
		 * Removes an object from the storage.
		 * @param	key The string key of the object.
		 */
		public function remove( key:String ):void
		{
			if ( !this[key] ) { return; }
			
			this[key] = null;
			delete this[key];
			
			iLength--;
		}
		
		/**
		 * Retrives an object from the store.
		 * @param	key The string key of the object.
		 * @return
		 */
		public function retrieve( key:String ):Object
		{
			return this[key];
		}
		
		/**
		 * Clears all data in the storage.
		 */
		public function clear():void
		{
			for each ( var key:String in this )
			{
				remove( key );
			}

			iLength = 0;
		}

		/**
		 * Returns the length of the storage.
		 * @param	bCalc Re-calculate the length? (can be taxing)
		 * @return
		 */
		public function length( bCalc:Boolean = false ):int
		{
			if ( bCalc )
			{
				var i:int;

				for each ( var key:String in this )
				{
					i++;
				}
				
				return i;
			}
			
			return iLength;
		}
	}
}