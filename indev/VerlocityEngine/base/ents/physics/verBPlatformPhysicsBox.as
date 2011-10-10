/*
	This file is subject to the terms and conditions defined in
    file 'license.txt', which is part of this source code package.
*/

package VerlocityEngine.base.ents.physics
{
	import VerlocityEngine.util.mathHelper;
	import VerlocityEngine.util.angleHelper;

	public class verBPlatformPhysicsBox extends verBDynamicCollider
	{
		protected var nLastVelX:Number;
		protected var nLastVelY:Number;

		protected var nDefaultGravity:Number;
		protected var nDefaultFriction:Number;
		
		public function verBPlatformPhysicsBox():void
		{
			SetPhysicsProperties();
		}

		public function SetPhysicsProperties( nSetGravity = .6, nSetFriction:Number = .65 ):void
		{
			nDefaultGravity = nSetGravity;
			nDefaultFriction = nSetFriction;

			InitPhysics();
			SetFriction( nDefaultFriction, 0 );
		}

		public override function InternalThink():void
		{
			super.InternalThink();
			
			if ( !bPhysicsEnabled ) { return; }

			PhysicsThink();
			GravityThink();
		}

		internal override function CollisionThink():void
		{
			super.CollisionThink();
			
			if ( IsBottomCollided )
			{
				nLastVelY = nVelY;
				nVelY = 0;
			}
			
			if ( IsTopCollided )
			{
				y += 2;
	
				nLastVelY = nVelY;
				nVelY = 0;
			}
			
			if ( IsLeftCollided )
			{
				nLastVelX = nVelX;
				nVelX = 0;
			}
			
			if ( IsRightCollided )
			{
				nLastVelX = nVelX;
				nVelX = 0;
			}
		}
		
		private function GravityThink():void
		{
			if ( IsBottomCollided || isNaN( nDefaultGravity ) || nDefaultGravity == 0 ) { return; }

			if ( nVelY < 8 )
			{
				nVelY += nDefaultGravity;
			}
		}
		
		private function PhysicsThink():void
		{
			x += Math.sin( .01745329 * ( rotation + 90 ) ) * nVelX;
			y -= Math.cos( .01745329 * ( rotation + 90 ) ) * nVelY;

			if ( Math.abs( nVelX ) <= .05 ) { nVelX = 0; }
			if ( Math.abs( nVelY ) <= .05 ) { nVelY = 0; }

			if ( !IsBottomCollided )
			{
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
		
		public override function Dispose():void
		{
			super.Dispose();
			
			nLastVelX = NaN;
			nLastVelY = NaN;
			
			nDefaultFriction = NaN;
			nDefaultGravity = NaN;			
		}
		
	}
}