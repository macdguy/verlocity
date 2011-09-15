package VerlocityEngine.base.ents.items
{
	import flash.display.DisplayObject;
	import flash.geom.Point;
	import VerlocityEngine.base.ents.verBEnt;
	import VerlocityEngine.util.mathHelper;
	import VerlocityEngine.util.angleHelper;

	public class verBPickup extends verBEnt
	{
		private var entActivator:verBEnt;

		private var bMoveTowards:Boolean;
		private var iMinDistanceToMove:int;
		private var iMoveSpeed:int;

		public override function InternalThink():void
		{
			super.InternalThink();

			if ( !entActivator || !bMoveTowards ) { return; }
			
			if ( !iMinDistanceToMove || ( iMinDistanceToMove && mathHelper.Dist2D( x, y, entActivator.x, entActivator.y ) < iMinDistanceToMove ) )
			{
				if ( !bPhysicsEnabled )
				{
					InitPhysics();
				}

				var ang:Point = angleHelper.Angle( x, y, entActivator.x, entActivator.y );
				SetVelocity( ang.x * iMoveSpeed, ang.y * iMoveSpeed );
			}
		}
		
		protected override function OnCollide( ent:* ):void
		{
			if ( !entActivator ) { return; }

			if ( ent.IsT( entActivator.GetType() ) )
			{
				OnPickup( ent );
			}
		}
		
		protected override function OnPickup( ent:* ):void {}
		
		public function SetPickup( entSetActivator:verBEnt, bShouldMoveTowards:Boolean = false, iSetMinMoveDist:int = 0, iSetMoveSpeed:int = 20 ):void
		{
			entActivator = entSetActivator;
			bMoveTowards = bShouldMoveTowards;
			iMinDistanceToMove = iSetMinMoveDist
			iMoveSpeed = iSetMoveSpeed;
		}		
	}
}