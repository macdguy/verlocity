/*
	This file is subject to the terms and conditions defined in
    file 'license.txt', which is part of this source code package.
*/

/*
	=========================================
			   Verlocity Engine
	=========================================
	|	Developed by Macklin Guy, 2011.		|
	|										|
	|										|
	-----------------------------------------
	verInventory.as
	-----------------------------------------
	This class holds the character inventory.
	This is designed for a single instance
	inventory.
*/

package VerlocityEngine.components
{
	import VerlocityEngine.VerlocityLanguage;

	public final class verInventory extends Object
	{
		//********* VERLOCITY COMPONENT HEADER *********//
		/************************************************/
		public function IsValid():Boolean { return wasCreated; }
		private var wasCreated:Boolean;
		
		public function verInventory():void
		{
			if ( wasCreated ) { throw new Error( VerlocityLanguage.T( "ComponentLoadFail" ) ); return; } wasCreated = true;
			Construct();
		}
		/************************************************/
		/************************************************/
		
		/*
		 ****************COMPONENT VARS******************
		*/
		
		/*
		 **************COMPONENT CREATION****************
		*/
		private function Construct():void
		{
		}

	}
}