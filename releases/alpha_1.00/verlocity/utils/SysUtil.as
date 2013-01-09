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
	import flash.net.LocalConnection;

	import verlocity.core.SingletonManager;
	import verlocity.Verlocity;

	public final class SysUtil 
	{
		/**
		 * Forces Flash's garabage collector.
		 * Highly CPU intensive.  Use with care.
		 */
		public static function GC():void
		{
			trace( "Garbage Collecting..." );

			try {
				new LocalConnection().connect('gc');
				new LocalConnection().connect('gc');
			} catch (e:*) {}
		}
		
		/**
		 * Returns if Verlocity is active and loaded.
		 * @return
		 */
		public static function IsVerlocityLoaded():Boolean
		{
			return SingletonManager.IsActive( Verlocity ) && Verlocity.IsLoaded();
		}
	}
}