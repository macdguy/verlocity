/*
 * ---------------------------------------------------------------
 * Verlocity
 * http://www.verlocityengine.com
 * 
 * This file is subject to the terms and conditions defined in
 * 'license.txt', which is part of this source code package.
 * ---------------------------------------------------------------
 * Description:
 * 		This plugin adds support for Starling, a 2D GPU powered graphics framework.
 * 		Remember, you have to import the SWC before you can use this plugin!
 * 		SWC Location: verlocity_plugins/starling/starling.swc
 * 
 * 	You can download more plugins at http://www.verlocityengine.com/index.php?p=plugins
 * ---------------------------------------------------------------
 * PLUGIN VERSION: v.01
 * STARLING VERSION: 1.1
*/
package verlocity_plugins 
{
	import verlocity.core.Plugin;
	import verlocity.core.PluginManager;
	
	import starling.core.Starling;
	import starling.display.Sprite;
	import starling.events.Event;

	public class PluginStarling extends Plugin
	{
		private static var starlingEngine:Starling;

		protected override function OnCreated():void
		{	
			// Create starling
			starlingEngine = new Starling( Sprite, stage );
			starlingEngine.enableErrorChecking = false;
			starlingEngine.simulateMultitouch = false;
			starlingEngine.start();

			starlingEngine.addEventListener( Event.CONTEXT3D_CREATE, StarlingIsReady );
		}

		/**
		 * Occurs when Starling is ready.
		 * @param	e
		 */
		private function StarlingIsReady( e:Event ):void
		{
			FinishLoading();
			starlingEngine.removeEventListener( Event.CONTEXT3D_CREATE, StarlingIsReady );
		}
		
		public function Unload():void
		{
			// Remove starling
			starlingEngine.stop();
			starlingEngine.dispose();
			starlingEngine = null;
		}

		/**
		 * Returns the starling graphical engine instance.
		 */
		public static function get core():Starling { return starlingEngine; }
	}
}