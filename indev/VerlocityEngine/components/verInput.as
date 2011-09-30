/*
	This file is subject to the terms and conditions defined in
    file 'license.txt', which is part of this source code package.
*/

package VerlocityEngine.components
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.ui.Keyboard;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Mouse;
	
	import VerlocityEngine.Verlocity;
	import VerlocityEngine.VerlocityLanguage;
	import VerlocityEngine.VerlocityHotkeys;
	import VerlocityEngine.VerlocitySettings;
	
	import VerlocityEngine.util.mathHelper;

	public final class verInput extends Object
	{
		//********* VERLOCITY COMPONENT HEADER *********//
		/************************************************/
		public function IsValid():Boolean { return wasCreated; }
		private var wasCreated:Boolean;
		
		public function verInput():void
		{
			if ( wasCreated ) { throw new Error( VerlocityLanguage.T( "ComponentLoadFail" ) ); return; } wasCreated = true;
			Construct();
			Concommands();
		}
		/************************************************/
		/************************************************/
		
		/*
		 ****************COMPONENT VARS******************
		*/
		private var objKeysDown:Object;
		private var objKeyHistory:Object;
		private var aComboKeys:Array;

		private var bMouseDown:Boolean;
		private var iMx:int, iMy:int;
		private var nMouseWheelDelta:Number;

		private var bHasKeyControls:Boolean = true;
		private var bHasMouseControls:Boolean = true;

		
		/*
		 **************COMPONENT CREATION****************
		*/
		private function Construct():void
		{
			objKeysDown = new Object();
			objKeyHistory = new Object();
			aComboKeys = new Array();

			// We don't want to remove these ever.
			Verlocity.stage.addEventListener( KeyboardEvent.KEY_DOWN, KeyPressed );
			Verlocity.stage.addEventListener( KeyboardEvent.KEY_UP, KeyReleased );

			Verlocity.stage.addEventListener( MouseEvent.MOUSE_MOVE, MouseMove );
			Verlocity.stage.addEventListener( MouseEvent.CLICK, MouseClick );
			Verlocity.stage.addEventListener( MouseEvent.MOUSE_DOWN, MouseDown );
			Verlocity.stage.addEventListener( MouseEvent.MOUSE_UP, MouseUp );
			Verlocity.stage.addEventListener( MouseEvent.MOUSE_WHEEL, MouseWheelDelta );
		}

		/*
		 *************COMPONENT CONCOMMANDS**************
		*/
		private function Concommands():void
		{
			if ( !Verlocity.console ) { return; }
		}


		/*
		 *************COMPONENT FUNCTIONS***************
		*/
		
		/*------------------ PRIVATE ------------------*/
		private function KeyPressed( ke:KeyboardEvent ):void
		{
			if ( VerlocitySettings.DISABLE_TAB )
			{			
				if ( ke.keyCode == Keyboard.TAB )
				{
					ke.currentTarget.tabChildren = false;
				}
			}

			if ( !HasKeyControl ) { return; }

			if ( objKeysDown )
			{
				objKeysDown[ ke.keyCode ] = true;
			}
			
			aComboKeys.unshift( ke.keyCode );
			aComboKeys.length = VerlocitySettings.KEY_MAXCOMBO;

			if ( Verlocity.state )
			{
				Verlocity.state.SkipSplash();
				
				if ( Verlocity.state.Get() )
				{
					Verlocity.state.Get().KeyInput( ke.keyCode );
				}
			}
		}

		private function KeyReleased( ke:KeyboardEvent ):void
		{
			if ( !HasKeyControl ) { return; }

			StoreKeyHistory( ke.keyCode );

			delete objKeysDown[ ke.keyCode ];
		}
		
		private function StoreKeyHistory( keyCode:uint ):void
		{
			// Check if we have history, create if we don't
			if ( objKeyHistory[ keyCode ] == null )
			{
				objKeyHistory[ keyCode ] = new Vector.<int>();
			}

			// Get history
			var vHistory:Vector.<int> = objKeyHistory[ keyCode ];

			// Store last
			vHistory.unshift( Verlocity.engine.CurTime() );
			if ( vHistory.length > 2 ) { vHistory.length = 2; }
		}
		
		private function MouseMove( me:MouseEvent ):void
		{
			if ( !HasMouseControl ) { return; }

			iMx = me.stageX; iMy = me.stageY;
		}

		private function MouseClick( me:MouseEvent ):void
		{
			if ( !HasMouseControl ) { return; }

			if ( Verlocity.state && Verlocity.state.Get() )
			{
				Verlocity.state.Get().MouseInput();
			}
		}
		
		private function MouseDown( me:MouseEvent ):void
		{
			if ( !HasMouseControl ) { return; }

			bMouseDown = true;
		}
		
		private function MouseUp( me:MouseEvent ):void
		{
			if ( !HasMouseControl ) { return; }

			bMouseDown = false;
		}
		
		private function MouseWheelDelta( me:MouseEvent ):void
		{
			if ( !HasMouseControl ) { return; }
			
			nMouseWheelDelta = me.delta;
		}


		/*------------------ PUBLIC -------------------*/
		public function KeyIsDown( key:* ):Boolean
		{
			if ( !objKeysDown ) { return false; }

			if ( key is uint )
			{
				return Boolean( key in objKeysDown );
			}
			else if ( key is String )
			{
				return Boolean( VerlocityHotkeys.Get( key ) in objKeysDown );
			}

			return false;
		}
		
		public function KeyIsDoubleTapped( key:* ):Boolean
		{
			if ( !objKeyHistory ) { return false; }

			var vHistory:Vector.<int>;

			// Get the history
			if ( key is uint )
			{
				if ( key in objKeyHistory )
				{
					vHistory = objKeyHistory[ key ];
				}
			}
			else if ( key is String )
			{
				if ( VerlocityHotkeys.Get( key ) in objKeyHistory )
				{
					vHistory = objKeyHistory[ VerlocityHotkeys.Get( key ) ];
				}
			}

			// History invalid or too short
			if ( !vHistory || vHistory.length < 2 ) { return false; }
			
			// Store key times
			var keyFirst:int = vHistory[1];
			var keyLast:int = vHistory[0];
			
			// Delete history, we don't need it anymore
			if ( key is uint ) { delete objKeyHistory[key]; }
			if ( key is String ) { delete objKeyHistory[ VerlocityHotkeys.Get( key ) ]; }

			// Compare difference in time
			if ( ( keyLast - keyFirst ) <= VerlocitySettings.KEY_DOUBLETAP_TIME )
			{
				return true;
			}

			return false;
		}
		
		public function ClearKeyHistory():void
		{
			objKeyHistory = new Object();
		}
		
		public function GetKeyHistory():Object
		{
			return objKeyHistory;
		}
		
		public function KeyCombo( aKeyCombo:Array ):Boolean
		{
			if ( aKeyCombo.length > aComboKeys.length)
			{
				return false;
			}
			else
			{
				var i:int = 0;
				while ( i < aKeyCombo.length )
				{
					if ( aKeyCombo[i] != aComboKeys[i] )
					{
						return false;
					}
					i++;
				}
			}

			return true;
		}
		
		public function MouseIsDown():Boolean
		{
			return bMouseDown;
		}
		
		public function MouseWheel():Number
		{
			return nMouseWheelDelta;
		}

		public function get Mx():int { return iMx; }
		public function get My():int { return iMy; }

		public function MouseIsInside( spr:Sprite ):Boolean
		{
			return iMx >= spr.x && iMx < spr.width && iMy < spr.y && iMy >= spr.height;
		}

		public function KeyEnable():void
		{
			if ( bHasKeyControls ) { return; }

			bHasKeyControls = true;

			objKeysDown = new Object();
			objKeyHistory = new Object();
			aComboKeys = new Array();
		}

		public function KeyDisable():void
		{
			if ( !bHasKeyControls ) { return; }

			bHasKeyControls = false;

			objKeysDown = null;
			objKeyHistory = null;
			aComboKeys.length = 0;
		}
		
		public function MouseEnable():void
		{
			if ( bHasMouseControls ) { return; }
			
			bHasMouseControls = true;
		}
		
		public function MouseDisable():void
		{
			if ( !bHasMouseControls ) { return; }
			
			bHasMouseControls = false;
		}
		
		public function MouseHide():void
		{
			Mouse.hide();
		}
		
		public function MouseShow():void
		{
			Mouse.show();
		}
		
		
		public function ForceFocus():void
		{
			Verlocity.stage.focus = Verlocity.stage;
		}

		public function get HasKeyControl():Boolean { return bHasKeyControls; }
		public function get HasMouseControl():Boolean { return bHasMouseControls; }

	}
}