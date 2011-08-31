/*
	=========================================
			   Verlocity Engine
	=========================================
	|	Developed by Macklin Guy, 2011.		|
	|										|
	|										|
	-----------------------------------------
	verPause.as
	-----------------------------------------
	Handles pausing and unpausing.
*/
package VerlocityEngine.components
{
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.utils.getTimer;
	
	import VerlocityEngine.Verlocity;
	import VerlocityEngine.VerlocityLanguage;
	import VerlocityEngine.VerlocitySettings;
	import VerlocityEngine.VerlocityHotkeys;
	import VerlocityEngine.VerlocityMessages;
	
	import VerlocityEngine.base.verBMovieClip;

	public class verPause 
	{
		//********* VERLOCITY COMPONENT HEADER *********//
		/************************************************/
		public function IsValid():Boolean { return wasCreated; }
		private var wasCreated:Boolean;
		
		public function verPause():void
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
		private var bPauseEnabled:Boolean;
		private var iPauseDelay:int;
		
		private var guiPauseMenu:DisplayObject;
		private var sPauseBG:Shape;

		private var vPauseMenu:Vector.<Array>;
		
		
		/*
		 **************COMPONENT CREATION****************
		*/
		private function Construct():void
		{
			bPauseEnabled = true;
			vPauseMenu = new Vector.<Array>();

			Verlocity.stage.addEventListener( KeyboardEvent.KEY_DOWN, PauseKeyHandle );
			Verlocity.stage.addEventListener( Event.DEACTIVATE, PauseLostFocusHandle );		
		}

		/*
		 *************COMPONENT CONCOMMANDS**************
		*/
		private function Concommands():void
		{
			if ( !Verlocity.console ) { return; }

			Verlocity.console.Register( "pause", function()
			{
				Pause();
			}, "Pauses the engine." );

			Verlocity.console.Register( "resume", function()
			{
				Resume();
			}, "Resumes the engine." );
		}
		
		
		/*
		 *************COMPONENT FUNCTIONS***************
		*/
		
		/*------------------ PRIVATE ------------------*/
		private function PauseKeyHandle( ke:KeyboardEvent ):void
		{
			if ( !bPauseEnabled || ( Verlocity.console && Verlocity.console.IsEnabled ) || iPauseDelay > getTimer() ) { return; }

			iPauseDelay = getTimer() + 1000;

			if ( VerlocityHotkeys.Get( "VerlocityPause" ) == ke.keyCode )
			{
				PauseToggle();
			}
		}
		
		private function PauseLostFocusHandle( e:Event )
		{
			if ( !bPauseEnabled || ( Verlocity.console && Verlocity.console.IsEnabled ) ) { return; }

			Pause();
		}
		
		private function PauseToggle():void
		{
			if ( Verlocity.engine.IsPaused )
			{
				Resume();
			}
			else
			{
				Pause();
			}
		}
		
		private function PauseAnimation( bPause:Boolean ):void
		{
			if ( Verlocity.stage.numChildren <= 0 ) { return; }

			var i:int = 0;
			while ( i < Verlocity.stage.numChildren )
			{
				if ( Verlocity.stage.getChildAt( i ) is Sprite )
				{
					var child:Sprite = Sprite( Verlocity.stage.getChildAt( i ) );

					var k:int = 0;
					while ( k < child.numChildren )
					{
						if ( child.getChildAt( k ) is verBMovieClip )
						{
							var mc:verBMovieClip = verBMovieClip( child.getChildAt( k ) );

							if ( bPause )
							{
								mc.pause();
							}
							else
							{
								mc.resume();
							}
						}
						mc = null;
						k++;
					}

					child = null;
				}

				i++;
			}
		}

		/*------------------ PUBLIC -------------------*/
		public function Pause():void
		{
			if ( Verlocity.engine.IsPaused ) { return; }

			Verlocity.engine.Pause();
			Verlocity.sound.PauseAll();

			Verlocity.input.KeyDisable();
			Verlocity.input.MouseDisable();

			//Verlocity.stage.frameRate = 15;
			PauseAnimation( true );

			// Fade out content with background
			sPauseBG = new Shape();
				sPauseBG.graphics.beginFill( 0x000000, .75 );
					sPauseBG.graphics.drawRect( 0, 0, Verlocity.ScrW, Verlocity.ScrH );
				sPauseBG.graphics.endFill();
			Verlocity.layers.layerUI.addChild( sPauseBG );
			
			// Add the pause menu
			if ( VerlocitySettings.SHOW_PAUSEMENU )
			{
				guiPauseMenu = new verGUIPauseMenu( Verlocity.ScrW / 2, Verlocity.ScrH / 2 );
			}
			else
			{
				if ( VerlocitySettings.PAUSEMENU_GUI )
				{
					guiPauseMenu = new VerlocitySettings.PAUSEMENU_GUI();
				}
			}
			if ( guiPauseMenu )
			{
				Verlocity.layers.layerUI.addChild( guiPauseMenu );
			}


			VerlocityMessages.Create( VerlocityLanguage.T( "VerlocityPause" ) );
		}

		public function Resume():void
		{
			if ( !Verlocity.engine.IsPaused ) { return; }

			Verlocity.engine.Resume();
			Verlocity.sound.ResumeAll();

			Verlocity.input.KeyEnable();
			Verlocity.input.MouseEnable();
			Verlocity.input.ForceFocus();

			//Verlocity.stage.frameRate = VerlocitySettings.FRAMERATE;
			PauseAnimation( false );
			
			// Remove the BG
			Verlocity.layers.layerUI.removeChild( sPauseBG );
			sPauseBG = null;
			
			// Remove the pause menu
			if ( guiPauseMenu )
			{
				Verlocity.layers.layerUI.removeChild( guiPauseMenu );
				if ( !VerlocitySettings.PAUSEMENU_GUI ) { verGUIPauseMenu( guiPauseMenu ).Dispose(); }
				guiPauseMenu = null;
			}

			VerlocityMessages.Create( VerlocityLanguage.T( "VerlocityUnpause" ) );
		}

		public function Enable():void
		{
			bPauseEnabled = true;
		}

		public function Disable():void
		{
			bPauseEnabled = false;
		}
		
		public function AddPauseMenuItem( sName:String, fFunction:Function ):void
		{
			vPauseMenu.push( new Array( sName, fFunction ) );
		}
		
		public function RemovePauseMenuItem( sName:String ):void
		{
			var iLength:int = vPauseMenu.length;
			if ( iLength == 0 ) { return; }

			for ( var i:int = 0; i < iLength; i++ )
			{
				if ( vPauseMenu[i][0] == sName )
				{
					delete vPauseMenu[i];
					vPauseMenu[i] = null;
					vPauseMenu.splice( i, 1 );				
				}
			}
		}
		
		public function ClearPauseMenuItems():void
		{
			vPauseMenu.length = 0;
		}
		
		public function get PauseMenu():Vector.<Array> { return vPauseMenu; }
		public function get IsPausable():Boolean { return bPauseEnabled; }
		public function get IsPaused():Boolean { return Verlocity.engine.IsPaused; }
	}
}


