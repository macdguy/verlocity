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
	verSave.as
	-----------------------------------------
	This class saves/loads local data for storage.
	You can easily save/load player data such as progress, score, or settings.
*/

package VerlocityEngine.components
{
	import VerlocityEngine.VerlocityLanguage;
	import flash.net.SharedObject;

	public final class verSave extends Object
	{
		//********* VERLOCITY COMPONENT HEADER *********//
		/************************************************/
		public function IsValid():Boolean { return wasCreated; }
		private var wasCreated:Boolean;
		
		public function verSave():void
		{
			if ( wasCreated ) { throw new Error( VerlocityLanguage.T( "ComponentLoadFail" ) ); return; } wasCreated = true;
		}
		/************************************************/
		/************************************************/
		
		/*
		 ****************COMPONENT VARS******************
		*/
		private var so:SharedObject;
		
		public function Save( data:Object, sPackageName:String ):void
		{
			so = SharedObject.getLocal( sPackageName );
				so.data.savedData = data;
			so.flush();
			so.close();
		}
		
		public function Load( sPackageName:String ):Object
		{
			so = SharedObject.getLocal( sPackageName );
			return so.data.savedData;
		}
		
		public function Delete( sPackageName:String ):void
		{
			so = SharedObject.getLocal( sPackageName );
			so.clear();
			so = null;
		}

	}
}