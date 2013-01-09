/*
 * ---------------------------------------------------------------
 * Verlocity
 * http://www.verlocityengine.com
 * 
 * This file is subject to the terms and conditions defined in
 * 'license.txt', which is part of this source code package.
 * ---------------------------------------------------------------
*/
package verlocity.physics
{
	import flash.geom.Point;
	import verlocity.Verlocity;
	import verlocity.utils.ArrayUtil;

	public final class PhysObject extends Object
	{
		private var nMass:Number;
		private var pVelocity:Point;

		private var bAsleep:Boolean;

		private var bGravityEnabled:Boolean;
		private var pGravity:Point;

		private var bFrictionEnabled:Boolean;
		private var pFriction:Point;

		private var iSurfaceMaterial:int;

		private var aForces:Array;

		public function PhysObject( pVelocityDirection:Point, nVelocityMagnitude:Number = 0, nSetMass:Number = 1 ):void
		{
			nMass = nSetMass;
			
			pVelocity = new Point();

			pVelocityDirection.normalize( 1 );
			pVelocity.x = pVelocityDirection.x * nVelocityMagnitude;
			pVelocity.y = pVelocityDirection.y * nVelocityMagnitude;
			
			aForces = new Array();
		}

		/**
		 * Returns the unit vector of the current velocity
		 */
		public function GetVelocity():Point
		{
			return pVelocity;
		}
		
		/**
		 * Sets the velocity
		 * @param	pNewVelocity
		 */
		public function SetVelocity( pNewVelocity:Point ):void
		{
			pVelocity = pNewVelocity;
		}
		
		/**
		 * Adds to the current velocity
		 * @param	pAddVelocity
		 */
		public function AddVelocity( pAddVelocity:Point ):void
		{
			pVelocity.x += pAddVelocity.x;
			pVelocity.y += pAddVelocity.y;
		}
		
		/**
		 * Returns the current X velocity.
		 */
		public function GetVX():Number
		{
			return pVelocity.x;
		}

		/**
		 * Sets the current X velocity
		 * @param	nVelocityX
		 */
		public function SetVX( nVelocityX:Number ):void
		{
			pVelocity.x = nVelocityX;
		}
		
		/**
		 * Returns the current Y velocity.
		 */
		public function GetVY():Number
		{
			return pVelocity.y;
		}
		
		/**
		 * Sets the current Y velocity.
		 */
		public function SetVY( nVelocityY:Number ):void
		{
			pVelocity.y = nVelocityY;
		}

		/**
		 * Returns a normalized vector that describes the direction of the current velocity.
		 */
		public function GetDirection():Point
		{
			var pDir:Point = new Point( pVelocity.x, pVelocity.y );
			pDir.normalize( 1 );

			return pDir;
		}
		
		/**
		 * Sets the velocity direction
		 */
		public function SetDirection( pDir:Point ):void
		{
			var nMagnitude:Number = pVelocity.length;
			
			pDir.normalize( 1 );

			pVelocity.x = pDir.x * nMagnitude;
			pVelocity.y = pDir.y * nMagnitude;
		}
		
		/**
		 * Returns the current magnitude (speed)
		 */
		public function GetMagnitude():Number
		{
			return pVelocity.length;
		}
		
		/**
		 * Sets the magnitude (speed)
		 */
		public function SetMagnitude( nMagnitude:Number ):void
		{
			pVelocity.normalize( 1 );
			
			pVelocity.x *= nMagnitude;
			pVelocity.y *= nMagnitude;
		}
		
		/**
		 * Sets the mass of the physics object
		 * @param	nNewMass
		 */
		public function SetMass( nNewMass:Number ):void
		{
			nMass = nNewMass;
		}
		
		/**
		 * Returns the mass of the physics object
		 * @return
		 */
		public function GetMass():Number
		{
			return nMass;
		}

		/**
		 * Adds a force to apply to this physics object
		 * @param	nTime The time to apply (use NaN to apply a constant force)
		 * @param	pDirection The direction of the force (normalized)
		 * @param	nMagnitude The magnitude or speed to this force will be
		 */
		public function AddForce( nTime:Number, pDirection:Point, nMagnitude:Number = NaN ):void
		{
			if ( isNaN( nMagnitude ) )
			{
				nMagnitude = pDirection.length;
			}

			pDirection.normalize( 1 );
			
			if ( nTime < 0 ) { nTime = NaN; }

			aForces.push( new Force( pDirection, nMagnitude, nTime ) );
		}

		/**
		 * Returns the calculated sum of all the forces being applied on this physic object
		 * @return
		 */
		public function GetSumOfAllForces():Point
		{
			var pSum:Point = new Point();

			if ( aForces.length <= 0 ) { return pSum; }
			
			for ( var i:int; i < aForces.length; i++ )
			{
				var force:Force = aForces[i];

				pSum.x += force.direction.x * force.magnitude;
				pSum.y += force.direction.y * force.magnitude;
			}

			return pSum;
		}
		
		/**
		 * An internal function that removes forces after their life time has expired.
		 */
		public function _UpdateForces():void
		{
			if ( aForces.length <= 0 ) { return; }

			for ( var i:int; i < aForces.length; i++ )
			{
				var force:Force = aForces[i];

				if ( !isNaN( force.lifetime ) )
				{
					if ( force.lifetime < Verlocity.CurTime() )
					{
						aForces.splice( i, 1 );
						--i;
					}
				}
			}
		}
		
		/**
		 * Returns the number of forces being applied to this physics object.
		 * @return
		 */
		public function CountForces():int
		{
			return aForces.length;
		}
		
		/**
		 * Removes all active forces
		 */
		public function RemoveAllForces():void
		{
			ArrayUtil.Empty( aForces );
		}

		/**
		 * Enables/disables gravity to be applied to this object
		 * Default gravity will be applied if you do not manually set a gravity constant for this object
		 * @param	bEnable Enable/disable gravity
		 */
		public function EnableGravity( bEnable:Boolean ):void
		{
			bGravityEnabled = bEnable;
		}

		/**
		 * Returns if gravity is enabled on this phyics object
		 * @return
		 */
		public function IsGravityEnabled():Boolean
		{
			return bGravityEnabled;
		}
		
		/**
		 * Sets the gravity of this physics object (overrides global gravity)
		 * @param	pOverrideGravity
		 */
		public function SetGravity( pOverrideGravity:Point ):void
		{
			pGravity = pOverrideGravity;
		}
		
		/**
		 * Returns the gravity of this physics object
		 * @return
		 */
		public function GetGravity():Point
		{
			if ( !pGravity )
			{
				return Verlocity.settings.PHYS_GRAVITY;
			}

			return pGravity;
		}
		
		/**
		 * Resets the gravity of this physics object to the global constant
		 */
		public function UseDefaultGravity():void
		{
			pGravity = null;
		}

		/**
		 * Enables/disables friction to be applied to this object
		 * Default friction will be applied if you do not manually set a friction constant for this object
		 * @param	bEnable Enable/disable friction
		 */
		public function EnableFriction( bEnable:Boolean ):void
		{
			bFrictionEnabled = bEnable;
		}

		/**
		 * Returns if friction is enabled on this phyics object
		 * @return
		 */
		public function IsFrictionEnabled():Boolean
		{
			return bFrictionEnabled;
		}
		
		/**
		 * Sets the friction of this physics object
		 * @param	pOverrideFriction
		 */
		public function SetFriciton( pOverrideFriction:Point ):void
		{
			pFriction = pOverrideFriction;
		}
		
		/**
		 * Returns the friction of this physics object
		 * @return
		 */
		public function GetFriction():Point
		{
			return pFriction;
		}
		
		/**
		 * Resets the friction of this physics object to the global constant
		 */
		public function UseDefaultFriction():void
		{
			pFriction = null;
		}

		/**
		 * Wakes up the physics object from sleep
		 */
		public function Wake():void
		{
			bAsleep = false;
		}

		/**
		 * Sleeps the physics object (all physics operations will be halted, but not cleared)
		 */
		public function Sleep():void
		{
			bAsleep = true;
		}

		/**
		 * Returns if the physics object is awake or asleep
		 * @return
		 */
		public function IsAsleep():Boolean
		{
			return bAsleep;
		}

		/**
		 * Clears all physics info.
		*/
		public function _Dispose():void
		{
			nMass = NaN;
			pVelocity = null;
			
			pGravity = null;
			pFriction = null;

			RemoveAllForces();
			aForces = null;
		}
	}
}