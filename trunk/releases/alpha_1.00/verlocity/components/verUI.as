/*
 * ---------------------------------------------------------------
 * Verlocity
 * http://www.verlocityengine.com
 * 
 * This file is subject to the terms and conditions defined in
 * 'license.txt', which is part of this source code package.
 * ---------------------------------------------------------------
 * Component: verUI
 * Author: Macklin Guy
 * ---------------------------------------------------------------
*/
package verlocity.components
{
	import flash.display.Stage;
	import flash.events.ContextMenuEvent;
	import flash.text.TextFormat;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.utils.Dictionary;
	import verlocity.display.ui.Text;
	import verlocity.utils.ArrayUtil;

	import verlocity.core.Component;
	import verlocity.display.ui.UIElement;
	import verlocity.display.ui.Button;
	import verlocity.Verlocity;

	/**
	 * Handles all the UI elements.  Buttons, text, scroll bars, etc.
	 * Has built in methods for key navigation
	 * with mouse-based buttons.
	 */
	public final class verUI extends Component
	{
		private var dictUI:Dictionary;
		private var rightClickMenu:ContextMenu;
		private var currentButtons:Array;
		private var iCurrentButton:int;

		/**
		 * Constructor of the component.
		 * @param	sStage
		 */
		public function verUI( sStage:Stage ):void
		{
			// Setup component
			super( sStage, true );
			
			// Component-specific construction
			dictUI = new Dictionary( true );
			iCurrentButton = -1;

			SetupRightClickMenu( Verlocity.settings.RIGHTCLICK_PROMOTE );
		}

		/**
		 * Concommands of the component.
		 */
		protected override function _Concommands():void 
		{
			Verlocity.console.Register( "ui_remove_all", function():void
			{
				RemoveAll();
			}, "Removes all UI elements." );
		}

		/**
		 * Destructor of the component.
		 */
		public override function _Destruct():void
		{	
			// Component-specific destruction
			RemoveAll();

			SetRightClickMenu( null );
			rightClickMenu = null;
			
			// Destroy component
			super._Destruct();
		}

		/*================== COMPONENT ==================*/

		/*------------------- PRIVATE -------------------*/
		private final function Store( sName:String, ui:UIElement ):void
		{
			dictUI[sName] = ui;
			dictUI[sName].name = sName;
		
			Verlocity.Trace( sName + Verlocity.lang.T( "GenericAddSuccess" ), "UI" );
		}		

		/**
		 * Sets up the right click menu.
		 * @param	bPromote Show the promo url?
		 */
		private final function SetupRightClickMenu( bPromote:Boolean ):void
		{
			rightClickMenu = new ContextMenu();
			rightClickMenu.hideBuiltInItems();
			
			// Setup promotion item
			if ( bPromote )
			{
				var verlocityItem:ContextMenuItem = new ContextMenuItem( Verlocity.settings.RIGHTCLICK_PROMOTETEXT );
					verlocityItem.separatorBefore = true;
					verlocityItem.addEventListener( ContextMenuEvent.MENU_ITEM_SELECT, Promotion );
				rightClickMenu.customItems.push( verlocityItem );
			}

			SetRightClickMenu( rightClickMenu );
		}
		
		/**
		 * Sets the right click menu to the proper layers.
		 * @param	menu
		 */
		private final function SetRightClickMenu( menu:ContextMenu ):void
		{
			// Set menu to UI layer
			if ( Verlocity.IsValid( Verlocity.layers ) )
			{
				Verlocity.layers.layerUI.contextMenu = menu;
			}
		}

		/**
		 * Opens promotion URL 
		 * @param	ce
		 */
		private final function Promotion( ce:ContextMenuEvent ):void
		{
			navigateToURL( new URLRequest( Verlocity.settings.RIGHTCLICK_PROMOTEURL ) );
		}
		
		/**
		 * Overrides the current button
		 * @param	i
		 */
		private final function SetHighlightedButton( i:int ):void
		{
			if ( !ArrayUtil.IsInRange( currentButtons, i ) ) { return; }

			// Select new button
			var buttonNew:Button = currentButtons[i];

			// Find a non-disabled button
			if ( IsValidButton( buttonNew ) )
			{
				// Update current
				iCurrentButton = i;

				buttonNew.SetHighlighted( true );
			}
		}
		
		/**
		 * Returns if a button is valid and not disabled
		 * @param	button
		 * @return
		 */
		private final function IsValidButton( button:Button ):Boolean
		{
			return button != null && !button.IsDisabled() && !button.IsSelected();
		}

		/*===============================================*/
		
		/*------------------- PUBLIC --------------------*/
		/**
		 * Creates a button.
		 * @param	sName The name of the button
		 * @param	sText The text displayed on the button
		 * @param	tfTextFormat The text format of the button text
		 * @param	iPosX The X position to place the button
		 * @param	iPosY The Y position to place the button
		 * @param	cButton The button class (style of the button)
		 * @param	fFunction The function the button preforms
		 * @param	fCondition The conditional function that toggles the button off/on
		 * @return
		 */
		public final function CreateButton( sName:String, sText:String, tfTextFormat:TextFormat, iPosX:int = 0, iPosY:int = 0, cButton:Class = null, fFunction:Function = null, fCondition:Function = null ):Button
		{
			// Check for duplicate
			if ( dictUI[sName] != null )
			{
				Verlocity.Trace( Verlocity.lang.T( "GenericDuplicate" ), "UI" );
				return null;
			}

			var ui:Button;

			// Create button
			if ( cButton == null ) { ui = new Button(); } else { ui = new cButton(); }

			ui.SetText( sText, tfTextFormat );
			ui.SetButton( fFunction, fCondition )
			ui.SetPos( iPosX, iPosY );

			// Add to layers
			if ( Verlocity.IsValid( Verlocity.layers ) )
			{
				Verlocity.layers.layerUI.addChild( ui );
			}

			// Stores the UI button
			Store( sName, UIElement( ui ) );
			
			return ui;
		}

		/**
		 * Creates a text element.
		 * @param	sName The name of the text
		 * @param	sText The text to display
		 * @param	tfTextFormat The text format of the text
		 * @param	sLayer The layer to put this on
		 * @param	iPosX The X position of the text
		 * @param	iPosY The Y position of the text
		 * @return
		 */
		public final function CreateText( sName:String, sText:String, tfTextFormat:TextFormat, sLayer:String, iPosX:int = 0, iPosY:int = 0 ):Text
		{
			// Check for duplicate
			if ( dictUI[sName] != null )
			{
				Verlocity.Trace( Verlocity.lang.T( "GenericDuplicate" ), "UI" );
				return null;
			}

			// Create text object
			var ui:Text = new Text();
			ui.SetText( sText, tfTextFormat );
			ui.SetPos( iPosX, iPosY );

			// Store it
			Store( sName, UIElement( ui ) );
			
			return ui;
		}

		/**
		 * Gets and returns a UI element
		 * @param	sName
		 * @return
		 */
		public final function Get( sName:String ):UIElement
		{
			return dictUI[sName];
		}
		
		/**
		 * Removes a UI element
		 * @param	sName
		 */
		public final function Remove( sName:String ):void
		{
			// Check for duplicates
			if ( dictUI[sName] == null )
			{
				Verlocity.Trace( sName + Verlocity.lang.T( "GenericMissing" ), "UI" );
				return;
			}

			// Remove from the stage
			if ( dictUI[sName].parent )
			{
				dictUI[sName].parent.removeChild( dictUI[sName] );
			}

			// Remove button from list
			if ( currentButtons.length > 0 )
			{
				var i:int = currentButtons.length - 1;
				while ( i > 0 )
				{
					if ( currentButtons[i] == dictUI[sName] )
					{
						delete currentButtons[i];
						currentButtons[i] = null;
						currentButtons.slice( i, 1 );
					}
					i--;
				}
			}

			// Remove UI element
			delete dictUI[sName];
			dictUI[sName] = null;

			Verlocity.Trace( Verlocity.lang.T( "GenericRemove" ) + sName, "UI" );
		}
		
		/**
		 * Removes all UI elements
		 */
		public final function RemoveAll():void
		{
			// Remove all elements
			for ( var currentUI:String in dictUI )
			{
				if ( dictUI[currentUI] )
				{
					dictUI[currentUI].Dispose();
					
					if ( dictUI[currentUI].parent )
					{
						dictUI[currentUI].parent.removeChild( dictUI[currentUI] );
					}
				}
			}

			// Clear list
			dictUI = new Dictionary( true );
			
			// Clear button list
			if ( currentButtons )
			{
				currentButtons.length = 0;
				currentButtons = null;
			}
			iCurrentButton = -1;
			
			Verlocity.Trace( Verlocity.lang.T( "GenericRemoveAll" ), "UI" );
		}
		
		/**
		 * Stores the button for key input
		 * @param	button The button
		 */
		public final function RegisterButton( button:Button ):void
		{
			// Add to key input
			if ( !currentButtons )
			{
				currentButtons = new Array();
			}
			
			// Don't allow duplicates
			if ( ArrayUtil.Contains( currentButtons, button ) )
			{
				return;
			}

			currentButtons.push( button );
		}
		
		/**
		 * Removes button from the key input list
		 * @param	button The button
		 */
		public final function UnregisterButton( button:Button ):void
		{
			if ( !currentButtons ) { return; }
			
			var i:int = ArrayUtil.GetIndex( currentButtons, button );
			if ( i == -1 ) { return; }

			currentButtons.splice( i, 1 );
			
			if ( iCurrentButton == i )
			{
				iCurrentButton = -1;
			}
		}
		
		/**
		 * Sets the current button to be highlighted
		 * @param	button
		 */
		public final function SetAsCurrentHighlightedButton( button:Button ):void
		{
			var i:int = ArrayUtil.GetIndex( currentButtons, button );
			
			if ( i != -1 )
			{
				UnHighlightCurrentButton();
				SetHighlightedButton( i );
			}
		}
		
		/**
		 * Removes the current button highlight
		 */
		public final function UnHighlightCurrentButton():void
		{
			if ( iCurrentButton == -1 ) { return; }

			var button:Button = currentButtons[ iCurrentButton ];

			if ( iCurrentButton != -1 && button != null )
			{
				button.SetHighlighted( false );
			}
		}
		
		/**
		 * Selects the next UI button (used for key input)
		 */
		public final function HighlightNextButton():void
		{
			if ( !currentButtons || currentButtons.length == 0 ) { return; }

			var buttonLast:Button;
			var buttonNew:Button;

			// Unselect previous button
			buttonLast = currentButtons[ iCurrentButton ];
			UnHighlightCurrentButton();

			// Set current button forward
			if ( iCurrentButton < 0 ) { iCurrentButton = 0; } else { iCurrentButton++; }
			if ( iCurrentButton > ( currentButtons.length - 1 ) ) { iCurrentButton = 0; }


			// Select new button
			buttonNew = currentButtons[ iCurrentButton ];

			// Find a non-disabled button
			if ( IsValidButton( buttonNew ) )
			{
				buttonNew.SetHighlighted( true );
			}
			else
			{
				// None was found, keep searching
				if ( buttonLast != buttonNew )
				{
					HighlightNextButton();
				}
			}
		}

		/**
		 * Selects the previous UI button (used for key input)
		 */
		public final function HighlightPreviousButton():void
		{
			if ( !currentButtons || currentButtons.length == 0 ) { return; }

			var buttonLast:Button;
			var buttonNew:Button;

			// Unselect previous button
			buttonLast = currentButtons[ iCurrentButton ];
			UnHighlightCurrentButton();

			// Set current button backwards
			iCurrentButton--;
			if ( iCurrentButton < 0 ) { iCurrentButton = currentButtons.length - 1; }


			// Select new button
			buttonNew = currentButtons[ iCurrentButton ];

			// Find a non-disabled button
			if ( IsValidButton( buttonNew ) )
			{
				buttonNew.SetHighlighted( true );
			}
			else
			{
				// None was found, keep searching
				if ( buttonLast != buttonNew )
				{
					HighlightPreviousButton();
				}
			}
		}

		/**
		 * Activates UI button (used for key input)
		 */
		public final function EnterHighlightedButton():void
		{
			if ( iCurrentButton < 0 || !currentButtons ) { return; }

			var button:Button = currentButtons[ iCurrentButton ];
			if ( IsValidButton( button ) )
			{
				button.DoButton();
			}
		}
	}
}