/*
 * ---------------------------------------------------------------
 * Verlocity
 * http://www.verlocityengine.com
 * 
 * This file is subject to the terms and conditions defined in
 * 'license.txt', which is part of this source code package.
 * ---------------------------------------------------------------
 * Description:
 * 		This plugin adds support Away 3D, a powerful 3D engine built in AS3.
 * 		Remember, you have to import the SWC before you can use this plugin!
 * 		SWC Location: verlocity_plugins/away3D/away3D.swc
 * 
 * 	You can download more plugins at http://www.verlocityengine.com/index.php?p=plugins
 * ---------------------------------------------------------------
 * PLUGIN VERSION: v.01
 * AWAY 3D VERSION: 3.6.0
*/
package verlocity_plugins 
{
	import verlocity.core.Plugin;
	import verlocity.core.PluginManager;
	
	import verlocity_plugins.away3D.ver3D;
	import verlocity.Verlocity;

	public class PluginAway3D extends Plugin
	{
		protected override function OnCreated():void
		{
			Verlocity.components.Register( new ver3D( stage ) );

			FinishLoading();
		}

		/**
		 * Returns the away 3D component
		 */
		public static function get core():ver3D { return Verlocity.components.Get( ver3D ); }
	}
}