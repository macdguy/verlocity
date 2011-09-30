/*
	This file is subject to the terms and conditions defined in
    file 'license.txt', which is part of this source code package.
*/

package VerlocityEngine.base.ents.npcs
{
	import VerlocityEngine.base.ents.verBExtendedEnt;

	public class verBNPC extends verBExtendedEnt
	{
		private var entDamage:int;
		private var entDisposition:int;
		
		public function SetDisposition( disp:int ):void
		{
			entDisposition = disp;
		}

		public function GetDisposition():int
		{
			return entDisposition;
		}
		
		public function SetDamageAmount( iDamage:int ):void
		{
			entDamage = iDamage;
		}
		
		public function GetDamageAmount():int
		{
			return entDamage;
		}
	}
}