package VerlocityEngine.base.sound
{
	import flash.display.DisplayObject;

	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	
	import flash.net.URLRequest;
	import flash.events.IOErrorEvent;

	import VerlocityEngine.Verlocity;

	import VerlocityEngine.util.mathHelper;

	public class verBSound extends Object
	{
		private var sndObj:Sound;
		private var sndChan:SoundChannel;
		private var sndTran:SoundTransform;

		private var sndParent:Object;
		private var sndOwner:Object;
		private var sndGroup:String;
		
		private var x:int;

		private var bIsStopped:Boolean;
		private var bDoesLoop:Boolean;
		private var bIsLocationBased:Boolean;

		private var nVolume:Number;
		private var nSetVolume:Number;

		private var nPan:Number;

		private var iPausePos:int;
		private var bIsPaused:Boolean;

		public function verBSound( sSound:*, nStartVolume:Number = 1, bLoops:Boolean = false, bLocationBased:Boolean = false, sGroup:String = "default" ):void
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
				Verlocity.Trace( "Sound", "ERROR: UNABLE TO PLAY SOUND, CHECK IF CLASS/URL IS VALID!" );
				sndObj.removeEventListener( IOErrorEvent.IO_ERROR, catchRequestError );
				Stop();
				return;
			}

			Play();
			Verlocity.Trace( "Sound", "Played " + sSound );
		}
		
		public function SetParent( newParent:Object ):void
		{
			sndParent = newParent;
		}
		
		public function RemoveParent():void
		{
			sndParent = null;
		}

		public function SetPos( iPosX:int ):void
		{
			x = iPosX;
		}
		
		public function SetGroup( sGroup:String ):void
		{
			sndGroup = sGroup;
		}

		public function GetGroup():String
		{
			return sndGroup;
		}
		
		public function GetOwner():Object
		{
			return sndOwner;
		}
		
		public function SetOwner( objOwner:Object ):void
		{
			sndOwner = objOwner;
		}
		
		private function Play( iPosition:int = 0 ):void
		{
			if ( !sndObj ) { return; }

			sndChan = sndObj.play( iPosition, 0, sndTran );

			sndTran.volume = nVolume;
			sndChan.soundTransform = sndTran;
		}

		public function Calc():void
		{
			if ( !sndObj || sndObj.length <= 0 ) { return; }

			LoopCalc();

			if ( bIsLocationBased )
			{
				PositionCalc();
				PanCalc();
				VolumeCalc();
			}
		}
		
		private function PositionCalc():void
		{
			if ( sndParent )
			{
				x = sndParent.x;
			}
		}
		
		private function LoopCalc():void
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

		private function PanCalc():void
		{
			var newPan:Number = mathHelper.Fit( x, 0, Verlocity.ScrW, -1, 1 );

			if ( nPan != newPan )
			{
				nPan = newPan;
				sndTran.pan = newPan;

				sndChan.soundTransform = sndTran;
			}
		}
		
		private function VolumeCalc():void
		{
			var newVolume:Number = nSetVolume;

			var iBounds:int = 1000;
			if ( x < 0 && x > -iBounds )
			{
				newVolume = mathHelper.Fit( x, -iBounds, 0, 0, nSetVolume );
			}

			if ( x > Verlocity.ScrW && x < ( Verlocity.ScrW + iBounds ) )
			{
				newVolume = mathHelper.Fit( x, Verlocity.ScrW, Verlocity.ScrW + iBounds, nSetVolume, 0 );
			}
			
			if ( x < -iBounds || x > ( Verlocity.ScrW + iBounds ) )
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

		public function SetVolume( nNewVolume:Number ):void
		{
			nVolume = nNewVolume;
			nSetVolume = nNewVolume;

			sndTran.volume = nVolume;
			sndChan.soundTransform = sndTran;
		}
		
		public function Pause():void
		{
			bIsPaused = true;
			iPausePos = sndChan.position;
			sndChan.stop();
		}
		
		public function Resume():void
		{	
			bIsPaused = false;
			Play( iPausePos );
		}

		public function Stop():void
		{	
			sndChan.stop();
			bIsStopped = true;
		}

		public function IsStopped():Boolean
		{
			return bIsStopped;
		}
		
		public function IsPaused():Boolean
		{
			return bIsPaused;
		}

		/**
		 * Cleans the sound data.
		 * @usage	Example usage: snd.Dispose();
		*/
		public function Dispose():void
		{
			if ( !bIsStopped ) { Stop(); }

			sndObj = null;
			sndChan = null;
			sndTran = null;
			
			x = NaN;
			nVolume = NaN;
			iPausePos = NaN;

			bIsStopped = false;
			bDoesLoop = false;
		}

	}

}
