/*
 * ---------------------------------------------------------------
 * Verlocity
 * http://www.verlocityengine.com
 * 
 * This file is subject to the terms and conditions defined in
 * 'license.txt', which is part of this source code package.
 * ---------------------------------------------------------------
*/
package verlocity.ents.effects
{
	import verlocity.ents.DisplayEntity;
	import verlocity.Verlocity;

	public class ScreenEffect extends DisplayEntity
	{
		public function ScreenEffect():void
		{
			super();

			bIsSpawned = true;

			nInitialX = x;
			nInitialY = y;

			Init();
			EnableUpdate();
		}

		public override function Spawn( sSetLayer:String, bSpawnOnBottom:Boolean = false ):void 
		{
			Verlocity.Trace( "Screen effects cannot be spawned normally.  Please use verEnts.CreateScreenEffect." );
		}
	}
}