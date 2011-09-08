package VerlocityEngine.base.ents.spawners
{
	import VerlocityEngine.base.ents.verBEnt;
	import VerlocityEngine.helpers.ElapsedTrigger;
	import VerlocityEngine.Verlocity;

	public class verBFrameSpawner extends verBEnt
	{
		private var etTrigger:ElapsedTrigger = new ElapsedTrigger();

		public function verBFrameSpawner():void { stop(); }
		
		public override function Think():void 
		{
			if ( etTrigger.IsTriggeredOnce() )
			{
				if ( currentFrame == totalFrames )
				{
					gotoAndStop( 1 );
				}
				else
				{
					gotoAndStop( currentFrame + 1 );
				}

				Verlocity.ents.RegisterContained( this );
			}
		}
		
		public override function Spawn( layer:* ):void
		{
			super.Spawn( layer );

			gotoAndStop( 1 );
			Verlocity.ents.RegisterContained( this );
		}
		
		public function WaitNextFrame( iDelay:int ):void
		{
			etTrigger.Reset( iDelay );
		}
	}
}