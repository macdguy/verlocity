/*
	=========================================
			   Verlocity Engine
	=========================================
	|	Developed by Macklin Guy, 2011.		|
	|										|
	|										|
	-----------------------------------------
	verAchievements.as
	-----------------------------------------
	This component handles achievements.
*/
package VerlocityEngine.components 
{
	import flash.display.Shape;
	import flash.events.Event;
	import VerlocityEngine.Verlocity;
	import VerlocityEngine.VerlocityLanguage;
	import VerlocityEngine.VerlocitySettings;
	import VerlocityEngine.util.mathHelper;
	import flash.utils.getTimer;

	public class verAchievements extends Object
	{
		//********* VERLOCITY COMPONENT HEADER *********//
		/************************************************/
		public function IsValid():Boolean { return wasCreated; }
		private var wasCreated:Boolean;
		
		public function verAchievements():void
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
		private var objAcheivements:Object;
		private var vGUIAchievements:Vector.<Array>;
		private var guiAchiList:verGUIAchiList;
		private var sAchiBG:Shape;

		public const ACHI_DISPNAME:int = 0;
		public const ACHI_DESC:int = 1;
		public const ACHI_DATA:int = 2;
		public const ACHI_MAX:int = 3;
		public const ACHI_UNLOCKED:int = 4;
		
		
		/*
		 **************COMPONENT CREATION****************
		*/
		private function Construct():void
		{
			objAcheivements = new Object();
			
			Verlocity.stage.addEventListener( Event.ENTER_FRAME, Think );
		}


		/*
		 *************COMPONENT CONCOMMANDS**************
		*/
		private function Concommands():void
		{
			if ( !Verlocity.console ) { return; }

			Verlocity.console.Register( "achi_unlock", function( achievement:String ):void
			{
				if ( !Get( achievement ) ) { Verlocity.console.Output( "Achievement not valid.  Use achi_list to list all." ); return; }
				if ( IsUnlocked( achievement ) ) { Verlocity.console.Output( "Achievement already unlocked!" ); return; }

				Unlock( achievement );
			}, "Unlock an achievement." );

			Verlocity.console.Register( "achi_info", function( achievement:String ):void
			{
				if ( !Get( achievement ) ) { Verlocity.console.Output( "Achievement not valid.  Use achi_list to list all." ); return; }

				Verlocity.console.Output( "Achievement: " + Get( achievement )[ ACHI_DISPNAME ] + " | " +
					GetValue( achievement ) + "/" + GetRequired( achievement ) + " | " +
					Get( achievement )[ ACHI_DESC ] );
				
			}, "Gets information about an achievement." );

			Verlocity.console.Register( "achi_list", function():void
			{
				var aList:Array = new Array();

				for ( var sAchievement:String in objAcheivements )
				{
					aList.push( sAchievement );
				}

				Verlocity.console.Output( "Achievements: " + aList.toString() );

				aList.length = 0; aList = null;
			}, "Lists all the registered achievements." );
		}
		
		
		/*
		 ****************COMPONENT LOOP (NOT PART OF VERENGINE)******************
		*/
		private function Think( e:Event ):void
		{
			if ( !vGUIAchievements ) { return; }

			var iLength:int = vGUIAchievements.length;
			if ( iLength <= 0 ) { vGUIAchievements = null; return; } 

			var i:int = iLength - 1;
			var achi:Array;

			while( i >= 0 )
			{
				achi = vGUIAchievements[i];

				if ( achi[1] < getTimer() )
				{
					if ( achi[0].alpha > 0 )
					{
						achi[0].alpha -= 0.025;
						achi[0].y -= mathHelper.Ease( achi[0].y, Verlocity.ScrH, 20 );
					}
					else
					{
						achi[0].Dispose();
						Verlocity.layers.layerVerlocity.removeChild( achi[0] );

						delete vGUIAchievements[i];
						vGUIAchievements[i] = null;
						vGUIAchievements.splice( i, 1 );
					}
				}
				
				if ( achi && achi[0].alpha >= 1 )
				{
					var iYOffset:int = Verlocity.ScrH - 75 - ( i * achi[0].height );
					if ( iYOffset != achi[0].y )
					{
						achi[0].y -= mathHelper.Ease( achi[0].y, iYOffset, 10 );
					}
				}

				achi = null;
				i--;
			}	
		}
		
		
		/*
		 *************COMPONENT FUNCTIONS****************
		*/
		
		/*------------------ PRIVATE ------------------*/		
		private function AchievementUnlocked( sName:String ):void
		{
			objAcheivements[sName][ ACHI_UNLOCKED ] = true;

			// Get readable info
			var sDisplayName:String = objAcheivements[sName][ ACHI_DISPNAME ];
			var sDesc:String = objAcheivements[sName][ ACHI_DESC ];

			// Display GUI
			if ( !vGUIAchievements ) { vGUIAchievements = new Vector.<Array>(); }

			var achi:verGUIAchievement = new verGUIAchievement( sDisplayName, sDesc );
				achi.SetPos( Verlocity.ScrW - ( achi.width * VerlocitySettings.GUI_SCALE ), Verlocity.ScrH - ( vGUIAchievements.length * achi.height ) );
				achi.SetScale( VerlocitySettings.GUI_SCALE );
			Verlocity.layers.layerVerlocity.addChild( achi );
			

			vGUIAchievements.push( new Array( achi, getTimer() + 5000 ) );

			Verlocity.Trace( "Achievements", "Achievement unlocked! " + sDisplayName );
		}

		private function CheckAchievementStatus( sName:String ):void
		{
			if ( objAcheivements[sName][ ACHI_DATA ] >= objAcheivements[sName][ ACHI_MAX ] )
			{
				AchievementUnlocked( sName );
			}
		}
		
		private function IsValidAch( sName:String ):Boolean
		{
			// Check if the achievement exists.
			if ( objAcheivements[sName] == null )
			{
				return false;
			}

			// Check if we already unlocked the achievement.
			if ( objAcheivements[sName][ ACHI_UNLOCKED ] )
			{
				return false;
			}

			return true;
		}


		/*------------------ PUBLIC -------------------*/
		public function Register( sName:String, sDisplayName:String, sDesc:String, iUnlocksAt:int = 1 ):void
		{
			if ( objAcheivements[sName] != null )
			{
				Verlocity.Trace( "Achievements", VerlocityLanguage.T( "GenericDuplicate" ) );
				return;
			}

			objAcheivements[sName] = new Array( sDisplayName, sDesc, 0, iUnlocksAt, false );
			
			Verlocity.Trace( "Achievements", sName + VerlocityLanguage.T( "GenericAddSuccess" ) );
		}

		public function Unlock( sName:String ):void
		{
			if ( !IsValidAch( sName ) ) { return; }

			objAcheivements[sName][ ACHI_DATA ] = objAcheivements[sName][ ACHI_MAX ];
			AchievementUnlocked( sName );
		}

		public function Set( sName:String, iAmount:int = 1 ):void
		{
			if ( !IsValidAch( sName ) ) { return; }

			objAcheivements[sName][ ACHI_DATA ] = iAmount;
			CheckAchievementStatus( sName );
		}

		public function Increase( sName:String, iAmount:int = 1 ):void
		{
			if ( !IsValidAch( sName ) ) { return; }

			var oldData:int = objAcheivements[sName][ ACHI_DATA ];
			objAcheivements[sName][ ACHI_DATA ] = oldData + iAmount;

			CheckAchievementStatus( sName );
		}

		public function Reset( sName:String ):void
		{
			if ( !IsValidAch( sName ) ) { return; }
			
			objAcheivements[sName][ ACHI_DATA ] = 0;
			objAcheivements[sName][ ACHI_UNLOCKED ] = false;
		}
		
		public function IsUnlocked( sName:String ):Boolean
		{
			if ( objAcheivements[sName] == null ) { return false; }
			
			return objAcheivements[sName][ ACHI_UNLOCKED ];
		}
		
		public function GetValue( sName:String ):int
		{
			if ( objAcheivements[sName] == null ) { return -1; }

			return objAcheivements[sName][ ACHI_DATA ];
		}
		
		public function GetRequired( sName:String ):int
		{
			if ( objAcheivements[sName] == null ) { return -1; }

			return objAcheivements[sName][ ACHI_MAX ];
		}
		
		public function GetPercent( sName:String ):Number
		{
			if ( objAcheivements[sName] == null ) { return 0; }

			return objAcheivements[sName][ ACHI_DATA ] / objAcheivements[sName][ ACHI_MAX ];
		}
		
		public function Get( sName:String ):Array
		{
			return objAcheivements[sName];
		}
		
		public function GetAll():Object
		{
			return objAcheivements;
		}
		
		public function OpenGUI():void
		{
			if ( guiAchiList ) { CloseGUI(); }

			// Fade out content with background
			sAchiBG = new Shape();
				sAchiBG.graphics.beginFill( 0x000000, .75 );
					sAchiBG.graphics.drawRect( 0, 0, Verlocity.ScrW, Verlocity.ScrH );
				sAchiBG.graphics.endFill();
			Verlocity.layers.layerUI.addChild( sAchiBG );

			// Add GUI
			guiAchiList = new verGUIAchiList( Verlocity.ScrW / 2, Verlocity.ScrH / 2 );
				guiAchiList.SetScale( VerlocitySettings.GUI_SCALE );
			Verlocity.layers.layerUI.addChild( guiAchiList );
			
			// Disable pause menu, if available
			if ( Verlocity.pause.PauseMenu )
			{
				Verlocity.pause.PauseMenu.ToggleButtons( false );
			}
		}
		
		public function CloseGUI():void
		{
			if ( !guiAchiList ) { return; }

			// Remove the BG
			Verlocity.layers.layerUI.removeChild( sAchiBG );
			sAchiBG = null;

			// Remove GUI
			Verlocity.layers.layerUI.removeChild( guiAchiList );
			guiAchiList.Dispose();
			guiAchiList = null;
			
			// Enable pause menu, if available
			if ( Verlocity.pause.PauseMenu )
			{
				Verlocity.pause.PauseMenu.ToggleButtons( true );
			}
		}
		
		public function get IsGUIOpen():Boolean { return Boolean( guiAchiList ); }
	}
}


