/*
	This file is subject to the terms and conditions defined in
    file 'license.txt', which is part of this source code package.
*/

package VerlocityEngine.languages 
{
	public dynamic class verLangEnglish extends Object
	{
		public function verLangEnglish():void
		{
			this["VerlocityLoadFail"] = "Verlocity engine can only be created once!";

			// Components
			this["ComponentSuccess"] = " component registered and loaded.";
			this["ComponentDuplicate"] = "Attempted to register component twice!";
			this["ComponentLoadFail"] = "A component and cannot be created twice!";


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
			this["verAchievementsNone"] = "No achievements.";
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
				this["VerlocityQualityH"] = "HIGH";
				this["VerlocityQualityM"] = "MEDIUM";
				this["VerlocityQualityL"] = "LOW";
		}
	}
}