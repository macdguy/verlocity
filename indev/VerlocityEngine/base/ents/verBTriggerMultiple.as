package VerlocityEngine.base.ents
{
	import VerlocityEngine.Verlocity;

	public class verBTriggerMultiple extends verBTrigger
	{
		protected var iDelay:int;
		protected var iDelayNext:int;

		public function SetTriggerMultiple( classSetFlag:Class, iDelayNextTrigger:int, fSetFunction:Function ):void
		{
			super.SetTrigger( classSetFlag, fSetFunction );

			iDelayNext = iDelayNextTrigger;
		}
		
		protected override function OnCollide( ent:* ):void
		{
			if ( iDelay < Verlocity.engine.CurTime() )
			{
				super.OnCollide( ent );
			}
		}

		public override function DoTrigger():void
		{
			if ( Boolean( fFunction ) )
			{
				fFunction();
			}

			iDelay = Verlocity.engine.CurTime() + iDelayNext;
		}	

	}
}