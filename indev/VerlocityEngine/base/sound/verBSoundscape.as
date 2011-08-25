package VerlocityEngine.base.sound
{
	public class verBSoundscape extends Object
	{
		private var aSoundGroups:Array = new Array();

		protected function AddSoundGroup( sgSoundGroup:verBSoundGroup, ssSoundSettings:verBSoundGroupSettings )
		{
			sgSoundGroup.SetSettings( ssSoundSettings );
			aSoundGroups.push( sgSoundGroup );
		}
		
		public function get SoundGroups():Array { return aSoundGroups; }
	}
}