/*
 * ---------------------------------------------------------------
 * Verlocity
 * http://www.verlocityengine.com
 * 
 * This file is subject to the terms and conditions defined in
 * 'license.txt', which is part of this source code package.
 * ---------------------------------------------------------------
 * Component: verCollision
 * Author: Macklin Guy
 * ---------------------------------------------------------------
*/
package verlocity.components
{
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	import verlocity.Verlocity;
	import verlocity.collision.CollisionInfo;
	import verlocity.core.Component;
	import verlocity.core.ListNode;
	import verlocity.ents.Entity;
	import verlocity.ents.DynamicEntity;

	/**
	 * Manages all the collision handling.
	 * Contains different types of collision methods
	 * which provide solutions for every possible collision
	 * information your game could require.
	 */
	public final class verCollision extends Component
	{
		private var bCollisionDisabled:Boolean;

		public const CO_BASIC:int = 1; // standard test (rect)
		public const CO_TILEMAP:int = 2; // aabb sweeping on tilemap array (verTilemap)
		public const CO_POINT:int = 3; // hotspot shape tests (hitTest)
		public const CO_CDK:int = 4; // per-pixel collision

		/**
		 * Constructor of the component.
		 */
		public function verCollision():void
		{
			// Setup component
			super();
			
			// Component-specific construction
			EnableCollision( true );
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
		/**
		 * Preforms various collision checks on an entity
		 * @param	ent
		 * @param	headNode
		 */
		internal final function _UpdateCollision( ent:DynamicEntity, headNode:ListNode ):void
		{
			if ( bCollisionDisabled ) { return; }
			if ( !CanCollide( ent ) && !ent.HasMoved() ) { return; }

			// Standard rect intersect test
			if ( ent.IsCollisionFlagOn( CO_BASIC ) )
			{
				RectTest( headNode, ent );
			}
		}
		
		/**
		 * Returns if an entity can collide
		 * @param	ent The dynamic entity to check
		 * @return
		 */
		private final function CanCollide( ent:DynamicEntity ):Boolean
		{
			return !ent.IsDead() && ent.IsCollisionEnabled() && ent.collisionRect;
		}
		
		/**
		 * Loops through and checks for collisions
		 * @param	ent1 The entity to test
		 * @param	headNode The head node
		 */
		private final function RectTest( headNode:ListNode, ent1:DynamicEntity ):void
		{
			var node:ListNode = headNode.next; // go forward a node  (checks 2,3,4,5 and so forth instead of 1,2,3,4,5)
			var ent2:Entity;

			while ( node )
			{
				ent2 = node.data;

				if ( ent2._IsDynamic && // Only dynamic
					 CanCollide( DynamicEntity( ent2 ) ) && // Check if collision is enabled
					 DynamicEntity( ent2 ).IsCollisionFlagOn( CO_BASIC ) ) // Check if the flag is enabled
				{
					// Preform rect test
					if ( ent1.IsColliding( DynamicEntity( ent2 ) ) )
					{
						// Send info to collision callback function
						ent1.OnCollide( ent2 );
						DynamicEntity( ent2 ).OnCollide( ent1 );
					}
				}

				node = node.next;
			}

			ent2 = null;
		}

		/*===============================================*/
		
		/*------------------- PUBLIC --------------------*/
		/**
		 * Enables/disables collision to be applied
		 * @param	bEnable Enable/disable collision
		 */
		public final function EnableCollision( bEnable:Boolean ):void
		{
			bCollisionDisabled = !bEnable;
		}

		/**
		 * Returns if collision is being applied
		 * @return
		 */
		public final function IsCollisionEnabled():Boolean
		{
			return !bCollisionDisabled;
		}
	}
}