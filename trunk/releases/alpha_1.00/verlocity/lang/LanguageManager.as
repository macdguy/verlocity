/*
 * ---------------------------------------------------------------
 * Verlocity
 * http://www.verlocityengine.com
 * 
 * This file is subject to the terms and conditions defined in
 * 'license.txt', which is part of this source code package.
 * ---------------------------------------------------------------
 * Description:
 * 		This class handles all the language used within the engine/game.
 *		Designed to be easily expanded on later with localization.
 * ---------------------------------------------------------------
*/	
package verlocity.lang 
{
	import verlocity.lang.*;
	import verlocity.core.Singleton;

	public final class LanguageManager extends Singleton
	{
		// Holds the current language data.
		private var curLanguage:LanguageData;
		
		public function LanguageManager( defaultLanguage:LanguageData ):void
		{
			// Make sure this is a singleton
			super();
			
			// Set default language
			curLanguage = defaultLanguage;			
		}

		/**
		 * Sets the language of the translator.
		 * @param	lang The language object.
		 */
		public function Set( language:LanguageData ):void
		{
			curLanguage = language;
		}

		/**
		 * Returns a translateed language data string to the proper language.
		 * @param	sTranslatedString The language data string containing the translation.
		 * @return
		 */
		public function T( sTranslatedString:String ):String
		{
			if ( curLanguage && curLanguage[sTranslatedString] )
			{
				return curLanguage[sTranslatedString];
			}

			return "Invalid language string ID!";
		}
		
		/**
		 * Removes the current language data.
		 */
		public override function _Destruct():void 
		{
			super._Destruct();
			curLanguage = null;
		}
	}
}