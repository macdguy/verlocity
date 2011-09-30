/*
	This file is subject to the terms and conditions defined in
    file 'license.txt', which is part of this source code package.
*/

package VerlocityEngine.base
{
	import flash.display.DisplayObject;

	public class verBScrFX extends verBScreenObject
	{
		public function verBScrFX():void
		{
			Construct();
		}

		/*
			 ===================
			======= HOOKS =======
			 ===================
			Override these functions for your own needs.
			They will be called appropriately.
		*/
		public function Construct():void {}
		public function Think():void {}
		public function Destruct():void { }
		
	}
}