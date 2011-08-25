package VerlocityEngine.helpers 
{
	import VerlocityEngine.Verlocity;

	public final class ElapsedTrigger
	{
		private var iEnd:int

		public function ElapsedTrigger( iElapsedTime:int ):void
		{
			iEnd = Verlocity.engine.CurTime() + iElapsedTime;
		}

		public function IsTriggered():Boolean
		{
			return Verlocity.engine.CurTime() >= iEnd;
		}
	}
}