import flash.display.DisplayObject;
import flash.display.Shape;
import flash.display.Sprite;
import flash.text.Font;
import flash.text.TextField;
import flash.text.TextFormat;
import VerlocityEngine.base.ui.verBUI;
import VerlocityEngine.base.ui.verBUIText;
import VerlocityEngine.base.ui.verBUIButton;
import VerlocityEngine.base.ui.verBUIScroll;

import VerlocityEngine.Verlocity;

internal class verGUIPauseMenu extends Sprite
{
	private var menuWidth:int = 200;
	private var menuHeight:int = 200;

	private const pauseFormat = new TextFormat( "_sans", 30, 0xFFFFFF );
	private const pauseMenuFormat = new TextFormat( "_sans", 16, 0xFFFFFF, true );
	private const pauseResumeFormat = new TextFormat( "_sans", 20, 0xFFFFFF, true );
	private const pauseTagFormat = new TextFormat( "_sans", 12, 0xFFFFFF, true );

	public function verGUIPauseMenu( iPosX:int, iPosY:int ):void
	{
		// Pause Text
		var pauseText:verBUIText = new verBUIText();
			pauseText.SetText( "PAUSED", pauseFormat );
			pauseText.SetWidth( menuWidth );
		addChild( pauseText );	

		// Pause Menu
		//======================
		var puiResume:verGUIPauseMenuButton = new verGUIPauseMenuButton( "RESUME", pauseResumeFormat, 5, 40,
			function() {
				Verlocity.pause.Resume();
			} );
		addChild( puiResume );
		
		var iLength:int = Verlocity.pause.PauseMenu.length;
		var iPosYLast:int = ( puiResume.y + puiResume.height );
		if ( iLength > 0 )
		{
			for ( var i:int = 0; i < iLength; i++ )
			{
				var puiMenuItem:verGUIPauseMenuButton = new verGUIPauseMenuButton( Verlocity.pause.PauseMenu[i][0], pauseMenuFormat, 5, 75 + ( i * 25 ), Verlocity.pause.PauseMenu[i][1] );
				addChild( puiMenuItem );
				
				if ( i + 1 == iLength ) { iPosYLast = puiMenuItem.y + puiMenuItem.height; }
			}
		}
		
		// Pause Menu Height Calc
		//=======================
		menuHeight = iPosYLast + 105;

		// Pause Menu BG
		// ======================
		graphics.beginFill( 0x000000, .25 );
			//graphics.lineStyle( 1, 0xFF9900 );
			graphics.drawRect( 0, 0, menuWidth, menuHeight );
		graphics.endFill();
		
		graphics.beginFill( 0x000000, .75 );
			graphics.drawRect( 0, 0, menuWidth, 35 );
			graphics.drawRect( 0, iPosYLast + 10, menuWidth, 105 );

			graphics.lineStyle( 1, 0xFF9900 );
			graphics.drawRect( 0, 35, menuWidth, 1 );
			graphics.drawRect( 0, iPosYLast + 10, menuWidth, 1 );
		graphics.endFill();
		
		x = iPosX - ( menuWidth / 2 ); y = iPosY - ( menuHeight / 2 );
		
		

		// Small Settings
		//======================
		var iSettingsY:int = iPosYLast + 30;

		// QUALITY
		var qualityText:verBUIText = new verBUIText();
			qualityText.SetText( "QUALITY", pauseTagFormat );
			qualityText.SetPos( 15, iPosYLast + 12 );
			qualityText.SetWidth( 70 );
		addChild( qualityText );

		var puiLowQ:verGUIPauseButton = new verGUIPauseButton( "L", pauseMenuFormat, 15, iSettingsY,
			function() {
				Verlocity.SetQuality( 1 );
			} );
		addChild( puiLowQ );

		var puiMedQ:verGUIPauseButton = new verGUIPauseButton( "M", pauseMenuFormat, 40, iSettingsY,
			function() {
				Verlocity.SetQuality( 2 );
			} );
		addChild( puiMedQ );

		var puiHighQ:verGUIPauseButton = new verGUIPauseButton( "H", pauseMenuFormat, 65, iSettingsY,
			function() {
				Verlocity.SetQuality( 3 );
			} );
		addChild( puiHighQ );


		// SOUND
		var soundText:verBUIText = new verBUIText();
			soundText.SetText( "VOLUME", pauseTagFormat );
			soundText.SetPos( 115, iPosYLast + 12 );
			soundText.SetWidth( 70 );
		addChild( soundText );

		var puiSndDown:verGUIPauseButton = new verGUIPauseButton( "-", pauseMenuFormat, 115, iSettingsY,
			function() {
				Verlocity.sound.VolumeDown();
			} );
		addChild( puiSndDown );

		var puiSndMute:verGUIPauseButton = new verGUIPauseButton( "M", pauseMenuFormat, 140, iSettingsY,
			function() {
				if ( Verlocity.sound.IsMuted ) { Verlocity.sound.UnMute(); } else { Verlocity.sound.Mute(); }
			} );
		addChild( puiSndMute );

		var puiSndUp:verGUIPauseButton = new verGUIPauseButton( "+", pauseMenuFormat, 165, iSettingsY,
			function() {
				Verlocity.sound.VolumeUp();
			} );
		addChild( puiSndUp );


		// MISC
		var puiAchievements:verGUIPauseButton = new verGUIPauseButton( "ACHIEVEMENTS", pauseMenuFormat, 15, iSettingsY + 30,
			function() {
				trace( "omg achievements" );
			}, 170 );
		addChild( puiAchievements );

		var puiFullscreen:verGUIPauseButton = new verGUIPauseButton( "FULLSCREEN", pauseMenuFormat, 15, iSettingsY + 55,
			function() {
				Verlocity.SetFullscreen( !Verlocity.IsFullscreen );
			}, 170 );
		addChild( puiFullscreen );
	}
	
