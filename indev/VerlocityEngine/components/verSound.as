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
	verSound.as
	-----------------------------------------
	This handles all the sound objects of the engine.

	TODO: 
		Fade in/out support (do within custom sound object class).
		FFT Analyzation of sound data.
*/

package VerlocityEngine.components 
{
	import flash.media.Sound;
	import flash.media.SoundMixer;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	
	import flash.events.IOErrorEvent;
	
	import VerlocityEngine.Verlocity;
	import VerlocityEngine.VerlocityLanguage;
	import VerlocityEngine.VerlocitySettings;
	import VerlocityEngine.VerlocityMessages;
	import VerlocityEngine.base.sound.verBSound;
	import VerlocityEngine.util.mathHelper;

	public final class verSound extends Object
	{
		//********* VERLOCITY COMPONENT HEADER *********//
		/************************************************/
		public function IsValid():Boolean { return wasCreated; }
		private var wasCreated:Boolean;
		
		public function verSound():void
		{
			if ( wasCreated ) { throw new Error( VerlocityLanguage.T( "ComponentLoadFail" ) ); return; } wasCreated = true;
			Construct();
			Concommands();
		}
		/************************************************/
		/************************************************/
		
		/*
		 ****************COMPONENT VARS******************
		*/
		private var vSounds:Vector.<verBSound>;
		
		private var stVolume:SoundTransform;
		private var nVolume:Number = 1;
		private var bIsMuted:Boolean;
		
		
		/*
		 **************COMPONENT CREATION****************
		*/
		private function Construct():void
		{
			vSounds = new Vector.<verBSound>();
			
			stVolume = new SoundTransform();
			SetVolume( VerlocitySettings.START_VOLUME );
		}

		/*
		 *************COMPONENT CONCOMMANDS**************
		*/
		private function Concommands():void
		{
			if ( !Verlocity.console ) { return; }

			Verlocity.console.Register( "sound_stopall", function():void
			{
				StopAll();
			}, "Stops all sounds being played." );

			Verlocity.console.Register( "sound_playurl", function( url:String ):void
			{
				Create( url );
			}, "Plays a sound from a URL." );
		}
		
		
		/*
		 ****************COMPONENT LOOP******************
		*/
		public function Think():void
		{
			var iLength:int = CountAll();
			if ( iLength <= 0 ) { return; } 

			var i:int = iLength - 1;
			var refCurrent:verBSound;

			while( i >= 0 )
			{
				refCurrent = vSounds[i];

				if ( refCurrent.IsStopped() )
				{
					refCurrent.Dispose();

					delete vSounds[i];
					vSounds[i] = null;
					vSounds.splice( i, 1 );
				}
				else
				{
					refCurrent.Calc();
				}

				refCurrent = null;
				i--;
			}
		}
		
		
		/*
		 *************COMPONENT FUNCTIONS***************
		*/
		
		/*------------------ PRIVATE ------------------*/
		/*------------------ PUBLIC -------------------*/
		public function CountAll():int
		{
			return vSounds.length;
		}
		
		public function Create( sSound:*, nStartVolume:Number = 1, bLoops:Boolean = false, bLocationBased:Boolean = false, sGroup:String = "default" ):verBSound
		{
			var newSound:verBSound = new verBSound( sSound, nStartVolume, bLoops, bLocationBased, sGroup );

			vSounds[ vSounds.length ] = newSound;

			return newSound;
		}

		public function StopAll( bGlobal:Boolean = false ):void
		{
			if ( bGlobal ) { SoundMixer.stopAll(); }

			var iLength:int = CountAll();
			if ( iLength <= 0 ) { return; } 

			var i:int = iLength - 1;
			var refCurrent:verBSound;

			while( i >= 0 )
			{
				refCurrent = vSounds[i];
				refCurrent.Stop();
				refCurrent = null;
				i--;
			}

			Verlocity.Trace( "Sound", VerlocityLanguage.T( "GenericRemoveAll" ) );
		}
		
		public function StopGroup( sGroup:String ):void
		{
			var iLength:int = CountAll();
			if ( iLength <= 0 ) { return; } 

			var i:int = iLength - 1;
			var refCurrent:verBSound;

			while( i >= 0 )
			{
				refCurrent = vSounds[i];

				if ( refCurrent.GetGroup() == sGroup )
				{
					refCurrent.Stop();
				}

				refCurrent = null;
				i--;
			}
		}
		
		public function StopAllInObject( obj:Object ):void
		{
			var iLength:int = CountAll();
			if ( iLength <= 0 ) { return; } 

			var i:int = iLength - 1;
			var refCurrent:verBSound;

			while( i >= 0 )
			{
				refCurrent = vSounds[i];

				if ( refCurrent.GetOwner() == obj )
				{
					refCurrent.Stop();
				}

				refCurrent = null;
				i--;
			}
		}

		public function PauseAll():void
		{
			var iLength:int = CountAll();
			if ( iLength <= 0 ) { return; } 

			var i:int = iLength - 1;
			var refCurrent:verBSound;

			while( i >= 0 )
			{
				refCurrent = vSounds[i];
				refCurrent.Pause();
				refCurrent = null;
				i--;
			}
		}

		public function ResumeAll():void
		{
			var iLength:int = CountAll();
			if ( iLength <= 0 ) { return; } 

			var i:int = iLength - 1;
			var refCurrent:verBSound;

			while( i >= 0 )
			{
				refCurrent = vSounds[i];
				refCurrent.Resume();
				refCurrent = null;
				i--;
			}
		}
		
		public function FadeOutAll():void
		{
			var iLength:int = CountAll();
			if ( iLength <= 0 ) { return; } 

			var i:int = iLength - 1;
			var refCurrent:verBSound;

			while( i >= 0 )
			{
				refCurrent = vSounds[i];
				refCurrent.FadeOut();
				refCurrent = null;
				i--;
			}
		}

		public function SetVolume( nSetVolume:Number ):void
		{
			nVolume = mathHelper.ClampNum( nSetVolume );

			stVolume.volume = nVolume;
			SoundMixer.soundTransform = stVolume;
		}

		public function SetVolumeGroup( sGroup:String, nSetVolume:Number ):void
		{
			nSetVolume = mathHelper.ClampNum( nSetVolume );

			var iLength:int = CountAll();
			if ( iLength <= 0 ) { return; } 

			var i:int = iLength - 1;
			var refCurrent:verBSound;

			while( i >= 0 )
			{
				refCurrent = vSounds[i];

				if ( refCurrent.GetGroup() == sGroup )
				{
					refCurrent.SetVolume( nSetVolume );
				}

				refCurrent = null;
				i--;
			}
		}
		
		public function GetVolume():Number
		{
			return nVolume;
		}
		
		public function VolumeUp( nAmount:Number = .05 ):void
		{
			if ( GetVolume() >= 1 ) { return; }

			SetVolume( GetVolume() + nAmount );

			VerlocityMessages.Create( VerlocityLanguage.T( "VerlocityVolumeUp" ) + "(" + Math.round( GetVolume() * 100 ) + "%)" );
		}
		
		public function VolumeDown( nAmount:Number = .05 ):void
		{
			if ( GetVolume() <= 0 ) { return; }

			SetVolume( GetVolume() - nAmount );

			if ( GetVolume() == 0 )
			{
				VerlocityMessages.Create( VerlocityLanguage.T( "VerlocityVolumeMute" ) );
			}
			else
			{
				VerlocityMessages.Create( VerlocityLanguage.T( "VerlocityVolumeDown" ) + "(" + Math.round( GetVolume() * 100 ) + "%)" );
			}
		}
	
		public function Mute():void
		{
			bIsMuted = true;

			stVolume.volume = 0;
			SoundMixer.soundTransform = stVolume;

			VerlocityMessages.Create( VerlocityLanguage.T( "VerlocityVolumeMute" ) );
		}
		
		public function UnMute():void
		{
			bIsMuted = false;

			stVolume.volume = nVolume;
			SoundMixer.soundTransform = stVolume;

			VerlocityMessages.Create( VerlocityLanguage.T( "VerlocityVolumeUnmute" ) );
		}

		public function get IsMuted():Boolean { return bIsMuted; }
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