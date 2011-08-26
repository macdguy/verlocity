/*
	=========================================
			   Verlocity Engine
	=========================================
	|	Developed by Macklin Guy, 2011.		|
	|										|
	|										|
	-----------------------------------------
	verConsole.as
	-----------------------------------------
	This class handles the console display and functions.
*/

package VerlocityEngine.components
{
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;

	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	
	import VerlocityEngine.Verlocity;
	import VerlocityEngine.VerlocityLanguage;
	import VerlocityEngine.VerlocityUtil;

	public final class verConsole extends Object
	{
		//********* VERLOCITY COMPONENT HEADER *********//
		/************************************************/
		public function IsValid():Boolean { return wasCreated; }
		private var wasCreated:Boolean;
		
		public function verConsole():void
		{
			if ( wasCreated ) { throw new Error( VerlocityLanguage.T( "ComponentLoadFail" ) ); return; } wasCreated = true;
			Construct();
		}
		/************************************************/
		/************************************************/
		
		/*
		 ****************COMPONENT VARS******************
		*/
		private var sprConsole:Sprite;
		private var taOutput:TextField;
		private var tiInput:TextField;
		private var txtFormat:TextFormat;

		private var bIsEnabled:Boolean;

		private var aHistory:Array;
		private var iCurHistory:int;
		
		private var objCommands:Object;
		private var guiRealTimeStats:verGUIRealTimeStats;
		
		private const CON_FUNC:int = 0;
		private const CON_DESC:int = 1;

		private const CON_HISTORYLIMIT:int = 10;
		
		
		/*
		 **************COMPONENT CREATION****************
		*/
		private function Construct():void
		{
			objCommands = new Object();
			
			// Console graphic
			sprConsole = new Sprite();
			sprConsole.name = "verConsole";
			sprConsole.y = Verlocity.ScrH - 150;

			// Realtime Stats
			guiRealTimeStats = new verGUIRealTimeStats();
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
				taOutput.width = Verlocity.ScrW - 10; taOutput.height = 120;
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
			Verlocity.stage.addEventListener( KeyboardEvent.KEY_DOWN, KeyHandle );		
			sprConsole.addEventListener( MouseEvent.MOUSE_OVER, ConsoleShow );
			sprConsole.addEventListener( MouseEvent.MOUSE_OUT, ConsoleHide );
			
			RegisterCommands();
		}
		
		
		/*
		 *************COMPONENT FUNCTIONS***************
		*/
		
		/*------------------ PRIVATE ------------------*/
		private function GetTextColor( sType:String = null ):String
		{
			switch( sType )
			{
				case "error": return "880000";
				case "warning": return "008888";
				case "notice": return "000088";
				case "command": return "888888";
			}

			return "FFFFFF";
		}

		
		// Console key input
		//====================
		private function KeyHandle( ke:KeyboardEvent ):void
		{
			if ( ke.keyCode == 192 || ke.keyCode == Keyboard.TAB ) // ~`
			{
				ToggleConsoleDisplay();
			}

			if ( !bIsEnabled || sprConsole.alpha != 1 ) { return; }
			
			switch( ke.keyCode )
			{
				case Keyboard.ENTER: ParseConCommand(); break;
				case Keyboard.UP: PreviousHistory(); break;
				case Keyboard.DOWN: NextHistory(); break;
			}
		}
		
		
		// Toggling console states
		//====================
		private function ConsoleShow( me:MouseEvent ):void
		{
			if ( !bIsEnabled ) { return; }

			sprConsole.alpha = 1;
			ToggleControls( false );
		}
		
		private function ConsoleHide( me:MouseEvent ):void
		{
			if ( !bIsEnabled ) { return; }

			sprConsole.alpha = .5;
			ToggleControls( true );
		}
		
		private function ToggleControls( bToggle:Boolean ):void
		{
			if ( bToggle )
			{
				if ( !Verlocity.engine.IsPaused )
				{
					Verlocity.input.KeyEnable();
					Verlocity.input.MouseEnable();
				}

				Verlocity.input.ForceFocus();
			}
			else
			{
				Verlocity.input.KeyDisable();
				Verlocity.input.MouseDisable();

				Verlocity.stage.focus = tiInput;				
			}
		}
		
		private function ToggleConsoleDisplay():void
		{
			if ( !bIsEnabled )
			{
				Verlocity.stage.addChild( sprConsole );

				guiRealTimeStats.visible = true;
				ToggleControls( false );
			}
			else
			{
				if ( Verlocity.stage.getChildByName( "verConsole" ) )
				{
					Verlocity.stage.removeChild( sprConsole );
				}				
				
				guiRealTimeStats.visible = false;				
				ToggleControls( true );
			}

			bIsEnabled = !bIsEnabled;
		}

		
		// Concommand handle
		//====================
		private function ParseConCommand():void
		{
			if ( tiInput.text.length <= 0 ) { return; }
			
			// Split based on spaces
			var args:Array = tiInput.text.split( " " );

			// Insert into history
			StoreToHistory();
			
			// Get concommand keyword and remove it from the array
			var command:String = args.shift();

			// Check if the command exists
			if ( !objCommands[command] )
			{ 
				Output( "'" + command + "' is not a valid command." );
				return;
			}

			var tempFunction:Function = new Function();
			tempFunction = objCommands[command][ CON_FUNC ];

			// Execute the command
			try
			{
				tempFunction.apply( this, args );
			}
			catch( e:ArgumentError )
			{
				if ( e.errorID == 1063 )
				{
					var expected:Number = Number( e.message.slice( e.message.indexOf( "Expected " ) + 9, e.message.lastIndexOf( "," ) ) );
					var lessArgs:Array = args.slice( 0, expected );

					Output( "Command failed. Expected " + expected + " arguments - got " + lessArgs.length );
					//tempFunction.apply( this, lessArgs );
				}
			}
			
			tempFunction = null;
		}
		
		private function SetInput( sString:String = "" ):void
		{
			tiInput.text = sString;
		}
		
		
		// Console history
		//====================
		private function StoreToHistory():void
		{
			if ( !aHistory ) { aHistory = new Array(); }

			aHistory.push( tiInput.text );
			SetInput();

			// Limit the history
			if ( aHistory.length >= CON_HISTORYLIMIT ) { aHistory.shift(); }
			
			iCurHistory = aHistory.length;
		}
		
		private function PreviousHistory():void
		{
			if ( !aHistory ) { return; }

			iCurHistory--;
			if ( iCurHistory < 0 ) { iCurHistory = ( aHistory.length - 1 ); }
			
			SetInput( aHistory[iCurHistory] );
		}
		
		private function NextHistory():void
		{
			if ( !aHistory ) { return; }

			iCurHistory++;
			if ( iCurHistory > ( aHistory.length - 1 ) ) { iCurHistory = 0; }
			
			SetInput( aHistory[iCurHistory] );		
		}


		// Built in concommands
		//====================
		private function RegisterCommands():void
		{
			Register( "clear", function()
			{
				SetInput(); taOutput.text = "";
				Output( "Cleared console." );
			}, "Clears the console output." );
		
			Register( "help", function()
			{
				Output( "\n--Available Commands--" );

				for ( var command:String in objCommands )
				{
					Output( command + " - " + objCommands[command][ CON_DESC ] );
				}

				Output( "----------------------" );

			}, "Displays a list of all the available console commands." );

			Register( "garbage", function()
			{
				var nOldMem:Number = Verlocity.stats.Memory;
				VerlocityUtil.GC();
				Output( "Ran garbage collector. Old mem: " + nOldMem + " | Current mem: " + Verlocity.stats.Memory );
				
				nOldMem = NaN;
			}, "Forces the garbage collector to clean up." );
		}


		/*------------------ PUBLIC -------------------*/		
		public function Output( sOutput:String, sCaller:String = null ):void
		{
			if ( sCaller )
			{
				sCaller = sCaller.toUpperCase();
				taOutput.appendText( "[" + sCaller + "] " + sOutput + "\n" );
			}
			else
			{
				taOutput.appendText( sOutput + "\n" );
			}
			
			taOutput.scrollV = taOutput.maxScrollV;
		}
		
		public function Register( sCommand:String, fFunction:Function, sDesc:String = "" ):void
		{
			if ( objCommands[sCommand] ) { return; }

			objCommands[sCommand] = new Array ( fFunction, sDesc );
		}
		
		public function IsEnabled():Boolean
		{
			return bIsEnabled;
		}

	}
}

