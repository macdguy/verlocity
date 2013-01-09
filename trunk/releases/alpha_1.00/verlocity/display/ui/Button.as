/*
 * ---------------------------------------------------------------
 * Verlocity
 * http://www.verlocityengine.com
 * 
 * This file is subject to the terms and conditions defined in
 * 'license.txt', which is part of this source code package.
 * ---------------------------------------------------------------
*/
package verlocity.display.ui
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import verlocity.utils.SysUtil;

	import flash.text.TextFormat;
	import flash.text.TextField;

	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;

	import verlocity.Verlocity;

	public class Button extends Text
	{
		protected var iState:int;

		protected var fFunction:Function;
		protected var bIsDisabled:Boolean;

		protected var bMouseOver:Boolean;

		protected var bIsSelected:Boolean;
		protected var fCondition:Function;
		protected var fDisableCondition:Function;

		protected var bIsHighlighted:Boolean;

		public const STATE_UP:int = 0;
		public const STATE_OUT:int = 1;
		public const STATE_OVER:int = 2;
		public const STATE_DOWN:int = 3;
		public const STATE_DISABLED:int = 4;		
		public const STATE_SELECTED:int = 5;

		public function Button( fSetFunction:Function = null, fSetCondition:Function = null, fSetDisableCondition:Function = null, bAddToKeyInput:Boolean = true ):void
		{
			addEventListener( MouseEvent.MOUSE_UP, OnUp );
			addEventListener( MouseEvent.MOUSE_DOWN, OnDown );
			addEventListener( MouseEvent.MOUSE_OVER, OnOver );
			addEventListener( MouseEvent.MOUSE_OUT, OnOut );
			
			SetButton( fSetFunction, fSetCondition, fSetDisableCondition );
			
			// Add to key input
			if ( bAddToKeyInput )
			{
				if ( Verlocity.IsValid( Verlocity.ui ) )
				{
					Verlocity.ui.RegisterButton( this );
				}
			}
		}
		
		/**
		 * Returns the current state of the button.
		 * @return
		 */
		public function GetState():int { return iState; }

		/**
		 * Resets the state of the button to its default.
		 */
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
		protected function Disabled():void {} // called when the button was disabled (occurs when you call Disable)
		protected function Selected():void {} // called when the button was selected (occurs when you call Select)
		protected function DrawBG():void
		{
			DrawRect( 0xFFFFFF, 1, 0, 0, false, 0, 0, 0, true, 10 );
		}

		/**
		 * Handles when the mouse click is released
		 * @param	me
		 */
		private function OnUp( me:MouseEvent ):void
		{
			if ( bIsDisabled ) { return; }

			iState = STATE_UP;
			Up();

			DoButton();
		}

		/**
		 * Handles when the mouse click is down
		 * @param	me
		 */
		private function OnDown( me:MouseEvent ):void
		{
			if ( bIsDisabled ) { return; }

			iState = STATE_DOWN;
			Down();
		}

		/**
		 * Handles when the mouse is hovering over
		 * @param	me
		 */
		private function OnOver( me:MouseEvent ):void
		{
			if ( bIsDisabled ) { return; }

			iState = STATE_OVER;
			MouseChange( true );
			Over();
		}

		/**
		 * Handles when the mouse leaves the area of the button
		 * @param	me
		 */
		private function OnOut( me:MouseEvent ):void
		{
			if ( bIsDisabled ) { return; }

			iState = STATE_OUT;
			MouseChange( false );
			Out();
		}
		
		/**
		 * Checks if the button should be selected/disabled based conditional functions.
		 * @param	e
		 */
		private function Update( e:Event ):void
		{
			if ( !SysUtil.IsVerlocityLoaded() || Verlocity.IsQuitting() ) { return; }

			if ( fCondition == null && fDisableCondition == null )
			{
				RemoveConditions();
				return;
			}

			if ( fCondition != null )
			{
				SetSelected( Boolean( fCondition ) && fCondition() );
			}
			
			if ( fDisableCondition != null )
			{
				SetEnabled( !( Boolean( fDisableCondition ) && fDisableCondition() ) );
			}
		}
		
		/**
		 * Handles when the mouse is over or out, updates cursor and status
		 * @param	bOver
		 */
		private function MouseChange( bOver:Boolean ):void
		{
			if ( bOver )
			{
				bMouseOver = true;
				Mouse.cursor = MouseCursor.BUTTON;

				// Override current key button with this
				if ( Verlocity.IsValid( Verlocity.ui ) )
				{
					Verlocity.ui.SetAsCurrentHighlightedButton( this );
				}
			}
			else
			{
				bMouseOver = false;
				Mouse.cursor = MouseCursor.ARROW;
			}
		}
		
		/**
		 * Sets the text to display on the button
		 * @param	sText Text to display
		 * @param	tfTextFormat The text format to use
		 */
		public override function SetText( sText:String, tfTextFormat:TextFormat = null ):void
		{
			super.SetText( sText, tfTextFormat );
			DrawBG();
			ResetState();
			
			if ( tfTextField ) { tfTextField.y = ( height / 2 ) - ( ( tfTextField.height ) / 2 ); }
		}

		/**
		 * Sets the width of the button
		 * @param	iWidth
		 */
		public override function SetWidth( iWidth:int ):void
		{
			super.SetWidth( iWidth );
			DrawBG();
			ResetState();			
		}

		/**
		 * Sets the function of the button
		 * @param	fSetFunction The function the button preforms
		 */
		/**
		 * Sets the functions of the button
		 * @param	fSetFunction The function the button preforms
		 * @param	fSetCondition The conditional to check if the button should be selected or not
		 */
		public function SetButton( fSetFunction:Function, fSetCondition:Function = null, fSetDisableCondition:Function = null ):void
		{
			fFunction = fSetFunction;
			fCondition = fSetCondition;
			fDisableCondition = fSetDisableCondition;

			if ( ( fCondition != null || fDisableCondition != null ) && 
				 !hasEventListener( Event.ENTER_FRAME ) )
			{
				addEventListener( Event.ENTER_FRAME, Update );
			}
		}

		/**
		 * Preforms the button's function
		 */
		public function DoButton():void
		{
			if ( Boolean( fFunction ) ) { fFunction(); }
			Press();
		}
		
		/**
		 * Enables/disables the button for use
		 */
		public function SetEnabled( bEnable:Boolean ):void
		{
			if ( bEnable )
			{
				if ( !bIsDisabled ) { return; }
			
				bIsDisabled = false;
				bIsSelected = false;

				iState = STATE_OUT;
				Out();
			}
			else // Disable
			{
				if ( bIsDisabled ) { return; }

				bIsDisabled = true;

				iState = STATE_DISABLED;
				MouseChange( false );
				
				Disabled();
			}
		}

		/**
		 * Enables/disables selection of the button.
		 * When a button is selected, it cannot be used.
		 * This is primarly for buttons that toggle settings.
		 */
		public function SetSelected( bSelect:Boolean ):void
		{
			if ( bSelect )
			{
				if ( bIsDisabled || bIsSelected || iState == STATE_SELECTED ) { return; }

				bIsDisabled = true;
				bIsSelected = true;

				iState = STATE_SELECTED;
				MouseChange( false );
				
				Selected();
			}
			else // Unselect
			{
				if ( !bIsSelected || iState != STATE_SELECTED ) { return; }
				
				bIsDisabled = false;
				bIsSelected = false;

				iState = STATE_OUT;
				Out();				
			}
		}

		/**
		 * Enables/disables highlighting the button, as if the mouse was over it.
		 * This is used for key controls.
		 */
		public function SetHighlighted( bHighlight:Boolean ):void
		{
			if ( bIsDisabled ) { return; }

			if ( bHighlight )
			{
				iState = STATE_OVER;
				Over();
			}
			else // Unhighlight
			{
				iState = STATE_OUT;
				Out();
			}

			bIsHighlighted = bHighlight;
		}
		
		/**
		 * Removes the conditions of the button.
		 */
		public function RemoveConditions():void
		{
			if ( hasEventListener( Event.ENTER_FRAME ) )
			{
				removeEventListener( Event.ENTER_FRAME, Update );
			}

			fCondition = null;
			fDisableCondition = null;
		}
		
		/**
		 * Returns if the button is disabled
		 * @return
		 */
		public function IsDisabled():Boolean
		{
			return bIsDisabled;
		}
		
		/**
		 * Returns if the button is selected
		 */
		public function IsSelected():Boolean
		{
			return bIsSelected;
		}
		
		/**
		 * Returns if the button is highlighted
		 * @return
		 */
		public function IsHighlighted():Boolean
		{
			return bIsHighlighted;
		}

		/**
		 * Destroys the entire button
		 */
		public override function Dispose():void
		{
			super.Dispose();
			
			if ( bMouseOver )
			{
				MouseChange( false );
			}
			
			if ( Verlocity.IsValid( Verlocity.ui ) )
			{
				Verlocity.ui.UnregisterButton( this );
			}

			fFunction = null;
			RemoveConditions();

			removeEventListener( MouseEvent.MOUSE_UP, OnUp );
			removeEventListener( MouseEvent.MOUSE_DOWN, OnDown );
			removeEventListener( MouseEvent.MOUSE_OVER, OnOver );
			removeEventListener( MouseEvent.MOUSE_OUT, OnOut );
		}
	}
}