package VerlocityEngine.base.ents.characters 
{
	import flash.geom.Point;
	import flash.display.DisplayObject;
	import VerlocityEngine.base.ents.verBExtendedEnt;
	import VerlocityEngine.util.angleHelper;
	import VerlocityEngine.util.mathHelper;
	
	import VerlocityEngine.base.ents.verBSprCollisionBox;
	import VerlocityEngine.VerlocitySettings;

	public class verBCharPlatforming extends verBExtendedEnt
	{
		private var objWorld:DisplayObject;

		protected var nJumpForce:Number;
		protected var nFootHeight:Number;

		protected var nLastVelX:Number;
		protected var nLastVelY:Number;

		protected var nAcceleration:Number;
		protected var nAirAcceleration:Number;
		protected var nMaxSpeed:Number;

		protected var nDefaultGravity:Number;
		protected var nDefaultFriction:Number;
		
		private var bIsOnGround:Boolean;
		private var bIsOnLeftWall:Boolean;
		private var bIsOnRightWall:Boolean;
		
		protected var col:verBSprCollisionBox;
		protected var colCenterX:Number;
		protected var colCenterY:Number;
		
		private var iDebugTimer:int;
		
		public function SetPlatformer( nSetJumpForce:Number = 8, nSetFootHeight:Number = 12,
									   nAccel:Number = 1, nAirAccel:Number = 1,
									   nSetMaxSpeed:Number = 6, nSetGravity = .6, nSetFriction:Number = .65 ):void
		{
			nJumpForce = nSetJumpForce;
			nFootHeight = nSetFootHeight;

			nAcceleration = nAccel;
			nAirAcceleration = nAirAccel;
			nMaxSpeed = nSetMaxSpeed;

			nDefaultGravity = nSetGravity;
			nDefaultFriction = nSetFriction;
			
			InitPhysics();
			SetFriction( nDefaultFriction, 0 );
			
			UpdateCollisionInfo();
		}

		public function SetCollisionWorld( objWorldToCollide:DisplayObject )
		{
			objWorld = objWorldToCollide;
		}
		public function GetCollisionWorld():DisplayObject { return objWorld; }

		
		public function MoveRight():void
		{
			if ( bIsOnRightWall ) { return; }

			scaleX = 1;

			if ( bIsOnGround )
			{
				nVelX += nAcceleration;
			}
			else
			{
				nVelX += nAirAcceleration;
			}
		}
		
		public function MoveLeft():void
		{
			if ( bIsOnLeftWall ) { return; }

			scaleX = -1;

			if ( bIsOnGround )
			{
				nVelX -= nAcceleration;
			}
			else
			{
				nVelX -= nAirAcceleration;
			}
		}
		
		public function Jump():void
		{
			nVelY = -nJumpForce; y--;
			bIsOnGround = false;
		}
		
		public function IsOnGround():Boolean { return bIsOnGround; }
		public function IsOnWall():Boolean { return bIsOnLeftWall || bIsOnRightWall; }
		public function IsOnLeftWall():Boolean { return bIsOnLeftWall; }
		public function IsOnRightWall():Boolean { return bIsOnRightWall; }

		protected function OnFeetCollide():void {}
		protected function OnHeadCollide():void {}
		protected function OnLeftCollide():void {}
		protected function OnRightCollide():void {}



		public override function InternalThink():void
		{
			super.InternalThink();

			if ( !objWorld ) { return; }

			CollisionThink();
			PhysicsThink();

			if ( VerlocitySettings.DEBUG )
			{
				if ( iDebugTimer > 10 )
				{
					Clear();
					iDebugTimer = 0;
				}
				else
				{
					iDebugTimer++;
				}
			}
		}
		
		public function UpdateCollisionInfo():void
		{	
			col = collision as verBSprCollisionBox;
			colCenterX = col.width / 2;
			colCenterY = col.height / 2;
		}

		private function CollisionThink():void
		{
			if ( !col ) { return; }
	
			// Check ground collision
			if ( Hit3( col.absX, col.absY, colCenterX ) )
			{
				nLastVelY = nVelY;
				nVelY = -1; nVelY = 0;

				bIsOnGround = true;
				
				// Keep on the top of the platform
				while ( Hit3( col.absX, col.absY, colCenterX, NaN, -2 ) ) { y--; }

				OnFeetCollide();
			}
			else
			{
				bIsOnGround = false;
			}

			// Check head collision
			if ( Hit3( col.absX, col.absY - col.height, colCenterX, NaN, -1 ) )
			{
				nLastVelY = nVelY;

				nVelY = 1; nVelY = 0;
				y += 2;

				OnHeadCollide();
			}
			
			// Check left side
			if ( Hit( col.absX - col.width + 2, col.absY - nFootHeight ) )
			{
				nLastVelX = nVelX;
				nVelX = 1; nVelX = 0;

				bIsOnLeftWall = true;
				OnLeftCollide();

				// Prevent morphing through
				while ( Hit( col.absX - col.width + 5, col.absY - nFootHeight ) ) { x += .1; }
			}
			else
			{
				bIsOnLeftWall = false;
			}
			
			// Check right side
			if ( Hit( col.absX + col.width - 2, col.absY - nFootHeight ) )
			{
				nLastVelX = nVelX;
				nVelX = -1; nVelX = 0;

				bIsOnRightWall = true;
				OnRightCollide();

				// Prevent morphing through
				while ( Hit( col.absX + col.width - 5, col.absY - nFootHeight ) ) { x -= .1; }
			}
			else
			{
				bIsOnRightWall = false;
			}
		}
		
		private function PhysicsThink():void
		{
			x += Math.sin( .01745329 * ( rotation + 90 ) ) * nVelX;
			y -= Math.cos( .01745329 * ( rotation + 90 ) ) * nVelY;

			if ( Math.abs( nVelX ) <= .05 ) { nVelX = 0; }
			if ( Math.abs( nVelY ) <= .05 ) { nVelY = 0; }

			if ( !bIsOnGround )
			{
				if ( nVelY < 10 )
				{
					nVelY += nDefaultGravity;
				}
				rotation -= rotation * .05;
			}
			else
			{
				var iRot:int = GetGroundAngle() + 90;
				if ( Math.abs( iRot ) < 35 )
				{
					rotation -= mathHelper.Ease( rotation, iRot, 10 );
				}
			}
		}

		private function GetGroundAngle():int
		{
			var nCalc1:Number = 0;
			var nCalc2:Number = 0;
			var nCalc3:Number = 0;

			var nRot:Number = rotation;

			for ( var i:int = 0; i < 360; i += 5 )
			{
				var nPointX:Number = col.absX + Math.sin( .01745329 * ( nRot + i ) ) * 5;
				var nPointY:Number = col.absY - Math.cos( .01745329 * ( nRot + i ) ) * 5;

				if ( objWorld.hitTestPoint( nPointX, nPointY, true ) )
				{
					nCalc1 += nPointX;
					nCalc2 += nPointY;
					++nCalc3;
				}
			}

			var nAngX:Number = 0;
			var nAngY:Number = 0;

			if ( nCalc3 > 0 )
			{
				nAngX = nCalc1 / nCalc3;
				nAngY = nCalc2 / nCalc3;
			}

			return Math.round( angleHelper.Rotation( nAngX, nAngY, col.absX, col.absY ) );
		}
		
		protected function Hit( x:Number, y:Number, hitObject:DisplayObject = null ):Boolean
		{
			// default to world
			if ( !hitObject ) { hitObject = objWorld; }

			if ( VerlocitySettings.DEBUG )
			{
				var uiTestColor:uint = 0xFF0000;
				if ( hitObject.hitTestPoint( x, y, true ) )
				{
					uiTestColor = 0x00FF00;
				}

				var p:Point = globalToLocal( new Point( x, y ) );

				graphics.beginFill( uiTestColor );
					graphics.drawRect( p.x - 1, p.y - 1, 2, 2 );
				graphics.endFill();
			}

			return hitObject.hitTestPoint( x, y, true );
		}
		
		private function Hit3( x:Number, y:Number, xOffset:Number = NaN, yOffset:Number = NaN, iDirection:int = 1 ):Boolean
		{
			// Horizontal check
			// left, middle, right
			if ( !isNaN( xOffset ) )
			{
				return Hit( x, y + iDirection ) || Hit( x - xOffset, y + iDirection ) || Hit( x + xOffset, y + iDirection );
			}
			
			// Vertical check
			// top, middle, bottom
			if ( !isNaN( yOffset ) )
			{
				return Hit( x + iDirection, y - yOffset ) || Hit( x + iDirection, y ) || Hit( x + iDirection, y + yOffset );
			}
			
			return false;
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
			bIsOnLeftWall = false;
			bIsOnRightWall = false;
		}
		
	}
}