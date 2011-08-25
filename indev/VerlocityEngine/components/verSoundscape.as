/*
	=========================================
			   Verlocity Engine
	=========================================
	|	Developed by Macklin Guy, 2011.		|
	|	Component aided by Scott Kauker		|
	|										|
	-----------------------------------------
	verSoundscape.as
	-----------------------------------------
	This class handles soundscapes, which plays
	a sound or combination of sounds that form an
	environment.
*/

package VerlocityEngine.components 
{
	import VerlocityEngine.base.sound.verBSoundGroup;
	import VerlocityEngine.base.sound.verBSoundscape;
	import VerlocityEngine.Verlocity;
	import VerlocityEngine.VerlocityLanguage;

	import VerlocityEngine.util.mathHelper;
	
	public final class verSoundscape extends Object
	{
		//********* VERLOCITY COMPONENT HEADER *********//
		/************************************************/
		public function IsValid():Boolean { return wasCreated; }
		private var wasCreated:Boolean;

		public function verSoundscape():void
		{
			if ( wasCreated ) { throw new Error( VerlocityLanguage.T( "ComponentLoadFail" ) ); return; } wasCreated = true;
		}
		/************************************************/
		/************************************************/

		/*
		 ****************COMPONENT VARS******************
		*/
		private var scCurrent:verBSoundscape;


		/*
		 ****************COMPONENT LOOP******************
		*/
		public function Think():void 
		{
			if ( !scCurrent ) { return; }

			if ( !scCurrent.SoundGroups || scCurrent.SoundGroups.length == 0 ) { return; }
			
			var curSoundGroup:verBSoundGroup;
			var iRand:int = 0;
			var sRand:String;
			var nRandVol:Number = 0;

			for ( var i:int = 0; i < scCurrent.SoundGroups.length; i++ )
			{
				curSoundGroup = scCurrent.SoundGroups[i];

				if ( curSoundGroup.Settings.Loops ) { return; }

				if ( Verlocity.engine.CurTime() >= curSoundGroup.Playtime )
				{
					iRand = mathHelper.Rand( 1, curSoundGroup.Amount );
					sRand = String ( iRand );
					if ( iRand < 10 ) { sRand = "0" + String( iRand ) };

					nRandVol = mathHelper.Rand( curSoundGroup.Settings.VolMin, curSoundGroup.Settings.VolMax );

					Verlocity.sound.Create( curSoundGroup.URL + sRand + "." + curSoundGroup.Extension, nRandVol, false, false, "verSoundscape" );

					curSoundGroup.Playtime = Verlocity.engine.CurTime() + mathHelper.Rand( curSoundGroup.Settings.TimeMin, curSoundGroup.Settings.TimeMax );
				}
				
				curSoundGroup = null;
			}
		}

		
		/*
		 *************COMPONENT FUNCTIONS***************
		*/
		
		/*------------------ PRIVATE ------------------*/
		private function FadeIn( scSoundscape:verBSoundscape ):void
		{
			if ( !scSoundscape.SoundGroups || scSoundscape.SoundGroups.length == 0 ) { return; }
			
			var curSoundGroup:verBSoundGroup;
			var sIndex:String;

			for ( var i:int = 0; i < scSoundscape.SoundGroups.length; i++ )
			{
				curSoundGroup = scCurrent.SoundGroups[i];

				if ( curSoundGroup.Settings.Loops )
				{
					for ( var k:int = 1; k < curSoundGroup.Amount + 1; k++ )
					{
						sIndex = String ( k );
						if ( k < 10 ) { sIndex = "0" + String( k ) };

						Verlocity.sound.Create( curSoundGroup.URL + sIndex + "." + curSoundGroup.Extension, curSoundGroup.Settings.VolMax, true, false, "verSoundscape" );
					}
				}
				
				curSoundGroup = null;
			}
		}

		private function FadeOut( scSoundscape:verBSoundscape ):void { }


		/*------------------ PUBLIC -------------------*/
		public function Set( scNew:verBSoundscape ):void
		{
			if ( scCurrent )
			{
				FadeOut( scCurrent );
				scCurrent = null;
			}

			scCurrent = scNew;
			FadeIn( scCurrent );
			
			Verlocity.Trace( "Soundscape", "Setting new soundscape " + scCurrent );			
		}
		
		public function Stop():void
		{
			Verlocity.sound.StopGroup( "verSoundscape" );
			
			if ( scCurrent ) { scCurrent = null; }
		}
	}
}