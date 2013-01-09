/*
 * ---------------------------------------------------------------
 * Verlocity
 * http://www.verlocityengine.com
 * 
 * This file is subject to the terms and conditions defined in
 * 'license.txt', which is part of this source code package.
 * ---------------------------------------------------------------
 * Component: verAchievements
 * Author: Macklin Guy
 * ---------------------------------------------------------------
*/
package verlocity.components
{
	import flash.display.Stage;
	import flash.events.Event;
	import flash.display.Shape;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;

	import verlocity.Verlocity;
	import verlocity.core.Component;
	import verlocity.utils.MathUtil;
	import verlocity.utils.GraphicsUtil;
	
	import verlocity.display.gui.Achievement;
	import verlocity.display.gui.AchievementList;

	/**
	 * Provides simple addition-based achievments.
	 * Achievements can be easily registered and when the player
	 * achieves them, a message on the bottom right will slide-in
	 * for a short duration.
	 * Additionally, this component comes with a GUI that displays
	 * a list of all achievements and their current progress.
	 */
	public final class verAchievements extends Component
	{
		private var dictAcheivements:Dictionary;

		private var vGUIAchievements:Vector.<Array>;
		private var guiAchiList:AchievementList;
		private var sAchiBG:Shape;

		public const ACHI_DISPNAME:int = 0;
		public const ACHI_DESC:int = 1;
		public const ACHI_DATA:int = 2;
		public const ACHI_MAX:int = 3;
		public const ACHI_UNLOCKED:int = 4;

		/**
		 * Constructor of the component.
		 * @param	sStage
		 */
		public function verAchievements( sStage:Stage ):void
		{
			// Setup component
			super( sStage, false );
			
			// Component-specific construction
			dictAcheivements = new Dictionary( true );
			stage.addEventListener( Event.ENTER_FRAME, Update );
		}

		/**
		 * Concommands of the component.
		 */
		protected override function _Concommands():void 
		{
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

				for ( var sAchievement:String in dictAcheivements )
				{
					aList.push( sAchievement );
				}

				Verlocity.console.Output( "Achievements: " + aList.toString() );

				aList.length = 0; aList = null;
			}, "Lists all the registered achievements." );
		}
		
		/**
		 * Updates the achievements
		 */
		private final function Update( e:Event ):void
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
						achi[0].y -= MathUtil.Ease( achi[0].y, Verlocity.ScrH, 20 );
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
						achi[0].y -= MathUtil.Ease( achi[0].y, iYOffset, 10 );
					}
				}

				achi = null;
				i--;
			}
		}

		/**
		 * Destructor of the component.
		 */
		public override function _Destruct():void
		{	
			// Component-specific destruction
			if ( dictAcheivements )
			{
				dictAcheivements = null;
			}

			CloseGUI();

			if ( vGUIAchievements )
			{
				vGUIAchievements.length = 0;
				vGUIAchievements = null;
			}
			
			stage.removeEventListener( Event.ENTER_FRAME, Update );
			
			// Destroy component
			super._Destruct();
		}

		/*================== COMPONENT ==================*/

		/*------------------- PRIVATE -------------------*/
		/**
		 * Displays a GUI when an achievement is unlocked
		 * @param	sName The achievement that was unlocked
		 */
		private final function AchievementUnlocked( sName:String ):void
		{
			dictAcheivements[sName][ ACHI_UNLOCKED ] = true;

			// Get readable info
			var sDisplayName:String = dictAcheivements[sName][ ACHI_DISPNAME ];
			var sDesc:String = dictAcheivements[sName][ ACHI_DESC ];

			// Display GUI
			if ( !vGUIAchievements ) { vGUIAchievements = new Vector.<Array>(); }

			var achi:Achievement = new Achievement( sDisplayName, sDesc );
				achi.SetPos( Verlocity.ScrW - ( achi.width * Verlocity.settings.GUI_SCALE ), Verlocity.ScrH - ( vGUIAchievements.length * achi.height ) );
				achi.SetScale( Verlocity.settings.GUI_SCALE );
			Verlocity.layers.layerVerlocity.addChild( achi );
			

			vGUIAchievements.push( new Array( achi, getTimer() + 5000 ) );

			Verlocity.Trace( "Achievements", "Achievement unlocked! " + sDisplayName );
		}

		/**
		 * Checks if the achievement was unlocked.
		 * @param	sName The achievement to check.
		 */
		private final function CheckAchievementStatus( sName:String ):void
		{
			if ( dictAcheivements[sName][ ACHI_DATA ] >= dictAcheivements[sName][ ACHI_MAX ] )
			{
				AchievementUnlocked( sName );
			}
		}
		
		/**
		 * Returns if an achievement is valid/not unlocked.
		 * @param	sName The achievement to check.
		 * @return
		 */
		private final function IsValidAch( sName:String ):Boolean
		{
			// Check if the achievement exists.
			if ( dictAcheivements[sName] == null )
			{
				return false;
			}

			// Check if we already unlocked the achievement.
			if ( dictAcheivements[sName][ ACHI_UNLOCKED ] )
			{
				return false;
			}

			return true;
		}

		/*===============================================*/
		
		/*------------------- PUBLIC --------------------*/
		/**
		 * Registers an achievement.
		 * @param	sName The acheivement's name.
		 * @param	sDisplayName The display name of the achievement.
		 * @param	sDesc The description of the achievment.
		 * @param	iUnlocksAt The value the achievement unlocks at.
		 */
		public final function Register( sName:String, sDisplayName:String, sDesc:String, iUnlocksAt:int = 1 ):void
		{
			if ( dictAcheivements[sName] != null )
			{
				Verlocity.Trace( "Achievements", Verlocity.lang.T( "GenericDuplicate" ) );
				return;
			}

			dictAcheivements[sName] = new Array( sDisplayName, sDesc, 0, iUnlocksAt, false );
			
			Verlocity.Trace( "Achievements", sName + Verlocity.lang.T( "GenericAddSuccess" ) );
		}

		/**
		 * Unlocks an achievement.
		 * @param	sName The achievement to unlock.
		 */
		public final function Unlock( sName:String ):void
		{
			if ( !IsValidAch( sName ) ) { return; }

			dictAcheivements[sName][ ACHI_DATA ] = dictAcheivements[sName][ ACHI_MAX ];
			AchievementUnlocked( sName );
		}

		/**
		 * Sets an achievement's value.
		 * @param	sName The achievement to set.
		 * @param	iAmount The value to set the achivement to.
		 */
		public final function Set( sName:String, iAmount:int = 1 ):void
		{
			if ( !IsValidAch( sName ) ) { return; }

			dictAcheivements[sName][ ACHI_DATA ] = iAmount;
			CheckAchievementStatus( sName );
		}

		/**
		 * Increases the value of the achievement.
		 * @param	sName The name of the achievement.
		 * @param	iAmount The amount to increase.
		 */
		public final function Increase( sName:String, iAmount:int = 1 ):void
		{
			if ( !IsValidAch( sName ) ) { return; }

			var oldData:int = dictAcheivements[sName][ ACHI_DATA ];
			dictAcheivements[sName][ ACHI_DATA ] = oldData + iAmount;

			CheckAchievementStatus( sName );
		}

		/**
		 * Resets an achievement and its data.
		 * @param	sName The achievment to reset.
		 */
		public final function Reset( sName:String ):void
		{
			if ( !IsValidAch( sName ) ) { return; }
			
			dictAcheivements[sName][ ACHI_DATA ] = 0;
			dictAcheivements[sName][ ACHI_UNLOCKED ] = false;
		}
		
		/**
		 * Returns if an achievement was unlocked.
		 * @param	sName The name of the achievement.
		 * @return
		 */
		public final function IsUnlocked( sName:String ):Boolean
		{
			if ( dictAcheivements[sName] == null ) { return false; }
			
			return dictAcheivements[sName][ ACHI_UNLOCKED ];
		}
		
		/**
		 * Returns the value of an achievement.
		 * @param	sName The name of the acheivement.
		 * @return
		 */
		public final function GetValue( sName:String ):int
		{
			if ( dictAcheivements[sName] == null ) { return -1; }

			return dictAcheivements[sName][ ACHI_DATA ];
		}
		
		/**
		 * Returns the required value of an achievement.
		 * @param	sName The name of the achievement.
		 * @return
		 */
		public final function GetRequired( sName:String ):int
		{
			if ( dictAcheivements[sName] == null ) { return -1; }

			return dictAcheivements[sName][ ACHI_MAX ];
		}
		
		/**
		 * Returns the percentage the achievement is at (val/required)
		 * @param	sName The name of the achievement.
		 * @return
		 */
		public final function GetPercent( sName:String ):Number
		{
			if ( dictAcheivements[sName] == null ) { return 0; }

			return dictAcheivements[sName][ ACHI_DATA ] / dictAcheivements[sName][ ACHI_MAX ];
		}
		
		/**
		 * Returns an acheivement table.
		 * @param	sName The name of the acheivement.
		 * @return
		 */
		public final function Get( sName:String ):Array
		{
			return dictAcheivements[sName];
		}
		
		/**
		 * Returns all registered achievements.
		 * @return
		 */
		public function GetAll():Object
		{
			return dictAcheivements;
		}
		
		/**
		 * Opens the achievement list GUI.
		 */
		public final function OpenGUI():void
		{
			if ( guiAchiList ) { CloseGUI(); }

			// Fade out content with background
			sAchiBG = new Shape();
				sAchiBG.graphics.beginFill( 0x000000, .75 );
					GraphicsUtil.DrawScreenRect( sAchiBG.graphics );
				sAchiBG.graphics.endFill();
			Verlocity.layers.layerUI.addChild( sAchiBG );

			// Add GUI
			guiAchiList = new AchievementList( Verlocity.ScrCenter.x, Verlocity.ScrCenter.y, stage );
				guiAchiList.SetScale( Verlocity.settings.GUI_SCALE );
			Verlocity.layers.layerUI.addChild( guiAchiList );
			
			// Disable pause menu, if available
			if ( Verlocity.IsValid( Verlocity.pause ) )
			{
				if ( Verlocity.pause.MenuGUI )
				{
					Verlocity.pause.MenuGUI.ToggleButtons( false );
				}
			}
		}
		
		/**
		 * Closes the achievement list GUI.
		 */
		public final function CloseGUI():void
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
			if ( Verlocity.IsValid( Verlocity.pause ) )
			{
				if ( Verlocity.pause.MenuGUI )
				{
					Verlocity.pause.MenuGUI.ToggleButtons( true );
				}
			}
		}
		
		/**
		 * Returns if the achievement GUI is open.
		 */
		public final function IsGUIOpen():Boolean { return Boolean( guiAchiList ); }

	}
}