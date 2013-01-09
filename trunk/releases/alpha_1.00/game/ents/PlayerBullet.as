package game.ents 
{
	import flash.display.Sprite;
	
	import verlocity.Verlocity;
	import verlocity.ents.DisplayEntity;
	import verlocity.utils.MathUtil;

	public class PlayerBullet extends DisplayEntity
	{
		public override function Construct():void
		{
			display.SetDisplayObject( new Art_PlayerBullet() );

			SetType( "bullet" );
			SetColorRGB( 0, 0, 0 );

			//InitPhysics();
			//SetVelocity( 20, 0 );
			
			RemoveOffScreen( true );
			
			// Scale with music
			if ( Verlocity.analyzer.AverageVolume > Verlocity.analyzer.CutOff )
			{
				scaleX = MathUtil.Clamp( Verlocity.analyzer.AverageVolume * 5, 2, 5 );
				scaleY = MathUtil.Clamp( Verlocity.analyzer.AverageVolume * 5, .5, 5 );
			}

			FadeColors( 0xFF7878, 0xB478D4, Verlocity.analyzer.AverageVolume );
		}

		public override function OnCollide( ent:* ):void
		{
			if ( ent.IsT( "enemy" ) )
			{
				Remove();
				ent.TakeDamage( 100 );
			}
		}
	}
}