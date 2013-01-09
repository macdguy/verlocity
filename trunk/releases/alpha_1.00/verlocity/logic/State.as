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
	public class State extends Object
	{
		/*================ OVERRIDES ================*/
		// Use the following overridable functions to create your state

		/**
		 * Called when the state is first created. (override)
		 * Used to create constants/setup the state.
		 * DO NOT CALL MANUALLY - THIS IS HANDLED BY verStates!
		 */
		public function Construct():void
		{
			
		}
		
		/**
		 * Called when the state is first initialized. (override)
		 * Used to create dynamics.
		 * DO NOT CALL MANUALLY - THIS IS HANDLED BY verStates!
		 */
		public function Init():void
		{
			
		}
		
		/**
		 * Called each game tick. (override)
		 * DO NOT CALL MANUALLY - THIS IS HANDLED BY verStates
		 */
		public function Update():void
		{
			
		}
		
		/**
		 * Called each game tick, if verInput is valid. (override)
		 * DO NOT CALL MANUALLY - THIS IS HANDLED BY verStates
		 */
		public function UpdateInput():void
		{
			
		}
		
		/**
		 * Called when the state is deinitialized, but not removed. (override)
		 * Used to delete dynamics.
		 * DO NOT CALL MANUALLY - THIS IS HANDLED BY verStates!
		 */
		public function DeInit():void
		{
			
		}
		
		/**
		 * Called when the state is removed. (override)
		 * Used to delete constants.
		 * DO NOT CALL MANUALLY - THIS IS HANDLED BY verStates!
		 */
		public function Destruct():void
		{
			
		}
		
		/**
		 * Return true to end the state. (override)
		 * DO NOT CALL MANUALLY - THIS IS HANDLED BY verStates!
		 * @return
		 */
		public function ShouldEnd():Boolean
		{
			return false;
		}

		/**
		 * Returns the string name of the state.
		 * @return
		 */
		public function ToString():String
		{
			return "Base State";
		}

		/*================ END OF OVERRIDES ================*/
		

		private var cNextState:Class;
		private var cClass:Object;
		private var bIsDisabled:Boolean;
		
		/**
		 * Creates a state and stores its class.
		 */
		public function State():void
		{
			cClass = Object( this ).constructor;
		}
		
		/**
		 * Returns the class name of the state.
		 */
		public function get className():Object
		{
			return cClass;
		}
		
		/**
		 * Returns the next state that will be set after this one ends.
		 */
		public function get NextState():Class
		{
			return cNextState;
		}
		
		/**
		 * Sets the next state that will be set after this one ends.
		 */
		public function set NextState( cSetNextState:Class ):void
		{
			cNextState = cSetNextState;
		}

		/**
		 * Sets if the state is disabled.
		 */
		public function set _disabled( bSetDisabled:Boolean ):void
		{
			bIsDisabled = bSetDisabled;
		}
		
		/**
		 * Returns if the state is disabled.
		 */
		public function get _disabled():Boolean { return bIsDisabled; }
	}
}