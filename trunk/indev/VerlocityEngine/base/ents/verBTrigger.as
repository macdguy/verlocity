package VerlocityEngine.base.ents
{
	public class verBTrigger extends verBExtendedEnt
	{
		protected var fFunction:Function;
		protected var classFlag:Class;
		
		public function verBTrigger():void
		{
			super();

			// we want to make sure when you're editing it in the IDE it's visible.
			// when it comes to spawning it, it's invisible.
			visible = false;
		}
		
		public function SetTrigger( classSetFlag:Class, fSetFunction:Function ):void
		{
			fFunction = fSetFunction;
			classFlag = classSetFlag;
		}
		
		protected override function OnCollide( ent:* ):void
		{
			if ( classFlag )
			{
				if ( ent.GetClass() == classFlag )
				{
					DoTrigger();
				}
			}
			else
			{
				DoTrigger();
			}
		}
		
		public function DoTrigger():void
		{
			if ( Boolean( fFunction ) )
			{
				fFunction();
			}

			Remove();
		}
		
		
	}
}