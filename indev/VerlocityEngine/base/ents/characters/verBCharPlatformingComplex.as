/*
	This file is subject to the terms and conditions defined in
    file 'license.txt', which is part of this source code package.
*/

package VerlocityEngine.base.ents.characters
{
	import flash.geom.Point;
	import flash.display.DisplayObject;
	import VerlocityEngine.base.ents.verBExtendedEnt;
	import VerlocityEngine.util.angleHelper;
	import VerlocityEngine.util.mathHelper;
	
	import VerlocityEngine.base.ents.verBSprCollisionBox;
	import VerlocityEngine.VerlocitySettings;

	public class verBCharPlatformingComplex extends verBCharPlatforming
	{
		internal override function PreventPhasing():void
		{
			// Ground phasing
			while ( HitHortizontal( col.absX, col.absY, colCenterX, -2 ) &&
					!HitVertical( col.absX, col.absY, colCenterY, -colCenterX -8 ) && // check right and left
					!HitVertical( col.absX, col.absY, colCenterY, 8 + colCenterX ) ) { y--; }

			// Wall phasing (left)
			while ( HitVertical( col.absX, col.absY, colCenterY, -colCenterX -2 ) ) { x += .1; }			
			
			// Wall phasing (right)
			while ( HitVertical( col.absX, col.absY, colCenterY, 2 + colCenterX ) ) { x -= .1; }
		}

		internal override function CollisionThink():void
		{
			if ( !col ) { return; }
	
			// Check ground collision
			if ( HitHortizontal( col.absX, col.absY, colCenterX ) )
			{
				nLastVelY = nVelY;
				nVelY = -1; nVelY = 0;

				bIsOnGround = true;
				bIsJumping = false;

				OnFeetCollide();
			}
			else
			{
				bIsOnGround = false;
			}

			if ( Math.abs( nVelY ) > 0 )
			{
				// Check head collision
				if ( HitHortizontal( col.absX, col.absY - col.height, colCenterX, -1 ) )
				{
					nLastVelY = nVelY;

					nVelY = 1; nVelY = 0;
					y += 2;

					OnHeadCollide();
				}
			}
			
			// Check left side
			if ( HitVertical( col.absX, col.absY, colCenterY, -colCenterX -5 ) )
			{
				nLastVelX = nVelX;
				nVelX = 1; nVelX = 0;

				bIsOnLeftWall = true;
				OnLeftCollide();
			}
			else
			{
				bIsOnLeftWall = false;
			}
				
			// Check right side
			if ( HitVertical( col.absX, col.absY, colCenterY, 5 + colCenterX ) )
			{
				nLastVelX = nVelX;
				nVelX = -1; nVelX = 0;

				bIsOnRightWall = true;
				OnRightCollide();
			}
			else
			{
				bIsOnRightWall = false;
			}
		}
		
		private function HitHortizontal( x:Number, y:Number, nOffset:Number = NaN, iDir:int = 1 ):Boolean
		{
			return Hit( x, y + iDir ) ||
				   Hit( x - ( nOffset / 2 ), y + iDir ) ||
				   Hit( x - nOffset, y + iDir ) ||
				   Hit( x + ( nOffset / 2 ), y + iDir ) ||
				   Hit( x + nOffset, y + iDir );
		}
		
		private function HitVertical( x:Number, y:Number, nOffset:Number = NaN, iDir:int = 1 ):Boolean
		{
			return Hit( x + iDir, y - ( nOffset / 2 ) ) ||
				   Hit( x + iDir, y - nOffset ) ||
				   Hit( x + iDir, y - nOffset - ( nOffset / 2 ) );
		}
		
	}
}