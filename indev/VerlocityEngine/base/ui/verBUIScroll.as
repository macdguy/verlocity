package VerlocityEngine.base.ui
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Rectangle;

	import flash.events.MouseEvent;

	import flash.ui.Mouse;
	import flash.ui.MouseCursor;

	public class verBUIScroll extends verBUI
	{
		private var sprContent:Sprite;
		private var sprViewArea:Sprite;

		private var sprScrollBar:Sprite;
		private var sprScrollBarArea:Sprite;
		
		private var rectScrollBounds:Rectangle;
		
		private var nCurrentRes:Number = 0;
		private var nVelY:Number = 0;
		private var nSpeed:Number = 0.45;

		public function verBUIScroll():void
		{
			addEventListener( MouseEvent.MOUSE_WHEEL, OnWheel );

			sprContent = new Sprite();  addChild( sprContent );
			sprViewArea = new Sprite();  addChild( sprViewArea );
			sprContent.mask = sprViewArea;

			sprScrollBarArea = new Sprite();  addChild( sprScrollBarArea );
			sprScrollBarArea.addEventListener( MouseEvent.CLICK, OnClick );

			sprScrollBar = new Sprite();  addChild( sprScrollBar );
			sprScrollBar.addEventListener( MouseEvent.MOUSE_DOWN, OnDown );
			sprScrollBar.addEventListener( MouseEvent.MOUSE_UP, OnUp );
			sprScrollBar.addEventListener( MouseEvent.MOUSE_OVER, OnOver );
			sprScrollBar.addEventListener( MouseEvent.MOUSE_OUT, OnOut );
			
			rectScrollBounds = new Rectangle();

			addEventListener( Event.ENTER_FRAME, Think );
		}
		
		// override these to customize your scroll bar
		protected function Up():void {} // called when the mouse button is up
		protected function Down():void {} // called when the mouse is button is down
		protected function Over():void {} // called when the mouse is over the scroll bar (ie. hover)
		protected function Out():void {} // called when the mouse moved out
		protected function DrawBG():void
		{
			DrawRect( 0xFFFFFF, 1, width, height, false, 0, 0, 0, true, 10 );
		}
		protected function DrawScrollBar():void
		{
			var iScrollAreaWidth:int = 10;

			// View area
			sprViewArea.graphics.beginFill( 0xFFFFFF, 1 );
				sprViewArea.graphics.drawRect( x + 2, y + 2, width - 4 - iScrollAreaWidth, height - 4 );
			sprViewArea.graphics.endFill();
			
			// Scroll bar area
			sprScrollBarArea.graphics.beginFill( 0xFFFFFF, .75 );
				sprScrollBarArea.graphics.drawRect( width - 4 - iScrollAreaWidth, y + 2, iScrollAreaWidth, height - 4 );
			sprScrollBarArea.graphics.endFill();
			
			// Scroll bar
			var iScrollBarHeight:int = sprScrollBarArea.height * ( sprViewArea.height / sprContent.height );
			
			sprScrollBar.graphics.beginFill( 0xCCCCCC, 1 );
				sprScrollBarArea.graphics.drawRect( width - 4 - iScrollAreaWidth, y + 2, iScrollAreaWidth, iScrollBarHeight );
			sprScrollBarArea.graphics.endFill();
		}

		private function Think( e:Event ):void
		{
			nVelY = sprContent.y + sprScrollBarArea.y * nCurrentRes - sprScrollBar.y * nCurrentRes;
			sprContent.y += ( nVelY - sprContent.y ) * nSpeed;
		}
		
		private function OnUp( me:MouseEvent ):void
		{
			Up();
			sprScrollBar.stopDrag();
		}

		private function OnDown( me:MouseEvent ):void
		{
			Down();
			sprScrollBar.startDrag( false, rectScrollBounds );
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
			if ( me.delta > 1 )
			{
				// up
			}
			else
			{
				// down
			}
		}
		
		private function OnClick( me:MouseEvent ):void
		{
			
		}
		
		private function UpdateScroll():void
		{
			DrawScrollBar();
			rectScrollBounds = new Rectangle( sprScrollBarArea.x, sprScrollBarArea.y, sprScrollBarArea.width, sprScrollBarArea.height );

			// Should we draw the scroll bar?
			if ( sprContent.height <= sprViewArea.height )
			{
				sprScrollBar.visible = sprScrollBarArea.visible = false;
			}
			else
			{
				sprScrollBar.visible = sprScrollBarArea.visible = true;
			}

			nCurrentRes = ( sprContent.height - sprViewArea.height ) / ( sprScrollBarArea.height - sprScrollBar.height ) * 1.01;
		}

		public function SetSize( iWidth:int, iHeight:int ):void
		{
			width = iWidth; height = iHeight;

			graphics.beginFill( 0, 0 );
				graphics.drawRect( 0, 0, iWidth, iHeight );
			graphics.endFill();
			
			graphics.beginFill( 0x000000, 0 );
				graphics.lineStyle( 1, 0xFFFF00 );
				graphics.drawRect( 0, 0, iWidth, iHeight );
			graphics.endFill();

			UpdateScroll();
			DrawBG();
		}
		
		public function SetSpeed( nSetSpeed:Number ):void
		{
			nSpeed = nSetSpeed;
		}

		public function Insert( dispObj:DisplayObject ):void
		{
			sprContent.addChild( dispObj );
		}

	}
}