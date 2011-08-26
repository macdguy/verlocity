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
		private var uiCurrentButton:verBUIButton;


		/*
		 **************COMPONENT CREATION****************
		*/
		private function Construct():void
		{
			objUI = new Object();
			
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

			Verlocity.console.Register( "ui_remove_all", function()
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
		public function CreateButton( sName:String, sText:String, tfTextFormat:TextFormat, iPosX:int = 0, iPosY:int = 0, cButton:Class = null, fFunction:Function = null, bStarting:Boolean = false ):verBUIButton
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
			
			if ( bStarting ) { uiCurrentButton = ui; }

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
			uiCurrentButton = null;
			
			Verlocity.Trace( "UI", VerlocityLanguage.T( "GenericRemoveAll" ) );
		}
		
		// The following functions do not work as intended.
		// This is a known bug and is being worked on.
		public function NextUIButton():void
		{
			if ( uiCurrentButton )
			{
				uiCurrentButton.GoToNextButton();
				uiCurrentButton = uiCurrentButton.NextButton;
			}
		}

		public function PreviousUIButton():void
		{
			if ( uiCurrentButton )
			{
				uiCurrentButton.GoToNextButton();
				uiCurrentButton = uiCurrentButton.PreviousButton;
			}			
		}
		
		public function EnterUIButton():void
		{
			if ( uiCurrentButton )
			{
				uiCurrentButton.DoButton();
			}
		}

	}

}