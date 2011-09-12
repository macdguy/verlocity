package Game.entities 
{
	import VerlocityEngine.base.ents.verBExtendedEnt;

	public class Ent_Template extends verBExtendedEnt
	{
		// Called when the entity is first created.
		public override function Init():void {}
		
		// Main loop for the entity.
		public override function Think():void {}
		
		// Called when the entity is being removed from the manager.
		public override function Deint():void {}

		// Called when the entity has collided with another entity.
		protected override function OnCollide( ent ):void { }
		
		// Called when the entity was removed.
		protected override function OnRemove():void { }
		
		// Called when the entity takes damage.
		protected function OnTakeDamage():void { }

		// Called when the entity was killed (this is gameplay/health related).
		protected function OnKill():void {}

		// Called when the entity was respawned.
		protected function OnRespawn():void { }
		
		// Called when the entity is spawned (placed in a layer)
		protected function OnSpawn():void {}
		
	}
}