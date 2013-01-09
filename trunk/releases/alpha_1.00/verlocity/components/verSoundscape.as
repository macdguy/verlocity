/*
 * ---------------------------------------------------------------
 * Verlocity
 * http://www.verlocityengine.com
 * 
 * This file is subject to the terms and conditions defined in
 * 'license.txt', which is part of this source code package.
 * ---------------------------------------------------------------
 * Component: verSoundscape
 * Author(s): Scott Kauker, Macklin Guy
 * ---------------------------------------------------------------
*/
package verlocity.components
{
	import flash.display.Stage;
	import flash.utils.getQualifiedClassName;

	import verlocity.Verlocity;
	import verlocity.core.Component;

	import verlocity.sound.SoundObject;
	import verlocity.sound.SoundGroup;
	import verlocity.sound.Soundscape;
	
	import verlocity.utils.MathUtil;

	/**
	 * Handles soundscapes, which play a combination of sounds that form an environment.
	 * Allows for easy creation, editing, and playing of soundscapes.
	 * A soundscape plays a sound or a combination of sounds that assist in forming
	 * and immersive enviornment.
	 */
	public final class verSoundscape extends Component
	{
		private var scCurrent:Soundscape;
		private var scNext:Soundscape;

		private var nCurVolume:Number;
		private var bFadeIn:Boolean;
		private var bFadeOut:Boolean;

		/**
		 * Constructor of the component.
		 */
		public function verSoundscape():void
		{
			// Setup component
			super( null, true );
			
			// Component-specific construction
			nCurVolume = Verlocity.sound.GetVolume();
		}
		
		/**
		 * Updates the soundscapes
		 */
		protected override function _Update():void 
		{
			if ( !scCurrent ) { return; }

			HandleFading();

			if ( !scCurrent.SoundGroups || scCurrent.SoundGroups.length == 0 ) { return; }
			
			var curSoundGroup:SoundGroup;
			var iRand:int = 0;
			var sRand:String;
			var nRandVol:Number = 0;

			for ( var i:int = 0; i < scCurrent.SoundGroups.length; i++ )
			{
				curSoundGroup = scCurrent.SoundGroups[i];

				if ( curSoundGroup.Settings.Loops ) { return; }

				if ( Verlocity.CurTime() >= curSoundGroup.Playtime )
				{
					// Get the sound file
					iRand = MathUtil.Rand( 1, curSoundGroup.Amount );
					sRand = String ( iRand );
					if ( iRand < 10 ) { sRand = "0" + String( iRand ) };

					// Get random volume
					nRandVol = MathUtil.Rand( curSoundGroup.Settings.VolMin, curSoundGroup.Settings.VolMax );

					// Play the sound
					Verlocity.sound.Create( curSoundGroup.URL + sRand + "." + curSoundGroup.Extension, 
											nRandVol * Verlocity.sound.GetVolume(), true, 
											false, false, "_verSoundscape" );
					

					// Set the playtime
					curSoundGroup.Playtime = Verlocity.CurTime() + MathUtil.Rand( curSoundGroup.Settings.TimeMin, curSoundGroup.Settings.TimeMax );
				}
				
				curSoundGroup = null;
			}
		}

		/**
		 * Destructor of the component.
		 */
		public override function _Destruct():void
		{	
			// Component-specific destruction
			Stop();
			
			scCurrent = null;
			scNext = null;
			nCurVolume = NaN;
			
			bFadeOut = false;
			bFadeIn = false;
			
			// Destroy component
			super._Destruct();
		}

		/*================== COMPONENT ==================*/

		/*------------------- PRIVATE -------------------*/
		/**
		 * Handles fading of the soundscape
		 */
		private final function HandleFading():void
		{
			if ( bFadeOut )
			{
				if ( nCurVolume > 0 )
				{
					nCurVolume -= 0.005;
					Verlocity.sound.SetVolumeGroup( "_verSoundscape", nCurVolume );
				}
				else
				{
					bFadeOut = false;
					SetNext( scNext );
				}
				return;
			}
			
			if ( bFadeIn )
			{
				if ( nCurVolume < Verlocity.sound.GetVolume() )
				{
					nCurVolume += 0.005;
					Verlocity.sound.SetVolumeGroup( "_verSoundscape", nCurVolume );
				}
				else
				{
					bFadeIn = false;
				}
				return;
			}
			
			if ( nCurVolume != Verlocity.sound.GetVolume() )
			{
				nCurVolume = Verlocity.sound.GetVolume();
				Verlocity.sound.SetVolumeGroup( "_verSoundscape", nCurVolume );
			}
		}

		/**
		 * Handles setting a new soundscape
		 * @param	scSoundscape
		 */
		private final function SetNext( scSoundscape:Soundscape ):void
		{
			if ( !scSoundscape.SoundGroups || scSoundscape.SoundGroups.length == 0 ) { return; }
	
			bFadeIn = true;
			scCurrent = scSoundscape;
			Verlocity.sound.StopGroup( "_verSoundscape" );

			var curSoundGroup:SoundGroup;
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

						Verlocity.sound.Create( curSoundGroup.URL + sIndex + "." + curSoundGroup.Extension, 
												curSoundGroup.Settings.VolMax, true, 
												true, false, "_verSoundscape" );
					}
				}
				
				curSoundGroup = null;
			}

			Verlocity.Trace( "Setting new soundscape " + scNext, "Soundscape" );
		}
		
		/**
		 * Returns the current name of the soundscape
		 * @return
		 */
		public final function GetName():String
		{
			return scCurrent ? getQualifiedClassName( scCurrent ) : "None";
		}

		/*===============================================*/
		
		/*------------------- PUBLIC --------------------*/
		/**
		 * Sets the current soundscape.
		 * @param	scNew The soundscape to set to
		 */
		public final function Set( scNew:Soundscape ):void
		{
			scNext = scNew;
			nCurVolume = Verlocity.sound.GetVolume();

			if ( scCurrent )
			{
				bFadeOut = true;
				Verlocity.Trace( "Fading out current soundscape " + scCurrent, "Soundscape" );
			}
			else
			{
				SetNext( scNext );
			}			
		}
		
		/**
		 * Stops the current soundscape
		 * @param	bFade Fade out the soundscape
		 */
		public final function Stop( bFade:Boolean = false ):void
		{
			if ( Verlocity.sound )
			{
				Verlocity.sound.StopGroup( "_verSoundscape", bFade );
			}

			if ( scCurrent ) { scCurrent = null; }
		}
	}
}