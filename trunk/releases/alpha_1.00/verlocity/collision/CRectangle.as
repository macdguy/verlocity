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
	public final class CRectangle extends Object
	{
		public var x:int;
		public var y:int;
		public var width:int;
		public var height:int;

		public var initWidth:int;
		public var initHeight:int;
		
		public var offsetX:int;
		public var offsetY:int;

		public function CRectangle( iPosX:int = 0, iPosY:int = 0, 
									iWidth:int = 0, iHeight:int = 0, 
									iOffsetX:int = 0, iOffsetY:int = 0 ):void
		{
			x = iPosX;
			y = iPosY;
			
			width = iWidth;
			initWidth = iWidth;

			height = iHeight;
			initHeight = iHeight;
			
			offsetX = iOffsetX;
			offsetY = iOffsetY;
		}

		/**
		 * Returns if two rectangles intersects
		 * @param	r Rectangle to test
		 * @return
		 */
		public function intersects( r:CRectangle ):Boolean
		{
			return !(this.x > r.x + (r.width - 1) || this.x + (this.width - 1) < r.x || this.y > r.y + (r.height - 1) || this.y + (this.height - 1) < r.y);
		}
	}
}