/*
	=========================================
			   Verlocity Engine
	=========================================
	|	Developed by Macklin Guy, 2011.		|
	|										|
	|										|
	-----------------------------------------
	VerlocityLanguage.as
	-----------------------------------------
	This class handles all the language used within the engine/game.
	Designed to be easily expanded on later with localization.
*/
package VerlocityEngine 
{
	import VerlocityEngine.languages.*;

	public final class VerlocityLanguage 
	{
		private static var currentLang:Object = new verLangEnglish();

		// TODO: Expand upon this later.
		public static function Set( lang:Object ):void
		{
			currentLang = lang;
		}

		public static function T( sTrans:String ):String
		{
			if ( currentLang[sTrans] )
			{
				return currentLang[sTrans];
			}

			return "Invalid language string ID!";
		}
	}
}