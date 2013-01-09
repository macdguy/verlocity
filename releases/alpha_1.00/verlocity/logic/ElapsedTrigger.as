/*
 * ---------------------------------------------------------------
 * Verlocity
 * http://www.verlocityengine.com
 * 
 * This file is subject to the terms and conditions defined in
 * 'license.txt', which is part of this source code package.
 * ---------------------------------------------------------------
*/
package verlocity.logic 
{
	import verlocity.Verlocity;

	public final class ElapsedTrigger
	{
		private var iEnd:int;
		private var iElapsedTime:int;
		private var bDisabled:Boolean;

		public function ElapsedTrigger( iSetElapsedTime:int = 0 ):void
		{
			iElapsedTime = iSetElapsedTime;

			iEnd = Verlocity.CurTime() + iElapsedTime;
		}

		public function IsTriggered():Boolean
		{
			return Verlocity.CurTime() >= iEnd && !bDisabled;
		}
		
		public function IsTriggeredOnce():Boolean
		{
			if ( Verlocity.CurTime() >= iEnd )
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

			iEnd = Verlocity.CurTime() + iElapsedTime;
			Enable();
		}
		
		public function Remaining():int
		{
			return Verlocity.CurTime() - iEnd;
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