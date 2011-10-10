/*
	This file is subject to the terms and conditions defined in
    file 'license.txt', which is part of this source code package.
*/

package VerlocityEngine.base.ents.physics 
{
	import flash.geom.Point;
	import flash.display.DisplayObject;
	import VerlocityEngine.base.ents.verBExtendedEnt;
	import VerlocityEngine.base.ents.verBSprCollisionBox;
	import VerlocityEngine.VerlocitySettings;
	import VerlocityEngine.Verlocity;

	public class verBDynamicCollider extends verBExtendedEnt
	{
		protected var objWorld:DisplayObject;

		protected var bIsTopCollided:Boolean;
		protected var bIsBottomCollided:Boolean;
		protected var bIsLeftCollided:Boolean;
		protected var bIsRightCollided:Boolean;

		protected var bIsAsleep:Boolean;		
		protected var bIsPhasing:Boolean;
		protected var bComplexCollisionX:Boolean;
		protected var bComplexCollisionY:Boolean;
		
		protected var col:verBSprCollisionBox;
		protected var colCenterX:Number;
		protected var colCenterY:Number;
		
		private var iDebugTimer:int;

		public function SetCollisionWorld( objWorldToCollide:DisplayObject )
		{
			objWorld = objWorldToCollide;
			UpdateCollisionInfo();
		}
		public function GetCollisionWorld():DisplayObject { return objWorld; }
		
		public function SetCollisionComplexity( bComplexX:Boolean, bComplexY:Boolean )
		{
			bComplexCollisionX = bComplexX;
			bComplexCollisionY = bComplexY;
		}

		public function get IsAsleep():Boolean { return bIsAsleep; }
		public function get IsTopCollided():Boolean { return bIsTopCollided; }
		public function get IsBottomCollided():Boolean { return bIsBottomCollided; }
		public function get IsLeftCollided():Boolean { return bIsLeftCollided; }
		public function get IsRightCollided():Boolean { return bIsRightCollided; }

		protected function OnTopCollide():void {}
		protected function OnBottomCollide():void {}
		protected function OnLeftCollide():void {}
		protected function OnRightCollide():void {}


		public override function InternalThink():void
		{
			super.InternalThink();

			if ( !objWorld ) { return; }

			// Don't update when we don't need to.
			if ( ShouldSleep() )
			{
				bIsAsleep = true;
			}
			else
			{
				bIsAsleep = false;
			}
			

			if ( !IsAsleep )
			{
				CollisionThink();
			}

			PreventPhasing();


			if ( VerlocitySettings.COLLISION_DEBUG )
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
			
			if ( !col ) { return; }

			colCenterX = col.width / 2;
			colCenterY = col.height / 2;
		}
		
		private function ShouldSleep():Boolean
		{
			return Math.abs( nVelX ) <= 0 && Math.abs( nVelY ) <= 0 && !Verlocity.camera.IsEasingY;
		}

		internal function PreventPhasing():void
		{
			if ( !col ) { return; }
			

			// Ground phasing
			while ( HitHortizontal( col.absX, col.absY, colCenterX, -2, bComplexCollisionX ) &&
					!HitVertical( col.absX, col.absY, colCenterY, -colCenterX -3, bComplexCollisionY ) && // check right and left
					!HitVertical( col.absX, col.absY, colCenterY, 3 + colCenterX, bComplexCollisionY ) )
			{
				bIsPhasing = true;
				y--;
			}

			// Wall phasing (left)
			while ( HitVertical( col.absX, col.absY, colCenterY, -colCenterX + 1, bComplexCollisionY ) )
			{
				bIsPhasing = true;
				x += .1;
			}			
			
			// Wall phasing (right)
			while ( HitVertical( col.absX, col.absY, colCenterY, 1 - colCenterX, bComplexCollisionY ) )
			{
				bIsPhasing = true;
				x -= .1;
			}
			
			bIsPhasing = false;
		}

		internal function CollisionThink():void
		{
			if ( !col ) { return; }

			// Check bottom collision
			if ( HitHortizontal( col.absX, col.absY, colCenterX, 1, bComplexCollisionX ) )
			{
				bIsBottomCollided = true;

				OnBottomCollide();
			}
			else
			{
				bIsBottomCollided = false;
			}
	

			// Check top collision
			if ( Math.abs( nVelY ) > 0 )
			{
				if ( HitHortizontal( col.absX, col.absY - col.height, colCenterX, -1, bComplexCollisionX ) )
				{
					bIsTopCollided = true;

					OnTopCollide();
				}
				else
				{
					bIsTopCollided = false;
				}
			}
			
			// Check left side
			if ( HitVertical( col.absX, col.absY, colCenterY, -colCenterX -1, bComplexCollisionY ) )
			{
				bIsLeftCollided = true;
				OnLeftCollide();
			}
			else
			{
				bIsLeftCollided = false;
			}
				
			// Check right side
			if ( HitVertical( col.absX, col.absY, colCenterY, 1 + colCenterX, bComplexCollisionY ) )
			{
				bIsRightCollided = true;
				OnRightCollide();
			}
			else
			{
				bIsRightCollided = false;
			}
		}
		
		protected function Hit( x:Number, y:Number, hitObject:DisplayObject = null ):Boolean
		{
			// default to world
			if ( !hitObject ) { hitObject = objWorld; }

			if ( VerlocitySettings.COLLISION_DEBUG )
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

		protected function HitHortizontal( x:Number, y:Number, nOffset:Number = NaN, iDir:int = 1, bComplex:Boolean = false, hitObject:DisplayObject = null ):Boolean
		{
			// 5 point test
			if ( bComplex )
			{
				return Hit( x, y + iDir, hitObject ) ||
					   Hit( x - ( nOffset / 2 ), y + iDir, hitObject ) ||
					   Hit( x - nOffset + 5, y + iDir, hitObject ) ||
					   Hit( x + ( nOffset / 2 ), y + iDir, hitObject ) ||
					   Hit( x + nOffset - 5, y + iDir, hitObject );
			}
			
			// 3 point test
			return Hit( x, y + iDir, hitObject ) ||
				   Hit( x - nOffset, y + iDir, hitObject ) ||
				   Hit( x + nOffset, y + iDir, hitObject );
		}
		
		protected function HitVertical( x:Number, y:Number, nOffset:Number = NaN, iDir:int = 1, bComplex:Boolean = false, hitObject:DisplayObject = null ):Boolean
		{
			// 3 point test
			if ( bComplex )
			{
				return Hit( x + iDir, y - ( nOffset / 2 ), hitObject ) ||
					   Hit( x + iDir, y - nOffset, hitObject ) ||
					   Hit( x + iDir, y - nOffset - ( nOffset / 2 ), hitObject );
			}
			
			// 1 point test
			return Hit( x + iDir, y - nOffset );
		}
		
		public override function Dispose():void
		{
			super.Dispose();

			objWorld = null;

			bIsAsleep = true;
			bIsPhasing = false;

			bIsBottomCollided = false;
			bIsTopCollided = false;
			bIsLeftCollided = false;
			bIsRightCollided = false;
		}
		
	}
}