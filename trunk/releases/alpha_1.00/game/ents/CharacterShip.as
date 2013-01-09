package game.ents
{
	import flash.display.Sprite;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;

	import verlocity.Verlocity;
	import verlocity.ents.DisplayEntity;
	import verlocity.utils.AngleUtil;
	import verlocity.utils.MathUtil;
	
	import verlocity.ents.DisplayEntity;

	/*import game.AssetHolder;	
	import verlocity_plugins.starling.StarDisplayEntity;*/

	public class CharacterShip extends DisplayEntity
	{
		private var iSpeed:int;
		public var nVX:Number;
		public var nVY:Number;
		private var nMod:Number;
		
		public override function Construct():void
		{
			display.SetDisplayObject( new Art_CharacterShip() );
			//display.SetTexture( AssetHolder.MatGrassSprite );

			SetFilters( new DropShadowFilter() );

			SetType( "character" );
			SetBounds( Verlocity.display.GetScreenRect(), 10 );

			iSpeed = 10;
		}

		public override function Init():void
		{
			nVX = x; nVY = y; nVX = 1; nVY = 1; nVX = -1; nVY = -1;
		}

		public override function Update():void
		{
			Movement();
			Physics();
		}

		private function Movement():void
		{
			if ( Verlocity.input.KeyIsDown( "LEFT" ) )
			{
				if ( !IsOnLeftBoundary() )
				{
					nVX = -1;
				}
			}
			if ( Verlocity.input.KeyIsDown( "RIGHT" ) )
			{
				if ( !IsOnRightBoundary() )
				{
					nVX = 1;
				}
			}
			if ( Verlocity.input.KeyIsDown( "UP" ) )
			{
				if ( !IsOnTopBoundary() )
				{
					if ( nVY > -1 ) { nVY -= .35; }
				}
			}
			if ( Verlocity.input.KeyIsDown( "DOWN" ) )
			{
				if ( !IsOnBottomBoundary() )
				{
					if ( nVY < 1 ) { nVY += .35; }
				}
			}

			if ( Verlocity.input.KeyIsDown( "SHOOT" ) ) { Shoot(); }
			if ( Verlocity.input.KeyIsDown( "BOMB" ) ) { ShootBomb(); }
		}

		private function Physics():void
		{
			// mod for moving backwards faster
			nMod = 1;

			// decrease over time
            if ( nVX != 0 && nVY != 0 )
            {
               nVX *= 0.8;
			   nVY *= 0.8;
			}
			
			// acceleration
			x += nVX * ( iSpeed * nMod );
			y += nVY * iSpeed;

			// rotation
			rotation = nVY * 8;
		}

		private var iShootDelay:int;
		private function Shoot():void
		{
			if ( iShootDelay > Verlocity.CurTime() ) { return; }
			
			EmitSound( Verlocity.ContentFolder + "shoot.mp3", .1 );

			var bullet:DisplayEntity = Verlocity.ents.Create( PlayerBullet );
				bullet.SetPos( x + 50, y );

				bullet.EnablePhysics( true );
				bullet.phys.SetVelocity( new Point( 30, 0 ) );
			bullet.Spawn( Verlocity.gameLayer );

			iShootDelay = Verlocity.CurTime() + 150;
		}
		
		private var iBombDelay:int;
		private function ShootBomb():void
		{
			if ( iBombDelay < Verlocity.CurTime() )
			{
				var bomb:PlayerBomb = Verlocity.ents.Create( PlayerBomb );
					bomb.SetPos( x, y );
				bomb.Spawn( "Gameplay" );
				
				iBombDelay = Verlocity.CurTime() + 5000;			
			}			
		}
	}
}