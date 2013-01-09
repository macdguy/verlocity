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
	import fl.motion.Color;

	public final class Particle extends Point
	{
		// General variables
		public var next:Particle; // for linked list
		public var properties:ParticleProperties;
		public var emitter:ParticleEmitter;

		// Color variables
		public var uiColor:uint;

		// Lifetime/render
		private var iCurTime:int;
		private var bRender:Boolean;
		
		// Physics
		private var pVel:Point;
		private var pAccel:Point;

		/**
		 * Sets the particle to a position and sets its properties.
		 * @param	pPosition New position of the particle
		 * @param	partProperties Properties of the particle
		 */
		public function _Initialize( pPosition:Point, partProperties:ParticleProperties ):void
		{
			// Set the position
			x = pPosition.x;
			y = pPosition.y;
			
			// Update the properties
			properties = partProperties;

			// Make sure we have properties
			if ( properties )
			{
				// Reset the current life time and render boolean
				iCurTime = 0;
				bRender = true;
				
				// Set the initial physics
				pVel = properties.pStartVel;
				pAccel = properties.pStartAccel;

				// Set the starting color
				uiColor = properties.uiColorStart;
			}
		}

		/**
		 * Updates the particle.
		 */
		public function _Update():void
		{
			// Only update if being rendered
			if ( !bRender ) { return; }

			// Remove if no properties
			if ( !properties )
			{
				Die();
				return;
			}

			// Check if the particle died
			if ( properties.iLifeTime >= 0 && iCurTime > properties.iLifeTime )
			{
				Die();
				return;
			}
			iCurTime++;
			
			// Physics
			// Apply velocity
			x += pVel.x / 4;
			y += pVel.y / 4;

			// Apply acceleration
			pVel.x += pAccel.x / 8;
			pVel.y += pAccel.y / 8;
	
			// Color
			if ( properties.iLifeTime >= 0 && ( iCurTime / properties.iLifeTime ) < 1 )
			{
				// Apply fading color (based on life time ratio)
				uiColor = Color.interpolateColor( properties.uiColorStart, properties.uiColorEnd, ( iCurTime / properties.iLifeTime ) );
			}
		}

		/**
		 * Removes the particle from being rendered.
		 */
		public function Die():void
		{
			bRender = false;
			
			// Clear any reference to an emitter
			emitter = null;
		}
		
		/**
		 * Returns if the particle is dead.
		 * @return
		 */
		public function IsDead():Boolean
		{
			return !bRender;
		}

		/**
		 * Deletes any data assoc. with the particle.
		 */
		public function Dispose():void
		{
			next = null;

			if ( properties )
			{
				properties.Dispose();
				properties = null;
			}

			emitter = null;

			uiColor = NaN;
			iCurTime = NaN;
			bRender = false;
			pVel = null;
			pAccel = null;
		}
	}
}