import flash.display.Sprite;
import flash.events.Event;
import flash.text.TextField;
import flash.text.TextFormat;

import flash.utils.getTimer;

import VerlocityEngine.Verlocity;

internal class verGUIRealTimeStats extends Sprite
{
	private var iDelay:int;;

	private const fpsFormat = new TextFormat( "_sans", 24, 0xFFFFFF );
	private var fpsText:TextField;

	private const statFormat = new TextFormat( "_sans", 10, 0xFFFFFF );
	private var statText:TextField;
	
	private var sprAnalyzer:Sprite;

	private var nBeat:Number = 0;

	public function verGUIRealTimeStats():void
	{
		// FPS (top left)
		fpsText = new TextField();
			fpsText.x = 15; fpsText.y = 10;
			fpsText.width = 30; fpsText.height = 28;
			fpsText.selectable = false; fpsText.defaultTextFormat = fpsFormat;
			fpsText.background = true; fpsText.backgroundColor = 0x000000;
		Verlocity.stage.addChild( fpsText );

		// Stats
		statText = new TextField();
			statText.width = 125; statText.height = 125;
			statText.x = Verlocity.ScrW - statText.width - 5; statText.y = 1;
			statText.selectable = false; statText.defaultTextFormat = statFormat;
			statText.background = true; statText.backgroundColor = 0x222222;
		addChild( statText );
		
		// Analyzer
		sprAnalyzer = new Sprite();
			sprAnalyzer.x = statText.x;	sprAnalyzer.y = 44;
		addChild( sprAnalyzer );
		
		graphics.beginFill( 0xFFCC00 );
			graphics.drawRect( Verlocity.ScrW - statText.width - 6, 0, 1, 125 );
		graphics.endFill();

		addEventListener( Event.ENTER_FRAME, Think );
	}
	
