package Game.states
{
	import VerlocityEngine.Verlocity;
	import VerlocityEngine.base.verBState;

	public class State_Template extends verBState
	{
		public override function SetupState():void
		{
			// Is this state a cutscene?
			Cutscene = false;

			// Should we add this state to the stage?
			AddToStage = false;

			// Which layer should we try to add this state to?
			Layer = null;

			// What state should we go to after this state?
			NextState = null;
		}

		// Called after the state is spawned.
		public override function BeginState():void {}
		
		// Main loop for the state.
		public override function Think():void {}
		
		// Called when the state ends.
		public override function EndState():void {}

		// Return false based on conditionals (ie. lives < 0) to end the state automatically.
		public override function ShouldEnd():Boolean { return false; }

		// The name of the state (used for debugging)
		public override function toString():String 
		{
			return "Template";
		}
	}
}