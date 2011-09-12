/*
	=========================================
			   Verlocity Engine
	=========================================
	|	Developed by Macklin Guy, 2011.		|
	|										|
	|										|
	-----------------------------------------
	verSoundAnalyzer.as
	-----------------------------------------
	This handles the sound analyzation.  Both real-time and pre-time.
*/

package VerlocityEngine.components 
{
	import VerlocityEngine.libraries.FrequencyAnalyzer;

	import VerlocityEngine.util.mathHelper;

	import VerlocityEngine.Verlocity;
	import VerlocityEngine.VerlocityLanguage;

	public final class verSoundAnalyzer extends Object
	{
		//********* VERLOCITY COMPONENT HEADER *********//
		/************************************************/
		public function IsValid():Boolean { return wasCreated; }
		private var wasCreated:Boolean;
		
		public function verSoundAnalyzer():void
		{
			if ( wasCreated ) { throw new Error( VerlocityLanguage.T( "ComponentLoadFail" ) ); return; } wasCreated = true;
			Construct();
		}
		/************************************************/
		/************************************************/
		
		/*
		 ****************COMPONENT VARS******************
		*/
		private var aAverages:Array;
		
		private var vAmplitudes:Vector.<Number>;
		private const aFrequencies:Array = FrequencyAnalyzer.THIRTY_ONE_BAND;
		private const nBandwidth:Number = 0.1;
		
		private var beatDelay:int;
		private var bBeat:Boolean;

		private const SND_AVG_BASS:int = 0;
		private const SND_AVG_MID:int = 1;
		private const SND_AVG_HIGH:int = 2;
		private const SND_AVG_HARMONIC:int = 3;
		private const SND_AVG_VOLUME:int = 4;
		
		private const SND_CUTOFF:Number = .4;
		
		/*
		 **************COMPONENT CREATION****************
		*/
		private function Construct():void
		{
			aAverages = new Array();
			aAverages[ SND_AVG_BASS ] = 0;
			aAverages[ SND_AVG_MID ] = 0;
			aAverages[ SND_AVG_HIGH ] = 0;
			aAverages[ SND_AVG_HARMONIC ] = 0;
			aAverages[ SND_AVG_VOLUME ] = 0;

			vAmplitudes = new Vector.<Number>();
		}
		
		
		/*
		 ****************COMPONENT LOOP******************
		*/
		public function Think():void
		{
			vAmplitudes = FrequencyAnalyzer.computeFrequencies( aFrequencies, nBandwidth, "stereo", 1 );

			aAverages[ SND_AVG_BASS ] = CalcAverage( 0, 4 ); // 20 - 200Hz
			aAverages[ SND_AVG_MID ] = CalcAverage( 16, 22 ); // 630 - 2.5k Hz
			aAverages[ SND_AVG_HIGH ] = CalcAverage( 21, 31 ); // 2k - 20k Hz
			aAverages[ SND_AVG_HARMONIC ] = CalcAverage( 16, 17 ); // 630 - 800Hz
			aAverages[ SND_AVG_VOLUME ] = CalcAverage( 0, 31 ); // 20 - 20k Hz
			
			bBeat = CalcBeat();		
		}
		
		
		/*
		 *************COMPONENT FUNCTIONS***************
		*/
		
		/*------------------ PRIVATE ------------------*/
		private function CalcBeat():Boolean
		{
			// TODO: Clean this up a bit.
			// TODO: Look into a better way of detecting the beat - this is quite difficult.

			if ( Verlocity.engine.CurTime() > beatDelay )
			{
				// TODO: Proper scale based on the average volume.
				/*if ( GetAverage( verEnums.SND_AVG_VOLUME ) > 0 )
				{
					if ( GetAverage( verEnums.SND_AVG_BASS ) > verEnums.SND_CUTOFF / GetAverage( verEnums.SND_AVG_VOLUME ) )
					{
						beatDelay = Verlocity.engine.CurTime() + ( 400 + ( 400 * ( 1 - GetAverage( verEnums.SND_AVG_BASS ) ) ) );
						return true;					
					}
				}*/

				if ( GetAverage( SND_AVG_BASS ) > SND_CUTOFF )
				{
					beatDelay = Verlocity.engine.CurTime() + ( 500 + ( 500 * ( 1 - GetAverage( SND_AVG_BASS ) ) ) );
					return true;
				}
			}

			return false;
		}

		private function CalcAverage( iStart:int, iEnd:int ):Number
		{
			iStart = mathHelper.Clamp( iStart, 0, vAmplitudes.length );
			iEnd = mathHelper.Clamp( iEnd, 0, vAmplitudes.length );

			var nAvg:Number = 0;

			var i:int = iStart;
			while( i < iEnd )
			{
				nAvg += vAmplitudes[i];
				i++;
			}

			var iDiv:int = ( iEnd - iStart )

			return iDiv == 0 && 0 || ( nAvg / iDiv )
		}

		/*------------------ PUBLIC -------------------*/
		public function GetFrequency():Vector.<Number>
		{
			return vAmplitudes;
		}
		
		public function GetAverage( iEnum:int ):Number
		{
			return aAverages[ iEnum ];
		}
		
		public function Beat():Boolean 
		{
			return bBeat;
		}
		
		public function get BeatDelay():int { return beatDelay; }
		public function get AverageVolume():Number { return GetAverage( SND_AVG_VOLUME ); }
		public function get AverageBass():Number { return GetAverage( SND_AVG_BASS ); }
		public function get AverageMid():Number { return GetAverage( SND_AVG_MID ); }
		public function get AverageHigh():Number { return GetAverage( SND_AVG_HIGH ); }
		public function get AverageHarmonic():Number { return GetAverage( SND_AVG_HARMONIC ); }
		public function get CutOff():Number { return SND_CUTOFF; }

	}

}