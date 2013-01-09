/*
 * ---------------------------------------------------------------
 * Verlocity
 * http://www.verlocityengine.com
 * 
 * This file is subject to the terms and conditions defined in
 * 'license.txt', which is part of this source code package.
 * ---------------------------------------------------------------
 * Component: verSave
 * Author: Macklin Guy
 * ---------------------------------------------------------------
*/
package verlocity.components
{
	import flash.net.SharedObject;

	import verlocity.Verlocity;
	import verlocity.core.Component;

	/**
	 * Saves/loads local data for storage.
	 * Easily saves/loads player data such as progress, score, or settings.
	 * Data is saved in SharedObjects.
	 * 
	 * Note: Because this relies on SharedObjects, there may be cases of unable
	 * to save data as the client can disable this feature. 
	 * If your game requires a lot of saving it would be wise to compile 
	 * Verlocity as an AIR application and save/load local data as files. 
	 * Also keep in mind that saved data can only be loaded 
	 * from the same SWF file at the same location.
	 */
	public final class verSave extends Component
	{
		private var so:SharedObject;

		/**
		 * Constructor of the component.
		 * @param	sStage
		 */
		public function verSave():void
		{
			// Setup component
			super();
			
			// Component-specific construction
		}

		/**
		 * Destructor of the component.
		 */
		public override function _Destruct():void
		{	
			// Component-specific destruction
			
			// Destroy component
			super._Destruct();
		}

		/*================== COMPONENT ==================*/

		/*------------------- PRIVATE -------------------*/

		/*===============================================*/
		
		/*------------------- PUBLIC --------------------*/
		/**
		 * Saves a data object into a SharedObject.
		 * Note: Game name is appended to the data automatically.
		 * @param	data The object with the data to save
		 * @param	sPackageName The string name of the data
		 */
		public final function Save( data:Object, sPackageName:String ):void
		{
			so = SharedObject.getLocal( sPackageName + Verlocity.game.GameName );
			so.data.savedData = data;

			so.flush();
			so.close();
		}
		
		/**
		 * Loads the data based on its string name.
		 * @param	sPackageName The string name of the data
		 * @return
		 */
		public final function Load( sPackageName:String ):Object
		{
			so = SharedObject.getLocal( sPackageName + Verlocity.game.GameName );
			return so.data.savedData;
		}
		
		/**
		 * Deletes the data based on its string name.
		 * @param	sPackageName The string name of the data
		 */
		public final function Delete( sPackageName:String ):void
		{
			so = SharedObject.getLocal( sPackageName + Verlocity.game.GameName );
			so.clear();
			so = null;
		}
	}
}