/*
 * ---------------------------------------------------------------
 * Verlocity
 * http://www.verlocityengine.com
 * 
 * This file is subject to the terms and conditions defined in
 * 'license.txt', which is part of this source code package.
 * ---------------------------------------------------------------
*/
package verlocity.input 
{
	public dynamic class KeyData extends Object
	{
		/**
		 * This class will be the basis of key data.
		 * If you do not override these, they will default back to these.
		 */
		public function KeyData():void
		{
			this["VerlocityVolumeDown"] = KeyCode.MINUS;
			this["VerlocityVolumeUp"] = KeyCode.EQUALS;
			this["VerlocityVolumeMute"] = KeyCode.M;
			this["VerlocityPause"] = KeyCode.P;
			this["VerlocityFullscreen"] = KeyCode.F;

			this["VerlocityNextUI"] = KeyCode.DOWN;
			this["VerlocityPreviousUI"] = KeyCode.UP;
			this["VerlocityEnterUI"] = KeyCode.ENTER;

			this["UP"] = KeyCode.UP;
			this["DOWN"] = KeyCode.DOWN;
			this["RIGHT"] = KeyCode.RIGHT;
			this["LEFT"] = KeyCode.LEFT;

			this["SHOOT"] = KeyCode.SPACE;
			this["BOMB"] = KeyCode.SHIFT;

			this["JUMP"] = KeyCode.A;
			this["ATTACK"] = KeyCode.S;
		}
	}
}