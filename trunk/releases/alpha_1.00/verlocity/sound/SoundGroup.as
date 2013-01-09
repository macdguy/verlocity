/*
 * ---------------------------------------------------------------
 * Verlocity
 * http://www.verlocityengine.com
 * 
 * This file is subject to the terms and conditions defined in
 * 'license.txt', which is part of this source code package.
 * ---------------------------------------------------------------
*/
package verlocity.sound
{
	public final class SoundGroup extends Object
	{
		private var ssSettings:SoundGroupSettings;

		private var sURL:String;
		private var iAmount:Number;
		private var sExtension:String;
		private var iPlaytime:int;
		
		/**
		 * Creates a sound group.
		 * @param	sSoundsURL The URL of the sounds to play (can be local)
		 * @param	iSoundAmount The amount of sounds
		 * @param	sSoundExtension The extension of the sounds
		 */
		public function SoundGroup( sSoundsURL:String, iSoundAmount:int, sSoundExtension:String = "mp3" ):void
		{
			sURL = sSoundsURL;
			iAmount = iSoundAmount;
			sExtension = sSoundExtension;
		}
		
		/**
		 * Sets the settings of the sound group.
		 * @param	ssNewSettings The sound group settings
		 */
		public function SetSettings( ssNewSettings:SoundGroupSettings ):void
		{
			ssSettings = ssNewSettings;
		}

		public function get Settings():SoundGroupSettings { return ssSettings; }
		public function get URL():String { return sURL; }
		public function get Amount():int { return iAmount; }
		public function get Extension():String { return sExtension; }
		public function get Playtime():int { return iPlaytime; }
		public function set Playtime( iSetPlaytime:int ):void { iPlaytime = iSetPlaytime; }
	}
}