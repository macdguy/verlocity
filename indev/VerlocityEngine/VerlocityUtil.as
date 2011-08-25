/*
	=========================================
			   Verlocity Engine
	=========================================
	|	Developed by Macklin Guy, 2011.		|
	|										|
	|										|
	-----------------------------------------
	VerlocityUtil.as
	-----------------------------------------
	Holds all the misc utility functions.
*/
package VerlocityEngine 
{
	import flash.net.LocalConnection;

	public final class VerlocityUtil 
	{
		/*
			Forces Flash's garbage collector.
			Used to clean up when we switch states.
			Highly CPU intensive.  Use with care.
		*/
		public static function GC():void
		{
			try {
				new LocalConnection().connect('gc');
				new LocalConnection().connect('gc');
			} catch (e:*) {}
		}
	}
}