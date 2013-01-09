/*
 * ---------------------------------------------------------------
 * Verlocity
 * http://www.verlocityengine.com
 * 
 * This file is subject to the terms and conditions defined in
 * 'license.txt', which is part of this source code package.
 * ---------------------------------------------------------------
 * Description:
 * 		This file is used for loading plugins.
 * 		Plugins are like extensions that fork Verlocity.
 * 
 * 		Primarily used for adding graphics engines such as
 * 		Starling or Away 3D.
 *		Unlike components, plugins cannot be unloaded at runtime.
 * 
 * 		Plugins may also import their own codebases that could require
 * 		certain setups/export settings - such as Flash 11.
 * 
 * 		For that reason, plugins are considered for advanced
 * 		users only.
 * 
 * 	You can download more plugins at http://www.verlocityengine.com/index.php?p=plugins
 * ---------------------------------------------------------------
*/
package verlocity_plugins 
{
	import verlocity.Verlocity;

	// Import plugins
	import verlocity_plugins.*;

	/**
	 * This is called after Velocity is created, but before components are created.
	*/
	public class Plugins extends Object
	{
		public function Plugins() 
		{
			// Load your plugins
			Verlocity.plugins.LoadPlugins( 
				//PluginStarling
				//PluginAway3D
			);
		}
	}
}