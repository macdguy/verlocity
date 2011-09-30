/*
	This file is subject to the terms and conditions defined in
    file 'license.txt', which is part of this source code package.
*/

/*
	=========================================
			   Verlocity Engine
	=========================================
	|	Developed by Macklin Guy, 2011.		|
	|										|
	|										|
	-----------------------------------------
	verEnts.as
	-----------------------------------------
	This class handles all the functions behind the entities.
	It is the entity manager of Verlocity.
	Handles loops, clean up, and rendering of entities.
*/

package VerlocityEngine.components 
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getDefinitionByName;
	import VerlocityEngine.base.ents.verBTriggerMultiple;

	import VerlocityEngine.Verlocity;
	import VerlocityEngine.VerlocityLanguage;
	import VerlocityEngine.base.ents.verBEnt;
	import VerlocityEngine.base.verBLayer;

	public final class verEnts extends Object
	{
		//********* VERLOCITY COMPONENT HEADER *********//
		/************************************************/		
		public function IsValid():Boolean { return wasCreated; }
		private var wasCreated:Boolean;

		public function verEnts():void
		{
			if ( wasCreated ) { throw new Error( VerlocityLanguage.T( "ComponentLoadFail" ) ); return; } wasCreated = true;
			Construct();
			Concommands();
		}
		/************************************************/
		/************************************************/

		/*
		 ****************COMPONENT VARS******************
		*/
		private var vEnts:Vector.<verBEnt>;
		private var bIsPaused:Boolean;


		/*
		 **************COMPONENT CREATION****************
		*/
		private function Construct():void
		{
			vEnts = new Vector.<verBEnt>();
		}

		/*
		 *************COMPONENT CONCOMMANDS**************
		*/
		private function Concommands():void
		{
			if ( !Verlocity.console ) { return; }

			Verlocity.console.Register( "ent_set", function( obj:String, property:String, value:String ):void
			{
				//if ( "hasOwnProperty" in obj ) { Output( "Set command failed: Object not valid." ); return; }
				//if ( !obj.hasOwnProperty( property ) ) { Output( "Set command failed: Property not found in object." ); return; }

				//obj[property] = value;
			}, "Sets a propterty (ex. height) to any entity." );

			Verlocity.console.Register( "ent_remove_all", function():void
			{
				RemoveAll( false );
			}, "Removes all entities (non-protected)." );
		}


		/*
		 ****************COMPONENT LOOP******************
		*/
		public function Think():void
		{
			if ( bIsPaused ) { return; }

			var iLength:int = vEnts.length;
			if ( iLength <= 0 ) { return; } 

			var i:int = iLength - 1;
			var refCurrent:verBEnt;

			while( i >= 0 )
			{
				refCurrent = vEnts[i];

				if ( refCurrent.IsDead() )
				{
					refCurrent.DeInit();
					refCurrent.Dispose();

					if ( refCurrent.parent )
					{
						refCurrent.parent.removeChild( refCurrent );
					}

					delete vEnts[i];
					vEnts[i] = null;
					vEnts.splice( i, 1 );
				}
				else
				{
					refCurrent.InternalThink();
					refCurrent.Think();
				}

				refCurrent = null;
				i--;
			}
		}


		/*
		 *************COMPONENT FUNCTIONS***************
		*/

		/*------------------ PRIVATE ------------------*/
		private function RecreateEnt( entClass:Class, iPosX:int = 0, iPosY:int = 0, iRot:int = 0 ):verBEnt
		{
			var newEnt:verBEnt = new entClass();
			newEnt.x = iPosX; newEnt.y = iPosY;
			newEnt.rotation = iRot;

			if ( Register( newEnt ) )
			{
				return newEnt;
			}
	
			return null;
		}
		
		private function Register( ent:verBEnt ):Boolean
		{
			if ( ent.id != -1 ) { return false; }

			vEnts[ vEnts.length ] = ent;
			ent.id = vEnts.length;
			
			return true;
		}


		/*------------------ PUBLIC -------------------*/
		public function Create( entClass:Class ):*
		{
			var newEnt:verBEnt = new entClass();

			Register( newEnt );

			return newEnt;
		}

		public function RegisterContained( disp:MovieClip ):void
		{
			if ( disp.numChildren == 0 ) { return; }

			var original:DisplayObject;

			var iNum:int = disp.numChildren - 1;

			// TODO: Solve sorting issue
			for ( var i:int = 0; i <= iNum; i++ )
			{
				original = disp.getChildAt( i );

				if ( original is verBEnt )
				{
					var originalName:String = getQualifiedClassName( original );
					var originalClass:Class = getDefinitionByName( originalName ) as Class;

					original.visible = false; // TODO: Fix removing child issue.

					var bc:* = RecreateEnt( originalClass, original.x, original.y, original.rotation );
					if ( bc )
					{
						disp.addChild( bc );
						Verlocity.Trace( "Ents", "Registered contained ent: " + originalClass );
					}
					else
					{
						Verlocity.Trace( "Ents", "Contained ent: " + originalClass + " already registered!" );
					}					
				}

				original = null;
			}
		}
		
		public function RemoveAll( bRemoveProtected:Boolean = false ):void
		{
			var iLength:int = vEnts.length;
			if ( iLength <= 0 ) { return; } 

			var i:int = iLength - 1;
			var refCurrent:verBEnt;

			while( i >= 0 )
			{
				refCurrent = vEnts[i];
				
				if ( bRemoveProtected || !refCurrent.IsProtected() )
				{
					refCurrent.Remove();
				}

				refCurrent = null;
				i--;
			}

			Verlocity.Trace( "Ents", VerlocityLanguage.T( "GenericRemoveAll" ) );
		}

		public function GetAll():Vector.<verBEnt>
		{
			return vEnts;
		}

		public function CountAll():int
		{
			return vEnts.length;
		}
		
		public function GetByClass( entClass:Class ):Array
		{
			var iLength:int = vEnts.length;
			if ( iLength <= 0 ) { return []; }
			

			var returnEnts:Array = new Array();

			var i:int = iLength - 1;
			var refCurrent:verBEnt;

			while( i >= 0 )
			{
				refCurrent = vEnts[i];

				if ( refCurrent.GetClass() == entClass )
				{
					returnEnts[ returnEnts.length ] = refCurrent;
				}

				refCurrent = null;
				i--;
			}
			
			return returnEnts;
		}
		
		public function GetByType( sType:String ):Array
		{
			var iLength:int = vEnts.length;
			if ( iLength <= 0 ) { return []; }
			

			var returnEnts:Array = new Array();

			var i:int = iLength - 1;
			var refCurrent:verBEnt;

			while( i >= 0 )
			{
				refCurrent = vEnts[i];

				if ( refCurrent.IsT( sType ) )
				{
					returnEnts[ returnEnts.length ] = refCurrent;
				}

				refCurrent = null;
				i--;
			}
			
			return returnEnts;
		}
		
		public function RemoveAllClass( entClass:Class ):void
		{
			var iLength:int = vEnts.length;
			if ( iLength <= 0 ) { return; } 

			var i:int = iLength - 1;
			var refCurrent:verBEnt;

			while( i >= 0 )
			{
				refCurrent = vEnts[i];
				
				if ( refCurrent.GetClass() == entClass )
				{
					refCurrent.Remove();
				}

				refCurrent = null;
				i--;
			}
		}
		
		public function RemoveAllType( sType:String ):void
		{
			var iLength:int = vEnts.length;
			if ( iLength <= 0 ) { return; } 

			var i:int = iLength - 1;
			var refCurrent:verBEnt;

			while( i >= 0 )
			{
				refCurrent = vEnts[i];

				if ( refCurrent.IsT( sType ) )
				{
					refCurrent.Remove();
				}

				refCurrent = null;
				i--;
			}
		}
		
		public function Pause():void
		{
			bIsPaused = true;
		}
		
		public function Resume():void
		{
			bIsPaused = false;
		}
		
		public function get IsPaused():Boolean { return bIsPaused; }

	}

}