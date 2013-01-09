/*
 * ---------------------------------------------------------------
 * Verlocity
 * http://www.verlocityengine.com
 * 
 * This file is subject to the terms and conditions defined in
 * 'license.txt', which is part of this source code package.
 * ---------------------------------------------------------------
*/
package verlocity.collision 
{
	import verlocity.Verlocity;
	import verlocity.ents.DynamicEntity;

	public final class CollisionInfo extends Object
	{
		private var iCollisionFlag:int;
		private var entCollidedWith:DynamicEntity;

		public function CollisionInfo( iFlag:int, entCollide:DynamicEntity = null ):void
		{
			iCollisionFlag = iFlag;
			entCollidedWith = entCollide;
		}
		
		public function get collisionType():int { return iCollisionFlag; }
		public function get ent():DynamicEntity { return entCollidedWith; }
	}
}