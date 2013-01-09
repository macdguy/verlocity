/*
	This file is subject to the terms and conditions defined in
    file 'license.txt', which is part of this source code package.
*/

package verlocity.ents.spawners
{
	import flash.display.DisplayObject;

	import verlocity.Verlocity;
	import verlocity.ents.Entity;
	import verlocity.ents.DisplayEntity;
	import verlocity.display.Layer;
	import verlocity.logic.ElapsedTrigger;
	
	import verlocity.utils.MathUtil;

	public class BeatSpawner extends Entity
	{
		private var etTrigger:ElapsedTrigger;

		private var cClass:Class;
		private var cDisplayClass:Class;
		private var sLayer:String;

		private var iDelay:int;
		private var iMinX:int, iMaxX:int, iMinY:int, iMaxY:int;
		
		public function BeatSpawner():void
		{
			super();
			
			etTrigger = new ElapsedTrigger();
		}
		
		/**
		 * Spawns an entity each time there is a beat
		 */
		public override function _Update():void 
		{
			super._Update();

			if ( !cClass || !sLayer ) { return; }
			
			if ( !Verlocity.IsValid( Verlocity.analyzer ) || Verlocity.analyzer._IsNotUpdating() ) { return; }

			if ( Verlocity.analyzer.Beat() && etTrigger.IsTriggered() )
			{
				SpawnEntity();
			}
		}
		
		/**
		 * Spawns an entity
		 */
		private function SpawnEntity():void
		{
			var ent:DisplayEntity = Verlocity.ents.Create( cClass, true );
				ent.display.SetDisplayObject( new cDisplayClass() );
				ent.SetPos( MathUtil.Rand( iMinX, iMaxX ), MathUtil.Rand( iMinY, iMaxY ) );
			ent.Spawn( sLayer );

			etTrigger.Reset( iDelay );
		}
		
		/**
		 * Sets the layer to spawn entities into
		 * @param	sSetLayer
		 */
		public function Spawn( sSetLayer:String ):void
		{
			if ( !Verlocity.IsValid( Verlocity.layers ) ) { return; }

			if ( !Verlocity.layers.IsValidLayer( sSetLayer ) )
			{
				Verlocity.Trace( "Ents", "Unable to spawn entity! Check if spawn layer is valid!" );
				return;
			}
			
			sLayer = sSetLayer;
		}
		
		/**
		 * Set spawn parameters
		 * @param	iSetDelay The delay between spawns
		 * @param	cSetClass The class of entity to spawn
		 * @param	cSetDisplayClass The display object class to use for art
		 * @param	bSetBitmap Should we bitmap the display object?
		 * @param	iSetMinX The minimum X spawn position
		 * @param	iSetMaxX The maximum X spawn position
		 * @param	iSetMinY The minimum Y spawn position
		 * @param	iSetMaxY The maximum Y spawn position
		 */
		public function SetSpawnParams( iSetDelay:int, cSetClass:Class, cSetDisplayClass:Class,
										iSetMinX:int, iSetMaxX:int, iSetMinY:int, iSetMaxY:int ):void
		{
			iDelay = iSetDelay;

			cClass = cSetClass;
			cDisplayClass = cSetDisplayClass;

			iMinX = iSetMinX; iMaxX = iSetMaxX;
			iMinY = iSetMinY; iMaxY = iSetMaxY;
		}
		
		/**
		 * Removes the elapsed trigger
		 */
		public override function _Dispose():void
		{
			super._Dispose();

			etTrigger = null;
		}
	}
}