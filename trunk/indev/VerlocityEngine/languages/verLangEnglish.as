package VerlocityEngine.languages 
{
	public class verLangEnglish extends Object
	{
		public var langData:Object = new Object();

		public function verLangEnglish():void
		{
			langData["VerlocityLoadFail"] = "Verlocity engine can only be created once!";

			// Components
			langData["ComponentSuccess"] = " component registered and loaded.";
			langData["ComponentDuplicate"] = "Attempted to register component twice!";
			langData["ComponentLoadFail"] = "A component and cannot be created twice!";

			// Generic
			langData["GenericAddSuccess"] = " successfully added.";
			langData["GenericAddFail"] = "Unable to add. ";
			langData["GenericDuplicate"] = "Found duplicate, skipping.";

			langData["GenericMissing"] = " does not exist.";
			langData["GenericRemove"] = "Removing ";
			langData["GenericRemoveAll"] = "Removed all.";
			
			// Messages
			langData["VerlocityPause"] = "Game paused";
			langData["VerlocityUnpause"] = "Game resumed";

			langData["VerlocityVolumeMute"] = "Volume muted ";
			langData["VerlocityVolumeUnmute"] = "Volume unmuted";
			langData["VerlocityVolumeDown"] = "Volume lowered ";
			langData["VerlocityVolumeUp"] = "Volume raised ";

			langData["VerlocityFullscreenOn"] = "Fullscreen enabled";
			langData["VerlocityFullscreenOff"] = "Fullscreen disabled";

			langData["VerlocityQuality"] = "Quality set to ";
				langData["VerlocityQualityH"] = "HIGH";
				langData["VerlocityQualityM"] = "MEDIUM";
				langData["VerlocityQualityL"] = "LOW";
		}
	}
}