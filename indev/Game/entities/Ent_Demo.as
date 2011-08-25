package Game.entities 
{
	import VerlocityEngine.Verlocity;
	import VerlocityEngine.base.ents.verBExtendedEnt;

	public class Ent_Demo extends verBExtendedEnt
	{
		public override function Think():void
		{
			y += Math.sin( Verlocity.engine.CurTime() / 1000 ) * 1;
			SetScale( ( Math.sin( Verlocity.engine.CurTime() / 1000 ) * .5 ) + 1 );
		}
	}
}