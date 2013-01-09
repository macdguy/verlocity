/*
 * ---------------------------------------------------------------
 * Verlocity
 * http://www.verlocityengine.com
 * 
 * This file is subject to the terms and conditions defined in
 * 'license.txt', which is part of this source code package.
 * ---------------------------------------------------------------
*/
package verlocity.lang 
{
	public dynamic class LanguageData extends Object
	{
		/**
		 * This class will be the basis of language data.
		 * If you do not override these, they will default back to these.
		 */
		public function LanguageData():void
		{
			this["VerlocityLoadFail"] = "Verlocity engine can only be created once!";

			// Components
			this["ComponentSuccess"] = " component registered and loaded.";
			this["ComponentFailed"] = " component failed registration due to lack of required components.";
			this["ComponentRemove"] = "Removed ";
			this["ComponentUnregister"] = "Unregistered ";
			this["ComponentDuplicate"] = "Component already registered!";

			// Plugins
			this["PluginSuccess"] = " plugin registered.";
			this["PluginLoaded"] = " plugin LOADED.";
			this["PluginFailed"] = " plugin failed to register and load.";
			this["PluginAllLoaded"] = "All plugins are loaded.";


			// Generic
			this["GenericAddSuccess"] = " successfully added.";
			this["GenericAddFail"] = "Unable to add. ";
			this["GenericDuplicate"] = "Found duplicate, skipping.";

			this["GenericMissing"] = " does not exist.";
			this["GenericRemove"] = "Removing ";
			this["GenericRemoveAll"] = "Removed all.";
			

			// Pause menu
			this["verPauseTitle"] = "PAUSE";
			this["verPauseResume"] = "RESUME";
			this["verPauseQuality"] = "QUALITY";
			this["verPauseQualityLow"] = "L";
			this["verPauseQualityMedium"] = "M";
			this["verPauseQualityHigh"] = "H";
			this["verPauseVolume"] = "VOLUME";
			this["verPauseAchievements"] = "ACHIEVEMENTS";
			this["verPauseFullscreen"] = "FULLSCREEN";
			

			// Achievement menu
			this["verAchievementsTitle"] = "ACHIEVEMENTS";
			this["verAchievementsNone"] = "No achievements. :(";
			this["verAchievementsExit"] = "CLOSE";

			
			// Messages
			this["VerlocityPause"] = "Game paused";
			this["VerlocityUnpause"] = "Game resumed";

			this["VerlocityVolumeMute"] = "Volume muted ";
			this["VerlocityVolumeUnmute"] = "Volume unmuted";
			this["VerlocityVolumeDown"] = "Volume lowered ";
			this["VerlocityVolumeUp"] = "Volume raised ";

			this["VerlocityFullscreenOn"] = "Fullscreen enabled";
			this["VerlocityFullscreenOff"] = "Fullscreen disabled";
			this["VerlocityFullscreenDisabled"] = "Fullscreen is not allowed";

			this["VerlocityQuality"] = "Quality set to ";
			this["VerlocityQuality0"] = "NETBOOK";
			this["VerlocityQuality1"] = "LOW";
			this["VerlocityQuality2"] = "MEDIUM";
			this["VerlocityQuality3"] = "HIGH";
			this["VerlocityQuality4"] = "BEST";
		}
	}
}