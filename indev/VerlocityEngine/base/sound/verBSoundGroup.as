/*
	This file is subject to the terms and conditions defined in
    file 'license.txt', which is part of this source code package.
*/

package VerlocityEngine.base.sound
{
	public class verBSoundGroup extends Object
	{
		private var ssSettings:verBSoundGroupSettings;

		private var sURL:String;
		private var iAmount:Number;
		private var sExtension:String;
		private var iPlaytime:int;
		
		public function verBSoundGroup( sSoundsURL:String, iSoundAmount:int, sSoundExtension:String = "mp3" ):void
		{
			sURL = sSoundsURL;
			iAmount = iSoundAmount;
			sExtension = sSoundExtension;
		}
		
		public function SetSettings( ssNewSettings:verBSoundGroupSettings ):void
		{
			ssSettings = ssNewSettings;
		}

		public function get Settings():verBSoundGroupSettings { return ssSettings; }
		public function get URL():String { return sURL; }
		public function get Amount():int { return iAmount; }
		public function get Extension():String { return sExtension; }
		public function get Playtime():int { return iPlaytime; }
		public function set Playtime( iSetPlaytime:int ):void { iPlaytime = iSetPlaytime; }
	}
}