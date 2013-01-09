/*
 * ---------------------------------------------------------------
 * Verlocity
 * http://www.verlocityengine.com
 * 
 * This file is subject to the terms and conditions defined in
 * 'license.txt', which is part of this source code package.
 * ---------------------------------------------------------------
 * Component: verParticles
 * Author: Macklin Guy
 * ---------------------------------------------------------------
*/
package verlocity.components
{
	import flash.display.Stage;
	import flash.geom.Rectangle;
	import verlocity.core.ListNode;
	import verlocity.utils.DisplayUtil;

	import flash.geom.Point;

	import verlocity.Verlocity;
	import verlocity.core.Component;
	import verlocity.core.LinkedList;
	import verlocity.particle.Particle;
	import verlocity.particle.ParticleEmitter;
	import verlocity.particle.ParticleProperties;

	/**
	 * Bitmap-based particle system.
	 * This class manages the displaying, calculating, and cleanup of all particles,
	 * emitters, and any bitmap filters applied to the particles.
	 */
	public class verParticles extends Component
	{
		private var bInitialized:Boolean;

		// Particles (linked list) and emitters (vector)
		private static var firstParticle:Particle;
		private static var vEmitters:Vector.<ParticleEmitter>;

		private var iMaxParticles:int;
		private var iMaxEmitters:int;

		private var iAliveParticles:int;
		private var iDeadParticles:int;
		
		private var iClearDelay:int;

		/**
		 * Constructor of the component.
		 */
		public function verParticles():void
		{
			// Setup component
			super( null, true, true, true );
			
			// Component-specific construction
			if ( !IsParticlePool() )
			{
				CreateParticlePool();
			}
		}

		/**
		 * Determines if the particles should render.
		 */
		protected override function _Update():void 
		{
			// Disable if the quality is low
			if ( Verlocity.display.IsQualityNetbook() )
			{
				//DisableRendering();
			}
		}

		/**
		 * Concommands of the component.
		 */
		protected override function _Concommands():void 
		{
			Verlocity.console.Register( "particle_remove_all", function():void
			{
				RemoveAllParticles();
			}, "Removes all alive particles." );

			Verlocity.console.Register( "particle_emitters_remove_all", function():void
			{
				RemoveAllEmitters();
			}, "Removes all alive emitters." );
		}

		/**
		 * Destructor of the component.
		 */
		public override function _Destruct():void
		{	
			// Component-specific destruction
			Remove();

			// Destroy component
			super._Destruct();
		}

		/*================== COMPONENT ==================*/

		/*------------------- PRIVATE -------------------*/
		/**
		 * Creates the particle pool
		 */
		private function CreateParticlePool():void
		{
			var lastParticle:Particle;

			for ( var i:int = 0; i < iMaxParticles; i++ )
			{
				// Create a simple particle
				var newParticle:Particle = new Particle();
	
				// Setup linked list
				if ( i == 0 )
				{
					// Set the first particle (for starting point of linked list)
					firstParticle = newParticle;
				}
				else
				{
					// Set the next in the linked list
					lastParticle.next = newParticle;
				}

				// Set the current to the previous
				lastParticle = newParticle;
			}
		}
		
		/**
		 * Loops through and renders the particles
		 */
		internal function _RenderParticles():void
		{
			//if ( _IsNotUpdating() ) { return; }

			// Reset counters
			iAliveParticles = 0;
			iDeadParticles = 0;

			var part:Particle = firstParticle;

			// Loop through all the particles
			while ( part != null )
			{
				// Should we render this particle?
				if ( !part.IsDead() )
				{
					// Add this to the alive particles :)
					iAliveParticles++;

					// Updates physics, lifetime, and color
					part._Update();

					// Make sure it's within render boundaries
					if ( IsOutOfBounds( part ) )
					{
						part.Die();
					}
					else
					{
						// Draw the particle
						Verlocity.bitmap.SetPixel( part.x, part.y, part.uiColor );
					}
				}
				else
				{
					// Add this particle to the dead (R.I.P.)
					iDeadParticles++;
				}

				// Go to the next particle
				part = part.next;
			}
		}
		
		/**
		 * Loops through and renders emitters, gathering particles
		 */
		internal function _RenderEmitters():void
		{
			//if ( _IsNotUpdating() ) { return; }

			// Return if there's no emitters
			if ( !vEmitters ) { return; }
			var iLength:int = vEmitters.length;
			if ( iLength == 0 ) { return; }

			// Loop through backwards
			var i:int = iLength - 1;
			while ( i >= 0 )
			{
				// Get the emitter
				var emitter:ParticleEmitter = vEmitters[i];

				// Remove dead emitters
				if ( emitter.IsDead() )
				{
					delete vEmitters[i];
					vEmitters.splice( i, 1 );
				}
				else // Render emitters
				{					
					// Updates lifetime
					emitter._Update();

					// Pull from particle pool
					var part:Particle = firstParticle;

					while ( part != null && emitter.CanEmit() )
					{
						// Collect only dead particles
						if ( part.IsDead() )
						{
							// Generate new properties
							part._Initialize( emitter.GeneratePosition(), emitter.GenerateProperties() );
							
							// Set the emitter source
							part.emitter = emitter;
						}
						
						// Count the emitted particles
						if ( part.emitter == emitter )
						{
							emitter.iCurParticles++;
						}

						// Go to the next particle
						part = part.next;
					}
				}

				i--;
			}
		}
		
		/**
		 * Returns if a particle is out of the render bounds
		 * @param	part
		 * @return
		 */
		private function IsOutOfBounds( part:Particle ):Boolean
		{
			if ( !Verlocity.bitmap.bitmapRect ) { return true; }

			return part.x < Verlocity.bitmap.bitmapRect.x ||
				   part.y < Verlocity.bitmap.bitmapRect.y ||
				   part.x > Verlocity.bitmap.bitmapRect.width ||
				   part.y > Verlocity.bitmap.bitmapRect.height;
		}

		/*===============================================*/
		
		/*------------------- PUBLIC --------------------*/
		/**
		 * Creates the particle system
		 * @param	sLayer The layer to spawn the bitmap (particles) in
		 * @param	iSetMaxParticles The max particles available (suggested 800)
		 * @param	iSetMaxEmitters The max emitters available (suggested 25)
		 */
		public function Create( sLayer:String, iSetMaxParticles:int = 800, iSetMaxEmitters:int = 25 ):void
		{
			if ( bInitialized ) { return; }

			bInitialized = true;

			// Set the maximum values
			iMaxParticles = iSetMaxParticles;
			iMaxEmitters = iSetMaxEmitters;

			// Create the particle pool (a linked list)
			if ( !IsParticlePool() )
			{
				CreateParticlePool();
			}
			
			// Create a holder for the emitters
			vEmitters = new Vector.<ParticleEmitter>;
		}
		
		/**
		 * Removes the particle system
		 */
		public function Remove():void
		{
			bInitialized = false;

			// Remove all the particles
			var current:Particle = firstParticle;
			var temp:Particle = current;

			// Loop through all particles
			while ( temp != null )
			{
				// Set temp to next
				temp = temp.next;

				// Dispose current
				current.Dispose();

				// Set current to temp
				current = temp;
			}
			
			firstParticle = null;
			
			// Remove all emitters
			RemoveAllEmitters();
			vEmitters = null;

			_SetUpdating( false );
		}
		
		/**
		 * Removes all active particles.
		 */
		public function RemoveAllParticles():void
		{
			var part:Particle = firstParticle;

			// Loop through all the particles
			while ( part != null )
			{
				// Stop rendering, add to the dead
				part.Die();

				// Go to the next particle
				part = part.next;
			}	
		}
		
		/**
		 * Creates a particle emitter
		 * @param	emitter
		 */
		public function CreateEmitter( emitter:ParticleEmitter ):void
		{			
			//if ( Verlocity.display.IsQualityNetbook() ) { return; }

			if ( !vEmitters ) { return; }

			// Have we reached the maximum emitters?
			if ( vEmitters.length >= iMaxEmitters )
			{
				emitter.Dispose();
				return;
			}

			// Enable rendering
			if ( vEmitters.length == 0 )
			{
				EnableRendering();
			}

			// Push the emitter into the vector
			vEmitters.push( emitter );
		}
		
		/**
		 * Removes all emitters
		 */
		public function RemoveAllEmitters():void
		{
			// Check if we have emitters to begin with
			var iLength:int = vEmitters.length;
			if ( iLength == 0 ) { return; }

			// Loop backwards
			var i:int = iLength - 1;
			while ( i >= 0 )
			{
				// Dipose all data completely
				vEmitters[i].Dispose();
				delete vEmitters[i];
				vEmitters.splice( i, 1 );

				i--;
			}
		}
		
		/**
		 * Removes all particles and emitters
		 */
		public function RemoveAll():void
		{
			RemoveAllParticles();
			RemoveAllEmitters();
		}
		
		/**
		 * Enables rendering of the particle system.
		 */
		public function EnableRendering():void
		{
			_SetUpdating( true );
		}
		
		/**
		 * Disables rendering of the particle system.
		 */
		public function DisableRendering():void
		{
			RemoveAll();

			_SetUpdating( false );
		}
		
		/**
		 * Returns if the particle pool was created
		 * @return
		 */
		public function IsParticlePool():Boolean
		{
			return Boolean( firstParticle );
		}	

		/**
		 * Returns the current amount of alive particles.
		 */
		public function get countParticles():int { return iAliveParticles; }

		/**
		 * Returns the current dead particles.
		 */
		public function get deadParticles():int { return iDeadParticles; }

		/**
		 * Returns the max particles available.
		 */
		public function get maxParticles():int { return iMaxParticles; }

		/**
		 * Returns the current amount of emitters active.
		 */
		public function get countEmitters():int { return vEmitters.length; }

		/**
		 * Returns the max emitters allowed.
		 */
		public function get maxEmitters():int { return iMaxEmitters; }
	}
}