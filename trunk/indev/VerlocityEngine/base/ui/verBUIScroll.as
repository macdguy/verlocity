/*
	This file is subject to the terms and conditions defined in
    file 'license.txt', which is part of this source code package.
*/

package VerlocityEngine.base.ui
{
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.geom.Rectangle;

	import flash.events.MouseEvent;

	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	
	import VerlocityEngine.Verlocity;

	public class verBUIScroll extends verBUI
	{
		private var iWidth:int;
		private var iHeight:int;
		private var sViewArea:Shape;

		private var uiContent:verBUI;
		private var uiScrollBar:verBUI;
		private var uiScrollBarArea:verBUI;
		
		private var rectScrollBounds:Rectangle;
		
		private var nCurrentRes:Number = 0;
		private var nVelY:Number = 0;
		private var nSpeed:Number = 0.1;

		public function verBUIScroll():void
		{
			uiContent = new verBUI();
			addChild( uiContent );
			
			sViewArea = new Shape();
			addChild( sViewArea );

			uiContent.mask = sViewArea;
			
			uiScrollBarArea = new verBUI();
				uiScrollBarArea.addEventListener( MouseEvent.CLICK, OnClick );
			addChild( uiScrollBarArea );
			
			uiScrollBar = new verBUI();
				uiScrollBar.addEventListener( MouseEvent.MOUSE_DOWN, OnDown );
				uiScrollBar.addEventListener( MouseEvent.MOUSE_UP, OnUp );
				Verlocity.stage.addEventListener( MouseEvent.MOUSE_UP, OnUp );
				uiScrollBar.addEventListener( MouseEvent.MOUSE_OVER, OnOver );
				uiScrollBar.addEventListener( MouseEvent.MOUSE_OUT, OnOut );
			addChild( uiScrollBar );

			addEventListener( MouseEvent.MOUSE_WHEEL, OnWheel );
			addEventListener( Event.ENTER_FRAME, Think );
		}
		
		public override function Dispose():void
		{
			removeEventListener( MouseEvent.MOUSE_WHEEL, OnWheel );
			removeEventListener( Event.ENTER_FRAME, Think );

			uiScrollBarArea.removeEventListener( MouseEvent.CLICK, OnClick );
			
			uiScrollBar.removeEventListener( MouseEvent.MOUSE_DOWN, OnDown );
			uiScrollBar.removeEventListener( MouseEvent.MOUSE_UP, OnUp );
			Verlocity.stage.removeEventListener( MouseEvent.MOUSE_UP, OnUp );
			uiScrollBar.removeEventListener( MouseEvent.MOUSE_OVER, OnOver );
			uiScrollBar.removeEventListener( MouseEvent.MOUSE_OUT, OnOut );
	
			for ( var i:int = 0; i < uiContent.numChildren; i++ )
			{
				var child:DisplayObject = uiContent.getChildAt( i );
				
				if ( child is verBUI )
				{
					verBUI( child ).Dispose();
				}

				uiContent.removeChildAt( i );
				i--;
			}

			removeChild( uiContent );
			uiContent = null;

			removeChild( sViewArea );
			sViewArea = null;
			
			removeChild( uiScrollBar );
			uiScrollBar = null;
			
			removeChild( uiScrollBarArea );
			uiScrollBarArea = null;
		}
		
		// override these to customize your scroll bar
		protected function Up():void {} // called when the mouse button is up
		protected function Down():void {} // called when the mouse is button is down
		protected function Over():void {} // called when the mouse is over the scroll bar (ie. hover)
		protected function Out():void {} // called when the mouse moved out
		protected function DrawBG():void
		{
			DrawRect( 0x000000, 0, width, height );
		}
		protected function DrawScrollBar():void
		{
			var iScrollAreaWidth:int = 10;
			
			// Scroll bar area
			uiScrollBarArea.Clear();
			uiScrollBarArea.DrawRect( 0x4444444, 1, iScrollAreaWidth, iHeight );
			uiScrollBarArea.SetPos( iWidth - iScrollAreaWidth, 0 );
			
			// Scroll bar
			var iScrollBarHeight:int = iHeight * ( iHeight / uiContent.height );
			uiScrollBar.Clear();
			uiScrollBar.SetPos( uiScrollBarArea.x, uiScrollBarArea.y );
			uiScrollBar.DrawRect( 0xFFFFFFF, 1, iScrollAreaWidth, iScrollBarHeight );
		}
		
		private function UpdateScroll():void
		{
			DrawScrollBar();
			rectScrollBounds = new Rectangle( uiScrollBarArea.x, uiScrollBarArea.y, 0, uiScrollBarArea.height - uiScrollBar.height );

			// Should we draw the scroll bar?
			if ( uiContent.height <= iHeight )
			{
				uiScrollBar.visible = uiScrollBarArea.visible = false;
			}
			else
			{
				uiScrollBar.visible = uiScrollBarArea.visible = true;
			}

			nCurrentRes = ( uiContent.height - sViewArea.height ) / ( uiScrollBarArea.height - uiScrollBar.height );
		}
		
		private function Think( e:Event ):void
		{
			nVelY = sViewArea.y + uiScrollBarArea.y * nCurrentRes - uiScrollBar.y * nCurrentRes;
			uiContent.y += ( nVelY - uiContent.y ) * nSpeed;
			
			if ( uiScrollBar.y > rectScrollBounds.height ) { uiScrollBar.y = rectScrollBounds.height; }
			if ( uiScrollBar.y < rectScrollBounds.y ) { uiScrollBar.y = rectScrollBounds.y; }
		}
		
		private function OnUp( me:MouseEvent ):void
		{
			uiScrollBar.stopDrag();
			Up();
		}

		private function OnDown( me:MouseEvent ):void
		{
			uiScrollBar.startDrag( false, rectScrollBounds );
			Down();
		}

		private function OnOver( me:MouseEvent ):void
		{
			Mouse.cursor = MouseCursor.BUTTON;
			Over();
		}

		private function OnOut( me:MouseEvent ):void
		{
			Mouse.cursor = MouseCursor.ARROW;
			Out();
		}

		private function OnWheel( me:MouseEvent ):void
		{
			if ( me.delta < 1 )
			{
				if ( uiScrollBar.y < rectScrollBounds.height )
				{
					uiScrollBar.y -= me.delta * 4;
				}
			}
			else
			{		
				if ( uiScrollBar.y > rectScrollBounds.y )
				{
					uiScrollBar.y -= me.delta * 4;
				}
			}
		}
		
		private function OnClick( me:MouseEvent ):void
		{
			uiScrollBar.y = me.localY - ( uiScrollBar.height / 2 );
		}

		public function SetSize( iSetWidth:int, iSetHeight:int ):void
		{
			iWidth = iSetWidth;
			iHeight = iSetHeight;

			sViewArea.graphics.clear();
			sViewArea.graphics.beginFill( 0 );
				sViewArea.graphics.drawRect( 0, 0, iWidth, iHeight );
			sViewArea.graphics.endFill();

			UpdateScroll();
			DrawBG();
		}
		
		public function GetHeight():int
		{
			return iHeight;
		}
		
		public function GetWidth():int
		{
			return iWidth;
		}
		
		public function SetSpeed( nSetSpeed:Number ):void
		{
			nSpeed = nSetSpeed;
		}

		public function Insert( dispObj:DisplayObject ):void
		{
			uiContent.addChild( dispObj );
			UpdateScroll();
		}

	}
}