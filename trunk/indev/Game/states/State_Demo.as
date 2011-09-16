package Game.states
{
	import VerlocityEngine.Verlocity;
	import VerlocityEngine.base.verBState;
	
	import Game.entities.Ent_Demo;

	public class State_Demo extends verBState
	{
		// Called when the state is first created.
		public override function SetupState():void
		{
			Verlocity.layers.Create( "Demo" );
		}

		// Called after the state is spawned.
		public override function BeginState():void
		{
			var demo:Ent_Demo = Verlocity.ents.Create( Ent_Demo );
				demo.SetPos( Verlocity.ScrW / 2, Verlocity.ScrH / 2 );
			demo.Spawn( "Demo" );
			
			Verlocity.achievements.Unlock( "Demo1" );
		}
		
		// Called when the state ends.
		public override function EndState():void
		{
			Verlocity.CleanSlate();
		}

		// The name of the state (used for debugging)
		public override function toString():String 
		{
			return "Demo";
		}
	}
}