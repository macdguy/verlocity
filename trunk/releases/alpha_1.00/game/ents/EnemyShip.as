package game.ents 
{
	import flash.geom.Point;
	import verlocity.particle.ParticleEmitter;

	import verlocity.Verlocity;

	import verlocity.ents.effects.Effect;
	import verlocity.ents.DisplayEntity;

	import verlocity.utils.MathUtil;
	import verlocity.utils.ColorUtil;

	public class EnemyShip extends DisplayEntity
	{
		public override function Construct():void
		{
			SetType( "enemy" );
			SetDefaultHealth( 100 );

			SetColorRGB( 255, 255, 255 );

			phys.SetVelocity( new Point( -5, 0 ) );
			
			RemoveOffScreen( true );
		}
		
		public override function Init():void
		{
			var eff:Effect = Verlocity.ents.CreateEffect( new Effect_EnemySpawn() );
				eff.SetPos( x, y );
			eff.Spawn( Verlocity.gameLayer );
		}
		
		public override function Update():void
		{
			// Move with the harmonics
			if ( Verlocity.analyzer.AverageHarmonic > .4 ) { x -= 7; } else { x -= 2; }
			
			// Change based on beat
			FadeColors( 0x9933CC, 0xFF3300, Verlocity.analyzer.AverageBass );
		}
		
		protected override function OnTakeDamage():void
		{
			var eff:Effect = Verlocity.ents.CreateEffect( new Effect_EnemyDamage() );
				eff.SetPos( x, y );
				eff.SetRotation( MathUtil.Rand( -360, 360 ) );
			eff.Spawn( Verlocity.gameLayer );
		}

		public override function OnCollide( ent:* ):void
		{
			if ( ent == Verlocity.player )
			{
				RemoveAllHealth();
			}
		}
		
		protected override function OnDeath():void
		{
			var eff:Effect = Verlocity.ents.CreateEffect( new Effect_EnemyDeath() );
				eff.SetPos( x, y );
				eff.SetRotation( MathUtil.Rand( -360, 360 ) );
			eff.Spawn( Verlocity.gameLayer );

			var emitter:ParticleEmitter = new ParticleEmitter( x, y, 0, 100 );
				emitter.SetPartColorStart( ColorUtil.RGBtoHEX( 180, 180, 180, 255 ), ColorUtil.RGBtoHEX( 255, 255, 255, 255 ) );
				emitter.SetPartColorEnd( ColorUtil.RandColor( 25, 255, 25, 255, 25, 255 ) );
				emitter.SetPartLifeTime( 10, 30 );
				emitter.SetPartVelocity( -5, 5, -5, 5 );
				emitter.SetPartAcceleration( -10, 10, -10, 10 );
			Verlocity.particles.CreateEmitter( emitter );
			
			Remove();
		}
	}
}