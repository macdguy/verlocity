﻿package VerlocityEngine.base.ui
{
	import flash.events.MouseEvent;

	import flash.text.TextFormat;
	import flash.text.TextField;

	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	
	import VerlocityEngine.Verlocity;

	public class verBUIButton extends verBUIText
	{
		protected var fFunction:Function;
		protected var iState:int;
		protected var bMouseOver:Boolean;

		protected var uiNextButton:verBUIButton;
		protected var uiPreviousButton:verBUIButton;

		protected var sBackground:Shape;
		protected var ctBGColor:ColorTransform = new ColorTransform();

		public const STATE_UP:int = 0;
		public const STATE_OUT:int = 1;
		public const STATE_OVER:int = 2;
		public const STATE_DOWN:int = 3;
		public const STATE_DISABLED:int = 4;		

		public function verBUIButton():void
		{
			addEventListener( MouseEvent.MOUSE_UP, OnUp );
			addEventListener( MouseEvent.MOUSE_DOWN, OnDown );
			addEventListener( MouseEvent.MOUSE_OVER, OnOver );
			addEventListener( MouseEvent.MOUSE_OUT, OnOut );
		}
		
		public function GetState():int { return iState; }

		public function ResetState():void
		{
			iState = STATE_OUT; Out();
		}


		// override these to customize your button
		protected function Press():void {} // called when the button was successfully pressed
		protected function Up():void {} // called when the mouse button is up
		protected function Down():void {} // called when the mouse is button is down
		protected function Over():void {} // called when the mouse is over the button (ie. hover)
		protected function Out():void {} // called when the mouse moved out
		protected function Disabled():void {} // called when the button was disabled
		protected function DrawBG():void
		{
			DrawRect( 0xFFFFFF, 1, 0, 0, false, 0, 0, 0, true, 10 );
		}


		private function OnUp( me:MouseEvent ):void
		{
			iState = STATE_UP;
			Up();

			DoButton();
		}

		private function OnDown( me:MouseEvent ):void
		{
			iState = STATE_DOWN;
			Down();
		}

		private function OnOver( me:MouseEvent ):void
		{
			iState = STATE_OVER;
			MouseChange( true );
			Over();
		}

		private function OnOut( me:MouseEvent ):void
		{
			iState = STATE_OUT;
			MouseChange( false );
			Out();
		}
		
		private function MouseChange( bOver:Boolean ):void
		{
			if ( bOver )
			{
				bMouseOver = true;
				Mouse.cursor = MouseCursor.BUTTON;
			}
			else
			{
				bMouseOver = false;
				Mouse.cursor = MouseCursor.ARROW;
			}
		}
		
		public override function SetText( sText:String, tfTextFormat:TextFormat = null ):void
		{
			super.SetText( sText, tfTextFormat );
			DrawBG();
			ResetState();
			
			if ( tfTextField ) { tfTextField.y = ( height / 2 ) - ( ( tfTextField.height ) / 2 ); }
		}

		public override function SetWidth( iWidth:int ):void
		{
			super.SetWidth( iWidth );
			DrawBG();
			ResetState();			
		}

		public function SetButton( fSetFunction:Function ):void
		{
			fFunction = fSetFunction;
		}

		public function DoButton():void
		{
			if ( Boolean( fFunction ) ) { fFunction(); }
			Press();
		}

		public override function Dispose():void
		{
			super.Dispose();

			if ( sBackground ) { removeChild( sBackground ); };
			
			if ( bMouseOver )
			{
				MouseChange( false );
			}
			
			ctBGColor = null;
			sBackground = null;
			fFunction = null;
			
			uiNextButton = null;
			uiPreviousButton = null;

			removeEventListener( MouseEvent.MOUSE_UP, OnUp );
			removeEventListener( MouseEvent.MOUSE_DOWN, OnDown );
			removeEventListener( MouseEvent.MOUSE_OVER, OnOver );
			removeEventListener( MouseEvent.MOUSE_OUT, OnOut );
		}
		

		public function GoToNextButton():void
		{
			Out();
			if ( uiNextButton ) { uiNextButton.Over(); }
		}

		public function GoToPreviousButton():void
		{
			Out();
			if ( uiPreviousButton ) { uiPreviousButton.Over(); }
		}
		
		public function get NextButton():verBUIButton { return uiNextButton; }
		public function set NextButton( uiNext:verBUIButton ):void { uiNextButton = uiNext; }
		public function get PreviousButton():verBUIButton { return uiPreviousButton; }
		public function set PreviousButton( uiPrevious:verBUIButton ):void { uiPreviousButton = uiPrevious; }
	}
}