/*
 * ---------------------------------------------------------------
 * Verlocity
 * http://www.verlocityengine.com
 * 
 * This file is subject to the terms and conditions defined in
 * 'license.txt', which is part of this source code package.
 * ---------------------------------------------------------------
*/
package verlocity.events
{
	import flash.events.Event;
	import verlocity.core.Plugin;

	/**
	 * Handles the events of a plugin
	 */
	public final class EventPlugin extends Event
	{
		public static const LOADED:String = "OnLoaded";
		public static const ALL_LOADED:String = "OnFullyLoaded";
		private var _plugin:Plugin;

		/**
		 * Creates a plugin event handler
		 * @param	type Event type
		 * @param	data Plugin that had an event
		 */
		public function EventPlugin( type:String, data:Plugin = null ):void
		{
			_plugin = data;
			super( type );
		}
		
		/**
		 * Returns the plugin that the event occured
		 */
		public function get plugin():Plugin { return _plugin; }
		
		/**
		 * Retruns the class name of the plugin that the event occured
		 */
		public function get pluginClass():Object { return _plugin.className; }
	}
}