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
	verVariables.as
	-----------------------------------------
	This component holds all your global variables.
	Useful for score, health, and more.
*/

package VerlocityEngine.components
{
	import VerlocityEngine.Verlocity;
	import VerlocityEngine.VerlocityLanguage;

	public final class verVariables extends Object
	{
		//********* VERLOCITY COMPONENT HEADER *********//
		/************************************************/
		public function IsValid():Boolean { return wasCreated; }
		private var wasCreated:Boolean;
		
		public function verVariables():void
		{
			if ( wasCreated ) { throw new Error( VerlocityLanguage.T( "ComponentLoadFail" ) ); return; } wasCreated = true;
			Construct();
		}
		/************************************************/
		/************************************************/
		
		/*
		 ****************COMPONENT VARS******************
		*/
		private var objVars:Object;


		/*
		 **************COMPONENT CREATION****************
		*/
		private function Construct():void
		{
			objVars = new Object();
		}		

		/*
		 *************COMPONENT FUNCTIONS****************
		*/
		
		/*------------------ PRIVATE ------------------*/	
		/*------------------ PUBLIC -------------------*/
		public function Register( sName:String, nStartValue:Number = 0 ):void
		{
			if ( objVars[sName] != null )
			{
				Verlocity.Trace( "Variables", VerlocityLanguage.T( "GenericDuplicate" ) );
				return;
			}

			objVars[sName] = nStartValue;
			
			Verlocity.Trace( "Variables", sName + VerlocityLanguage.T( "GenericAddSuccess" ) );
		}

		public function Set( sName:String, nValue:Number ):void
		{
			if ( objVars[sName] == null ) { return; }

			objVars[sName] = nValue;
		}

		public function Get( sName:String ):Number
		{
			return objVars[sName];
		}

		public function Increase( sName:String, nAmount:Number = 1 ):void
		{
			if ( objVars[sName] == null ) { return; }

			var oldData:Number = objVars[sName];			
			objVars[sName] = oldData + nAmount;
		}

		public function Reset( sName:String ):void
		{
			if ( objVars[sName] == null ) { return; }

			objVars[sName] = 0;
		}

	}
}