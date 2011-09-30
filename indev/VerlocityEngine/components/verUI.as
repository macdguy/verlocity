/*
	This file is subject to the terms and conditions defined in
    file 'license.txt', which is part of this source code package.
*/

/*
	=========================================
			   Verlocity Engine
	=========================================
	|	Developed by Macklin Guy, 2011.		|
	|										|
	|										|
	-----------------------------------------
	verUI.as
	-----------------------------------------
	This class holds all the UI elements.  Buttons, text, etc.
	There are two types of UI - interactive and dynamic.
*/

package VerlocityEngine.components 
{
	import flash.text.TextFormat;
	import flash.events.ContextMenuEvent;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;

	import VerlocityEngine.Verlocity;
	import VerlocityEngine.VerlocityLanguage;
	import VerlocityEngine.VerlocitySettings;
	import VerlocityEngine.base.ui.*;

	public final class verUI extends Object
	{
		//********* VERLOCITY COMPONENT HEADER *********//
		/************************************************/		
		public function IsValid():Boolean { return wasCreated; }
		private var wasCreated:Boolean;

		public function verUI():void
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
		private var objUI:Object;
		private var currentButtons:Vector.<verBUIButton>;
		private var iCurrentButton:int;


		/*
		 **************COMPONENT CREATION****************
		*/
		private function Construct():void
		{
			objUI = new Object();
			iCurrentButton = -1;
			
			if ( VerlocitySettings.RIGHTCLICK_PROMOTE )
			{
				SetRightClickMenu();
			}
		}

		/*
		 *************COMPONENT CONCOMMANDS**************
		*/
		private function Concommands():void
		{
			if ( !Verlocity.console ) { return; }

			Verlocity.console.Register( "ui_remove_all", function():void
			{
				RemoveAll();
			}, "Removes all UI elements." );
		}


		/*
		 *************COMPONENT FUNCTIONS***************
		*/

		/*------------------ PRIVATE ------------------*/
		private function Store( sName:String, ui:verBUI ):void
		{
			objUI[sName] = ui;
			objUI[sName].name = sName;
		
			Verlocity.Trace( "UI", sName + VerlocityLanguage.T( "GenericAddSuccess" ) );
		}		

		private function SetRightClickMenu():void
		{
			var rightclickMenu:ContextMenu = new ContextMenu();
			rightclickMenu.hideBuiltInItems();

			var verlocityItem:ContextMenuItem = new ContextMenuItem( VerlocitySettings.RIGHTCLICK_PROMOTETEXT );
			verlocityItem.separatorBefore = true;
			verlocityItem.addEventListener( ContextMenuEvent.MENU_ITEM_SELECT, Promotion );

			function Promotion( ce:ContextMenuEvent ):void
			{
				navigateToURL( new URLRequest( VerlocitySettings.RIGHTCLICK_PROMOTEURL ) );
			}

			rightclickMenu.customItems.push( verlocityItem );
			Verlocity.layers.layerUI.contextMenu = rightclickMenu;
		}


		/*------------------ PUBLIC -------------------*/
		public function CreateButton( sName:String, sText:String, tfTextFormat:TextFormat, iPosX:int = 0, iPosY:int = 0, cButton:Class = null, fFunction:Function = null ):verBUIButton
		{
			if ( objUI[sName] != null )
			{
				Verlocity.Trace( "UI", VerlocityLanguage.T( "GenericDuplicate" ) );
				return null;
			}

			var ui:verBUIButton;
			if ( cButton == null ) { ui = new verBUIButton(); } else { ui = new cButton(); }

				ui.SetText( sText, tfTextFormat );
				if ( Boolean( fFunction ) ) { ui.SetButton( fFunction ); }
			
				ui.SetOriginPos( iPosX, iPosY );
			Verlocity.layers.layerUI.addChild( ui );
			
			if ( !currentButtons )
			{
				currentButtons = new Vector.<verBUIButton>();
			}
			currentButtons.push( ui );

			Store( sName, verBUI( ui ) );
			
			return ui;
		}

		public function CreateText( sName:String, sText:String, tfTextFormat:TextFormat, sLayer:String, iPosX:int = 0, iPosY:int = 0 ):verBUIText
		{
			if ( objUI[sName] != null )
			{
				Verlocity.Trace( "UI", VerlocityLanguage.T( "GenericDuplicate" ) );
				return null;
			}

			var ui:verBUIText = new verBUIText();
				ui.SetText( sText, tfTextFormat );
			ui.SetOriginPos( iPosX, iPosY );

			Store( sName, verBUI( ui ) );
			
			return ui;
		}

		public function Get( sName:String ):verBUI
		{
			return objUI[sName];
		}
		
		public function Remove( sName:String ):void
		{
			if ( objUI[sName] == null )
			{
				Verlocity.Trace( "UI", sName + VerlocityLanguage.T( "GenericMissing" ) );
				return;
			}

			if ( objUI[sName].parent )
			{
				objUI[sName].parent.removeChild( objUI[sName] );
			}
			
			// Remove buttons
			if ( currentButtons.length > 0 )
			{
				var i:int = currentButtons.length - 1;
				while ( i > 0 )
				{
					if ( currentButtons[i] == objUI[sName] )
					{
						delete currentButtons[i];
						currentButtons[i] = null;
						currentButtons.slice( i, 1 );
					}
					i--;
				}
			}

			delete objUI[sName];
			objUI[sName] = null;
			
			Verlocity.Trace( "UI", VerlocityLanguage.T( "GenericRemove" ) + sName );
		}
		
		public function RemoveAll():void
		{
			for ( var currentUI:String in objUI )
			{
				if ( objUI[currentUI] )
				{
					objUI[currentUI].Dispose();
					
					if ( objUI[currentUI].parent )
					{
						objUI[currentUI].parent.removeChild( objUI[currentUI] );
					}
				}
			}

			objUI = new Object();
			
			if ( currentButtons )
			{
				currentButtons.length = 0;
				currentButtons = null;
			}

			iCurrentButton = -1;
			
			Verlocity.Trace( "UI", VerlocityLanguage.T( "GenericRemoveAll" ) );
		}
		
		public function NextUIButton():void
		{
			if ( !currentButtons || currentButtons.length == 0 ) { return; }

			// Unselect previous button
			if ( iCurrentButton >= 0 && currentButtons[iCurrentButton] )
			{
				currentButtons[iCurrentButton].Unselect();
			}
			
			// Set current button forward
			if ( iCurrentButton < 0 )
			{
				iCurrentButton = 0;
			}
			else
			{
				iCurrentButton++;
			}
			
			// Loop if needed
			if ( iCurrentButton > ( currentButtons.length - 1 ) )
			{
				iCurrentButton = 0;
			}

			// Select new button
			if ( currentButtons[iCurrentButton] )
			{
				currentButtons[iCurrentButton].Select();
			}
		}

		public function PreviousUIButton():void
		{
			if ( !currentButtons || currentButtons.length == 0 ) { return; }

			// Unselect previous button
			if ( iCurrentButton >= 0 && currentButtons[iCurrentButton] )
			{
				currentButtons[iCurrentButton].Unselect();
			}

			// Set current button backwards
			iCurrentButton--;
			
			// Loop backwards if needed
			if ( iCurrentButton < 0 )
			{
				iCurrentButton = currentButtons.length - 1;
			}

			// Select new button
			if ( currentButtons[iCurrentButton] )
			{
				currentButtons[iCurrentButton].Select();
			}
		}
		
		public function EnterUIButton():void
		{
			if ( iCurrentButton < 0 || !currentButtons ) { return; }

			if ( currentButtons[iCurrentButton] )
			{
				currentButtons[iCurrentButton].DoButton();
			}
		}

	}

}