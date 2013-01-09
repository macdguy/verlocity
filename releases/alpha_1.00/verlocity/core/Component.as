/*
 * ---------------------------------------------------------------
 * Verlocity
 * http://www.verlocityengine.com
 * 
 * This file is subject to the terms and conditions defined in
 * 'license.txt', which is part of this source code package.
 * ---------------------------------------------------------------
*/
package verlocity.core
{
	import verlocity.Verlocity;
	import flash.display.Stage;

	public class Component extends Singleton
	{
		// Access to the stage
		protected var stage:Stage;
		
		// Class for registration
		private var cClassname:Object;
		
		// Determines if the component thinks
		private var bUpdates:Boolean;
		
		// Determines if the component can be paused
		private var bPausable:Boolean;
		
		// Defines if the component is paused
		private var bPaused:Boolean;

		/**
		 * The constructor of a component.
		 * @param	sStage The stage (to allow access to)
		 * @param	bUpdate Update this component each frame (calls _Update)
		 * @param	bPauses Can this component pause?
		 * @param	bPauseOnStart Should this component be paused when first created?
		 */
		public function Component( sStage:Stage = null, 
								   bUpdate:Boolean = false, 
								   bPauses:Boolean = false, 
								   bPauseOnStart:Boolean = false ):void
		{
			super();
			stage = sStage;

			// Determine if the component updates/pauses
			bUpdates = bUpdate;
			if ( bUpdates )
			{
				bPausable = bPauses;
				
				if ( bPausable )
				{
					bPaused = bPauseOnStart;
				}
			}

			// Add concommands
			if ( Verlocity.IsValid( Verlocity.console ) )
			{
				_Concommands();
			}

			// Print
			trace( "----COMPONENT " + className + "-------------\n" +
					"Updates: " + bUpdates + "\n" +
					"Pausable: " + bPausable + "\n" +
					"Pause On Start: " + bPauseOnStart + "\n" +
					"----------------------------------------------------" );
		}

		/**
		 * Called when the component is destroyed.
		 */
		public override function _Destruct():void
		{
			// Remove from singleton manager
			super._Destruct();
			
			// Remove from component manager
			ComponentManager.Unregister( this.className );
			
			// Remove stage reference
			stage = null;
		}

		/**
		 * Updates the component, if possible.
		 */
		internal function _UpdateComponent():void
		{
			if ( bPaused ) { return; }

			if ( bUpdates )
			{
				// Call protected function that can be overriden
				_Update();
			}
		}
		
		/**
		 * Returns the class name of the component for
		 * dictionary registration.
		 */
		internal function get className():Object
		{
			if ( !cClassname )
			{
				cClassname = Object( this ).constructor;
			}

			return cClassname;
		}


		/**
		 * Called if verConsole is enabled, used to create concommands for the component.
		 */
		protected function _Concommands():void {}
		
		/**
		 * Called each engine tick (verEngine), if the component updates
		 */
		protected function _Update():void {}
		

		/**
		 * Pauses/resumes the component updating, if it's pausable.
		 */
		public function _SetUpdating( bUpdating:Boolean ):void
		{
			if ( !bPausable ) { return; }

			bPaused = !bUpdating;
		}

		/**
		 * Returns if the component is not updating (paused).
		 * @return
		 */
		public function _IsNotUpdating():Boolean
		{
			return bPaused;
		}
	}
}