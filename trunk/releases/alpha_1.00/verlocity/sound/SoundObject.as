/*
 * ---------------------------------------------------------------
 * Verlocity
 * http://www.verlocityengine.com
 * 
 * This file is subject to the terms and conditions defined in
 * 'license.txt', which is part of this source code package.
 * ---------------------------------------------------------------
*/
package verlocity.sound
{
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	
	import flash.net.URLRequest;
	import flash.events.IOErrorEvent;

	import verlocity.Verlocity;
	import verlocity.utils.MathUtil;

	public class SoundObject extends Object
	{
		private var sndRef:*;
		private var sndObj:Sound;
		private var sndChan:SoundChannel;
		private var sndTran:SoundTransform;

		private var sndParent:Object;
		private var sndOwner:Object;
		private var sndGroup:String;
		
		private var iPosX:int;

		private var bIsStopped:Boolean;
		private var bDoesLoop:Boolean;
		private var bIsLocationBased:Boolean;
		
		private var bFadingOut:Boolean;
		private var bFadingIn:Boolean;
		private var nFadeSpeed:Number;

		private var nVolume:Number;
		private var nSetVolume:Number;

		private var nPan:Number;

		private var nPausePos:Number;
		private var bIsPaused:Boolean;

		/**
		 * Creates a new sound object.
		 * @param	sSound The sound: Sound, Class, or String (URL) is accepted.
		 * @param	nStartVolume The starting volume of the sound
		 * @param	bLoops Does the sound loop?
		 * @param	bLocationBased Is this sound location based (pans left/right based on the X position)
		 * @param	sGroup The string sound group this sound is part of (not to be confused with SoundGroup class)
		 */
		public function SoundObject( sSound:*, nStartVolume:Number = 1, bLoops:Boolean = false, bLocationBased:Boolean = false, sGroup:String = "default" ):void
		{
			sndObj = new Sound();
			sndChan = new SoundChannel();
			sndTran = new SoundTransform( 1, 0 );
			
			// Set the appropriate variables.
			bDoesLoop = bLoops;
			bIsLocationBased = bLocationBased;

			nVolume = nStartVolume;
			nSetVolume = nStartVolume;

			sndGroup = sGroup;

			// Determine the sound type.
			if ( sSound is Sound ) { sndObj = sSound; }
			if ( sSound is Class ) { sndObj = new sSound(); }
			if ( sSound is String ) { sndObj.load( new URLRequest( sSound ) ); }

			// Make sure sound is valid.
			sndObj.addEventListener( IOErrorEvent.IO_ERROR, catchRequestError );
			function catchRequestError( e:IOErrorEvent ):void
			{
				Verlocity.Trace( "ERROR: UNABLE TO PLAY SOUND, CHECK IF CLASS/URL IS VALID!", "Sound" );
				sndObj.removeEventListener( IOErrorEvent.IO_ERROR, catchRequestError );
				Stop();
				return;
			}

			sndRef = sSound;
		}

		/**
		 * Updates the sound object.
		 */
		public function _Update():void
		{
			if ( !sndObj || sndObj.length <= 0 ) { return; }

			UpdateLoop();
			UpdateFade();

			if ( bIsLocationBased )
			{
				UpdatePosition();
			}
		}

		/**
		 * Cleans the sound data.
		 * @usage	Example usage: snd.Dispose();
		*/
		public function _Dispose():void
		{
			if ( !bIsStopped ) { Stop(); }

			sndObj = null;
			sndChan = null;
			sndTran = null;

			nVolume = NaN;
			nPausePos = NaN;

			bIsStopped = false;
			bDoesLoop = false;

			bFadingOut = false;
			bFadingIn = false;
			nFadeSpeed = NaN;
		}
		
		/**
		 * Sets the sound object to a parent (will follow its current X position)
		 * Requires a x variable (or getter) to be on the parent object
		 * @param	newParent
		 */
		public function SetParent( newParent:Object ):void
		{
			sndParent = newParent;
		}
		
		/**
		 * Removes the sound object's current parent.
		 */
		public function RemoveParent():void
		{
			sndParent = null;
		}

		/**
		 * Sets the position of the sound object (must be location-based for to have any effect).
		 * @param	iNewPosX The position on the x axis
		 */
		public function SetPos( iNewPosX:int ):void
		{
			if ( iNewPosX == iPosX ) { return; }

			iPosX = iNewPosX;

			// Update pan/volume
			UpdatePan();
			UpdateVolume();
		}

		/**
		 * Returns the current X position
		 * @return
		 */
		public function GetPos():int
		{
			return iPosX;
		}
		
		/**
		 * Returns the current X position
		 */
		public function get x():int
		{
			return iPosX;
		}
		
		/**
		 * Updates the position of the sound object based on its parent.
		 */
		private function UpdatePosition():void
		{
			if ( sndParent && sndParent.x )
			{
				SetPos( sndParent.x );
			}
		}

		/**
		 * Calculates the panning functionality.
		 */
		private function UpdatePan():void
		{
			var newPan:Number = MathUtil.Fit( iPosX, 0, Verlocity.ScrW, -1, 1 );

			if ( nPan != newPan )
			{
				nPan = newPan;
				sndTran.pan = newPan;

				sndChan.soundTransform = sndTran;
			}
		}
		
		/**
		 * Calculates the volume.
		 */
		private function UpdateVolume():void
		{
			var newVolume:Number = nSetVolume;

			var iBounds:int = 1000;
			if ( iPosX < 0 && iPosX > -iBounds )
			{
				newVolume = MathUtil.Fit( iPosX, -iBounds, 0, 0, nSetVolume );
			}

			if ( iPosX > Verlocity.ScrW && iPosX < ( Verlocity.ScrW + iBounds ) )
			{
				newVolume = MathUtil.Fit( iPosX, Verlocity.ScrW, Verlocity.ScrW + iBounds, nSetVolume, 0 );
			}
			
			if ( iPosX < -iBounds || iPosX > ( Verlocity.ScrW + iBounds ) )
			{
				newVolume = 0;
			}


			if ( nVolume != newVolume )
			{
				nVolume = newVolume;
				sndTran.volume = newVolume;

				sndChan.soundTransform = sndTran;			
			}
		}
		
		/**
		 * Sets the sound object's string group name.
		 * @param	sGroup The string group name
		 */
		public function SetGroup( sGroup:String ):void
		{
			sndGroup = sGroup;
		}

		/**
		 * Returns the sound object's string group name.
		 * @return
		 */
		public function GetGroup():String
		{
			return sndGroup;
		}
		
		/**
		 * Sets the owner of the sound object.
		 * @param	objOwner
		 */
		public function SetOwner( objOwner:Object ):void
		{
			sndOwner = objOwner;
		}
		
		/**
		 * Returns the owner of the sound object. (usually what emitted it).
		 * @return
		 */
		public function GetOwner():Object
		{
			return sndOwner;
		}

		/**
		 * Plays the sound object.
		 * @param	iPosition The position to start playing at.
		 */
		public function Play( nPosition:Number = 0 ):void
		{
			if ( isNaN( nPosition ) ) { return; }
			if ( !sndObj || !sndChan || !sndTran || !sndRef ) { return; }
			
			if ( sndObj.bytesLoaded != sndObj.bytesTotal ) { return; }

			sndChan = sndObj.play( nPosition, 0, sndTran );

			sndTran.volume = nVolume;
			sndChan.soundTransform = sndTran;

			Verlocity.Trace( "Played " + sndRef, "Sound" );
		}
		
		/**
		 * Checks if the sound should loop.
		 */
		private function UpdateLoop():void
		{
			if ( bDoesLoop )
			{
				if ( sndChan.position >= sndObj.length )
				{
					Play();
				}
			}
			else
			{
				if ( sndChan.position >= sndObj.length )
				{
					Stop();
				}
			}
		}
		
		/**
		 * Calculates the fading functionality.
		 */
		private function UpdateFade():void
		{
			if ( bFadingOut )
			{
				if ( nVolume > 0 )
				{	
					nVolume = MathUtil.ClampNum( nVolume - nFadeSpeed );
					sndTran.volume = nVolume;
					sndChan.soundTransform = sndTran;
				}
				else
				{
					bFadingOut = false;
					Stop();
				}
			}
			
			if ( bFadingIn )
			{
				if ( nVolume < nSetVolume )
				{
					nVolume = MathUtil.Clamp( nVolume + nFadeSpeed, nVolume, nSetVolume );
					sndTran.volume = nVolume;
					sndChan.soundTransform = sndTran;
				}
				else
				{
					bFadingIn = false;
				}
			}
		}

		/**
		 * Sets the volume of the sound object.
		 * @param	nNewVolume The volume to set to
		 */
		public function SetVolume( nNewVolume:Number ):void
		{
			nNewVolume = MathUtil.ClampNum( nNewVolume );

			nVolume = nNewVolume;
			nSetVolume = nNewVolume;
			
			bFadingIn = false;
			bFadingOut = false;

			sndTran.volume = nVolume;
			sndChan.soundTransform = sndTran;
		}
		
		/**
		 * Pauses the sound object.
		 */
		public function Pause():void
		{
			if ( bIsPaused ) { return; }

			bIsPaused = true;
			nPausePos = sndChan.position;
			sndChan.stop();
		}
		
		/**
		 * Resumes the paused sound object.
		 */
		public function Resume():void
		{
			if ( !bIsPaused ) { return; }

			bIsPaused = false;
			Play( nPausePos );
		}

		/**
		 * Stops the sound object.  This will remove the sound object completely!
		 */
		public function Stop():void
		{	
			sndChan.stop();
			bIsStopped = true;
		}
		
		/**
		 * Fades out the sound object.  This will remove the sound object after finishing!
		 * @param	nSetFadeSpeed The speed to fade out at
		 */
		public function FadeOut( nSetFadeSpeed:Number = 0.025 ):void
		{
			bFadingOut = true;
			nFadeSpeed = nSetFadeSpeed;
		}
		
		/**
		 * Fades in the sound.
		 * @param	nSetFadeSpeed The speed to fade in at
		 */
		public function FadeIn( nSetFadeSpeed:Number = 0.025 ):void
		{
			bFadingIn = true;
			nFadeSpeed = nSetFadeSpeed;

			nVolume = 0;
			sndTran.volume = nVolume;
			sndChan.soundTransform = sndTran;
		}

		/**
		 * Returns if the sound object is stopped (ie. dead).
		 * @return
		 */
		public function IsStopped():Boolean
		{
			if ( !sndRef ) { return true; }

			return bIsStopped;
		}
		
		/**
		 * Returns if the sound object is paused.
		 * @return
		 */
		public function IsPaused():Boolean
		{
			return bIsPaused;
		}
	}
}