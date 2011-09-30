/*
	This file is subject to the terms and conditions defined in
    file 'license.txt', which is part of this source code package.
*/

package VerlocityEngine.base.ents
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	import VerlocityEngine.Verlocity;
	import VerlocityEngine.VerlocitySettings;
	import VerlocityEngine.util.mathHelper;

	public class verBExtendedEnt extends verBEnt
	{
		protected var entHealth:int;
		protected var entCollision:verBSprCollisionBox;

		protected var spawnHealth:int;

		protected var bIsDying:Boolean;

		public function verBExtendedEnt():void
		{
			super();

			var rectBounds:Rectangle = getBounds( this );
			SetCollisionBox( rectBounds.x, rectBounds.y, rectBounds.width, rectBounds.height );
		}

		public override function InternalThink():void
		{
			super.InternalThink();

			if ( !bIsBeingRemoved )
			{
				CollisionThink();
				DeathThink();
			}

			TimedRemoveThink();
		}

		protected function OnRespawn():void {}
		protected function OnTakeDamage():void {}
		protected function OnKill():void {}
		protected function OnCollide( ent:* ):void {}

		public override function Dispose():void
		{
			super.Dispose();

			if ( entCollision )
			{
				removeChild( entCollision );
				entCollision = null;
			}

			entHealth = NaN;
		
			spawnX = NaN; spawnY = NaN;
			spawnHealth = NaN;

			bIsDying = false;
		}

		public function GetHealth():int
		{
			return entHealth;
		}

		public function SetHealth( newHealth:int ):void
		{
			entHealth = mathHelper.Clamp( newHealth, 0, newHealth );
			CheckHealth();
		}
		
		private function CheckHealth():void
		{
			if ( entHealth <= 0 )
			{
				Kill();
			}
		}

		public function TakeDamage( iDamageAmount:int ):void
		{
			var newHealth:int = entHealth - iDamageAmount;

			SetHealth( newHealth );
			
			OnTakeDamage();
		}

		public function Kill( bPlayAnim:Boolean = false ):void
		{
			if ( bIsDying ) { return; }

			bIsDying = true;

			OnKill();

			if ( bPlayAnim )
			{
				gotoAndPlay( "die" );
			}
			else
			{
				Remove();
			}
		}
		
		private function DeathThink():void
		{
			if ( !bIsDying ) { return; }

			if ( currentFrame >= totalFrames )
			{
				Remove();
			}
		}

		public function Respawn():void
		{
			DeInit();
			Init();

			x = spawnX; y = spawnY;
			entHealth = spawnHealth;

			OnRespawn();
		}

		public function SetCollisionBox( colX:int = 0, colY:int = 0, colWidth:int = 10, colHeight:int = 10 ):void
		{
			if ( !entCollision )
			{
				entCollision = new verBSprCollisionBox();
			}

			entCollision.graphics.clear();

			if ( VerlocitySettings.COLLISION_DEBUG )
			{
				entCollision.graphics.beginFill( 0xFF0000, .5 );
			}
			else
			{
				entCollision.graphics.beginFill( 0x00, 0 );
			}

			entCollision.graphics.drawRect( colX, colY, colWidth, colHeight );
			entCollision.graphics.endFill();
			
			addChild( entCollision );
		}
		
		private function CollisionThink():void
		{
			var iLength:int = Verlocity.ents.CountAll();
			if ( iLength <= 1 ) { return; }

			var i:int = iLength - 1;

			var refCurrentEnt:verBEnt;
			var bHitObject:Boolean;

			while( i >= 0 )
			{
				refCurrentEnt = Verlocity.ents.GetAll()[i];

				if ( this != refCurrentEnt )
				{
					if ( IsTouching( refCurrentEnt, true ) )
					{
						OnCollide( verBEnt( refCurrentEnt ) );
					}
				}

				refCurrentEnt = null;
				i--;
			}
		}
		
		public function get collision():DisplayObject
		{
			if ( entCollision )
			{
				return entCollision;
			}

			return this;
		}
		
		public function IsTouching( ent:DisplayObject, bUseCollisionBox:Boolean = false ):Boolean
		{
			if ( bUseCollisionBox )
			{
				return entCollision.hitTestObject( ent );
			}

			return hitTestObject( ent );
		}

	}

}
