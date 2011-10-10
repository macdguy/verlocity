/*
	This file is subject to the terms and conditions defined in
    file 'license.txt', which is part of this source code package.
*/

package VerlocityEngine.base.ents
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import VerlocityEngine.Verlocity;
	import VerlocityEngine.base.verBScreenObject;
	import VerlocityEngine.base.sound.verBSound;
	
	import VerlocityEngine.util.mathHelper;

	public class verBEnt extends verBScreenObject
	{
		public function verBEnt():void
		{
			stop();
		}

		/**
		 * This function should NEVER be called outside of the entity manager.
		*/
		public function InternalThink():void
		{
			PhysicsUpdate();
			ScreenThink();
			BoundaryThink();
		}


		/*
			 ===================
			======= HOOKS =======
			 ===================
			Override these functions for your own needs.
			They will be called appropriately.
		*/
		public function Init():void {}
		public function Think():void {}
		public function DeInit():void {}

		protected function OnSpawn():void {}

		protected var spawnX:int;
		protected var spawnY:int;
		protected var bIsSpawned:Boolean;
		protected var sLayer:String;

		public function Spawn( layer:* ):void
		{
			if ( layer is String )
			{
				layer = Verlocity.layers.Get( layer );
			}
			else if ( layer is DisplayObject )
			{
				layer = layer;
			}

			if ( !layer ) { Verlocity.Trace( "Ents", "Unable to spawn entity! Check spawn layer is correct!" ); return; }

			layer.addChild( this );
			sLayer = layer;
			
			play();
			
			bIsSpawned = true;
			spawnX = x; spawnY = y;

			OnSpawn();
		}
		
		public function GetLayerName():String
		{
			return sLayer;
		}


		/**
		 * Cleans the entity's data.
		 * @usage	Example usage: ent.Dispose();
		*/
		public override function Dispose():void
		{
			super.Dispose();

			entOwner = null;

			spawnX = NaN; spawnY = NaN;
			bIsSpawned = false;
			rectBounds = null;
			iBoundPadding = NaN;
		
			bPhysicsEnabled = false;
			nVelX = NaN; nVelY = NaN; nGravityX = NaN; nGravityY = NaN;
		}



		/*
			 =====================
			======= HELPERS =======
			 =====================
		*/

		/**
		 * Returns the class of the entity.
		 * @usage	Example usage: ent.GetClass();
		*/
		public function GetClass():Object
		{
			return Object( this ).constructor;
		}

		/**
		 * Returns the display parent of the entity.
		 * @usage	Example usage: ent.GetParent();
		*/
		public function GetParent():DisplayObject
		{
			return parent;
		}
		
		private var iID:int = -1;
		public function get id():int { return iID; }
		public function set id( iSetID:int ):void { iID = iSetID; }



		/*
			 =======================
			======= OWNERSHIP =======
			 =======================
		*/
		protected var entOwner:Object;

		/**
		 * Sets the owner of the entity.  Useful for bullets, weapons, inventory, etc.
		 * @param	newOwner The object that owns the entity.
		 * @usage	Example usage: ent.SetOwner( Character );
		*/
		public function SetOwner( newOwner:Object ):void
		{
			entOwner = newOwner;
		}

		/**
		 * Returns the current owner of the entity.
		 * @usage	Example usage: ent.GetOwner();
		*/
		public function GetOwner():Object
		{
			return entOwner;
		}


		/*
			 =======================
			======= TYPE FLAG =======
			 =======================
		*/	
		protected var sType:String;
		
		/**
		 * Sets the string type of the entity.  Useful for flag checking.
		 * NOTE: All types will become lower case to prevent confusion.
		 * @param	newOwner The string type you wish to set.
		 * @usage	Example usage: ent.SetType( "bullet" );
		*/
		public function SetType( sSetType:String ):void
		{
			sType = sSetType.toLowerCase();
		}

		/**
		 * Returns the current string type of the entity.
		 * @usage	Example usage: ent.GetType();
		*/
		public function GetType():String
		{
			return sType;
		}
		
		/**
		 * Returns if the entity is matches a type.  A little faster than ent.Is
		 * @usage	Example usage: ent.IsT( "bullet" );
		*/
		public function IsT( sCheckType:String ):Boolean
		{
			return sCheckType.toLowerCase() == sType;
		}

		/**
		 * Returns if the entity matches a type or class.
		 * @usage	Example usage: ent.Is( "bullet" );  or  ent.Is( PlayerBullet );
		*/
		public function Is( sCheck:* ):Boolean
		{
			if ( sCheck is String )
			{
				return sCheck.toLowerCase() == sType;
			}
			if ( sCheck is Class )
			{
				return sCheck == GetClass();
			}

			return false;
		}



		/*
			 =============================
			====== SCREEN MANAGEMENT ======
			 =============================
		*/
		protected var bShouldRemoveOffScreen:Boolean;

		/**
		 * Handles the check if the object is on the screen.
		 * @private
		*/
		private function ScreenThink():void
		{
			if ( !bShouldRemoveOffScreen ) { return; }

			if ( !IsOnScreen() ) 
			{
				Remove();
			}
		}

		protected var rectBounds:Rectangle;
		protected var iBoundPadding:int;

		private function BoundaryThink():void
		{
			if ( !rectBounds ) { return; }

			x = mathHelper.Clamp( x, rectBounds.x + iBoundPadding, rectBounds.width - ( width - iBoundPadding ) );
			y = mathHelper.Clamp( y, rectBounds.y + iBoundPadding, rectBounds.height - ( height - iBoundPadding ) );
		}
		
		public function SetBounds( rectSetBounds:Rectangle, iPadding:int = 0 ):void
		{
			rectBounds = rectSetBounds;
			iBoundPadding = iPadding;
		}
		
		public function ClearBounds():void
		{
			rectBounds = null;
			iBoundPadding = NaN;
		}

		/**
		 * Returns if the entity is within the boundaries of the screen.
		 * @usage	Example usage: ent.IsOnScreen();
		*/
		public function IsOnScreen():Boolean
		{
			var iOffset:int = 100;
			var rectBounds:Rectangle = new Rectangle( -iOffset, -iOffset, Verlocity.ScrW + iOffset, Verlocity.ScrH + iOffset );
			
			if ( absX < rectBounds.x || absX > rectBounds.width )
			{
				return false;
			}
			
			if ( absY < rectBounds.y || absY > rectBounds.height )
			{
				return false;
			}

			return true;
		}

		/**
		 * Tells the entity to remove itself when its off screen.  Useful for bullets.
		 * @param	bShouldRemove Should the entity be removed off screen?
		 * @usage	Example usage: ent.RemoveOffScreen();
		 */
		public function RemoveOffScreen( bShouldRemove:Boolean = true ):void
		{
			bShouldRemoveOffScreen = bShouldRemove;
		}



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
		public function EmitSound( sSound:*, nStartVolume:Number = 1, bLoops:Boolean = false, bParent:Boolean = false ):void
		{
			var newSound:verBSound = Verlocity.sound.Create( sSound, nStartVolume, bLoops, true );
			newSound.SetPos( x );
			newSound.SetOwner( this );
			if ( bParent ) { newSound.SetParent( this ); }
		}



		/*
			 =====================
			======= PHYSICS =======
			 =====================
		*/
		protected var bPhysicsEnabled:Boolean;

		public var nVelX:Number, nVelY:Number;
		protected var nGravityX:Number, nGravityY:Number;
		protected var nFrictionX:Number, nFrictionY:Number;

		/**
		 * Handles the updates of physics.
		 * @private
		*/
		private function PhysicsUpdate():void
		{
			if ( !bPhysicsEnabled || bIsDead ) { return; }

			x += nVelX; y += nVelY;

			if ( nGravityX != 0 ) { nVelX += nGravityX; }
			if ( nGravityY != 0 ) { nVelY += nGravityY; }
			
			if ( nFrictionX != 0 ) { nVelX *= nFrictionX; }
			if ( nFrictionY != 0 ) { nVelY *= nFrictionY; }
		}

		/**
		 * Initalizes the basic physics for our entity.
		 * @usage	Example usage: ent.InitPhysics();
		*/
		public function InitPhysics():void
		{
			if ( bPhysicsEnabled ) { Verlocity.Trace( "Ent", "Tried to initialize physics a second time!" ); return; }

			nVelX = 0; nVelY = 0;
			nGravityX = 0; nGravityY = 0;
			nFrictionX = 0; nFrictionY = 0;

			bPhysicsEnabled = true;
		}

		/**
		 * Halts the basic physics for our entity.
		 * @usage	Example usage: ent.HaltPhysics();
		*/
		public function HaltPhysics():void
		{
			if ( !bPhysicsEnabled ) { Verlocity.Trace( "Ent", "Tried to halt physics when physics was not initialized!" ); return; }

			nVelX = 0; nVelY = 0;
			nGravityX = 0; nGravityY = 0;
			nFrictionX = 0; nFrictionY = 0;
		}		

		/**
		 * Use this to set the velocity of the object.
		 * MAKE SURE YOU INITIALIZE THE PHYSICS BEFORE CALLING THIS!
		 * To initialize physics use ent.InitPhysics();
		 * @param	nNewVelX The new velocity amount in the X direction.
		 * @param	nNewVelY The new velocity amount in the Y direction.
		 * @usage	Example usage: ent.SetVelocity( 10, 0 );
		*/
		public function SetVelocity( nNewVelX:Number, nNewVelY:Number ):void
		{
			if ( !bPhysicsEnabled ) { Verlocity.Trace( "Ent", "Tried to set velocity when physics was not initialized!" ); return; }

			nVelX = nNewVelX;
			nVelY = nNewVelY;
		}

		/**
		 * Use this to set the gravity of the object.
		 * MAKE SURE YOU INITIALIZE THE PHYSICS BEFORE CALLING THIS!
		 * To initialize physics use ent.InitPhysics();
		 * @param	nNewGravityX The new gravity amount in the X direction.
		 * @param	nNewGravityY The new gravity amount in the Y direction.
		 * @usage	Example usage: ent.SetGravity( 0, -9.8 );
		*/
		public function SetGravity( nNewGravityX:Number, nNewGravityY:Number ):void
		{
			if ( !bPhysicsEnabled ) { Verlocity.Trace( "Ent", "Tried to set gravity when physics was not initialized!" ); return; }

			nGravityX = nNewGravityX;
			nGravityY = nNewGravityY;
		}

		/**
		 * Use this to set the friction of the object.
		 * MAKE SURE YOU INITIALIZE THE PHYSICS BEFORE CALLING THIS!
		 * To initialize physics use ent.InitPhysics();
		 * @param	nNewFrictionX The new friction amount in the X direction.
		 * @param	nNewFrictionY The new friction amount in the Y direction.
		 * @usage	Example usage: ent.SetFriction( 2, 0 );
		*/
		public function SetFriction( nNewFrictionX:Number, nNewFrictionY:Number ):void
		{
			if ( !bPhysicsEnabled ) { Verlocity.Trace( "Ent", "Tried to set friction when physics was not initialized!" ); return; }

			nFrictionX = nNewFrictionX;
			nFrictionY = nNewFrictionY;
		}
		
		public function PhysPush( nAddVelX:Number, nAddVelY:Number ):void
		{
			if ( !bPhysicsEnabled ) { Verlocity.Trace( "Ent", "Tried to push entity when physics was not initialized!" ); return; }

			nVelX += nAddVelX;
			nVelY -= nAddVelY;
		}

	}

}
