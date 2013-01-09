package game.ents 
{
	import verlocity.Verlocity;
	import verlocity.ents.DisplayEntity;
	import verlocity.ents.effects.Effect;

	import verlocity.utils.MathUtil;

	public class PlayerBomb extends DisplayEntity
	{
		public override function Construct():void
		{
			display.SetDisplayObject( new Art_PlayerBomb() );

			SetType( "bullet" );
			SetScale( MathUtil.Rand( 2, 3 ) );
		}
		
		public override function Init():void
		{
			var eff:Effect = Verlocity.ents.CreateEffect( new Effect_BombShockwave() );
				eff.SetPos( x, y );
			eff.Spawn( Verlocity.gameLayer );
		}

		public override function Update():void
		{
			if ( GetScale() < 80 )
			{
				SetScale( GetScale() + 2 );
				return;
			}

			FadeRemove();
		}
		
		public override function OnCollide( ent:* ):void
		{
			if ( ent.IsT( "enemy" ) )
			{
				ent.TakeDamage( 150 );
			}
		}
	}
}