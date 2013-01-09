/*
 * ---------------------------------------------------------------
 * Verlocity
 * http://www.verlocityengine.com
 * 
 * This file is subject to the terms and conditions defined in
 * 'license.txt', which is part of this source code package.
 * ---------------------------------------------------------------
 * Component: verEnts
 * Author: Macklin Guy
 * ---------------------------------------------------------------
*/
package verlocity.components
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;

	import verlocity.Verlocity;
	import verlocity.core.Component;
	import verlocity.core.LinkedList;
	import verlocity.core.ListNode;
	import verlocity.ents.Entity;
	import verlocity.ents.DynamicEntity;
	import verlocity.ents.DisplayEntity;
	import verlocity.ents.effects.Effect;
	import verlocity.ents.effects.ScreenEffect;
	import verlocity.utils.ArrayUtil;

	/**
	 * Manages all the entities.
	 * The entity manager which handles updating, memory management, and rendering
	 * of entities.
	 * The entities are handled in a linked list data structure.
	 */
	public final class verEnts extends Component
	{
		// Static entities
		private var llEnts:LinkedList;

		/**
		 * Constructor of the component.
		 */
		public function verEnts():void
		{
			// Setup component
			super( null, true, true );
			
			// Component-specific construction
			llEnts = new LinkedList();
		}
		
		/**
		 * Updates all the different lists of entities.
		 */
		protected override function _Update():void
		{
			UpdateEnts( llEnts );
		}

		/**
		 * Updates all the entities in a list.
		 * @param	list Linked list of entities
		 */
		private final function UpdateEnts( list:LinkedList ):void
		{
			var ent:Entity;
			var node:ListNode = list.head;

			while ( node )
			{
				ent = node.data;

				if ( ent.IsDead() )
				{
					RemoveEntity( ent, list, node );
				}
				else
				{
					UpdateEntity( ent, list, node );
				}

				node = node.next;
			}

			ent = null;
		}

		/**
		 * Concommands of the component.
		 */
		protected override function _Concommands():void 
		{
			/*Verlocity.console.Register( "ent_set", function( obj:String, property:String, value:String ):void
			{
				//if ( "hasOwnProperty" in obj ) { Output( "Set command failed: Object not valid." ); return; }
				//if ( !obj.hasOwnProperty( property ) ) { Output( "Set command failed: Property not found in object." ); return; }

				//obj[property] = value;
			}, "Sets a propterty (ex. height) to any entity." );*/

			Verlocity.console.Register( "ent_remove_all", function():void
			{
				RemoveAll( false );
			}, "Removes all entities (non-protected)." );
		}

		/**
		 * Destructor of the component.
		 */
		public override function _Destruct():void
		{	
			// Component-specific destruction
			RemoveAll();

			llEnts.dispose();
			llEnts = null;
			
			// Destroy component
			super._Destruct();
		}

		/*================== COMPONENT ==================*/

		/*------------------- PRIVATE -------------------*/
		/**
		 * Updates an entity.
		 * @param	ent The entity
		 * @param	list The linked list
		 * @param	node The node
		 */
		private final function UpdateEntity( ent:Entity, list:LinkedList, node:ListNode ):void
		{
			if ( !ent || !node || !list || !ent.IsUpdating() ) { return; }
			
			ent._Update();
			ent.Update();
			
			if ( ent._IsDynamic )
			{
				// Apply physics
				if ( Verlocity.IsValid( Verlocity.phys ) )
				{
					Verlocity.phys._UpdatePhysics( DynamicEntity( ent ) );
				}
					
				// Apply collision
				if ( Verlocity.IsValid( Verlocity.collision ) )
				{
					Verlocity.collision._UpdateCollision( DynamicEntity( ent ), node );
				}
			}
		}
		
		/**
		 * Removes an entity.
		 * @param	ent The entity
		 * @param	list The linked list
		 * @param	node The node
		 */
		private final function RemoveEntity( ent:Entity, list:LinkedList, node:ListNode ):void
		{
			if ( !ent || !node || !list ) { return; }
			
			ent.DeInit(); // User defined
			ent._Dispose(); // Data clean
			
			list.splice( node );
		}

		/**
		 * Registers an entity to the manager.
		 * @param	ent The entity
		 * @return
		 */
		private final function RegisterEntity( ent:Entity ):Boolean
		{
			if ( ent._id != -1 ) { return false; }

			llEnts.push( ent );
			ent._id = llEnts.length;

			ent.Construct();

			// This will be enabled once its spawned
			if ( !ent._IsDisplay )
			{
				ent.EnableUpdate();
			}
			
			return true;
		}

		/*===============================================*/
		
		/*------------------- PUBLIC --------------------*/
		/**
		 * Creates an entity.
		 * @param	entClass The class of the entity you wish to create
		 * @param	bCollision Should collision be checked on this?
		 * @param	dispObject The display object that represents the artwork of the entity
		 * @return
		 */
		public final function Create( entClass:Class, bCollision:Boolean = true ):*
		{
			var newEnt = new entClass();

			RegisterEntity( Entity( newEnt ) );

			if ( newEnt._IsDisplay )
			{
				newEnt.EnableCollision( bCollision );
				if ( bCollision ) { newEnt.SetupCollision(); }
			}
			else
			{
				newEnt.Init();
			}

			return newEnt;
		}
		
		/**
		 * Creates a display object entity with a sprite display object.
		 * This is useful for creating a simple drawable entity that has access to the graphics class.
		 * @param	bCollision Should collision be checked on this?
		 * @return
		 */
		public final function CreateSprite( bCollision:Boolean ):DisplayEntity
		{
			var newEnt:DisplayEntity = Create( DisplayEntity, bCollision );
			newEnt.display.SetDisplayObject( new Sprite() );
			
			return newEnt;
		}
		
		/**
		 * Creates an effect.  Effects are one time animations objects without collision.
		 * @param	effMovieClip The movieclip effect.
		 * @return
		 */
		public final function CreateEffect( mc:MovieClip ):Effect
		{
			var eff:Effect = new Effect( mc );
			
			eff.EnableCollision( false );
			
			RegisterEntity( Entity( eff ) );

			return eff;
		}

		/**
		 * Creates and spawns a screen effect.
		 * Screen effects are displayed on the top of the entire screen. 
		 * @param	scrFX Screen effect to spawn
		 * @param	bProtected Is it protected?
		 * @return
		 */
		public final function CreateScreenEffect( scrFX:ScreenEffect, bAddOnTop:Boolean = true, bProtected:Boolean = false ):*
		{
			// Default to sprite
			if ( !scrFX.display.IsValid() ) { scrFX.display.SetDisplayObject( new Sprite() ); }
			
			scrFX.EnableCollision( false );
	
			RegisterEntity( Entity( scrFX ) );

			// Add to the screen
			Verlocity.layers.layerScrFX.addChild( scrFX.display.displayObj );

			// Push to the top
			if ( bAddOnTop )
			{
				var iNum:int = Verlocity.layers.layerScrFX.numChildren;

				if( iNum > 0 )
				{
					Verlocity.layers.layerScrFX.setChildIndex( scrFX.display.displayObj, iNum - 1 );
				}
			}

			scrFX.SetProtected( bProtected );

			return scrFX;
		}

		/**
		 * Removes all of the entities.
		 * @param	bRemoveProtected Should we remove protected entities?
		 */
		public final function RemoveAll( bRemoveProtected:Boolean = false ):void
		{
			var node:ListNode = llEnts.head;
			var curEnt:Entity;

			while ( node )
			{
				curEnt = node.data;
				
				if ( bRemoveProtected || !curEnt.IsProtected() )
				{
					curEnt.Remove();
				}

				node = node.next;
			}
			
			curEnt = null;
			node = null;

			Verlocity.Trace( Verlocity.lang.T( "GenericRemoveAll" ), "Ents" );
		}

		/**
		 * Returns all of the current entities.
		 * @return
		 */
		public final function GetAll():Array
		{
			var node:ListNode = llEnts.head;
			var array:Array = new Array();

			while ( node )
			{
				array[ array.length ] = node.data;
				node = node.next;
			}
			
			node = null;

			return array;
		}
		
		/**
		 * Resets all entities (calls their reset and init function).
		 * This occurs each time a state is soft reset.
		 */
		public final function ResetAll():void
		{
			var node:ListNode = llEnts.head;
			var curEnt:Entity;

			while ( node )
			{
				curEnt = node.data;
				
				if ( !curEnt.IsDead() )
				{
					curEnt.Init();
					curEnt.Reset();
				}

				node = node.next;
			}
			
			curEnt = null;
			node = null;
		}

		/**
		 * Returns the linked list that holds all the entities.
		 * @return
		 */
		public final function GetLinkedList():LinkedList
		{
			return llEnts;
		}

		/**
		 * Returns the amount of current entities.
		 * @return
		 */
		public final function CountAll():int
		{
			return llEnts.length;
		}
		
		/**
		 * Returns an array of entities by class name.
		 * @param	entClass The class name to search by
		 * @return
		 */
		public final function GetByClass( entClass:Class ):Array
		{
			var node:ListNode = llEnts.head;
			var curEnt:Entity;
			
			var returnEnts:Array = new Array();

			while ( node )
			{
				curEnt = node.data;

				if ( curEnt.GetClass() == entClass )
				{
					returnEnts[ returnEnts.length ] = curEnt;
				}

				node = node.next;
			}
			
			curEnt = null;
			node = null;

			return returnEnts;
		}
		
		/**
		 * Returns an array of entities by type.
		 * @param	sType The type to search by
		 * @return
		 */
		public final function GetByType( sType:String ):Array
		{
			var node:ListNode = llEnts.head;
			var curEnt:Entity;
			
			var returnEnts:Array = new Array();

			while ( node )
			{
				curEnt = node.data;

				if ( curEnt.IsT( sType ) )
				{
					returnEnts[ returnEnts.length ] = curEnt;
				}

				node = node.next;
			}
			
			curEnt = null;
			node = null;

			return returnEnts;
		}
		
		
		/**
		 * Returns an array of entities by name.
		 * @param	sName The name to search by
		 * @return
		 */
		public final function GetByName( sName:String ):Array
		{
			var node:ListNode = llEnts.head;
			var curEnt:Entity;
			
			var returnEnts:Array = new Array();

			while ( node )
			{
				curEnt = node.data;

				if ( curEnt.name == sName )
				{
					returnEnts[ returnEnts.length ] = curEnt;
				}

				node = node.next;
			}
			
			curEnt = null;
			node = null;

			return returnEnts;
		}
		
		/**
		 * Removes all entities based on class name.
		 * @param	entClass The class to remove by
		 * @param	bRemoveProtected Should we remove protected entities?
		 */
		public final function RemoveAllClass( entClass:Class, bRemoveProtected:Boolean = false ):void
		{
			var node:ListNode = llEnts.head;
			var curEnt:Entity;

			while ( node )
			{
				curEnt = node.data;

				if ( ( bRemoveProtected || !curEnt.IsProtected() ) && 
					  curEnt.GetClass() == entClass )
				{
					curEnt.Remove();
				}

				node = node.next;
			}
			
			curEnt = null;
			node = null;
		}
		
		/**
		 * Removes all entities based on type.
		 * @param	sType The type to remove by
		 * @param	bRemoveProtected Should we remove protected entities?
		 */
		public final function RemoveAllType( sType:String, bRemoveProtected:Boolean = false ):void
		{
			var node:ListNode = llEnts.head;
			var curEnt:Entity;

			while ( node )
			{
				curEnt = node.data;

				if ( ( bRemoveProtected || !curEnt.IsProtected() ) && 
					 curEnt.IsT( sType ) )
				{
					curEnt.Remove();
				}

				node = node.next;
			}
			
			curEnt = null;
			node = null;
		}
		
		/**
		 * Removes all entities based on an array of types.
		 * @param	aArray The array of string types
		 * @param	bRemoveProtected
		 */
		public final function RemoveAllTypes( aArray:Array, bRemoveProtected:Boolean = false ):void
		{
			if ( aArray.length == 0 ) { return; }

			for ( var i:int; i < aArray.length; i++ )
			{
				RemoveAllType( String( aArray[i] ), bRemoveProtected );
			}

			aArray = null;
		}

		/**
		 * Pauses animations of all entities that have animations.
		 */
		public final function PauseAllAnimations():void
		{
			var node:ListNode = llEnts.head;
			var curEnt;

			while ( node )
			{
				curEnt = node.data;
				
				if ( curEnt._IsDisplay )
				{
					curEnt.Pause();
				}

				node = node.next;
			}

			curEnt = null;
			node = null;
		}

		/**
		 * Resumes animations of all entities that have animations.
		 */
		public final function ResumeAllAnimations():void
		{
			var node:ListNode = llEnts.head;
			var curEnt;

			while ( node )
			{
				curEnt = node.data;
				
				if ( curEnt._IsDisplay )
				{
					curEnt.Resume();
				}

				node = node.next;
			}
			
			curEnt = null;
			node = null;
		}
	}
}