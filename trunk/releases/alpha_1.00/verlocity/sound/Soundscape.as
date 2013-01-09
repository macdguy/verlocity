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
	public final class Soundscape extends Object
	{
		private var aSoundGroups:Array = new Array();

		/**
		 * Adds a soundgroup to the soundscape.
		 * @param	sgSoundGroup The sound group to add
		 * @param	ssSoundSettings The sound settings to apply to the group
		 */
		protected function AddSoundGroup( sgSoundGroup:SoundGroup, ssSoundSettings:SoundGroupSettings ):void
		{
			sgSoundGroup.SetSettings( ssSoundSettings );
			aSoundGroups.push( sgSoundGroup );
		}
		
		public function get SoundGroups():Array { return aSoundGroups; }
	}
}