/*
	This file is subject to the terms and conditions defined in
    file 'license.txt', which is part of this source code package.
*/

package VerlocityEngine.base.ents.physics
{
	import VerlocityEngine.base.ents.characters.verBCharPlatforming;
	import VerlocityEngine.base.ents.verBEnt;
	import VerlocityEngine.Verlocity;

	public class verBPlatformPhysicsBoxInteractive extends verBPlatformPhysicsBox
	{
		protected var entCharacter:verBCharPlatforming;

		public override function InternalThink():void
		{
			super.InternalThink();

			if ( entCharacter )
			{
				CharacterCollisionThink();
			}
		}

		private function CharacterCollisionThink():void
		{
			// Check left side
			if ( HitVertical( col.absX, col.absY, colCenterY, -colCenterX -10, bComplexCollisionY, entCharacter.collision ) )
			{
				if ( entCharacter.nVelX > 0 && entCharacter.IsOnGround )
				{
					if ( !bIsRightCollided )
					{
						nVelX = entCharacter.nVelX;
					}
					else
					{
						entCharacter.nVelX = 0;
					}
					entCharacter.bIsPushing = true;
				}
				else
				{
					entCharacter.bIsPushing = false;
				}

				OnLeftCollide();
				OnHitCharacter();
				
				return;
			}

			// Check right side
			if ( HitVertical( col.absX, col.absY, colCenterY, 10 + colCenterX, bComplexCollisionY, entCharacter.collision ) )
			{
				if ( entCharacter.nVelX < 0 && entCharacter.IsOnGround )
				{
					if ( !bIsLeftCollided )
					{
						nVelX = entCharacter.nVelX;
					}
					else
					{
						entCharacter.nVelX = 0;
					}
					entCharacter.bIsPushing = true;
				}
				else
				{
					entCharacter.bIsPushing = false;
				}

				OnRightCollide();
				OnHitCharacter();
				
				return;
			}


			// Check top collision
			if ( HitHortizontal( col.absX, col.absY - col.height - 15, colCenterX, 1, bComplexCollisionX, entCharacter.collision ) )
			{
				// TODO: Fix bug with jumping on top of boxes causing weird ground collision issues.
				entCharacter.IsOnGround = true;
				entCharacter.y--;
				entCharacter.nVelY = 0;

				OnHitCharacter();
			}
		}
		protected function OnHitCharacter():void {}

		public function SetCharacter( ent:verBCharPlatforming ):void { entCharacter = ent; }
		public function GetCharacter():verBCharPlatforming { return entCharacter; }

		public override function Dispose():void
		{
			super.Dispose();
			
			entCharacter = null;
		}
		
	}
}