	private function Think( e:Event ):void
	{
		fpsText.text = String( Verlocity.stats.FPS );

		if ( !visible ) { return; }
		
		var PausedText:String = String( Verlocity.engine.IsPaused );
		if ( !Verlocity.pause.IsPausable ) { PausedText = "disabled"; }
		
		statText.text = "FPS: " + Verlocity.stats.FPS + " / " + Verlocity.stage.frameRate +
		"\nMEM: " + Verlocity.stats.Memory + 
		"\nMS: " + Verlocity.stats.MS + 
		"\nEntities: " + Verlocity.ents.CountAll() + 
		"\nSounds: " + Verlocity.sound.CountAll() +
		"\nState: " + Verlocity.state.GetName() +
		"\nBeat: ";
		
		// Analyzer	
		sprAnalyzer.graphics.clear();

		// Beat
		sprAnalyzer.graphics.beginFill( 0xFFFFFF );
			if ( Verlocity.analyzer.Beat() )
			{
				nBeat = 1;
				sprAnalyzer.graphics.beginFill( 0xFF0000 );
			} 
			else
			{
				if ( nBeat > 0 ) { nBeat -= .05 }
			}
			sprAnalyzer.graphics.drawRect( 30, 42, 40 * nBeat, 5 );
		sprAnalyzer.graphics.endFill();

		// FFT
		sprAnalyzer.graphics.beginFill( 0xFFFFFF );
			var i:int = 0;
			while ( i < Verlocity.analyzer.GetFrequency().length )
			{
				sprAnalyzer.graphics.drawRect( 8 + ( 2 * i ), 75, 1, -10 * Verlocity.analyzer.GetFrequency()[i] );
				i++;
			}
		sprAnalyzer.graphics.endFill();
	}
}