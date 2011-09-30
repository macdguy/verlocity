/*
	This file is subject to the terms and conditions defined in
    file 'license.txt', which is part of this source code package.
*/

package VerlocityEngine.base.sound
{
	public class verBSoundscape extends Object
	{
		private var aSoundGroups:Array = new Array();

		protected function AddSoundGroup( sgSoundGroup:verBSoundGroup, ssSoundSettings:verBSoundGroupSettings ):void
		{
			sgSoundGroup.SetSettings( ssSoundSettings );
			aSoundGroups.push( sgSoundGroup );
		}
		
		public function get SoundGroups():Array { return aSoundGroups; }
	}
}