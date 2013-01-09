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
	import flash.events.Event;
	import verlocity.utils.MathUtil;

	public class Entity extends Object
	{
		/*
			 ===================
			======= SETUP =======
			 ===================
		*/
		private var iID:int = -1;

		/**
		 * Returns the registration ID of the entity.
		*/
		public function get _id():int { return iID; }

		/**
		 * Sets the registration ID (called by verEnts)
		 * @param iSetID The registration ID to set to.
		*/
		public function set _id( iSetID:int ):void { iID = iSetID; }
		

		private var sName:String;

		/**
		 * Returns the name of the entity.
		*/
		public function get name():String { return sName; }

		/**
		 * Sets the name of the entity.
		 * @param sName The name of the entity.
		*/
		public function set name( sSetName:String ):void { sName = sSetName; }
		
		/**
		 * Returns if this entity base contains display functionality (will not Init until spawned).
		 */
		public function get _IsDisplay():Boolean { return false; }
		
		/**
		 * Returns if the entity is dynamic.
		 */
		public function get _IsDynamic():Boolean { return false; }
		
		/**
		 * Returns the entity base class.
		 */
		public function get baseClass():Object { return Entity; }

		/**
		 * Called each engine tick, do not override this.
		 * DO NOT CALL MANUALLY - THIS IS HANDLED BY verEnts!
		 */
		public function _Update():void {}


		/*
			 ===================
			======= HOOKS =======
			 ===================
		*/
		/*
			Override these functions for your own needs.
			They will be called appropriately.
		*/

		/**
		 * Called before the entity is spawned to setup the constants of the entity.
		 * DO NOT CALL MANUALLY - THIS IS HANDLED BY verEnts!
		 */
		public function Construct():void {}

		/**
		 * Called when the entity is first registered/spawned.  Called each soft reset.
		 * DO NOT CALL MANUALLY - THIS IS HANDLED BY verEnts!
		 */
		public function Init():void {}

		/**
		 * Called each engine tick.  Toggle with EnableUpdate( bEnabe ).
		 * DO NOT CALL MANUALLY - THIS IS HANDLED BY verEnts!
		*/
		public function Update():void {}

		/**
		 * Called when the entity is deleted.
		 * DO NOT CALL MANUALLY - THIS IS HANDLED BY verEnts!
		*/
		public function DeInit():void {}

		/**
		 * Called when the entity's health has been changed.
		*/
		protected function OnHealthChanged():void {}

		/**
		 * Called when the entity's health is now 0.
		*/
		protected function OnDeath():void {}

		/**
		 * Called when the entity took damage via TakeDamage function.
		*/
		protected function OnTakeDamage():void {}

		/*
			 =======================
			======= PROTECTION =======
			 =======================
		*/
		private var bIsProtected:Boolean;

		/**
		 * Protects an entity from being removed by clean up
		 * calls, such as CleanSlate.  To remove them, you need to
		 * set bRemoveProtected to true in clean up function calls.
		 * @param bProtected Mark this object as protected to prevent automatic clean up.
		*/
		public function SetProtected( bProtected:Boolean = true ):void
		{
			bIsProtected = bProtected;
		}

		/**
		 * Returns if the entity is protected.
		 * See SetProtected for more details.
		*/
		public function IsProtected():Boolean
		{
			return bIsProtected;
		}


		/*
			 =============================
			======= CLEANUP/REMOVAL =======
			 =============================
		*/
		private var bIsDead:Boolean;

		/**
		 * Marks the entity for removal.
		 * @usage	Example usage: ent.Remove();
		*/
		public function Remove():void
		{
			if ( bIsDead ) { return; }

			// Mark for removal from verEnts
			bIsDead = true;
		}

		/**
		 * Returns if the entity is dead.  Used to automatically clean remove the entity.
		 * @usage	Example usage: ent.IsDead();
		*/
		public function IsDead():Boolean
		{
			return bIsDead;
		}

		/**
		 * Cleans the entity's data.
		 * DO NOT CALL MANUALLY - THIS IS HANDLED BY verEnts!
		*/
		public function _Dispose():void
		{
			sType = null;
			
			entOwner = null;
			entClass = null;

			bIsDead = true;
			bIsProtected = false;
			bIsUpdating = false;
			bDefaultHealthSet = false;
			
			iHealth = 0;
			iMaxHealth = 0;
			iDefaultHealth = 0;
		}


		/*
			 =======================
			======= OWNERSHIP =======
			 =======================
		*/
		private var entOwner:Object;

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
			 =====================
			======= CLASS =======
			 =====================
		*/
		private var entClass:Object;

		/**
		 * Returns the class of the entity.
		 * @usage	Example usage: ent.GetClass();
		*/
		public function GetClass():Object
		{
			if ( !entClass )
			{
				entClass = Object( this ).constructor;
			}

			return entClass;
		}


		/*
			 =======================
			======= TYPE FLAG =======
			 =======================
		*/	
		private var sType:String;
		
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
		 * Returns if the entity matches a class.
		 * @usage	Example usage: ent.Is( PlayerBullet );
		*/
		public function Is( cClass:Class ):Boolean
		{
			return cClass == GetClass();
		}
		
		/**
		 * Returns if the entity is matches a type (lowercase only).
		 * A little faster than ent.Is()
		 * @usage	Example usage: ent.IsT( "bullet" );
		*/
		public function IsT( sCheckType:String ):Boolean
		{
			return sCheckType.toLowerCase() == sType;
		}


		/*
			 =====================
			======= TOGGLES =======
			 =====================
		*/
		private var bIsUpdating:Boolean;

		/**
		 * Sets if the entity will update each engine tick.
		 * @param bThinking A boolean that determines if the entity should update.
		*/
		public function EnableUpdate( bUpdate:Boolean = true ):void
		{
			bIsUpdating = bUpdate;
		}
		
		/**
		 * Returns if the entity is updating.
		*/		
		public function IsUpdating():Boolean
		{
			return bIsUpdating;
		}


		/*
			 ==============================
			============ HEALTH ============
			 ==============================
		*/
		private var iHealth:int;
		private var iDefaultHealth:int;
		private var bDefaultHealthSet:Boolean;
		private var iMaxHealth:int;

		/**
		 * Sets the default health of this entity.
		 * Used to respawn the entity with the proper health.
		 * This can only be set once per instance!
		 * @param	setHealth The default health to set to (usually 100).  Required to be over zero!
		 */
		public function SetDefaultHealth( setHealth:int = 100 ):void
		{
			// Default health already set
			if ( bDefaultHealthSet ) { return; }

			// Make sure they specify greater than zero.
			if ( setHealth <= 0 ) { return; }

			iDefaultHealth = setHealth;
			SetHealth( iDefaultHealth );
		}
		
		/**
		 * Resets the entity's health to the default health.
		 * Requires SetDefaultHealth to be called first!
		 */
		public function ResetHealth():void
		{
			iHealth = iDefaultHealth;
		}

		/**
		 * A getter that returns the default health the entity has.
		 */
		public function get defaultHealth():int { return iDefaultHealth; }

		/**
		 * Sets the health value of this entity.
		 * If the health is zero, the entity will call the OnDeath function.
		 */
		public function SetHealth( newHealth:int ):void
		{
			iHealth = MathUtil.Clamp( newHealth, 0, maxHealth );
			OnHealthChanged();

			if ( IsHealthZero() )
			{
				OnDeath();
			}
		}

		/**
		 * A getter that returns the current health value of the entity.
		 */
		public function get health():int { return iHealth; }

		/**
		 * A setter that sets the maximum health this entity can have.
		 */
		public function set maxHealth( setHealth:int ):void { iMaxHealth = setHealth; }

		/**
		 * A getter that returns the maximum health this entity can have.
		 */
		public function get maxHealth():int
		{
			if ( iMaxHealth > 0 )
			{
				return iMaxHealth;
			}

			return defaultHealth;
		}

		/**
		 * Subtracts the current health.  Also calls OnTakeDamage function
		 * If the health is zero, the entity will call the OnDeath function.
		 * @param	iDamageAmount The amount of health to remove.
		 */
		public function TakeDamage( iDamageAmount:int ):void
		{
			SetHealth( iHealth - iDamageAmount );
			OnTakeDamage();
		}
		
		/**
		 * Removes all health of the entity.
		 */
		public function RemoveAllHealth():void
		{
			SetHealth( 0 );
		}
		
		/**
		 * Returns if the health is zero.
		 */
		public function IsHealthZero():Boolean
		{
			return iHealth <= 0;
		}
		
		/**
		 * Resets the entity to its original values.
		 */
		public function Reset():void
		{
			ResetHealth();
		}
	}
}