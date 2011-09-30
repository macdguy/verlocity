/*
	This file is subject to the terms and conditions defined in
    file 'license.txt', which is part of this source code package.
*/

package VerlocityEngine.base.ents
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	import VerlocityEngine.Verlocity;
	import VerlocityEngine.base.verBScreenObject;
	import VerlocityEngine.base.sound.verBSound;

	public class verBSoundEmitter extends verBEnt
	{
		private var sndEmit:verBSound;
		
		public function StartEmitting( sSound:*, nStartVolume:Number = 1, bLoops:Boolean = false ):void
		{
			sndEmit = Verlocity.sound.Create( sSound, nStartVolume, bLoops, true );
			sndEmit.SetPos( x );
			sndEmit.SetOwner( this );
			sndEmit.SetParent( this );
		}
		
		public function StopEmitting():void
		{
			sndEmit.Stop();
		}
		
		public function SetVolume( nNewVolume:Number ):void
		{
			sndEmit.SetVolume( nNewVolume );
		}
	}
}