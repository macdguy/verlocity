/*
 * ---------------------------------------------------------------
 * Verlocity
 * http://www.verlocityengine.com
 * 
 * This file is subject to the terms and conditions defined in
 * 'license.txt', which is part of this source code package.
 * ---------------------------------------------------------------
*/
package verlocity
{
	import flash.display.Stage;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;

	import verlocity.components.*;
	import verlocity.settings.SettingsManager;
	import verlocity.settings.SettingsData;
	import verlocity.lang.LanguageManager;
	import verlocity.input.KeyManager;
	import verlocity.display.DisplayManager;
	import verlocity.display.MessageManager;
	import verlocity.core.Singleton;
	import verlocity.core.SingletonManager;
	import verlocity.core.Component;
	import verlocity.core.ComponentManager;
	import verlocity.core.PluginManager;
	import verlocity.core.Global;
	import verlocity.core.Game;
	import verlocity.utils.ObjectUtil;
	import verlocity.utils.SysUtil;
	import verlocity.events.EventPlugin;

	public final class Verlocity extends Singleton
	{
		private static var bLoaded:Boolean;
		private static var stage:Stage;

		private static var G_:Global;

		private static var gLoadedGame:Game;
		private static var gGame:Game;
		private static var bIsQuitting:Boolean;

		private static var settingsManager:SettingsManager;
		private static var displayManager:DisplayManager;
		private static var languageManager:LanguageManager;
		private static var keyManager:KeyManager;
		private static var messageManager:MessageManager;
		private static var componentManager:ComponentManager;
		private static var pluginManager:PluginManager;

		/**
		 * Creates the Verlocity engine.
		 * @param	sStage The stage
		 * @param	sSettings Settings data (if none specified, will use defaults)
		 */
		public function Verlocity( sStage:Stage, sSettings:SettingsData = null, gSetGame:Game = null ):void
		{
			// Make sure this is a singleton
			super();

			trace( "Creating Verlocity..." );

			// Update stage and global library
			stage = sStage;
			G_ = Global.getInstance();
			gLoadedGame = gSetGame; // Set the game to load

			// Create the settings
			settingsManager = new SettingsManager( stage, sSettings );
			trace( "Output now internal; Set Settings.DEBUG to true to see all outputs." );

			// Debug mode
			if ( Verlocity.settings.DEBUG )
			{
				trace( "Debug mode is on!" );
			}
			
			// Create the display manager.
			Trace( "Creating display manager...", "Verlocity" );
			displayManager = new DisplayManager( stage );
			displayManager._ApplyFlashSettings();

			// Create the language manager.
			Trace( "Creating language manager...", "Verlocity" );
			languageManager = new LanguageManager( Verlocity.settings.DEFAULT_LANGUAGE );

			// Create the key manager.
			Trace( "Creating key manager...", "Verlocity" );
			keyManager = new KeyManager( Verlocity.settings.DEFAULT_KEYLIST );

			// Create the message manager.
			Trace( "Creating message manager...", "Verlocity" );
			messageManager = new MessageManager( stage );

			// Create the component manager.
			Trace( "Creating component manager...", "Verlocity" );
			componentManager = new ComponentManager();
			
			// Load plugins
			Trace( "Loading plugins...", "Verlocity" );
			pluginManager = new PluginManager();
			pluginManager._SetupPlugins( stage );
			
			// Determine if we need to load plugins...
			if ( !pluginManager.PluginsToLoad )
			{
				_FinishLoad();
			}
		}
		
		/**
		 * Finish loading the final parts of Verlocity.
		 */
		public static function _FinishLoad():void
		{
			if ( bLoaded ) { return; }

			// Load components
			Trace( "Registring components...", "Verlocity" );
			RegisterComponents();
			Trace( "Components registered.", "Verlocity" );

			// Finish loading of Verlocity
			trace( "!!!!!Verlocity created successfully!!!!!" );
			bLoaded = true;
			
			// Set loaded game
			if ( gLoadedGame )
			{
				SetGame( gLoadedGame );
				gLoadedGame = null;
			}
		}


		/*
		 =====================COMPONENTS=====================
		*/

		/**
		 * Registers all the components.
		 */
		private static function RegisterComponents():void
		{
			// Create the console
			if ( Verlocity.settings.DEBUG )
			{
				Trace( "Creating console..." );
				componentManager.Register( new verConsole( stage ) );
			}

			// Core components
			componentManager.Register( new verEngine( stage ) );
			componentManager.Register( new verStates( stage ), verEngine );
			componentManager.Register( new verCamera( stage ) );
			componentManager.Register( new verLayers( stage ), verCamera );
			componentManager.Register( new verEnts(), verEngine, verLayers );
			componentManager.Register( new verBitmap() );
			componentManager.Register( new verPhysics(), verEnts );
			componentManager.Register( new verCollision(), verEnts );
			componentManager.Register( new verInput( stage ), verEngine );
			componentManager.Register( new verSound(), verEngine );
			componentManager.Register( new verPause( stage ), verEngine, verSound, verInput, verEnts );

			// Additional components
			componentManager.Register( new verSave() );
			componentManager.Register( new verVariables() );
			componentManager.Register( new verStats( stage ) );
			componentManager.Register( new verUI( stage ) );
			componentManager.Register( new verSoundAnalyzer(), verEngine );
			componentManager.Register( new verAchievements( stage ) );
			componentManager.Register( new verSoundscape(), verEngine, verSound );
			componentManager.Register( new verParticles(), verEngine, verBitmap );
		}

		/*
		 * EASY ACCESS GETTERS
		 * NOTE: Developers, create your own getter with your components.
		*/
		public static function get console():verConsole { return componentManager.Get( verConsole ); }
		public static function get engine():verEngine { return componentManager.Get( verEngine ); }
		public static function get camera():verCamera { return componentManager.Get( verCamera ); }
		public static function get layers():verLayers { return componentManager.Get( verLayers ); }
		public static function get state():verStates { return componentManager.Get( verStates ); }
		public static function get input():verInput	{ return componentManager.Get( verInput ); }
		public static function get stats():verStats { return componentManager.Get( verStats ); }
		public static function get ents():verEnts { return componentManager.Get( verEnts ); }
		public static function get bitmap():verBitmap { return componentManager.Get( verBitmap ); }
		public static function get phys():verPhysics { return componentManager.Get( verPhysics ); }
		public static function get collision():verCollision { return componentManager.Get( verCollision ); }
		public static function get analyzer():verSoundAnalyzer { return componentManager.Get( verSoundAnalyzer ); }
		public static function get sound():verSound { return componentManager.Get( verSound ); }
		public static function get pause():verPause { return componentManager.Get( verPause ); }
		public static function get save():verSave { return componentManager.Get( verSave ); }
		public static function get vars():verVariables { return componentManager.Get( verVariables ); }
		public static function get achievements():verAchievements { return componentManager.Get( verAchievements ); }
		public static function get ui():verUI { return componentManager.Get( verUI ); }
		public static function get soundscape():verSoundscape { return componentManager.Get( verSoundscape ); }
		public static function get particles():verParticles { return componentManager.Get( verParticles ); }

		/*
		 =====================END OF COMPONENTS=====================
		*/


		/*
		 ******************FUNCTIONS********************
		*/
		
		/*------------------ PRIVATE ------------------*/

		/**
		 * Removes a manager from the engine
		 * @param	manager The manager to remove
		 * @param	sName The name of the manager (for debug print)
		 */
		private static function RemoveManager( manager:*, sName:String ):void
		{
			if ( !SysUtil.IsVerlocityLoaded() ) { return; }

			Trace( "Removing " + sName + " manager...", "Verlocity" );
			manager._Destruct();
			manager = null;
		}

		/*------------------ PUBLIC -------------------*/
		
		/**
		 * Sets the game.
		 * @param	gSetGame The game to set to.
		 */
		public static function SetGame( gSetGame:Game ):void
		{
			if ( !SysUtil.IsVerlocityLoaded() )
			{ 
				trace( "Verlocity needs to be created before a game can be set!" );
				return;
			}

			// Remove the current game
			if ( gGame ) { EndGame(); }

			// Set the game
			gGame = gSetGame;

			Trace( "Starting game: " + gGame.GameName + " by " + gGame.GameAuthor + " Description: " + gGame.GameDescription, "Verlocity" );
			
			// Start the game
			gGame._Construct();

			Trace( "Game started.", "Verlocity" );
		}
		
		/**
		 * Ends the active game.
		 */
		public static function EndGame():void
		{
			if ( !SysUtil.IsVerlocityLoaded() ) { return; }

			if ( !gGame ) { return; }
			
			Trace( "Ending game: " + gGame.GameName, "Verlocity" );

			// End the game
			gGame._Destruct();
			
			Trace( "Game ended.", "Verlocity" );
		}
		
		/**
		 * Restarts the active game.
		 */
		public static function RestartGame():void
		{
			if ( !SysUtil.IsVerlocityLoaded() ) { return; }

			if ( !gGame ) { return; }
			
			Trace( "Restarting game: " + gGame.GameName, "Verlocity" );
			
			// Restart the game
			gGame._Destruct();
			gGame._Construct();
		}
		
		private static var playerEntity:*;

		/**
		 * Sets a reference to the player (can be an entity).
		 * You can get this with Verlocity.player
		 * @param	playerEnt
		 */
		public static function SetPlayer( playerEnt:* ):void
		{
			playerEntity = playerEnt;
		}
		
		/**
		 * Returns the reference to the player entity.
		 * @return
		 */
		public static function get player():* { return playerEntity; }
		
		private static var sGameLayer:String;
		
		/**
		 * Sets a reference of the game layer.
		 * You can get this with Verlocity.gameLayer
		 * @param	sLayer
		 */
		public static function SetGameLayer( sLayer:String ):void
		{
			sGameLayer = sLayer;
		}
		
		/**
		 * Returns the string reference of the game layer.
		 */
		public static function get gameLayer():String { return sGameLayer }

		/**
		 * Completely removes and closes Verlocity and its components.
		 * When you quit out of Verlocity, make sure you're not doing anything else with it
		 * in the following update scope, as it will cause an error.
		 * When in doubt, follow Quit with a return.
		 */
		public static function Quit():void
		{
			if ( !SysUtil.IsVerlocityLoaded() || bIsQuitting ) { return; }

			bIsQuitting = true;

			Trace( "Removing Verlocity...", "Verlocity" );

			//CleanSlate( true, false );
			EndGame();

			// Clear the global dictionary
			if ( G_ )
			{
				G_.clear();
				G_ = null;
			}

			// Remove all components
			Trace( "Removing all components...", "Verlocity" );
			componentManager._Destruct();
			componentManager = null;
			Trace( "Components removed.", "Verlocity" );
			
			// Remove all managers
			RemoveManager( languageManager, "language" );
			RemoveManager( displayManager, "display" );
			RemoveManager( keyManager, "key" );
			RemoveManager( messageManager, "message" );
			RemoveManager( settingsManager, "settings" );

			// Remove this from the singleton manager
			SingletonManager.Remove( Verlocity );

			// Notify successful removal
			trace( "!!!!!Verlocity removed successfully!!!!!" );

			SysUtil.GC(); // Get rid of all the data

			bIsQuitting = false;
			bLoaded = false;
		}
		
		/**
		 * Returns if Verlocity is quitting.
		 */
		public static function IsQuitting():Boolean { return bIsQuitting; }

		/**
		 * Returns if an object is valid (checks for IsValid function).
		 * @param	obj Object to check if valid (checks IsValid function).
		 * @return
		 */
		public static function IsValid( obj:Object ):Boolean
		{
			return ObjectUtil.IsValid( obj );
		}

		/**
		 * Returns if the component is currently loaded.
		 * @param	comp
		 */
		public static function IsComponentLoaded( comp:* ):Boolean
		{
			return componentManager && componentManager.Get( comp );
		}
		
		/**
		 * Returns if Verlocity was fully loaded.
		 */
		public static function IsLoaded():Boolean { return bLoaded; }

		/**
		 * Traces a debug message into the console.  Only available when VerlocitySettings.DEBUG is on.
		 * @param	sTrace The message to trace.
		 * @param	sCaller The caller of the trace (optional).
		 */
		public static function Trace( sTrace:String, sCaller:String = null ):void
		{
			if ( SysUtil.IsVerlocityLoaded() && !settings.DEBUG ) { return; }

			// Format the traced message
			var sFormattedString:String = sTrace;

			// Add the caller
			if ( sCaller )
			{
				sFormattedString = "[" + sCaller + "] " + sFormattedString;
			}

			// If console is valid, trace there instead
			if ( SysUtil.IsVerlocityLoaded() && !IsQuitting() && IsComponentLoaded( verConsole ) )
			{
				console.Output( sFormattedString );
				return;
			}

			// Preform the trace
			trace( sFormattedString );
		}
		
		/**
		 * Traces an error.  This will create a notification icon in the bottom left.
		 * @param	sError The error message to display
		 * @param	sCaller The caller of the error message (optional).
		 */
		public static function TraceError( sError:String, sCaller:String = null ):void
		{
			if ( !SysUtil.IsVerlocityLoaded() ) { return; }

			if ( !settings.DEBUG ) { return; }

			// Display the message
			Trace( "ERROR " + sError, sCaller );
	
			// TODO: Notification icon
		}

		/**
		 * Returns the key code based on a registered key name.
		 * @param	sKeyName The key name
		 * @return
		 */
		public static function Key( sKeyName:String ):uint
		{
			if ( !SysUtil.IsVerlocityLoaded() ) { return 0; }

			return keyManager.Get( sKeyName );
		}

		/**
		 * Returns the elapsed running time of the application.
		 * Uses verEngine, if loaded, otherwise defaults to native getTimer().
		 * @return
		 */
		public static function CurTime():int
		{
			if ( IsValid( engine ) )
			{
				return engine.CurTime();
			}
			
			return getTimer();
		}
		
		/**
		 * Clears all component objects.  Very useful for clearing an entire scene for level changes.
		 * @param	bRemoveProtected Remove protected objects?
		 * @param	bFadeOutSound Fade out the sound?
		 * @param	bClearBitmapAssets Remove all bitmap assets?
		 */
		public static function CleanSlate( bRemoveProtected:Boolean = false, bFadeOutSound:Boolean = false, bClearBitmapAssets:Boolean = false ):void
		{
			if ( !SysUtil.IsVerlocityLoaded() ) { return; }

			if ( IsValid( ents ) ) { ents.RemoveAll( bRemoveProtected ); }

			if ( IsValid( camera ) ) { camera.Reset(); }
			if ( IsValid( layers ) ) { layers.RemoveAll(); }

			if ( IsValid( ui ) ) { ui.RemoveAll(); }

			if ( IsValid( soundscape ) ) { soundscape.Stop( bFadeOutSound ); }
			if ( IsValid( sound ) ) { sound.StopAll( bFadeOutSound, bRemoveProtected ); }
			
			if ( IsValid( bitmap ) && bClearBitmapAssets ) { bitmap.RemoveAllAssets(); }
		}
		
		/**
		 * Resets all component objects.
		 * @param	bStopSounds
		 */
		public static function ResetSlate( bStopSounds:Boolean = true ):void
		{
			if ( !SysUtil.IsVerlocityLoaded() ) { return; }

			if ( IsValid( camera ) ) { camera.Reset(); }
			if ( IsValid( layers ) ) { layers.ResetAll(); }

			if ( IsValid( ui ) ) { ui.UnHighlightCurrentButton(); }
			//if ( IsValid( a3D ) ) { a3D.ResetCamera(); }

			if ( bStopSounds )
			{
				if ( IsValid( soundscape ) ) { soundscape.Stop(); }
				if ( IsValid( sound ) ) { sound.StopAll(); }
			}
			
			if ( IsValid( analyzer ) ) { analyzer.EnableAnalyzer( false ); }
			
			if ( IsValid( particles ) ) { particles.RemoveAll(); }
		}

		/**
		 * Returns the global stage width (resolution).
		 */
		public static function get ScrW():int { return stage.stageWidth; }
		
		/**
		 * Returns the global stage height (resolution).
		 */
		public static function get ScrH():int { return stage.stageHeight; }
		
		/**
		 * Returns the global stage center point.
		 */
		public static function get ScrCenter():Point { return new Point( ScrW / 2, ScrH / 2 ); }
		
		/**
		 * Returns the content folder.
		 */
		public static function get ContentFolder():String { return settings.CONTENT_FOLDER; }

		/**
		 * Returns the active game.
		 */
		public static function get game():Game { return gGame; }
		
		/**
		 * Returns the display manager.
		 */
		public static function get display():DisplayManager { return displayManager; }
		
		/**
		 * Returns the language manager, which allows for translation.
		 */
		public static function get lang():LanguageManager { return languageManager; }
		
		/**
		 * Returns the key manager.
		 */
		public static function get keys():KeyManager { return keyManager; }
		
		/**
		 * Returns the HUD message manager.
		 */
		public static function get message():MessageManager { return messageManager; }

		/**
		 * Returns the component manager.
		 */
		public static function get components():ComponentManager { return componentManager; }

		/**
		 * Returns Verlocity's settings.
		 */
		public static function get settings():SettingsData { return settingsManager.Get(); }

		/**
		 * Returns the plugin manager.
		 */
		public static function get plugins():PluginManager { return pluginManager; }
	}
}