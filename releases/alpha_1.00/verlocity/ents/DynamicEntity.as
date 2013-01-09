/*
 * ---------------------------------------------------------------
 * Verlocity
 * http://www.verlocityengine.com
 * 
 * This file is subject to the terms and conditions defined in
 * 'license.txt', which is part of this source code package.
 * ---------------------------------------------------------------
*/
package verlocity.ents
{
	import flash.geom.Point;
	import flash.geom.Rectangle;

	import verlocity.Verlocity;
	import verlocity.collision.CollisionInfo;
	import verlocity.collision.CRectangle;
	import verlocity.physics.PhysObject;
	import verlocity.sound.SoundObject;

	import verlocity.utils.AngleUtil;
	import verlocity.utils.MathUtil;

	/**
	 * All moving entities rely on this dynamic entity base for its position. 
	 * It handles collision, physics, boundaries, and sound.
	 */
	public class DynamicEntity extends Entity
	{
		/**
		 * Called each engine tick, do not override this.
		 * DO NOT CALL MANUALLY - THIS IS HANDLED BY verEnts!
		 */
		public override function _Update():void 
		{
			super._Update();

			ScreenUpdate();
			
			if ( Verlocity.settings.DEBUG_COLLISION )
			{
				DrawCollisionRect();
			}
		}

		/**
		 * Returns if the entity is dynamic.
		 */
		public override function get _IsDynamic():Boolean { return true; }

		/**
		 * Returns the entity base class.
		 */
		public override function get baseClass():Object { return DynamicEntity; }

		/*
			 ==============================
			========== POSITIONING =========
			 ==============================
		*/
		protected var nPosX:Number;
		protected var nPosY:Number;

		private var curPoint:Point;

		private var nPreviousX:Number;
		private var nPreviousY:Number;
		protected var nInitialX:Number;
		protected var nInitialY:Number;

		/**
		 * Sets the X and Y position of the entity
		 * @param	nSetPosX The X position to set the entity to.
		 * @param	nSetPosY The Y position to set the entity to.
		 * @usage	Example usage: ent.SetPos( 125, 25 );
		*/
		public function SetPos( nSetPosX:Number, nSetPosY:Number ):void
		{
			x = nSetPosX; y = nSetPosY;
		}
		
		/**
		 * Returns the current position as a point
		 * @return
		 */
		public function GetPos():Point
		{
			return new Point( x, y );
		}

		/**
		 * Resets the entity to its initial position.
		 */
		public function ResetPos():void
		{
			if ( !isNaN( nInitialX ) )
			{
				x = nInitialX;
			}
			
			if ( !isNaN( nInitialY ) )
			{
				y = nInitialY;
			}
		}

		/**
		 * Sets the calculated x position of this entity
		 */
		public function set x( nSetPosX:Number ):void
		{
			// Calc boundaries
			if ( !isNaN( nPosX ) ) { CalcXBoundaries( nSetPosX ); }

			// Set initial position
			if ( isNaN( nInitialX ) ) { nInitialX = nSetPosX; }

			// Store previous
			nPreviousX = nPosX;
			
			// Prevent exiting boundary limits
			if ( IsOnXBoundary() )
			{
				nPosX = nPreviousX;
				return;
			}

			// Position is within boundary, set it
			nPosX = nSetPosX;

			// Update collision
			UpdateCollisionRect( nPosX );
		}
		
		/**
		 * Returns the current calculated x position of this entity
		 */
		public function get x():Number { return nPosX; }

		/**
		 * Sets the calculated y position of this entity
		 */
		public function set y( nSetPosY:Number ):void
		{
			// Calc boundaries
			if ( !isNaN( nPosY ) ) { CalcYBoundaries( nSetPosY ); }

			// Set initial position
			if ( isNaN( nInitialY ) ) { nInitialY = nSetPosY; }

			// Store previous
			nPreviousY = nPosY;
			
			// Prevent exiting boundary limits
			if ( IsOnYBoundary() )
			{
				nPosY = nPreviousY;
				return;
			}
			
			// Position is within boundary, set it
			nPosY = nSetPosY;

			// Update collision
			UpdateCollisionRect( NaN, nPosY );
		}

		/**
		 * Returns the current calculated y position of this entity
		 */
		public function get y():Number { return nPosY; }
		
		/**
		 * Returns the absolute X position.
		*/
		public function get absX():Number { return x; }

		/**
		 * Returns the absolute Y position.
		*/		
		public function get absY():Number { return y; }

		/**
		 * A getter that returns the initial X position.
		 */
		public function get initX():Number { return nInitialX; }
		
		/**
		 * A getter that returns the initial Y position.
		 */
		public function get initY():Number { return nInitialY; }

		/**
		 * Returns if the entity has moved (determined by its previous position set)
		 * This is used to optimize collision and physics calculations
		 * @return
		 */
		public function HasMoved():Boolean
		{
			return nPosX != nPreviousX || nPosY != nPreviousY;
		}

		/**
		 * Returns the rotation (0-360) from the relation of the mouse and the entity.
		 * @return
		 */
		public function GetMouseRotation():Number
		{
			return AngleUtil.Rotation( new Point( absX, absY ), new Point( Verlocity.input.Mx, Verlocity.input.My ) );
		}

		/*
			 =============================
			====== SCREEN MANAGEMENT ======
			 =============================
		*/
		private var bShouldRemoveOffScreen:Boolean;
		protected var iRemoveOffScreenPadding:int = 100;

		/**
		 * Returns if the entity is within the boundaries of the screen.
		*/
		public function IsOnScreen():Boolean
		{
			if ( absX < ( Verlocity.display.GetScreenRect().x - iRemoveOffScreenPadding ) || 
				 absX > ( Verlocity.display.GetScreenRect().width + iRemoveOffScreenPadding ) ||
				 absY < ( Verlocity.display.GetScreenRect().y - iRemoveOffScreenPadding ) || 
				 absY > ( Verlocity.display.GetScreenRect().height + iRemoveOffScreenPadding ) )
			{
				return false;
			}

			return true;
		}

		/**
		 * Handles the check if the object is on the screen.
		 * @private
		*/
		private function ScreenUpdate():void
		{
			if ( !bShouldRemoveOffScreen ) { return; }

			if ( !IsOnScreen() ) 
			{
				Remove();
			}
		}

		/**
		 * Tells the entity to remove itself when its off screen.  Useful for bullets.
		 * @param	bShouldRemove Should the entity be removed off screen?
		 * @param	iPadding Padding to use when removing off screen
		 */
		public function RemoveOffScreen( bShouldRemove:Boolean = true, iPadding:int = 100 ):void
		{
			bShouldRemoveOffScreen = bShouldRemove;
			iRemoveOffScreenPadding = iPadding;
		}

		/*
			 ====================
			====== BOUNDARY ======
			 ====================
		*/
		protected var rectBounds:Rectangle;
		protected var iBoundPadding:int = 100;
		
		private var bIsOnLeftBoundary:Boolean;
		private var bIsOnRightBoundary:Boolean;
		private var bIsOnTopBoundary:Boolean;
		private var bIsOnBottomBoundary:Boolean;
		
		/**
		 * Calculates if a position is beyond the Y boundaries
		 * @param	nSetPosX
		 */
		protected function CalcXBoundaries( nSetPosX:Number ):void
		{
			if ( !rectBounds || !collisionRect ) { return; }

			var nRealOrigin:Number = nSetPosX + collisionRect.offsetX;
			var nRealWidth:Number = nRealOrigin + collisionRect.width;

			bIsOnLeftBoundary = Boolean( nRealOrigin <= rectBounds.x + iBoundPadding );
			bIsOnRightBoundary = Boolean( nRealWidth >= rectBounds.width - iBoundPadding );
		}
		
		/**
		 * Calculates if a position is beyond the Y boundaries
		 * @param	nSetPosY
		 */
		protected function CalcYBoundaries( nSetPosY:Number ):void
		{
			if ( !rectBounds || !collisionRect ) { return; }

			var nRealOrigin:Number = nSetPosY + collisionRect.offsetY;
			var nRealHeight:Number = nRealOrigin + collisionRect.height;

			bIsOnTopBoundary = Boolean( nRealOrigin <= rectBounds.y + iBoundPadding );
			bIsOnBottomBoundary = Boolean( nRealHeight >= rectBounds.height - iBoundPadding );			
		}
		
		/**
		 * Sets the screen boundaries of the entity.
		 * This limits the movement of the entity to these boundaries.
		 * @param	rectSetBounds The rectangle boundary
		 * @param	iInnerPadding The inner padding of the bounds
		 */
		public function SetBounds( rectSetBounds:Rectangle, iInnerPadding:int = 0 ):void
		{
			rectBounds = rectSetBounds;
			iBoundPadding = iInnerPadding;
		}
		
		/**
		 * Clears the boundaries of the entity.
		 */
		public function ClearBounds():void
		{
			rectBounds = null;
			iBoundPadding = NaN;
		}
		
		/**
		 * Returns if the entity is touching the left boundary.
		 */
		public function IsOnLeftBoundary():Boolean { return bIsOnLeftBoundary; }
		
		/**
		 * Returns if the entity is touching the right boundary.
		 */
		public function IsOnRightBoundary():Boolean { return bIsOnRightBoundary; }
		
		/**
		 * Returns if the entity is touching the top boundary.
		 */
		public function IsOnTopBoundary():Boolean { return bIsOnTopBoundary; }
		
		/**
		 * Returns if the entity is touching the bottom boundary.
		 */
		public function IsOnBottomBoundary():Boolean { return bIsOnBottomBoundary; }

		/**
		 * Returns if the entity is touching on the boundary on the X axis.
		 */
		public function IsOnXBoundary():Boolean { return bIsOnLeftBoundary || bIsOnRightBoundary; }

		/**
		 * Returns if the entity is touching on the boundary on the Y axis.
		 */
		public function IsOnYBoundary():Boolean { return bIsOnTopBoundary || bIsOnBottomBoundary; }

		/**
		 * Returns if the entity is touching the boundary.
		 */
		public function IsOnBoundary():Boolean { return IsOnXBoundary() || IsOnYBoundary(); }


		/*
			 ==============================
			============ PHYSICS ===========
			 ==============================
		*/ 
		private var bPhysicsEnabled:Boolean;
		private var physicsObj:PhysObject;

		/**
		 * Enables/disables calculations for physics.
		 * @param	bEnable Enables/disables physics
		 * @param	bRemovePhysicsObj Remove the physics object on disable?
		 */
		public function EnablePhysics( bEnable:Boolean = true, bRemovePhysicsObj:Boolean = true ):void
		{
			bPhysicsEnabled = bEnable;

			// Create new physics object on enable
			if ( bEnable && !physicsObj )
			{
				physicsObj = new PhysObject( new Point(), 0 );
				return;
			}

			// Remove existing physics object on disable
			if ( !bEnable && physicsObj && bRemovePhysicsObj )
			{
				physicsObj._Dispose();
				physicsObj = null;
				return;
			}
		}

		/**
		 * Returns if physics is enabled
		 */
		public function IsPhysicsEnabled():Boolean
		{
			return bPhysicsEnabled;
		}
		
		/**
		 * Returns the physics object
		 * @return
		 */
		public function GetPhysicsObject():PhysObject
		{
			return physicsObj;
		}
		
		/**
		 * Returns the physics object (short-hand).
		 * If the physics object doesn't exist, it'll create a new one.
		 */
		public function get phys():PhysObject
		{
			if ( !physicsObj )
			{
				EnablePhysics();
			}

			return physicsObj;
		}

		/**
		 * Sets the physicial properies of this entity
		 * @param	nMass The calculated mass of the entity
		 * @param	pVelocityDirection The initial velocity direction (normalized)
		 * @param	nVelocityMagnitude The initial velocity magnitude
		 */
		public function SetPhysicsProperties( nMass:Number, pVelocityDirection:Point, nVelocityMagnitude:Number ):void
		{
			if ( !physicsObj )
			{
				physicsObj = new PhysObject( pVelocityDirection, nVelocityMagnitude, nMass );
				return;
			}

			physicsObj.SetMass( nMass );
			physicsObj.SetVelocity( new Point( pVelocityDirection.x * nVelocityMagnitude, pVelocityDirection.y * nVelocityMagnitude ) );
		}



		/*
			 ==============================
			============ COLLISION ===========
			 ==============================
		*/
		protected var bCollisionEnabled:Boolean;
		protected var iCollisionFlags:int;
		protected var rectCollision:CRectangle;

		/**
		 * Enables/disables calculations for collision.
		 * If no collision flags are set, by default, the CO_BASIC collision flag is set.
		 * @param	bEnable Enables/disables collision
		 */
		public function EnableCollision( bEnable:Boolean = true ):void
		{
			bCollisionEnabled = bEnable;
			
			if ( !bEnable )
			{
				rectCollision = null;
			}

			if ( iCollisionFlags == 0 )
			{
				iCollisionFlags = Verlocity.collision.CO_BASIC;
			}
		}

		/**
		 * Set collision flags.  For multiples, seperate each flag with |
		 * These can be found in Verlocity.collision.CO_*
		 * @param	iFlags The collision flags to test (found in Verlocity.collision.CO_*)
		 */
		public function SetCollisionFlags( iFlags:int ):void
		{
			iCollisionFlags = iFlags;
		}

		/**
		 * Returns if collision is enabled
		 */
		public function IsCollisionEnabled():Boolean
		{
			return bCollisionEnabled;
		}

		/**
		 * Returns if a collision flag is enabled or not.
		 * @param	iCollisionFlag The collision flag to test (found in Verlocity.collision.CO_*)
		 */
		public function IsCollisionFlagOn( iCollisionFlag:int ):Boolean
		{
			return Boolean( iCollisionFlags & iCollisionFlag );
		}
		
		/**
		 * Sets the collision rect (required for collision)
		 * @param	rect The rectangle to use for collision
		 * @param	nOffsetX The offset from the center point of the entity
		 * @param	nOffsetY The offset from the center point of the entity
		 */
		public function SetCollisionRect( rect:Rectangle, nOffsetX:Number = 0, nOffsetY:Number = 0 ):void
		{
			rectCollision = new CRectangle( absX + rect.x, absY + rect.y, rect.width, rect.height, nOffsetX, nOffsetY );
		}
		
		/**
		 * Update the position/scale of the collision rect
		 */
		protected function UpdateCollisionRect( nSetPosX:Number = NaN, 
												nSetPosY:Number = NaN, 
												nSetScaleX:Number = NaN, 
												nSetScaleY:Number = NaN,
												nSetWidth:Number = NaN,
												nSetHeight:Number = NaN,
												nSetOffsetX:Number = NaN,
												nSetOffsetY:Number = NaN ):void
		{
			if ( !rectCollision || !HasMoved() ) { return; }

			if ( !isNaN( nSetOffsetX ) ) { rectCollision.offsetX = nSetOffsetX; }
			if ( !isNaN( nSetOffsetY ) ) { rectCollision.offsetY = nSetOffsetY; }

			if ( !isNaN( nSetWidth ) ) { rectCollision.initWidth = nSetWidth; }
			if ( !isNaN( nSetHeight ) ) { rectCollision.initHeight = nSetHeight; }
			
			if ( !isNaN( nSetPosX ) ) { rectCollision.x = nSetPosX + rectCollision.offsetX; }
			if ( !isNaN( nSetPosY ) ) { rectCollision.y = nSetPosY + rectCollision.offsetY; }

			if ( !isNaN( nSetScaleX ) )
			{
				rectCollision.width = rectCollision.initWidth * nSetScaleX;
				rectCollision.x = nSetPosX + rectCollision.offsetX * nSetScaleX;
			}

			if ( !isNaN( nSetScaleY ) )
			{
				rectCollision.height = rectCollision.initHeight * nSetScaleY;
				rectCollision.y = nSetPosY + rectCollision.offsetY * nSetScaleY;
			}
		}

		/**
		 * Draws debug boxes where the collision rect is
		 */
		private var iDebugClear:int;
		protected function DrawCollisionRect():void
		{
			if ( !rectCollision || !HasMoved() ) { return; }

			if ( iDebugClear < Verlocity.CurTime() )
			{
				Verlocity.layers.layerDraw.graphics.clear();
				
				iDebugClear = Verlocity.CurTime() + 50;
			}

			// Draws collision rect
			Verlocity.layers.layerDraw.graphics.beginFill( 0xFF0000, 1 );
			Verlocity.layers.layerDraw.graphics.drawRect( rectCollision.x, rectCollision.y, rectCollision.width, rectCollision.height );
			Verlocity.layers.layerDraw.graphics.endFill();

			// Draws origin
			Verlocity.layers.layerDraw.graphics.beginFill( 0x00FF00, 1 );
			Verlocity.layers.layerDraw.graphics.drawRect( x - 2, y - 2, 4, 4 );
			Verlocity.layers.layerDraw.graphics.endFill();
		}
		
		/**
		 * Returns the collision rect
		 * @return
		 */
		public function get collisionRect():CRectangle
		{
			return rectCollision;
		}
		
		/**
		 * Returns the method of basic collision between other types
		 * @param	ent
		 * @return
		 */
		public function IsColliding( ent:DynamicEntity ):Boolean
		{
			if ( !rectCollision || !ent.collisionRect ) { return false; }
			
			return rectCollision.intersects( ent.rectCollision );
		}
		
		/**
		 * Called when a rectangle collision occured.
		 * @param	ent The entity that collided
		 */
		public function OnCollide( ent:* ):void { }



		/*
			 ==============================
			======= TILEMAP SNAPPING =======
			 ==============================
		*/
		//private var bTilemapSnapEnabled:Boolean;

		/**
		 * Enables/disables tilemap snapping.
		 * @param	bEnable Enables/disables tilemap snapping
		 */
		/*public function EnableTilemapSnapping( bEnable:Boolean = true ):void
		{
			bTilemapSnapEnabled = bEnable;
		}*/

		/**
		 * Returns if tilemap snapping is enabled.
		 */
		/*public function IsTilemapSnappingEnabled():Boolean
		{
			return bTilemapSnapEnabled;
		}*/


		/*
			 =============================
			============ SOUND ============
			 =============================
		*/
		/**
		 * Plays a sound at the location of the entity.
		 * @param	sSound The sound to play.
		 * @param	nStartVolume The starting volume of the sound.
		 * @param	bLoops Should the sound loop or not?
		 * @param	bParent Set this to true if you want the sound to follow the entity's position.
		 * @usage	Example usage: ent.EmitSound( "hurt.mp3" );
		*/
		public function EmitSound( sSound:*, nStartVolume:Number = 1, bLoops:Boolean = false, bParent:Boolean = false, bFadeIn:Boolean = false ):void
		{
			if ( !Verlocity.IsValid( Verlocity.sound ) ) { return; }

			var sound:SoundObject = Verlocity.sound.Create( sSound, nStartVolume, false, bLoops, true );
			sound.SetPos( x );
			sound.SetOwner( this );
			
			if ( bParent ) { sound.SetParent( this ); }
			
			if ( bFadeIn ) { sound.FadeIn(); } else { sound.Play(); }
		}

		/**
		 * Stops all sounds that are emitting from this entity.
		*/
		public function StopAllSounds():void
		{
			if ( !Verlocity.IsValid( Verlocity.sound ) ) { return; }

			Verlocity.sound.StopAllInObject( this );
		}



		/**
		 * Cleans the entity's data.
		 * DO NOT CALL MANUALLY - THIS IS HANDLED BY verEnts!
		*/
		public override function _Dispose():void
		{
			super._Dispose();
			
			if ( physicsObj )
			{
				physicsObj._Dispose();
				physicsObj = null;
			}

			rectCollision = null;
			
			ClearBounds();
			bShouldRemoveOffScreen = false;
		}
		
		/**
		 * Resets the entity to its original values.
		 */
		public override function Reset():void
		{
			super.Reset();
			
			ResetPos();
		}
	}
}