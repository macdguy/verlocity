package VerlocityEngine.base.ents 
{
	import flash.display.Sprite;
	import flash.geom.Point;

	public class verBSprCollisionBox extends Sprite
	{
		/**
		 * Returns the absolute Y position.
		 * @usage	Example usage: scrobj.absY;
		*/		
		public function get absX():int
		{
			if ( parent )
			{
				return parent.localToGlobal( new Point( x, y ) ).x;
			}
				
			return x;
		}

		/**
		 * Returns the absolute Y position.
		 * @usage	Example usage: scrobj.absY;
		*/		
		public function get absY():int
		{
			if ( parent )
			{
				return parent.localToGlobal( new Point( x, y ) ).y;
			}
				
			return y;
		}
	}
}