	public function Dispose():void
	{
		for ( var i:int = 0; i < numChildren; i++ )
		{
			var child:verBUI = verBUI( getChildAt( i ) );
			child.Dispose();

			removeChildAt( i );
			i--;
		}
	}
}

internal class verGUIPauseMenuButton extends verBUIButton
{
	private var iWidth:int = 190;

	public function verGUIPauseMenuButton( sText:String, tfFormat:TextFormat, iPosX:int, iPosY:int, fButton:Function ):void
	{
		SetText( sText, tfFormat );
		SetButton( fButton );
		SetOriginPos( iPosX, iPosY );
		SetWidth( iWidth );

		DrawBG();
	}

	protected override function DrawBG():void
	{
		Clear();
		DrawRect( 0xFFFFFF, 0, iWidth, tfTextField.height );
	}

	protected override function Down():void
	{
		Clear();
		DrawRect( 0xCA7900, .25, iWidth, tfTextField.height );
		SetTextColor( 0xFF9900 );
	}

	protected override function Up():void { Over(); }
	protected override function Over():void
	{
		Clear();
		DrawRect( 0xFF9900, .75, iWidth, tfTextField.height );
		SetTextColor( 0xFFFFFF );
	}

	protected override function Out():void
	{
		Clear();
		DrawRect( 0xFFFFFF, 0, iWidth, tfTextField.height );
		SetTextColor( 0xFFFFFF );
	}	
}

