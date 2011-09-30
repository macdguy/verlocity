/*
	This file is subject to the terms and conditions defined in
    file 'license.txt', which is part of this source code package.
*/

package VerlocityEngine.base.ents
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	import VerlocityEngine.Verlocity;
	import VerlocityEngine.util.mathHelper;
	
	import flash.events.MouseEvent;
	import flash.ui.Mouse;

	public class verBMouseEnt extends verBExtendedEnt
	{
		protected var bIsMouseDown:Boolean;
		protected var bIsMouseOver:Boolean;

		public function verBMouseEnt():void
		{
			super();

			mouseEnabled = true;
			addEventListener( MouseEvent.CLICK, MouseClick );
			addEventListener( MouseEvent.MOUSE_DOWN, MouseDown );
			addEventListener( MouseEvent.MOUSE_UP, MouseUp );
			addEventListener( MouseEvent.MOUSE_OUT, MouseOut );
			addEventListener( MouseEvent.MOUSE_OVER, MouseOver );
		}

		protected function OnMouseClick():void {}
		protected function OnMouseDown():void {}
		protected function OnMouseUp():void {}
		protected function OnMouseOver():void {}
		protected function OnMouseOut():void { }
		
		public function get IsMouseOver():Boolean { return bIsMouseOver; }
		public function get IsMouseDown():Boolean { return bIsMouseDown; }
		
		private function MouseClick( me:MouseEvent ):void
		{
			OnMouseClick();
		}
		
		private function MouseDown( me:MouseEvent ):void
		{
			bIsMouseDown = true;
			OnMouseDown();
		}
		
		private function MouseUp( me:MouseEvent ):void
		{
			bIsMouseDown = false;
			OnMouseUp();
		}
		
		private function MouseOut( me:MouseEvent ):void
		{
			bIsMouseDown = false;
			bIsMouseOver = false;
			OnMouseOut();
		}
		
		private function MouseOver( me:MouseEvent ):void
		{
			bIsMouseOver = true;
			OnMouseOver();
		}

		public override function Dispose():void
		{
			super.Dispose();
			
			bIsMouseDown = false;
			bIsMouseOver = false;
			
			mouseEnabled = false;
			removeEventListener( MouseEvent.CLICK, MouseClick );
			removeEventListener( MouseEvent.MOUSE_DOWN, MouseDown );
			removeEventListener( MouseEvent.MOUSE_UP, MouseUp );
			removeEventListener( MouseEvent.MOUSE_OUT, MouseOut );
			removeEventListener( MouseEvent.MOUSE_OVER, MouseOver );
		}

	}

}
