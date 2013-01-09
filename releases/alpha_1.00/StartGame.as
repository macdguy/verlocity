package
{
	import flash.display.MovieClip;
	import flash.geom.Point;

	import verlocity.Verlocity;
	import verlocity.core.Game;

	import game.DemoGame;
	import game.Settings;
	import game.states.State_Demo;

	public class StartGame extends MovieClip
	{
		/*
		 * The width/height of the application.
		 * The IDE will overwrite this, this is mainly for Flex users.
		*/
		[SWF(width = "1280", height = "720" )];

		public function StartGame():void
		{
			/**
			 * Create a game instance.
			 */
			var myGame:Game = new Game( DemoGame, new State_Demo(), "Demo", "Macklin Guy", "This is just a demo game" );

			/**
			 * Create an instance of Verlocity.
			 * Once created, you can access the components statically.
			 * 
			 * To check if a component is valid, use Verlocity.IsValid( component ).
			 * ex. if ( Verlocity.IsValid( Verlocity.ents ) ) { etc...
			 */
			new Verlocity( stage, new Settings(), myGame );
		}
	}
}