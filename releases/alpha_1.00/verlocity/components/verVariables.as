/*
 * ---------------------------------------------------------------
 * Verlocity
 * http://www.verlocityengine.com
 * 
 * This file is subject to the terms and conditions defined in
 * 'license.txt', which is part of this source code package.
 * ---------------------------------------------------------------
 * Component: verVariables
 * Author: Macklin Guy
 * ---------------------------------------------------------------
*/
package verlocity.components
{
	import flash.utils.Dictionary;
	import verlocity.core.Component;

	/**
	 * Creates global variables useful for score, health, and more.
	 * Automatically obfuscates to prevent memory hacking (TODO).
	 */
	public final class verVariables extends Component
	{
		private var dictVars:Dictionary;

		/**
		 * Constructor of the component.
		 * @param	sStage
		 */
		public function verVariables():void
		{
			// Setup component
			super();
			
			// Component-specific construction
			dictVars = new Dictionary( true );
		}

		/**
		 * Destructor of the component.
		 */
		public override function _Destruct():void
		{	
			// Component-specific destruction
			dictVars = null;
			
			// Destroy component
			super._Destruct();
		}

		/*================== COMPONENT ==================*/

		/*------------------- PRIVATE -------------------*/

		/*===============================================*/
		
		/*------------------- PUBLIC --------------------*/
		/**
		 * Sets a variable to a specific value.
		 * @param	sName The string name of the variable for later access
		 * @param	nValue The value to set the variable to
		 */
		public final function Set( sName:String, nValue:Number ):void
		{
			dictVars[sName] = nValue;
		}

		/**
		 * Returns a variable based on string name given
		 * @param	sName The string name of the variable
		 * @return
		 */
		public final function Get( sName:String ):Number
		{
			return dictVars[sName];
		}

		/**
		 * Increases a variable by a defined amount
		 * @param	sName The string name of the variable
		 * @param	nAmount The amount to increase
		 */
		public final function Increase( sName:String, nAmount:Number = 1 ):void
		{
			if ( dictVars[sName] == null ) { return; }

			var oldData:Number = dictVars[sName];		
			dictVars[sName] = oldData + nAmount;
		}

		/**
		 * Resets a variable to zero
		 * @param	sName The string name of the variable
		 */
		public final function Reset( sName:String ):void
		{
			if ( dictVars[sName] == null ) { return; }

			dictVars[sName] = 0;
		}
		
		/**
		 * Removes a variable
		 * @param	sName The string name of the variable
		 */
		public final function Delete( sName:String ):void
		{
			if ( dictVars[sName] == null ) { return; }

			delete dictVars[sName];
			dictVars[sName] = null;
		}
	}
}