/*
	This file is subject to the terms and conditions defined in
    file 'license.txt', which is part of this source code package.
*/

package VerlocityEngine.base.ents.npcs
{
	import flash.display.DisplayObject;
	import VerlocityEngine.base.ents.characters.verBCharPlatforming;
	import VerlocityEngine.base.ents.verBEnt;
	
	import VerlocityEngine.util.mathHelper;

	public class verBNPCPlatforming extends verBCharPlatforming
	{
		protected var bIgnoreEdges:Boolean;
		protected var bIsMoving:Boolean = true;
		protected var bMoveWhileOffScreen:Boolean;

		protected var entCharacter:verBCharPlatforming;

		protected var bFollow:Boolean;
		protected var bAutoJump:Boolean;
		protected var iMinFollowDist:int;


		public override function InternalThink():void
		{
			if ( !bMoveWhileOffScreen && !IsOnScreen() ) { return; }
			
			super.InternalThink();

			AIThink();
			
			if ( bIsMoving )
			{
				MovementThink();
				CharacterCollisionThink();
			}
		}

		private function MovementThink():void
		{
			if ( FacingRight ) 
			{
				MoveRight();
			}
			
			if ( FacingLeft )
			{
				MoveLeft();
			}
		}
		
		protected function AIThink():void
		{
			if ( IsOnLeftWall ) { FaceRight(); }
			if ( IsOnRightWall ) { FaceLeft(); }
			
			// Follow character.
			if ( entCharacter && bFollow )
			{
				if ( mathHelper.Dist1D( entCharacter.absX, absX ) < iMinFollowDist )
				{
					var nDirY:Number = absY - entCharacter.absY;
					var nDirX:Number = entCharacter.absX - absX;
					
					if ( nDirY < 20 )
					{
						if ( nDirX > 0 )
						{
							FaceRight();
						}
						else
						{
							FaceLeft();
						}
					}
						
					if ( bAutoJump )
					{
						if ( mathHelper.IsBetween( nDirY, 10, iMinFollowDist ) && IsOnWall )
						{
							Jump();
						}
					}
				}
			}
		}
		
		private function CharacterCollisionThink():void
		{
			if ( !entCharacter ) { return; }

			// Check left side
			if ( Hit( col.absX - col.width + 2, col.absY - colCenterY, entCharacter ) )
			{
				OnHitCharacter();

				nLastVelX = nVelX;
				nVelX = 0;
			}
				
			// Check right side
			if ( Hit( col.absX + col.width - 2, col.absY - colCenterY, entCharacter ) )
			{
				OnHitCharacter();

				nLastVelX = nVelX;
				nVelX = 0;
			}
		}
		protected function OnHitCharacter():void {}

		public function SetCharacter( ent:verBCharPlatforming ):void { entCharacter = ent; }
		public function GetCharacter():verBCharPlatforming { return entCharacter; }

		public function SetFollow( bSetFollow:Boolean, iSetMinFollowDist:int, bSetAutoJump:Boolean ):void
		{
			bFollow = bSetFollow;
			iMinFollowDist = iSetMinFollowDist;
			bAutoJump = bSetAutoJump;
		}
		

		public override function Dispose():void
		{
			super.Dispose();
			
			entCharacter = null;
		}
	}
}