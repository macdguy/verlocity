package VerlocityEngine.base.ents.characters 
{
	import flash.display.DisplayObject;
	import VerlocityEngine.base.ents.verBExtendedEnt;

	public class verBCharPlatforming extends verBExtendedEnt
	{
		private var objWorld:DisplayObject;

		protected var nJumpForce:Number;

		protected var nAcceleration:Number;
		protected var nMaxSpeed:Number;

		protected var nDefaultGravity:Number;
		protected var nDefaultFriction:Number;
		
		private var bIsOnGround:Boolean;
		private var bIsOnWall:Boolean;
		private var bIsOnLeftWall:Boolean;
		private var bIsOnRightWall:Boolean;
		
		public function SetPlatformer( nSetJumpForce:Number = 8, 
									   nAccel:Number = 1, nSetMaxSpeed:Number = 6,
									   nSetGravity = .6, nSetFriction:Number = .65 ):void
		{
			nJumpForce = nSetJumpForce;

			nAcceleration = nAccel;
			nMaxSpeed = nSetMaxSpeed;

			nDefaultGravity = nSetGravity;
			nDefaultFriction = nSetFriction;
			
			InitPhysics();
			SetFriction( nDefaultFriction, 0 );
		}

		public function SetCollisionWorld( objWorldToCollide:DisplayObject )
		{
			objWorld = objWorldToCollide;
		}
		public function GetCollisionWorld():DisplayObject { return objWorld; }

		
		public function MoveRight():void
		{
			if ( bIsOnGround )
			{
				nVelX += nAcceleration; x++;
			}
			else
			{
				nVelX += nAcceleration / 2;
			}
		}
		
		public function MoveLeft():void
		{
			if ( bIsOnGround )
			{
				nVelX -= nAcceleration; x--;
			}
			else
			{
				nVelX -= nAcceleration / 2;
			}
		}
		
		public function Jump():void
		{
			nVelY = -nJumpForce; y--;
			bIsOnGround = false;
		}
		
		public function get IsOnGround():Boolean { return bIsOnGround; }
		public function get IsOnWall():Boolean { return bIsOnWall; }
		public function get IsOnLeftWall():Boolean { return bIsOnLeftWall; }
		public function get IsOnRightWall():Boolean { return bIsOnRightWall; }

		protected function OnFeetCollide():void {}
		protected function OnHeadCollide():void {}
		protected function OnLeftCollide():void {}
		protected function OnRightCollide():void { }



		public override function InternalThink():void
		{
			super.InternalThink();

			if ( !objWorld ) { return; }

			CollisionThink();
			PhysicsThink();
		}

		private function CollisionThink():void
		{
			// Check ground collision
			if ( objWorld.hitTestPoint( x, y, true ) )
			{
				nVelY = 0;
				bIsOnGround = true;

				OnFeetCollide();
			}
			else
			{
				bIsOnGround = false;
			}
			
			// Prevent morphing
			if ( bIsOnGround )
			{
				while ( objWorld.hitTestPoint( x, y - 1, true ) )
				{
					y--;
				}
				while ( !objWorld.hitTestPoint( x, y + 1, true ) )
				{
					y++;
				}
			}

			// Check head collision
			if ( objWorld.hitTestPoint( x, y - height + 1, true ) )
			{
				nVelY = 0; y += 2;

				OnHeadCollide();
			}
			
			// Check left side
			if ( objWorld.hitTestPoint( x - ( width / 2 ), y - ( height / 2 ), true ) )
			{
				nVelX = 0;
				bIsOnWall = true;
				bIsOnLeftWall = true;
				OnLeftCollide();
				
				// Prevent morphing through
				while ( objWorld.hitTestPoint( x - ( width / 2 ) + .1, y - ( height / 2 ), true ) )
				{
					x += .1;
				}
			}
			else
			{
				bIsOnWall = false;
				bIsOnLeftWall = false;
			}
			
			// Check right side
			if ( objWorld.hitTestPoint( x + ( width / 2 ), y - ( height / 2 ), true ) )
			{
				nVelX = 0;
				bIsOnWall = true;
				bIsOnRightWall = true;
				OnRightCollide();
				
				// Prevent morphing through
				while ( objWorld.hitTestPoint( x + ( width / 2 ) - .1, y - ( height / 2 ), true ) )
				{
					x -= .1;
				}
			}
			else
			{
				bIsOnWall = false;
				bIsOnRightWall = false;
			}
		}
		
		private function PhysicsThink():void
		{
			x = x + Math.sin( .01745329 * ( rotation + 90 ) ) * nVelX;
			y = y - Math.cos( .01745329 * ( rotation + 90 ) ) * nVelY;

			if ( Math.abs( nVelX ) <= .05 )
			{
				nVelX = 0;
			}
			
			if ( !bIsOnGround )
			{
				if ( nVelY < 20 )
				{
					nVelY += nDefaultGravity;
				}
			}
		}
		
		public override function Dispose():void
		{
			super.Dispose();

			objWorld = null;

			nJumpForce = NaN;

			nAcceleration = NaN;
			nMaxSpeed = NaN;

			nDefaultGravity = NaN;
			nDefaultFriction = NaN;
			
			bIsOnGround = false;
			bIsOnWall = false;
			bIsOnLeftWall = false;
			bIsOnRightWall = false;
		}
		
	}
}