/*
 * ---------------------------------------------------------------
 * Verlocity
 * http://www.verlocityengine.com
 * 
 * This file is subject to the terms and conditions defined in
 * 'license.txt', which is part of this source code package.
 * ---------------------------------------------------------------
 * Component: verSound
 * Author: Macklin Guy
 * Description:
 * 		This handles all sound objects.
 * ---------------------------------------------------------------
*/
package verlocity.components
{
	import flash.display.Stage;
	import flash.media.Sound;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	
	import flash.events.IOErrorEvent;
	
	import verlocity.Verlocity;
	import verlocity.sound.SoundObject;
	import verlocity.utils.MathUtil;

	import verlocity.core.Component;

	/**
	 * Handles all the sound objects/streams of the engine.
	 * Sound objects can be location based and provide
	 * various functions 
	 */
	public final class verSound extends Component
	{
		private var vSounds:Vector.<SoundObject>;
		
		private var stVolume:SoundTransform;
		private var nVolume:Number = 1;
		private var bIsMuted:Boolean;

		/**
		 * Constructor of the component.
		 */
		public function verSound():void
		{
			// Setup component
			super( null, true, true );
			
			// Component-specific construction
			vSounds = new Vector.<SoundObject>();

			stVolume = new SoundTransform();
			SetVolume( Verlocity.settings.START_VOLUME );
		}

		/**
		 * Concommands of the component.
		 */
		protected override function _Concommands():void 
		{
			Verlocity.console.Register( "sound_stopall", function():void
			{
				StopAll();
			}, "Stops all sounds being played." );

			Verlocity.console.Register( "sound_playurl", function( url:String ):void
			{
				Create( url );
			}, "Plays a sound from a URL." );
		}

		/**
		 * Updates all sounds
		 */
		protected override function _Update():void
		{
			var iLength:int = vSounds.length;
			if ( iLength <= 0 ) { return; } 

			var i:int = iLength - 1;
			var refCurrent:SoundObject;

			while( i >= 0 )
			{
				refCurrent = vSounds[i];

				if ( refCurrent.IsStopped() )
				{
					refCurrent._Dispose();

					delete vSounds[i];
					vSounds[i] = null;
					vSounds.splice( i, 1 );
				}
				else
				{
					refCurrent._Update();
				}

				refCurrent = null;
				i--;
			}
		}

		/**
		 * Destructor of the component.
		 */
		public override function _Destruct():void
		{	
			// Component-specific destruction
			StopAll();
			
			// Destroy component
			super._Destruct();
		}

		/*================== COMPONENT ==================*/

		/*------------------- PRIVATE -------------------*/
		/**
		 * Stops a sound
		 * @param	sound Sound object
		 * @param	bFade Fade out
		 */
		private final function StopSound( sound:SoundObject, bFade:Boolean = false ):void
		{
			if ( !sound ) { return; }

			if ( bFade )
			{
				sound.FadeOut();
			}
			else
			{
				sound.Stop();
			}
		}

		/*===============================================*/
		
		/*------------------- PUBLIC --------------------*/
		
		/**
		 * Creates a sound object and returns it
		 * @param	sSound URL, class, or Sound accepted
		 * @param	nStartVolume The starting volume of the sound
		 * @param	bPlayAuto Play the sound directly after creation
		 * @param	bLoops Should the sound loop?
		 * @param	bLocationBased Should the sound be location based (ie. have a X position)
		 * @param	sGroup The sound group this sound should go in
		 * @return
		 */
		public final function Create( sSound:*, nStartVolume:Number = 1, 
								bPlayAuto:Boolean = true, bLoops:Boolean = false, 
								bLocationBased:Boolean = false, sGroup:String = "default" ):SoundObject
		{
			var newSound:SoundObject = new SoundObject( sSound, nStartVolume, bLoops, bLocationBased, sGroup );

			vSounds[ vSounds.length ] = newSound;
			newSound.Play();

			return newSound;
		}

		/**
		 * Returns the amount of sounds currently alive.
		 * @return
		 */
		public final function CountAll():int
		{
			return vSounds.length;
		}

		/**
		 * Stops all sounds (deletes them)
		 * @param	bFade Fade out the sounds?
		 * @param	bGlobal Stop all sounds (even those that aren't handled by verSound)
		 */
		public final function StopAll( bFade:Boolean = false, bGlobal:Boolean = false ):void
		{
			if ( bGlobal ) { SoundMixer.stopAll(); }

			var iLength:int = vSounds.length;
			if ( iLength <= 0 ) { return; } 

			var i:int = iLength - 1;
			var snd:SoundObject;

			while( i >= 0 )
			{
				snd = vSounds[i];
				StopSound( snd, bFade );
				snd = null;
				i--;
			}

			Verlocity.Trace( Verlocity.lang.T( "GenericRemoveAll" ), "Sound" );
		}
		
		/**
		 * Stops all sounds in a group (deletes them)
		 * @param	sGroup The string name of the group
		 * @param	bFade Fade out the sounds?
		 */
		public final function StopGroup( sGroup:String, bFade:Boolean = false ):void
		{
			var iLength:int = vSounds.length;
			if ( iLength <= 0 ) { return; } 

			var i:int = iLength - 1;
			var snd:SoundObject;

			while( i >= 0 )
			{
				snd = vSounds[i];

				if ( snd.GetGroup() == sGroup )
				{
					StopSound( snd, bFade );
				}

				snd = null;
				i--;
			}
		}
		
		/**
		 * Stops all sounds emitted from an object (deletes them)
		 * @param	obj The object that owns the sounds
		 * @param	bFade Fade out the sounds?
		 */
		public final function StopAllInObject( obj:Object, bFade:Boolean = false ):void
		{
			var iLength:int = vSounds.length;
			if ( iLength <= 0 ) { return; } 

			var i:int = iLength - 1;
			var snd:SoundObject;

			while( i >= 0 )
			{
				snd = vSounds[i];

				if ( snd.GetOwner() == obj )
				{
					StopSound( snd, bFade );
				}

				snd= null;
				i--;
			}
		}

		/**
		 * Pauses all sounds
		 */
		public final function PauseAll():void
		{
			var iLength:int = vSounds.length;
			if ( iLength <= 0 ) { return; } 

			var i:int = iLength - 1;
			var snd:SoundObject;

			while( i >= 0 )
			{
				snd = vSounds[i];
				snd.Pause();
				snd = null;
				i--;
			}
		}

		/**
		 * Resumes all paused sounds
		 */
		public final function ResumeAll():void
		{
			var iLength:int = vSounds.length;
			if ( iLength <= 0 ) { return; } 

			var i:int = iLength - 1;
			var snd:SoundObject;

			while( i >= 0 )
			{
				snd = vSounds[i];
				snd.Resume();
				snd = null;
				i--;
			}
		}
		
		/**
		 * Fades out (and removes) all sounds.
		 */
		public final function FadeOutAll():void
		{
			StopAll( true );
		}

		/**
		 * Sets the overall volume
		 * @param	nSetVolume The volume to set to (0-1)
		 */
		public final function SetVolume( nSetVolume:Number ):void
		{
			nVolume = MathUtil.ClampNum( nSetVolume );
			
			if ( nVolume > 0 )
			{
				UnMute();
			}

			stVolume.volume = nVolume;
			SoundMixer.soundTransform = stVolume;
		}

		/**
		 * Sets the volume of sounds based on group
		 * @param	sGroup The group to set volume of
		 * @param	nSetVolume The volume to set to (0-1)
		 */
		public final function SetVolumeGroup( sGroup:String, nSetVolume:Number ):void
		{
			nSetVolume = MathUtil.ClampNum( nSetVolume );

			var iLength:int = vSounds.length;
			if ( iLength <= 0 ) { return; } 

			var i:int = iLength - 1;
			var snd:SoundObject;

			while( i >= 0 )
			{
				snd = vSounds[i];

				if ( snd.GetGroup() == sGroup )
				{
					snd.SetVolume( nSetVolume );
				}

				snd = null;
				i--;
			}
		}
		
		/**
		 * Returns the overall volume
		 * @return
		 */
		public final function GetVolume():Number
		{
			return nVolume;
		}
		
		/**
		 * Turns the overall volume up by a certain amount
		 * Also notifies via HUD messages.
		 * @param	nAmount The amount to turn up the volume by
		 */
		public final function VolumeUp( nAmount:Number = .05 ):void
		{
			if ( nVolume >= 1 ) { return; }

			SetVolume( nVolume + nAmount );

			Verlocity.message.Create( Verlocity.lang.T( "VerlocityVolumeUp" ) + "(" + Math.round( GetVolume() * 100 ) + "%)" );
		}
		
		/**
		 * Turns the overall volume down by a certain amount
		 * Also notifies via HUD messages.
		 * @param	nAmount The amount to turn down the volume by
		 */
		public final function VolumeDown( nAmount:Number = .05 ):void
		{
			if ( nVolume <= 0 ) { return; }

			SetVolume( nVolume - nAmount );

			if ( nVolume == 0 )
			{
				Verlocity.message.Create( Verlocity.lang.T( "VerlocityVolumeMute" ) );
			}
			else
			{
				Verlocity.message.Create( Verlocity.lang.T( "VerlocityVolumeDown" ) + "(" + Math.round( GetVolume() * 100 ) + "%)" );
			}
		}
	
		/**
		 * Mutes the overall sound
		 */
		public final function Mute():void
		{
			if ( bIsMuted ) { return; }

			bIsMuted = true;

			stVolume.volume = 0;
			SoundMixer.soundTransform = stVolume;

			Verlocity.message.Create( Verlocity.lang.T( "VerlocityVolumeMute" ) );
		}
		
		/**
		 * Unmutes the overall sound
		 */
		public final function UnMute():void
		{
			if ( !bIsMuted ) { return; }

			bIsMuted = false;

			stVolume.volume = nVolume;
			SoundMixer.soundTransform = stVolume;

			Verlocity.message.Create( Verlocity.lang.T( "VerlocityVolumeUnmute" ) );
		}
		
		/**
		 * Toggles muting off and on
		 */
		public final function ToggleMute():void
		{
			if ( IsMuted() )
			{
				UnMute();
			}
			else
			{
				Mute();
			}
		}

		/**
		 * Returns if the sound is muted.
		 */
		public final function IsMuted():Boolean { return bIsMuted; }
		
		/**
		 * Returns if the volume is at its maximum value.
		 * @return
		 */
		public final function IsMaxVolume():Boolean { return nVolume >= 1; }
		
		/**
		 * Returns if the volume is at its minimum value.
		 * @return
		 */
		public final function IsMinVolume():Boolean { return nVolume <= 0; }
	}
}

/*import flash.display.Sprite;
import VerlocityEngine.Verlocity;

internal class verGUIVolumeBars extends Sprite
{
	public function verGUIVolumeBars():void
	{
		graphics.beginFill( 0xFFFFFF );
			var i:int = Math.round( Verlocity.sound.GetVolume() * 10 );
			while ( i > 0 )
			{
				graphics.drawRect( 2 * i, 75, 1, -10 * i );
				i++;
			}
		graphics.endFill();
	}
}*/