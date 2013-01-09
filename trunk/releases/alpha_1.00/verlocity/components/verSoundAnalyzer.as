/*
 * ---------------------------------------------------------------
 * Verlocity
 * http://www.verlocityengine.com
 * 
 * This file is subject to the terms and conditions defined in
 * 'license.txt', which is part of this source code package.
 * ---------------------------------------------------------------
 * Component: verSoundAnalyzer
 * Author: Macklin Guy
 * ---------------------------------------------------------------
*/
package verlocity.components
{
	import verlocity.Verlocity;
	import verlocity.sound.FrequencyAnalyzer;
	import verlocity.core.Component;
	import verlocity.utils.MathUtil;

	/**
	 * Preforms sound both real-time and pre-time sound analyzation.
	 * Real-time analysis includes beat detection, floating averages 
	 * of overall volume, bass, mid, high, and harmonic. 
	 * It relies on SoundMixer.computeSpectrum and 
	 * the FrequencyAnalyzer class by Ben Stucki.
	 */
	public final class verSoundAnalyzer extends Component
	{
		private var vAmplitudes:Vector.<Number>;
		private var aFrequencies:Array;
		private var nBandwidth:Number;
		
		private var beatDelay:int;
		private var bBeat:Boolean;

		private var SND_AVG_BASS:Number;
		private var SND_AVG_MID:Number;
		private var SND_AVG_HIGH:Number;
		private var SND_AVG_HARMONIC:Number;
		private var SND_AVG_VOLUME:Number;
		private const SND_CUTOFF:Number = .4;

		/**
		 * Constructor of the component.
		 */
		public function verSoundAnalyzer():void
		{
			// Setup component
			super( null, true, true, true );
			
			// Component-specific construction
			SND_AVG_BASS = 0
			SND_AVG_MID = 0
			SND_AVG_HIGH = 0
			SND_AVG_HARMONIC = 0
			SND_AVG_VOLUME = 0

			vAmplitudes = new Vector.<Number>();
			aFrequencies = FrequencyAnalyzer.THIRTY_ONE_BAND;
			nBandwidth = 0.1;
		}
		
		/**
		 * Updates the FFT and averages.
		 */
		protected override function _Update():void
		{
			// Get the FFT
			vAmplitudes = FrequencyAnalyzer.computeFrequencies( aFrequencies, nBandwidth, "stereo", 1 );

			// Update averages
			SND_AVG_BASS = CalcAverage( 0, 4 ); // 20 - 200Hz
			SND_AVG_MID = CalcAverage( 16, 22 ); // 630 - 2.5k Hz
			SND_AVG_HIGH = CalcAverage( 21, 31 ); // 2k - 20k Hz
			SND_AVG_HARMONIC = CalcAverage( 16, 17 ); // 630 - 800Hz
			SND_AVG_VOLUME = CalcAverage( 0, 31 ); // 20 - 20k Hz
			
			// Calc for beat
			bBeat = CalcBeat();
		}

		/**
		 * Destructor of the component.
		 */
		public override function _Destruct():void
		{	
			// Component-specific destruction
			vAmplitudes = null;

			aFrequencies.length = 0;
			aFrequencies = null;
			
			nBandwidth = NaN;
			
			// Destroy component
			super._Destruct();
		}

		/*================== COMPONENT ==================*/

		/*------------------- PRIVATE -------------------*/
		/**
		 * Calculates if there was a beat that occured.
		 * @return
		 */
		private final function CalcBeat():Boolean
		{
			// TODO: Look into a better way of detecting the beat - this is quite difficult.

			if ( Verlocity.CurTime() > beatDelay )
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

				if ( SND_AVG_BASS > SND_CUTOFF )
				{
					beatDelay = Verlocity.CurTime() + ( 500 + ( 500 * ( 1 - SND_AVG_BASS ) ) );
					return true;
				}
			}

			return false;
		}

		/**
		 * Calculates the averages of a specific range from the FFT.
		 * @param	iStart The starting frequency
		 * @param	iEnd The ending frequency
		 * @return
		 */
		private final function CalcAverage( iStart:int, iEnd:int ):Number
		{
			iStart = MathUtil.Clamp( iStart, 0, vAmplitudes.length );
			iEnd = MathUtil.Clamp( iEnd, 0, vAmplitudes.length );

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

		/*===============================================*/
		
		/*------------------- PUBLIC --------------------*/
		/**
		 * Returns the current audio FFT.
		 * @return
		 */
		public final function GetFrequency():Vector.<Number>
		{
			return vAmplitudes;
		}
		
		/**
		 * Returns if there was a beat that occured.
		 * @return
		 */
		public final function Beat():Boolean 
		{
			return bBeat;
		}
		
		/**
		 * Enables/disables the real-time analyzation.
		 * @param	bEnabled
		 */
		public final function EnableAnalyzer( bEnabled:Boolean = true ):void
		{
			_SetUpdating( bEnabled );
		}

		/**
		 * Returns the beat delay (for beat detection).
		 */
		public final function get BeatDelay():int { return beatDelay; }
		
		/**
		 * Returns the cut off (for beat detection).
		 */
		public final function get CutOff():Number { return SND_CUTOFF; }
		
		/**
		 * Returns the current average volume.  20Hz - 20kHz
		 */
		public final function get AverageVolume():Number { return SND_AVG_VOLUME; }
		
		/**
		 * Returns the current average bass.  20Hz - 200Hz
		 */
		public final function get AverageBass():Number { return SND_AVG_BASS; }
		
		/**
		 * Returns the current average mid.  630Hz - 2.5kHz
		 */
		public final function get AverageMid():Number { return SND_AVG_MID; }
		
		/**
		 * Returns the current average high.  2kHz - 20kHz
		 */
		public final function get AverageHigh():Number { return SND_AVG_HIGH; }
		
		/**
		 * Returns the current average harmonic.  630Hz - 800Hz
		 */
		public final function get AverageHarmonic():Number { return SND_AVG_HARMONIC; }
	}
}