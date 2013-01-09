/*
 * ---------------------------------------------------------------
 * Verlocity
 * http://www.verlocityengine.com
 * 
 * This file is subject to the terms and conditions defined in
 * 'license.txt', which is part of this source code package.
 * ---------------------------------------------------------------
 * Component: verConsole
 * Author: Macklin Guy
 * ---------------------------------------------------------------
*/
package verlocity.components
{
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;

	import verlocity.Verlocity;

	import verlocity.core.Component;
	import verlocity.input.KeyCode;
	import verlocity.display.gui.RealTimeStats;
	import verlocity.utils.DisplayUtil;
	import verlocity.utils.SysUtil;
	import verlocity.utils.StringUtil;

	/**
	 * In-game debugging console with real-time stat display and logging.
	 * The console supports registering console commands.
	 * In order to enable the console, you must first enable Settings.DEBUG
	 */
	public final class verConsole extends Component
	{
		private var sprConsole:Sprite;
		private var taOutput:TextField;
		private var tiInput:TextField;
		private var txtFormat:TextFormat;

		private var bIsEnabled:Boolean;

		private var aHistory:Array;
		private var iCurHistory:int;

		private var dictCommands:Dictionary;
		private var guiRealTimeStats:RealTimeStats;
		
		private const CON_FUNC:int = 0;
		private const CON_DESC:int = 1;
		private const CON_HISTORYLIMIT:int = 10;

		/**
		 * Constructor of the component.
		 * @param	sStage
		 */
		public function verConsole( sStage:Stage ):void
		{
			// Setup component
			super( sStage );
			
			// Component-specific construction

			// Console graphic
			sprConsole = new Sprite();
			sprConsole.y = Verlocity.ScrH - 150;

			// Realtime Stats
			guiRealTimeStats = new RealTimeStats( sStage );
			guiRealTimeStats.visible = false;
			sprConsole.addChild( guiRealTimeStats );

			// Background
			sprConsole.graphics.beginFill( 0x333333 );
				sprConsole.graphics.drawRect( 0, 0, Verlocity.ScrW, 150 );
			sprConsole.graphics.endFill();

			// Yellow Line
			sprConsole.graphics.beginFill( 0xFFCC00 );
				sprConsole.graphics.drawRect( 0, 0, Verlocity.ScrW, 1 );
			sprConsole.graphics.endFill();

			// Text format
			txtFormat = new TextFormat( "_sans", 14 );

			// Output text
			taOutput = new TextField();
				taOutput.x = 5; taOutput.y = 5;
				taOutput.width = Verlocity.ScrW - 110; taOutput.height = 120;
				taOutput.selectable = true;
				//taOutput.background = true; taOutput.backgroundColor = 0x222222;
				//taOutput.border = true; taOutput.borderColor = 0x333333;
				taOutput.textColor = 0xCCCCCC; taOutput.defaultTextFormat = txtFormat;
			sprConsole.addChild( taOutput );

			// Input text
			tiInput = new TextField();
				tiInput.x = 5, tiInput.y = 125;
				tiInput.width = Verlocity.ScrW - 10; tiInput.height = 20;
				tiInput.type = TextFieldType.INPUT; tiInput.selectable = true;
				tiInput.background = true; tiInput.backgroundColor = 0x222222;
				//tiInput.border = true; tiInput.borderColor = 0x333333;
				tiInput.textColor = 0xFFFFFF;
				tiInput.restrict = "A-Za-z0-9.'/ -_";
				tiInput.defaultTextFormat = txtFormat;
			sprConsole.addChild( tiInput );

			// Listeners
			sStage.addEventListener( KeyboardEvent.KEY_DOWN, KeyHandle );		
			sprConsole.addEventListener( MouseEvent.MOUSE_OVER, ActivateConsole );
			sprConsole.addEventListener( MouseEvent.MOUSE_OUT, DeactivateConsole );
			tiInput.addEventListener( MouseEvent.MOUSE_OVER, FocusInput );
			tiInput.addEventListener( MouseEvent.MOUSE_OUT, UnFocusInput );

			// Concommands
			dictCommands = new Dictionary( true );
			RegisterCommands();
		}

		/**
		 * Destructor of the component.
		 */
		public override function _Destruct():void
		{	
			// Component-specific destruction

			// Realtime Stats
			guiRealTimeStats.Dispose();
			guiRealTimeStats = null;

			txtFormat = null;
			taOutput = null;
			tiInput = null;

			// Listeners
			stage.removeEventListener( KeyboardEvent.KEY_DOWN, KeyHandle );
			sprConsole.removeEventListener( MouseEvent.MOUSE_OVER, ActivateConsole );
			sprConsole.removeEventListener( MouseEvent.MOUSE_OUT, DeactivateConsole );
			tiInput.removeEventListener( MouseEvent.MOUSE_OVER, FocusInput );
			tiInput.removeEventListener( MouseEvent.MOUSE_OUT, UnFocusInput );

			// Console graphic
			DisplayUtil.RemoveAllChildren( sprConsole );
			if ( sprConsole && sprConsole.stage )
			{
				stage.removeChild( sprConsole );
			}
			sprConsole =  null;

			// Concommands
			dictCommands = null;

			// Destroy component
			super._Destruct();
		}

		/*================== COMPONENT ==================*/

		/*------------------- PRIVATE -------------------*/
		/**
		 * Handles console key presses (tab/~, enter, up, down)
		 * @param	ke
		 */
		private final function KeyHandle( ke:KeyboardEvent ):void
		{
			if ( ke.keyCode == KeyCode.TILDE || ke.keyCode == KeyCode.TAB )
			{
				ToggleConsoleDisplay();
			}

			if ( !bIsEnabled || sprConsole.alpha != 1 ) { return; }
			
			switch( ke.keyCode )
			{
				case KeyCode.ENTER: ParseConCommand(); break;
				case KeyCode.UP: PreviousHistory(); break;
				case KeyCode.DOWN: NextHistory(); break;
			}
		}

		/**
		 * Activates the console
		 * @param	me
		 */
		private final function ActivateConsole( me:MouseEvent = null ):void
		{
			if ( !bIsEnabled || !sprConsole ) { return; }

			sprConsole.alpha = 1;
			EnableControls( false );
		}
		
		/**
		 * Deactivates the console
		 * @param	me
		 */
		private final function DeactivateConsole( me:MouseEvent = null ):void
		{
			if ( !bIsEnabled || !sprConsole ) { return; }

			sprConsole.alpha = .5;
			EnableControls( true );
		}
		
		/**
		 * Handles when the input is focused.
		 * @param	me
		 */
		private final function FocusInput( me:MouseEvent = null ):void
		{
			stage.focus = tiInput;
			Verlocity.input.SetCursor( Verlocity.input.CURSOR_IBEAM );
		}
		
		/**
		 * Handles when the input is unfocused.
		 * @param	me
		 */
		private final function UnFocusInput( me:MouseEvent = null ):void
		{
			Verlocity.input.SetCursor( Verlocity.input.CURSOR_AUTO );
		}
		
		/**
		 * Enables/disables controls and focuses keyboard on console input
		 * @param	bEnable
		 */
		private final function EnableControls( bEnable:Boolean ):void
		{
			if ( bEnable )
			{
				if ( !Verlocity.engine.IsPaused() )
				{
					Verlocity.input.EnableKeys( true );
					Verlocity.input.EnableMouse( true );
				}

				Verlocity.input.ForceFocus();
			}
			else
			{
				Verlocity.input.EnableKeys( false );
				Verlocity.input.EnableMouse( false );

				stage.focus = tiInput;
			}
		}
		
		/**
		 * Toggles display of console.
		 */
		private final function ToggleConsoleDisplay():void
		{
			if ( !bIsEnabled )
			{
				stage.addChild( sprConsole );

				guiRealTimeStats.visible = true;
				stage.focus = tiInput
			}
			else
			{
				if ( sprConsole && sprConsole.stage )
				{
					stage.removeChild( sprConsole );
				}
				
				guiRealTimeStats.visible = false;				
				EnableControls( true );
			}

			bIsEnabled = !bIsEnabled;
		}

		
		// Concommand handle
		//====================
		/**
		 * Preforms concommand.
		 */
		private final function ParseConCommand():void
		{
			if ( tiInput.text.length <= 0 ) { return; }
			
			// Split based on spaces
			var args:Array = tiInput.text.split( " " );

			// Insert into history
			StoreToHistory();
			
			// Get concommand keyword and remove it from the array
			var command:String = args.shift();

			// Check if the command exists
			if ( !dictCommands[command] || !dictCommands[command][ CON_FUNC ] )
			{ 
				Output( "'" + command + "' is not a valid command." );
				return;
			}

			var tempFunction:Function = new Function();
			tempFunction = dictCommands[command][ CON_FUNC ];

			// Execute the command
			try
			{
				tempFunction.apply( this, args );
			}
			catch( e:ArgumentError )
			{
				if ( e.errorID == 1063 )
				{
					var expected:int = int( e.message.slice( e.message.indexOf( "Expected " ) + 9, e.message.lastIndexOf( "," ) ) );
					var lessArgs:Array = args.slice( 0, expected );

					Output( "Command failed. Expected " + expected + " arguments - got " + lessArgs.length );
					//tempFunction.apply( this, lessArgs );
				}
			}
			
			tempFunction = null;
		}
		
		/**
		 * Sets the input text.
		 * @param	sString
		 */
		private final function SetInput( sString:String = "" ):void
		{
			tiInput.text = sString;
		}

		
		// Console history
		//====================
		/**
		 * Stores the input text to history.
		 */
		private final function StoreToHistory():void
		{
			if ( !aHistory ) { aHistory = new Array(); }

			aHistory.push( tiInput.text );

			// Clear input
			SetInput();

			// Limit the history
			if ( aHistory.length >= CON_HISTORYLIMIT ) { aHistory.shift(); }
			
			iCurHistory = aHistory.length;
		}
		
		/**
		 * Sets the input to the previous concommand in the history
		 */
		private final function PreviousHistory():void
		{
			if ( !aHistory ) { return; }

			iCurHistory--;
			if ( iCurHistory < 0 ) { iCurHistory = ( aHistory.length - 1 ); }
			
			SetInput( aHistory[iCurHistory] );
			tiInput.setSelection( tiInput.text.length, tiInput.text.length );
		}
		
		/**
		 * Sets the input to the next concommand in the history
		 */
		private final function NextHistory():void
		{
			if ( !aHistory ) { return; }

			iCurHistory++;
			if ( iCurHistory > ( aHistory.length - 1 ) ) { iCurHistory = 0; }
			
			SetInput( aHistory[iCurHistory] );
			tiInput.setSelection( tiInput.text.length, tiInput.text.length );
		}


		// Built in concommands
		//====================
		/**
		 * Registers default concommands.
		 */
		private final function RegisterCommands():void
		{
			Register( "clear", function():void
			{
				SetInput(); taOutput.text = "";
				Output( "Cleared console." );
			}, "Clears the console output." );
		
			Register( "help", function():void
			{
				Output( "\n--Available Commands--" );

				for ( var command:String in dictCommands )
				{
					Output( command + " - " + dictCommands[command][ CON_DESC ] );
				}

				Output( "----------------------" );

			}, "Displays a list of all the available console commands." );

			Register( "garbage", function():void
			{
				var nOldMem:Number = Verlocity.stats.Memory;
				SysUtil.GC();
				Output( "Ran garbage collector. Old mem: " + nOldMem + " | Current mem: " + Verlocity.stats.Memory );
				
				nOldMem = NaN;
			}, "Forces the garbage collector to clean up." );
		}

		/*===============================================*/

		/*------------------- PUBLIC --------------------*/
		/**
		 * Outputs a string into the console window.  Use Verlocity.Trace for expanded features.
		 * @param	sOutput The string to output.
		 */
		public final function Output( sOutput:String ):void
		{
			if ( !taOutput ) { trace( sOutput ); return; }
			
			var sFormattedOutput:String = sOutput;

			// Add timestamp
			sFormattedOutput = StringUtil.FormattedTime( Verlocity.CurTime() / 1000 ) + " | " + sOutput;

			// Append output
			taOutput.appendText( sFormattedOutput + "\n" );

			// Scroll down
			taOutput.scrollV = taOutput.maxScrollV;
		}

		/**
		 * Registers a concommand
		 * @param	sCommand The concommand
		 * @param	fFunction The function to preform
		 * @param	sDesc The description of the concommand (for the help function)
		 */
		public final function Register( sCommand:String, fFunction:Function, sDesc:String = "" ):void
		{
			if ( dictCommands[sCommand] ) { return; }

			dictCommands[sCommand] = new Array ( fFunction, sDesc );
		}
		
		/**
		 * Returns if the console is active/displaying.
		 */
		public final function IsActive():Boolean
		{
			return bIsEnabled;
		}
		
		/**
		 * Returns if the console is keyboard focused.
		 */
		public final function IsFocused():Boolean
		{
			return stage.focus == tiInput;
		}
	}
}