import VerlocityEngine.base.ui.verBUI;
import VerlocityEngine.base.ui.verBUIBar;
import VerlocityEngine.base.ui.verBUIScroll;
import VerlocityEngine.base.ui.verBUIText;
import flash.text.TextFormat;


/* Font Formats */
internal const nameFormat:TextFormat = new TextFormat( "_sans", 20, 0xFFFFFF, true );
internal const descFormat:TextFormat = new TextFormat( "_sans", 14, 0xFFFFFF );

/* Sizing */
internal const achiWidth:int = 255;
internal const achiHeight:int = 75;

internal class verGUIAchievement extends verBUI
{
	public function verGUIAchievement( sName:String, sDesc:String ):void
	{
		// BG
		DrawRect( 0x333333, .5, achiWidth, achiHeight );
		
		// Inside
		DrawRect( 0x222222, 1, achiWidth - 12, achiHeight - 12, true, 3, 0xE68C32, 1, false, NaN, 6, 6 );
		
		var achName:verBUIText = new verBUIText();
			achName.SetText( sName, nameFormat );
			achName.SetPos( 6, 8 );
			achName.SetWidth( achiWidth - 12 );
		addChild( achName );
		
		var achDesc:verBUIText = new verBUIText();
			achDesc.SetText( sDesc, descFormat );
			achDesc.SetPos( 24, 36 );
			achDesc.SetWidth( achiWidth - 48 );
			achDesc.SetHeight( achiHeight - 18 );
		addChild( achDesc );
	}

