/*
 * ---------------------------------------------------------------
 * Verlocity
 * http://www.verlocityengine.com
 * 
 * This file is subject to the terms and conditions defined in
 * 'license.txt', which is part of this source code package.
 * ---------------------------------------------------------------
 * Description:
 * 		This class handles all the settings.
 * ---------------------------------------------------------------
*/	
package verlocity.settings 
{
	import flash.display.Stage;
	import verlocity.core.Singleton;

	public final class SettingsManager extends Singleton
	{
		// Holds the current settings data.
		private var curSettings:SettingsData;
		
		public function SettingsManager( stage:Stage, settings:SettingsData = null ):void
		{
			// Make sure this is a singleton
			super();
			
			// Set default language
			if ( !settings )
			{
				settings = new SettingsData();
			}

			curSettings = settings;
		}
		
		/**
		 * Returns the settings data.
		 * @return
		 */
		public function Get():SettingsData
		{
			return curSettings;
		}
		
		/**
		 * Removes the current language data.
		 */
		public override function _Destruct():void 
		{
			super._Destruct();
			curSettings = null;
		}
	}
}