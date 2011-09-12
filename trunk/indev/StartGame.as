package  
{
	import flash.display.MovieClip;
	import flash.display.Stage;

	import VerlocityEngine.Verlocity;

	import Game.GameplayManager;
	import Game.states.State_Demo;

	public final class StartGame extends MovieClip
	{
		public function StartGame():void
		{
			/*
				Once we create an instance of the engine, we can access its components staticlly.

				If you want complete assurance, do checks on each component.
				Ex. if ( Verlocity.ents ) { ... do Verlocity.ents logic ... }
			*/
			var VerlocityEngine:Verlocity = new Verlocity( stage );

			// Make sure we check if Verlocity is valid before starting the game.
			if ( Verlocity.IsValid() )
			{
				var Gameplay:GameplayManager = new GameplayManager();

				Verlocity.state.Set( new State_Demo() );
			}
		}
	}
}