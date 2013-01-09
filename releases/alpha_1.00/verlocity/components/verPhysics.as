/*
 * ---------------------------------------------------------------
 * Verlocity
 * http://www.verlocityengine.com
 * 
 * This file is subject to the terms and conditions defined in
 * 'license.txt', which is part of this source code package.
 * ---------------------------------------------------------------
 * Component: verPhysics
 * Author: Macklin Guy
 * Description:
 * 		This calculates physics for entities.
 * 		TODO: Global forces
 * ---------------------------------------------------------------
*/
package verlocity.components
{
	import flash.display.Stage;
	import flash.geom.Point;

	import verlocity.Verlocity;
	import verlocity.ents.DynamicEntity;
	import verlocity.core.Component;

	/**
	 * Calculates physical forces that are acted upon the entities.
	 * Handles velocity, gravity, accerlation, and outside forces.
	 */
	public final class verPhysics extends Component
	{
		private var bPhysicsEnabled:Boolean;

		/**
		 * Constructor of the component.
		 */
		public function verPhysics():void
		{
			// Setup component
			super();
			
			// Component-specific construction
			EnablePhysics( true );
		}

		/**
		 * Destructor of the component.
		 */
		public override function _Destruct():void
		{	
			// Component-specific destruction
	
			// Destroy component
			super._Destruct();
		}

		/*================== COMPONENT ==================*/

		/*------------------- PRIVATE -------------------*/
		internal final function _UpdatePhysics( ent:DynamicEntity ):void
		{
			if ( !bPhysicsEnabled || !ent || ent.IsDead() || !ent.IsPhysicsEnabled() ) { return; }
			
			var pAccel:Point = new Point();
			var pForces:Point = ent.phys.GetSumOfAllForces();
			
			// Calculate gravity
			if ( ent.phys.IsGravityEnabled() )
			{
				pForces.x += ent.phys.GetGravity().x;
				pForces.y += ent.phys.GetGravity().y;
			}
			
			// Calculate friction
			if ( ent.phys.IsFrictionEnabled() )
			{
				pForces.x += ent.phys.GetFriction().x;
				pForces.y += ent.phys.GetFriction().y;
			}
			
			// Calculate acceleration
			pAccel.x = pForces.x / ent.phys.GetMass();
			pAccel.y = pForces.y / ent.phys.GetMass();
			
			// Calculate velocity
			ent.phys.SetVX( pAccel.x + ent.phys.GetVX() );
			ent.phys.SetVY( pAccel.y + ent.phys.GetVY() );
			
			// Update positions
			ent.x = ent.phys.GetVX() + ent.x;
			ent.y = ent.phys.GetVY() + ent.y;

			// Update the forces
			ent.phys._UpdateForces();
		}

		/*===============================================*/
		
		/*------------------- PUBLIC --------------------*/
		/**
		 * Enables/disables physics to be applied
		 * @param	bEnable Enable/disable physics
		 */
		public final function EnablePhysics( bEnable:Boolean ):void
		{
			bPhysicsEnabled = bEnable;
		}

		/**
		 * Returns if physics is being applied
		 * @return
		 */
		public final function IsPhysicsEnabled():Boolean
		{
			return bPhysicsEnabled;
		}
	}
}