/*
 * ---------------------------------------------------------------
 * Verlocity
 * http://www.verlocityengine.com
 * 
 * This file is subject to the terms and conditions defined in
 * 'license.txt', which is part of this source code package.
 * ---------------------------------------------------------------
*/
package verlocity.particle
{
	import flash.geom.Point;
	import verlocity.utils.ColorUtil;

	public final class ParticleEmitter extends Point
	{
		// Particle count
		public var iCurParticles:int;
		public var iMaxParticleAmount:int;

		// Lifetime
		private var iCurTime:int;
		private var iLifeTime:int;

		// Is the emitter dead?
		private var bIsDead:Boolean;

		// Positions seeds (relative to to emitter position)
		private var rStartPosX:RandSeed;
		private var rStartPosY:RandSeed;
		
		// Color seeds
		private var uiColorStart1:uint;
		private var uiColorStart2:uint;
		private var uiColorEnd1:uint;
		private var uiColorEnd2:uint;

		// Lifetime seed
		private var rLifeTime:RandSeed;

		// Physics seeds
		private var rStartVelX:RandSeed;
		private var rStartVelY:RandSeed;
		private var rStartAccelX:RandSeed;
		private var rStartAccelY:RandSeed;
		
		/**
		 * Creates a particle emitter
		 * @param	iPosX X position of the emitter
		 * @param	iPosY Y position of the emitter
		 * @param	iSetLifeTime Sets the lifetime of the emitter
		 * @param	iMaxPartAmount Max particles allowed to be emitted at any one time
		 */
		public function ParticleEmitter( iPosX:int, iPosY:int, iSetLifeTime:int, iMaxPartAmount:int ):void
		{
			x = iPosX;
			y = iPosY;
			
			iCurTime = 0;
			iLifeTime = iSetLifeTime;
			
			iMaxParticleAmount = iMaxPartAmount;
		}

		/**
		 * Updates the emitter.
		 */
		public function _Update():void
		{
			if ( bIsDead ) { return; }

			// Check if the emitter died
			if ( iLifeTime >= 0 && iCurTime > iLifeTime )
			{
				Remove();
				return;
			}
			iCurTime++;

			// Reset particle count (gets counted each frame by Particle System)
			iCurParticles = 0;
		}

		/**
		 * Returns if the emitter can actually emit a particle
		 * @return
		 */
		public function CanEmit():Boolean
		{
			return iCurParticles < iMaxParticleAmount && !bIsDead;
		}

		/**
		 * Removes the emitter.
		 */
		public function Remove():void
		{
			bIsDead = true;
		}
		
		/**
		 * Returns if the emitter is dead
		 */
		public function IsDead():Boolean
		{
			return bIsDead;
		}

		/**
		 * Sets the start position of the particles.
		 * @param	nPosXLow Low range of X position
		 * @param	nPosXHigh High range of X position
		 * @param	nPosYLow Low range of Y position
		 * @param	nPosYHigh High range of Y postiion
		 */
		public function SetPartPosition( nPosXLow:Number = NaN, nPosXHigh:Number = NaN, nPosYLow:Number = NaN, nPosYHigh:Number = NaN ):void
		{
			rStartPosX = new RandSeed( nPosXLow, nPosXHigh );
			rStartPosY = new RandSeed( nPosYLow, nPosYHigh );
		}

		/**
		 * Sets the particles' starting color.  Randomly chooses between first and second colors.
		 * @param	uiColor1 The first color
		 * @param	uiColor2 The second color
		 */
		public function SetPartColorStart( uiColor1:uint, uiColor2:uint = 0 ):void
		{
			uiColorStart1 = uiColor1;

			if ( uiColor2 == 0 )
			{
				uiColorStart2 = uiColor1;
			}
			else
			{
				uiColorStart2 = uiColor2;
			}
		}

		/**
		 * Sets the particles' ending color.  Randomly chooses between first and second colors.
		 * @param	uiColor1 The first color
		 * @param	uiColor2 The second color
		 */
		public function SetPartColorEnd( uiColor1:uint, uiColor2:uint = 0 ):void
		{
			uiColorEnd1 = uiColor1;
			
			if ( uiColor2 == 0 )
			{
				uiColorEnd2 = uiColor1;
			}
			else
			{
				uiColorEnd2 = uiColor2;
			}
		}

		/**
		 * Sets the particles' life time.  Randomly chooses between low and high.
		 * @param	nLifeTimeLow The lowest lifetime
		 * @param	nLifeTimeHigh The highest lifetime
		 */
		public function SetPartLifeTime( nLifeTimeLow:Number, nLifeTimeHigh:Number = NaN ):void
		{
			rLifeTime = new RandSeed( nLifeTimeLow, nLifeTimeHigh );
		}

		/**
		 * Sets the particles' starting velocity
		 * @param	nVelXLow Low range of X velocity
		 * @param	nVelXHigh High range of X velocity
		 * @param	nVelYLow Low range of Y velocity
		 * @param	nVelYHigh High range of Y velocity
		 */
		public function SetPartVelocity( nVelXLow:Number = NaN, nVelXHigh:Number = NaN, nVelYLow:Number = NaN, nVelYHigh:Number = NaN ):void
		{
			rStartVelX = new RandSeed( nVelXLow, nVelXHigh );
			rStartVelY = new RandSeed( nVelYLow, nVelYHigh );
		}

		/**
		 * Sets the particles' starting acceleration
		 * @param	nAccelXLow Low range of the X accel
		 * @param	nAccelXHigh High range of the X accel
		 * @param	nAccelYLow Low range of the Y accel
		 * @param	nAccelYHigh High range of the Y accel
		 */
		public function SetPartAcceleration( nAccelXLow:Number = NaN, nAccelXHigh:Number = NaN, nAccelYLow:Number = NaN, nAccelYHigh:Number = NaN ):void
		{
			rStartAccelX = new RandSeed( nAccelXLow, nAccelXHigh );
			rStartAccelY = new RandSeed( nAccelYLow, nAccelYHigh );
		}

		/**
		 * Gets a random position based on the origin and returns it as a Point for particles.
		 * @return
		 */
		public function GeneratePosition():Point
		{
			if ( !rStartPosX || !rStartPosY ) { return new Point( x, y ); }

			return new Point( x + rStartPosX.Get(), y + rStartPosY.Get() );
		}
		
		/**
		 * Generates a random particle properties for applying to particles
		 * Make sure everything is set before calling this.
		 * @return
		 */
		public function GenerateProperties():ParticleProperties
		{
			// Make sure everything is filled in, if it's missing
			GenerateDefaults();

			// Shuffle values for randomization of particles
			return new ParticleProperties( ColorUtil.RandColorHex( uiColorStart1, uiColorStart2 ), 
										   ColorUtil.RandColorHex( uiColorEnd1, uiColorEnd2 ), 
										   rLifeTime.Get(), 
										   new Point( rStartVelX.Get(), rStartVelY.Get() ),
										   new Point( rStartAccelX.Get(), rStartAccelY.Get() ) );
		}
		
		/**
		 * Generates default particle properties if they don't exist
		 */
		private function GenerateDefaults():void
		{
			// Color
			if ( !uiColorStart1 )
			{
				SetPartColorStart( 0xFFFFFF );
			}
			
			if ( !uiColorEnd1 )
			{
				SetPartColorEnd( 0xFFFFFF );
			}
			
			// Lifetime
			if ( !rLifeTime )
			{
				SetPartLifeTime( 1 );
			}
			
			// Physics
			if ( !rStartVelX )
			{
				SetPartVelocity( -1, 1, -1, 1 );
			}
			
			if ( !rStartAccelX )
			{
				SetPartAcceleration( 0, 0, 0, 0 );
			}			
		}

		/**
		 * Deletes any data assoc. with the particle emitter
		 */
		public function Dispose():void
		{
			bIsDead = true;

			// Remove lifetime
			iCurTime = NaN;
			iLifeTime = NaN;

			// Remove particle counts
			iMaxParticleAmount = NaN;
			iCurParticles = NaN;

			// Remove colors
			uiColorStart1 = NaN;
			uiColorStart2 = NaN;
			uiColorEnd1 = NaN;
			uiColorEnd2 = NaN;

			// Remove seeds
			rLifeTime = null;
			rStartVelX = null;
			rStartVelY = null;
			rStartAccelX = null;
			rStartAccelY = null;
		}
	}
}