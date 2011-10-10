/*
	This file is subject to the terms and conditions defined in
    file 'license.txt', which is part of this source code package.
*/

package VerlocityEngine.base.ents.characters 
{
	import flash.display.MovieClip;
	import VerlocityEngine.base.ents.physics.verBPlatformPhysicsBox;

	public class verBCharPlatforming extends verBPlatformPhysicsBox
	{
		protected var nJumpForce:Number;

		protected var nAcceleration:Number;
		protected var nAirAcceleration:Number;
		protected var nMaxSpeed:Number;

		internal var bIsJumping:Boolean;
		public var bIsPushing:Boolean;
		
		protected var CurrentAnimation:MovieClip;
		protected var CurrentAnimClass:Class;
		
		public function SetPlatformer( nSetJumpForce:Number = 8, 
									   nAccel:Number = 1, nAirAccel:Number = 1, 
									   nSetMaxSpeed:Number = 6,
									   nSetGravity = .6, nSetFriction:Number = .65 ):void
		{
			nJumpForce = nSetJumpForce;

			nAcceleration = nAccel;
			nAirAcceleration = nAirAccel;
			nMaxSpeed = nSetMaxSpeed;

			SetPhysicsProperties( nSetGravity, nSetFriction );
		}

		
		public function MoveRight():void
		{
			if ( IsOnRightWall ) { return; }

			FaceRight();

			if ( IsOnGround )
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
			if ( IsOnLeftWall ) { return; }

			FaceLeft();

			if ( IsOnGround )
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

			bIsBottomCollided = false;
			bIsJumping = true;
		}
		
		public function get IsOnGround():Boolean { return bIsBottomCollided; }
		public function set IsOnGround( bBottom:Boolean ):void { bIsBottomCollided = bBottom; }

		public function get IsJumping():Boolean { return bIsJumping; }
		public function get IsPushing():Boolean { return bIsPushing; }
		public function get IsOnWall():Boolean { return bIsLeftCollided || bIsRightCollided; }
		public function get IsOnLeftWall():Boolean { return bIsLeftCollided; }
		public function get IsOnRightWall():Boolean { return bIsRightCollided; }
		public function get FacingRight():Boolean { return scaleX > 0; }
		public function get FacingLeft():Boolean { return scaleX < 0; }

		public override function InternalThink():void
		{
			super.InternalThink();

			if ( IsOnGround )
			{
				bIsJumping = false;
			}
		}

		public function SetAnimation( animClass:Class ):void
		{
			if ( CurrentAnimClass && ( CurrentAnimClass == animClass ) ) { return; }

			// TODO clean this up, minimize memory usage
			CurrentAnimClass = animClass;
			
			// Remove last
			if ( CurrentAnimation )
			{
				removeChild( CurrentAnimation );
				CurrentAnimation = null;
			}

			// Add animation
			CurrentAnimation = new animClass();
			addChild( CurrentAnimation );
		}

		protected function FaceRight():void
		{
			scaleX = 1;
		}
		
		protected function FaceLeft():void
		{
			scaleX = -1;
		}
		
		public override function Dispose():void
		{
			super.Dispose();

			nJumpForce = NaN;

			nAcceleration = NaN;
			nMaxSpeed = NaN;
		}
		
	}
}