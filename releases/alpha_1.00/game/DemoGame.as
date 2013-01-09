package game 
{
	import flash.display.Stage;

	import verlocity.Verlocity;
	import verlocity.logic.DelayedFunction;

	import game.effects.SFX_BeatBorder;

	public class DemoGame extends Object
	{
		public function DemoGame():void
		{
			Verlocity.achievements.Register( "Splash", "Splash Power", "Start Verlocity" );
			Verlocity.achievements.Unlock( "Splash" );

			new DelayedFunction( 5000, function() {
				Verlocity.Trace( "Delayed function test was a success!" );
			} );
			
			Verlocity.ents.CreateScreenEffect( new SFX_BeatBorder(), true, true );
		}
	}
}