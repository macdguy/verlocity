/*
	This file is subject to the terms and conditions defined in
    file 'license.txt', which is part of this source code package.
*/

package VerlocityEngine.base.ents
{
	import VerlocityEngine.Verlocity;
	import flash.display.DisplayObject;

	public class verBScrEffect extends verBEffect
	{
		public function SpawnSFX( bHasAnim:Boolean = true, bProtected:Boolean = false ):void
		{
			bNoAnimation = !bHasAnim;
			SetProtected( bProtected );

			Verlocity.layers.AddSFX( this );
			play();
			
			bIsSpawned = true;
			spawnX = x; spawnY = y;

			OnSpawn();
		}
		
		public override function Spawn( layer:* ):void
		{
			Verlocity.Trace( null, "Notice: Please use SpawnSFX for screen FX objects!" );
			
			SpawnSFX();

			return;
		}
	}
}