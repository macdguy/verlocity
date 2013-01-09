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
	import flash.display.Stage;

	import verlocity.events.EventPlugin;
	import verlocity.Verlocity;

	public class Plugin extends Singleton
	{
		// Access to the stage
		protected var stage:Stage;
		
		// Class for registration
		private var cClassname:Object;
		
		// Are we loaded?
		internal var loaded:Boolean;

		/**
		 * The constructor of a plugin.
		 */
		public function Plugin():void
		{
			super();
		}

		/**
		 * Called when the component is destroyed.
		 */
		public override function _Destruct():void
		{
			// Remove from singleton manager
			super._Destruct();
			
			// Remove stage reference
			stage = null;
		}
		
		/**
		 * Internally called.
		 * DO NOT OVERRIDE THIS!
		 * Override OnCreated instead
		 */
		internal function _OnCreate( sStage:Stage ):void
		{
			stage = sStage;
			OnCreated();
		}

		/**
		 * Called when the plugin is created.
		 * Used to setup whatever is needed for the plugin to function.
		 */
		protected function OnCreated():void {}
		
		/**
		 * Call this when the plugin is fully loaded.
		 */
		protected function FinishLoading():void
		{
			Verlocity.plugins._FinishLoadPlugin( this );
		}
		
		/**
		 * Returns the class name of the component for
		 * dictionary registration.
		 */
		public function get className():Object
		{
			if ( !cClassname )
			{
				cClassname = Object( this ).constructor;
			}

			return cClassname;
		}
	}
}