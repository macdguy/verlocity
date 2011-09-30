/*
	This file is subject to the terms and conditions defined in
    file 'license.txt', which is part of this source code package.
*/

package VerlocityEngine.helpers 
{
	import VerlocityEngine.Verlocity;

	public final class ElapsedTrigger
	{
		private var iEnd:int;
		private var iElapsedTime:int;
		private var bDisabled:Boolean;

		public function ElapsedTrigger( iSetElapsedTime:int = 0 ):void
		{
			iElapsedTime = iSetElapsedTime;

			iEnd = Verlocity.engine.CurTime() + iElapsedTime;
		}

		public function IsTriggered():Boolean
		{
			return Verlocity.engine.CurTime() >= iEnd && !bDisabled;
		}
		
		public function IsTriggeredOnce():Boolean
		{
			if ( bDisabled ) { return false; }

			if ( Verlocity.engine.CurTime() >= iEnd )
			{
				Disable();
				return true;
			}
			
			return false;
		}
		
		public function Reset( iSetElapsedTime:int = NaN ):void
		{
			if ( !isNaN( iSetElapsedTime ) )
			{
				iElapsedTime = iSetElapsedTime;				
			}

			iEnd = Verlocity.engine.CurTime() + iElapsedTime;
			Enable();
		}
		
		public function Remaining():int
		{
			return Verlocity.engine.CurTime() - iEnd;
		}
		
		public function Disable():void
		{
			bDisabled = true;
		}
		
		public function Enable():void
		{
			bDisabled = false;
		}
	}
}