internal class verGUIPauseButton extends verBUIButton
{
	private var iWidth:int;

	public function verGUIPauseButton( sText:String, tfFormat:TextFormat, iPosX:int, iPosY:int, fButton:Function, iSetWidth:int = 20 ):void
	{
		SetText( sText, tfFormat );
		SetButton( fButton );
		SetOriginPos( iPosX, iPosY );
		
		iWidth = iSetWidth;
		SetWidth( iWidth );
		
		tfTextField.y = .5;

		if ( iWidth == 20 ) { tfTextField.x = 2; }
		if ( tfTextField.text == "M" ) { tfTextField.x = 1.5; }
		
		DrawBG();
	}

	protected override function DrawBG():void
	{
		Clear();
		DrawRect( 0xFFFFFF, 0, iWidth, 20, true, 2, 0xFFFFFF );
	}

	protected override function Down():void
	{
		Clear();
		DrawRect( 0xCA7900, 1, iWidth, 20, true, 2, 0xFFFFFF );
		SetPos( originX, originY + 2 );
	}

	protected override function Up():void { Over(); }
	protected override function Over():void
	{
		Clear();
		DrawRect( 0xFF9900, 1, iWidth, 20, true, 2, 0xFFFFFF );
		ResetPos();
	}

	protected override function Out():void
	{
		Clear();
		DrawRect( 0xFFFFFF, 0, iWidth, 20, true, 2, 0xFFFFFF );
		ResetPos();
	}	
}