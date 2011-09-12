/*
	=========================================
			   Verlocity Engine
	=========================================
	|	Developed by Macklin Guy, 2011.		|
	|										|
	|										|
	-----------------------------------------
	VerlocityComponents.as
	-----------------------------------------
	This holds all the instanced components.
*/
package VerlocityEngine 
{
	import VerlocityEngine.base.ui.verBUI;
	import VerlocityEngine.components.*;
	import VerlocityEngine.VerlocityLanguage;

	public final class VerlocityComponents
	{
		/*
		 **********************VARS***********************
		*/
		private static var objComponents:Object = new Object();

		/*
		 ******************FUNCTIONS********************
		*/
		/*------------------ PRIVATE ------------------*/
		internal static function Register( sName:String, component:Object ):void
		{
			if ( objComponents[sName] != null )
			{
				Verlocity.Trace( "Components", VerlocityLanguage.T( "ComponentDuplicate" ) );
				return;
			}

			objComponents[sName] = new component();
			

			if ( Verlocity.engine && "Think" in objComponents[sName] )
			{
				Verlocity.engine.RegisterComponent( objComponents[sName] );
			}

			Verlocity.Trace( "Components", sName + VerlocityLanguage.T( "ComponentSuccess" ) );
		}
		
		/*------------------ PUBLIC -------------------*/
		public static function Get( sName:String ):*
		{
			return objComponents[sName];
		}
	}
}