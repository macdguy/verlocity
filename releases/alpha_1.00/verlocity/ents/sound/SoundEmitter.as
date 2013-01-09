/*
 * ---------------------------------------------------------------
 * Verlocity
 * http://www.verlocityengine.com
 * 
 * This file is subject to the terms and conditions defined in
 * 'license.txt', which is part of this source code package.
 * ---------------------------------------------------------------
*/
package verlocity.ents.sound
{	
	import verlocity.Verlocity;
	import verlocity.ents.Entity;
	import verlocity.sound.SoundObject;

	public class SoundEmitter extends Entity
	{
		private var sndEmit:SoundObject;
		
		/**
		 * Starts emitting a location based sound
		 * @param	sSound
		 * @param	nStartVolume
		 * @param	bLoops
		 */
		public function StartEmitting( sSound:*, nStartVolume:Number = 1, bLoops:Boolean = false ):void
		{
			if ( sndEmit )
			{
				StopEmitting();
			}

			sndEmit = Verlocity.sound.Create( sSound, nStartVolume, true, bLoops, true );
			sndEmit.SetOwner( this );
		}
		
		/**
		 * Stops emitting the sound and kills the emitter
		 * @param	bFade Fade out
		 */
		public function StopEmitting( bFade:Boolean = false ):void
		{
			if ( !sndEmit ) { return; }

			if ( bFade ) { sndEmit.FadeOut(); } else { sndEmit.Stop(); }
			Remove();
		}
		
		/**
		 * Sets the volume of the emitting sound
		 * @param	nNewVolume
		 */
		public function SetVolume( nNewVolume:Number ):void
		{
			if ( !sndEmit ) { return; }
	
			sndEmit.SetVolume( nNewVolume );
		}
		
		/**
		 * Sets the X position of the emitter
		 */
		public function set x( nPosX:Number ):void
		{
			if ( !sndEmit ) { return; }

			sndEmit.SetPos( nPosX );
		}
		
		/**
		 * Returns the X position of the emitter
		 */
		public function get x():Number
		{
			if ( !sndEmit ) { return -1; }

			return sndEmit.x;
		}
	}
}