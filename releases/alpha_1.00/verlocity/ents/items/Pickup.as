/*
 * ---------------------------------------------------------------
 * Verlocity
 * http://www.verlocityengine.com
 * 
 * This file is subject to the terms and conditions defined in
 * 'license.txt', which is part of this source code package.
 * ---------------------------------------------------------------
*/
package verlocity.ents.items
{
	import flash.geom.Point;
	import verlocity.ents.DisplayEntity;
	import verlocity.ents.DynamicEntity;
	import verlocity.utils.MathUtil;
	import verlocity.utils.AngleUtil;

	public class Pickup extends DisplayEntity
	{
		private var entActivator:DynamicEntity;

		private var bMoveTowards:Boolean;
		private var iMinDistanceToMove:int;
		private var iMoveSpeed:int;

		/**
		 * Handles moving towards the activator entitiy. 
		 */
		public override function _Update():void
		{
			super._Update();

			if ( !entActivator || !bMoveTowards ) { return; }
			
			if ( !iMinDistanceToMove || ( iMinDistanceToMove && MathUtil.Dist2D( new Point( x, y ), new Point( entActivator.x, entActivator.y ) ) < iMinDistanceToMove ) )
			{
				if ( !IsPhysicsEnabled() )
				{
					EnablePhysics( true );
				}

				var ang:Point = AngleUtil.Angle( new Point( x, y ), new Point( entActivator.x, entActivator.y ) );
				phys.SetVelocity( new Point( ang.x * iMoveSpeed, ang.y * iMoveSpeed ) );
			}
		}
		
		/**
		 * When the pickup collided with the activator entity.
		 * @param	ent The collided entity
		 */
		public override function OnCollide( ent:* ):void
		{
			if ( !entActivator ) { return; }

			if ( ent.IsT( entActivator.GetType() ) )
			{
				OnPickup( ent );
			}
		}
		
		/**
		 * Override this to fire an event when the activator entity collides with this pickup.
		 * @param	ent The activator entity
		 */
		protected function OnPickup( ent:* ):void {}
		
		/**
		 * Sets the pickup data to apply to this pickup.
		 * @param	entSetActivator The entity that activates/collides with this pickup.
		 * @param	bShouldMoveTowards Should this pickup move towards the activator?
		 * @param	iSetMinMoveDist The minimum distance to begin moving towards activator (requires bShouldMoveTowards to be on).
		 * @param	iSetMoveSpeed The speed to being moving towards activator (requires bShouldMoveTowards to be on).
		 */
		public function SetPickup( entSetActivator:DynamicEntity, bShouldMoveTowards:Boolean = false, iSetMinMoveDist:int = 0, iSetMoveSpeed:int = 20 ):void
		{
			entActivator = entSetActivator;
			bMoveTowards = bShouldMoveTowards;
			iMinDistanceToMove = iSetMinMoveDist
			iMoveSpeed = iSetMoveSpeed;
		}		
	}
}