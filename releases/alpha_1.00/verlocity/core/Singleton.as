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
	public class Singleton extends Object
	{
		public function Singleton() 
		{
			// Enforce singleton rules
			SingletonManager.Validate( this );
		}
		
		/**
		 * Remove this singleton from the manager.
		 */
		public function _Destruct():void
		{
			SingletonManager.Remove( this );
		}
		
		/**
		 * Returns if this singleton is active/valid.
		 * @return
		 */
		public function _IsValid():Boolean
		{
			return SingletonManager.IsActive( this );
		}
	}
}