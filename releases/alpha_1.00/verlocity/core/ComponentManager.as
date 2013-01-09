/*
 * ---------------------------------------------------------------
 * Verlocity
 * http://www.verlocityengine.com
 * 
 * This file is subject to the terms and conditions defined in
 * 'license.txt', which is part of this source code package.
 * ---------------------------------------------------------------
 * Description:
 * 		Stores and accesses all the instanced components.
 * 		Components are stored/accessed in a Dicitionary.
 * ---------------------------------------------------------------
*/
package verlocity.core 
{
	import flash.utils.Dictionary;

	import verlocity.components.*;
	import verlocity.Verlocity;

	public final class ComponentManager extends Singleton
	{
		// Holds the components.
		private static var dictComponents:Dictionary;
		
		private static var bUpdateDisabled:Boolean;

		/**
		 * Creates a new holder for the components.
		 */
		public function ComponentManager():void
		{
			super();
			dictComponents = new Dictionary( true );
		}
		
		/**
		 * Removes all registered components and their data.
		 */
		public override function _Destruct():void 
		{
			super._Destruct();

			RemoveAll();
			dictComponents = null;
		}

		/**
		 * Registers a component to the component manager.
		 * @param	component The component to register.
		 * @param	required (array) The list of required components before this component can be created.
		 */
		public function Register( component:Component, ... required ):void
		{
			// Check for duplicate
			if ( dictComponents[component.className] )
			{
				Verlocity.Trace( Verlocity.lang.T( "ComponentDuplicate" ), "Components" );

				component._Destruct();
				component = null;
				return;
			}
			
			// Check for required components
			var bRequiredFailed:Boolean;
			if ( required.length > 0 )
			{
				for ( var i:int = 0; i < required.length; i++ )
				{
					if ( !SingletonManager.IsActive( required[i] ) )
					{
						bRequiredFailed = true;
					}
				}
			}

			// Cancel registration if required components aren't available
			if ( bRequiredFailed )
			{
				Verlocity.Trace( component.className + Verlocity.lang.T( "ComponentFailed" ), "Components" );

				component._Destruct();
				component = null;
				return;
			}			

			// Store the component
			dictComponents[component.className] = component;

			// Component was registered successfully.
			Verlocity.Trace( component.className + Verlocity.lang.T( "ComponentSuccess" ) + "\n\n", "Components" );
		}
		
		/**
		 * Gets a registered component.
		 * @param	componentClass The component class.
		 * @return
		 */
		public function Get( componentClass:Object ):*
		{
			if ( !dictComponents ) { return; }

			if ( dictComponents[componentClass] )
			{
				return dictComponents[componentClass];
			}
			
			return null;
		}
		
		/**
		 * Returns all active components.
		 */
		public static function GetAll():Dictionary
		{
			return dictComponents;
		}
		
		/**
		 * Destroys a registered component.
		 * @param	componentClass The component class.
		 */
		public static function Remove( componentClass:Object ):void
		{
			if ( !dictComponents ) { return; }

			// Check if it exists
			if ( !dictComponents[componentClass] ) { return; }

			// Destroy it
			Component( dictComponents[componentClass] )._Destruct();
			Unregister( componentClass );

			trace( "   " + Verlocity.lang.T( "ComponentRemove" ) + componentClass );
		}
		
		/**
		 * Unregisters a registered component.
		 * @param	componentClass The component class.
		 */
		public static function Unregister( componentClass:Object ):void
		{
			if ( !dictComponents ) { return; }

			// Check if it exists
			if ( !dictComponents[componentClass] ) { return; }

			// Remove from manager
			dictComponents[componentClass] = null;
			delete dictComponents[componentClass];

			trace( "   " + Verlocity.lang.T( "ComponentUnregister" ) + componentClass );
		}
		
		/**
		 * Updates all components (called by verEngine)
		 * @param	component The component to update
		 */
		public static function _UpdateAll():void
		{
			if ( !dictComponents ) { return; }

			if ( Verlocity.IsQuitting() || bUpdateDisabled ) { return; }

			for ( var componentClass:Object in dictComponents )
			{
				// Update components that can be updated
				Component( dictComponents[componentClass] )._UpdateComponent();
			}
		}

		/**
		 * Sets if all the components should be updated.
		 * @param	bPause
		 */
		public static function _SetUpdateAll( bPause:Boolean ):void
		{
			bUpdateDisabled = bPause;
		}

		/**
		 * Removes all the registered components.
		 */
		public function RemoveAll():void
		{
			if ( !dictComponents ) { return; }
			
			// Remove state first
			if ( Verlocity.IsValid( Verlocity.state ) )
			{
				Remove( verStates );
			}

			// Remove the rest
			for ( var componentClass:Object in dictComponents )
			{
				Remove( componentClass );
			}
		}
	}
}