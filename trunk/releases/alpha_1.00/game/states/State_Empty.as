/*
 * ---------------------------------------------------------------
 * Verlocity
 * http://www.verlocityengine.com
 * 
 * This file is subject to the terms and conditions defined in
 * 'license.txt', which is part of this source code package.
 * ---------------------------------------------------------------
*/
package game.states 
{
	import verlocity.logic.State;

	public class State_Empty extends State
	{
		public override function Construct():void
		{
			trace( "CONSTRUCT" );
		}
		
		public override function Init():void
		{
		}
		
		public override function Update():void
		{			
		}
		
		public override function DeInit():void
		{
		}

		public override function Destruct():void 
		{
			trace( "DESTRUCT" );
		}
	}
}