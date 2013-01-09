/*
 * ---------------------------------------------------------------
 * Verlocity
 * http://www.verlocityengine.com
 * 
 * This file is subject to the terms and conditions defined in
 * 'license.txt', which is part of this source code package.
 * ---------------------------------------------------------------
 * Description:
 * 		Manages loading of external plugins (starling, away 3D, etc).
 * ---------------------------------------------------------------
*/
package verlocity.core 
{
	import flash.display.Stage;
	import flash.utils.Dictionary;

	import verlocity.Verlocity;
	import verlocity.events.EventPlugin;
	import verlocity_plugins.Plugins;
	
	/**
	 * Creates a plugin manager that handles the base of plugin systems.
	 */
	public final class PluginManager extends Singleton
	{
		private var stage:Stage;
		private var dictPlugins:Dictionary;
		private var bPluginsToLoad:Boolean;
		
		public function _SetupPlugins( sStage:Stage ):void
		{
			stage = sStage;
			dictPlugins = new Dictionary();

			// Create then remove
			var pluginSettings = new Plugins();
			pluginSettings = null;
		}

		/**
		 * Loads all the plugins.
		 * @param	plugins The dictionary of plugin classes to load.
		 */
		public function LoadPlugins( ... plugins ):void
		{
			// No plugins, skip loading them!
			if ( !plugins || plugins.length == 0 )
			{
				bPluginsToLoad = false;
				dictPlugins = null;
				return;
			}
			
			bPluginsToLoad = true;

			// Load the plugins
			for ( var i:int = 0; i < plugins.length; i++ )
			{
				RegisterPlugin( plugins[i] );
			}
		}
		
		/**
		 * Returns if there are plugins that need to be loaded.
		 */
		public function get PluginsToLoad():Boolean { return bPluginsToLoad; }
		
		/**
		 * Registers a plugin to load.
		 * @param	pluginClass The plugin class to load
		 */
		private function RegisterPlugin( pluginClass:Object ):void
		{
			// Check for duplicate
			if ( dictPlugins[pluginClass] ) { return; }

			var plugin = new pluginClass();

			if ( plugin is Plugin )
			{
				dictPlugins[ pluginClass ] = plugin;
				Verlocity.Trace( pluginClass + Verlocity.lang.T( "PluginSuccess" ), "Plugins" );

				Plugin( plugin )._OnCreate( stage );
				
				return;
			}

			plugin = null;
			Verlocity.Trace( pluginClass + Verlocity.lang.T( "PluginFail" ), "Plugins" );
		}
		
		/**
		 * When a plugin is done loading, call this.
		 * @param	pluginClass
		 */
		public function _FinishLoadPlugin( plugin:Plugin ):void
		{
			if ( dictPlugins[ plugin.className ] )
			{
				Verlocity.Trace( plugin.className + Verlocity.lang.T( "PluginLoaded" ), "Plugins" );

				plugin.loaded = true;
			}
			
			CheckPluginLoadStatus();
		}
		
		/**
		 * This checks if all the plugins are loaded.
		 * If they are, it'll finish loading the rest of Verlocity.
		 */
		private function CheckPluginLoadStatus():void
		{
			var bIsReady:Boolean = true;

			// Check if the plugins are fully loaded
			for ( var pluginClass:Object in dictPlugins )
			{
				var plugin:Plugin = dictPlugins[ pluginClass ];
				
				if ( !plugin.loaded )
				{
					bIsReady = false;
				}
			}
			
			// Plugins are loaded! Let's finish loading Verlocity now...
			if ( bIsReady )
			{
				Verlocity.Trace( Verlocity.lang.T( "PluginAllLoaded" ), "Plugins" );

				Verlocity._FinishLoad();
			}
		}
	}
}