	public override function Dispose():void
	{
		for ( var i:int = 0; i < numChildren; i++ )
		{
			var child:verBUI = verBUI( getChildAt( i ) );
			child.Dispose();

			removeChildAt( i );
			i--;
		}
		
		Clear();
	}
}



import VerlocityEngine.base.ui.verBUIButton;

import VerlocityEngine.Verlocity;
import VerlocityEngine.VerlocitySettings;
import VerlocityEngine.VerlocityLanguage;


/* Font Formats */
internal const achiFormat:TextFormat = new TextFormat( "_sans", 30, 0xFFFFFF );
internal const achiMenuFormat:TextFormat = new TextFormat( "_sans", 16, 0xFFFFFF, true );

/* Sizing */
internal var menuWidth:int = 300;
internal var menuHeight:int = 400;

internal class verGUIAchiList extends verBUI
{
	public function verGUIAchiList( iPosX:int, iPosY:int ):void
	{
		// Achi Text
		var achiText:verBUIText = new verBUIText();
			achiText.SetText( VerlocityLanguage.T( "verAchievementsTitle" ), achiFormat );
			achiText.SetWidth( menuWidth );
		addChild( achiText );	

		// Achi List
		//======================
		var iPosYLast:int = ( achiText.y + achiText.height );
		var iCount:int = 0;
		
		// Scroll UI (incase the achievements are bigger)
		var iScrollHeight:int = 250 * VerlocitySettings.GUI_SCALE;
		
		var achiScroll:verBUIScroll = new verBUIScroll();
			achiScroll.SetPos( 0, iPosYLast );
			achiScroll.SetSize( menuWidth, iScrollHeight );
		addChild( achiScroll );

		// Display all achievements
		for ( var sAchievement:String in Verlocity.achievements.GetAll() )
		{
			var achi:verGUIAchiProgress = new verGUIAchiProgress( Verlocity.achievements.Get( sAchievement ) );
				achi.SetPos( 10, ( achiHeight + 4 ) * iCount );
			achiScroll.Insert( achi );

			iCount++;
		}

		// Check if we have achievements
		if ( iCount == 0 )
		{
			// No achievements
			var achiTextErr:verBUIText = new verBUIText();
				achiTextErr.SetPos( 0, iPosYLast + 2 );
				achiTextErr.SetText( VerlocityLanguage.T( "verAchievementsNone" ), achiMenuFormat );
				achiTextErr.SetWidth( menuWidth );
			addChild( achiTextErr );
			
			achiScroll.SetSize( menuWidth, achiTextErr.GetHeight() );
		}
		else
		{
			// Resize based on list amount if it's smaller
			var iAchieveListHeight:int = ( achiHeight + 4 ) * iCount;
			if ( iAchieveListHeight < iScrollHeight )
			{ 
				achiScroll.SetSize( menuWidth, iAchieveListHeight );
			}
		}

		// Resize menu height based on this
		iPosYLast = achiScroll.y + achiScroll.GetHeight();
		menuHeight = iPosYLast + 50;

		// Achi Menu BG
		// ======================
		graphics.beginFill( 0x000000, 1 );
			//graphics.lineStyle( 1, 0xFF9900 );
			graphics.drawRect( 0, 0, menuWidth, menuHeight );
		graphics.endFill();
		
		graphics.beginFill( 0x000000, 1 );
			graphics.drawRect( 0, 0, menuWidth, 35 );
			graphics.drawRect( 0, iPosYLast + 3, menuWidth, menuHeight - iPosYLast - 2 );

			graphics.lineStyle( 1, 0xFF9900 );
			graphics.drawRect( 0, 35, menuWidth, 1 );
			graphics.drawRect( 0, iPosYLast + 3, menuWidth, 1 );
		graphics.endFill();
		
		x = iPosX - ( menuWidth / 2 ) * VerlocitySettings.GUI_SCALE;
		y = iPosY - ( menuHeight / 2 ) * VerlocitySettings.GUI_SCALE;

		var achiClose:verGUIAchiButton = new verGUIAchiButton( VerlocityLanguage.T( "verAchievementsExit" ), achiMenuFormat, ( menuWidth / 2 ) - ( 170 / 2 ), menuHeight - 35,
			function():void {
				Verlocity.achievements.CloseGUI();
			}, 170 );
		addChild( achiClose );
	}
	
