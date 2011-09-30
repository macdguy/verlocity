/*
	This file is subject to the terms and conditions defined in
    file 'license.txt', which is part of this source code package.
*/

package VerlocityEngine.base.ents.spawners
{
	import VerlocityEngine.base.ents.verBEnt;
	import VerlocityEngine.helpers.ElapsedTrigger;
	import VerlocityEngine.Verlocity;
	import VerlocityEngine.util.mathHelper;

	public class verBBeatSpawner extends verBEnt
	{
		private var etTrigger:ElapsedTrigger = new ElapsedTrigger();

		private var cClass:Class;
		private var spLayer:*;
		private var iDelay:int;
		private var iMinX:int, iMaxX:int, iMinY:int, iMaxY:int;
		
		public override function Think():void 
		{
			if ( !cClass ) { return; }

			if ( Verlocity.analyzer.Beat() && etTrigger.IsTriggered() )
			{
				var ent:* = Verlocity.ents.Create( cClass );
					ent.SetPos( mathHelper.Rand( iMinX, iMaxX ), mathHelper.Rand( iMinY, iMaxY ) );
				ent.Spawn( spLayer );

				etTrigger.Reset( iDelay );
			}
		}
		
		public override function Spawn( layer:* ):void
		{
			spLayer = layer;
		}
		
		public function SetSpawnParams( iSetDelay:int, cSetClass:Class, iSetMinX:int, iSetMaxX:int, iSetMinY:int, iSetMaxY:int ):void
		{
			iDelay = iSetDelay;

			cClass = cSetClass;
			iMinX = iSetMinX; iMaxX = iSetMaxX;
			iMinY = iSetMinY; iMaxY = iSetMaxY;
		}
		
		public override function DeInit():void
		{
			etTrigger = null;
		}
	}
}