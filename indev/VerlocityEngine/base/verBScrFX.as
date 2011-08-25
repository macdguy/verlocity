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