	public override function Dispose():void
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


internal const achiProgressHeight:int = 75;

internal class verGUIAchiProgress extends verBUI
{
	public function verGUIAchiProgress( aAchievement:Array ):void
	{
		// Highlight if achieved
		var achiColor:uint = 0xE68C32;
		
		if ( !aAchievement[ Verlocity.achievements.ACHI_UNLOCKED ] )
		{
			achiColor = 0xCCCCCC;
			alpha = .5;
		}
		
		var iWidth:int = menuWidth - 30;

		// BG
		DrawRect( 0x222222, 1, iWidth, achiProgressHeight, true, 2, achiColor );
		
		// Name
		var achName:verBUIText = new verBUIText();
			achName.SetText( aAchievement[ Verlocity.achievements.ACHI_DISPNAME ], achiMenuFormat );
			achName.SetPos( 0, 0 );
			achName.SetWidth( iWidth );
		addChild( achName );
		
		// Description
		var achDesc:verBUIText = new verBUIText();
			achDesc.SetText( aAchievement[ Verlocity.achievements.ACHI_DESC ], descFormat );
			achDesc.SetPos( 0, 20 );
			achDesc.SetWidth( iWidth );
		addChild( achDesc );
		
		// Progress Bar
		var nCurrentPercent:Number = aAchievement[ Verlocity.achievements.ACHI_DATA ] / aAchievement[ Verlocity.achievements.ACHI_MAX ];
		var achProgress:verBUIBar = new verBUIBar();
			achProgress.SetPos( 20, 50 );
			achProgress.CreateBar( iWidth - 40, 20, nCurrentPercent, 0xCCCCCC, 1, 0xFFFFFF, 1 );
		addChild( achProgress );

		// Progress Text
		var sProgress:String = aAchievement[ Verlocity.achievements.ACHI_DATA ] + " / " + aAchievement[ Verlocity.achievements.ACHI_MAX ];
		if ( aAchievement[ Verlocity.achievements.ACHI_UNLOCKED ] ) { sProgress = "UNLOCKED"; }

		var achTextProgress:verBUIText = new verBUIText();
			achTextProgress.SetText( sProgress, achiMenuFormat );
			if ( aAchievement[ Verlocity.achievements.ACHI_UNLOCKED ] ) { achTextProgress.SetTextColor( 0x00000 ); }
			achTextProgress.SetPos( achProgress.x, achProgress.y );
			achTextProgress.SetWidth( achProgress.width );
		addChild( achTextProgress );
	}

	public override function Dispose():void
	{
		for ( var i:int = 0; i < numChildren; i++ )
		{
			var child:verBUI = verBUI( getChildAt( i ) );
			child.Dispose();

			removeChildAt( i );
			i--;
		}
		
		Clear();
	}
}


internal class verGUIAchiButton extends verBUIButton
{
	private var iWidth:int;

	public function verGUIAchiButton( sText:String, tfFormat:TextFormat, iPosX:int, iPosY:int, fButton:Function, iSetWidth:int ):void
	{
		SetText( sText, tfFormat );
		SetButton( fButton );
		SetOriginPos( iPosX, iPosY );
		
		iWidth = iSetWidth;
		SetWidth( iWidth );
		
		tfTextField.y = .5;

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