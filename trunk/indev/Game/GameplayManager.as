package Game 
{
	import VerlocityEngine.Verlocity;

	public class GameplayManager 
	{
		public function GameplayManager() 
		{
			// Put all your fancy gameplay stuff here.
			// Mostly anything that runs regardless of states (achievements, console vars, global variables, etc.)
			
			// Example achievements
			if ( Verlocity.achievements )
			{
				Verlocity.achievements.Register( "Demo1", "Demo-tastic", "Begin Demo", 1 );
				Verlocity.achievements.Register( "Demo2", "Demoman", "Restart Demo Twice", 2 );
			}
			
			// Example pause menu item
			if ( Verlocity.pause )
			{
				Verlocity.pause.AddPauseMenuItem( "RESTART", function():void
				{
					Verlocity.state.Restart();
					Verlocity.achievements.Increase( "Demo2" );
				} );
			}
			
			// Example convar
			if ( Verlocity.console )
			{
				Verlocity.console.Register( "hello", function():void
				{
					Verlocity.console.Output( "hello world!" );
				}, "[demo only] Prints hello world!" );
			}
		}
	}
}