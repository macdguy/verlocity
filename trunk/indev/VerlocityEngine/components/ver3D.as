/*
	This file is subject to the terms and conditions defined in
    file 'license.txt', which is part of this source code package.
*/

package VerlocityEngine.components 
{
	import away3d.loaders.Obj;
	import VerlocityEngine.Verlocity;
	import VerlocityEngine.VerlocityLanguage;
	import VerlocityEngine.VerlocitySettings;

	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Vector3D;

	import away3d.core.base.Object3D;
	import away3d.cameras.Camera3D;
	import away3d.containers.View3D;
	import away3d.containers.Scene3D;
	import away3d.containers.ObjectContainer3D;
	
	import away3d.materials.WireframeMaterial;
	import away3d.primitives.LineSegment;
	import away3d.core.base.Vertex;
	import away3d.core.utils.Cast;
	import away3d.core.render.Renderer;

	public class ver3D 
	{
		//********* VERLOCITY COMPONENT HEADER *********//
		/************************************************/
		public function IsValid():Boolean { return wasCreated; }
		private var wasCreated:Boolean;
		
		public function ver3D():void
		{
			if ( wasCreated ) { throw new Error( VerlocityLanguage.T( "ComponentLoadFail" ) ); return; } wasCreated = true;
		}
		/************************************************/
		/************************************************/
		
		/*
		 ****************COMPONENT VARS******************
		*/
		private var a3Dscene:Scene3D;

		private var a3Dcamera:Camera3D;
		private var a3Dview:View3D;
 
		private var a3Dcontainer:ObjectContainer3D;
		
		
		/*
		 ****************COMPONENT LOOP******************
		*/
		public function Think():void
		{
			if ( a3Dcamera ) { a3Dcamera.update(); }
			if ( a3Dview ) { a3Dview.render(); }
		}
		
		
		/*
		 *************COMPONENT FUNCTIONS***************
		*/
		
		/*------------------ PRIVATE ------------------*/
		private function Resize( e:Event = null ):void
		{
			if ( !a3Dview ) { return; }

			a3Dview.x = Verlocity.ScrW / 2;
			a3Dview.y = Verlocity.ScrH / 2;
		}

		/*------------------ PUBLIC -------------------*/
		public function Create( layer:*, bZOrderFix:Boolean = false ):void
		{
			if ( layer is String ) { layer = Verlocity.layers.Get( layer ); }
			else if ( layer is DisplayObject ) { layer = layer; } else { return; }

			if ( !layer ) { Verlocity.Trace( "Away3D", "Unable to create 3D! Check if layer is valid!" ); return; }

			// Create a new scene
			a3Dscene = new Scene3D();

			// Create a new camera
			a3Dcamera = new Camera3D( { zoom: 25, focus: 30, x:0, y:0, z:0 } );
			a3Dcamera.lookAt( new Vector3D( 0, 0, 0 ) );
     
			// Create a new view
			a3Dview = new View3D( { scene:a3Dscene, camera:a3Dcamera } );
			a3Dview.renderer = Renderer.BASIC;

			// Center the viewport
			a3Dview.x = Verlocity.ScrW / 2;
			a3Dview.y = Verlocity.ScrH / 2;
			layer.addChild( a3Dview );
			
			// Create a container
			a3Dcontainer = new ObjectContainer3D();
			a3Dscene.addChild( a3Dcontainer );
			
			
			if ( VerlocitySettings.A3D_DEBUG )
			{
				// DEBUG LINES
				var origin:Vertex = new Vertex(0, 0, 0);

				var xAxis:LineSegment = new LineSegment( { material:new WireframeMaterial( 0xFF0000, { width:2 } )} );
					xAxis.start = origin;
					xAxis.end = new Vertex( 100, 0, 0 );
				a3Dcontainer.addChild( xAxis );

				var yAxis:LineSegment = new LineSegment( { material:new WireframeMaterial( 0x00FF00, { width:2 } ) } );
					yAxis.start = origin;
					yAxis.end = new Vertex( 0, 100, 0 );
				a3Dcontainer.addChild( yAxis );

				var zAxis:LineSegment = new LineSegment( { material:new WireframeMaterial( 0x0000FF, { width:2 } ) } );
				zAxis.start = origin;
				zAxis.end = new Vertex( 0, 0, 100 );
				a3Dcontainer.addChild( zAxis );
			}
			
			if ( bZOrderFix ) { ZOrderFix( true ); }
			
			Verlocity.stage.addEventListener( Event.RESIZE, Resize );

			Verlocity.Trace( "Away3D", "Created Away3D instance successfully." );
		}

		public function get camera():Camera3D { return a3Dcamera; }
		public function get view():View3D { return a3Dview; }
		public function get container():ObjectContainer3D { return a3Dcontainer; }

		public function Material( materialClass:Class ):BitmapData
		{
			return Cast.bitmap( materialClass );
		}
		
		/**
		 * This fix is VERY taxing!
		 * @param	bEnabled Turn on the Z order fix.
		 */
		public function ZOrderFix( bEnabled:Boolean ):void
		{
			if ( !a3Dview ) { return; }
			
			if ( bEnabled )
			{
				a3Dview.renderer = Renderer.CORRECT_Z_ORDER;
			}
			else
			{
				a3Dview.renderer = Renderer.BASIC;
			}
		}
		
		public function CreateModel( obj:Class, iPosX:int = 0, iPosY:int = 0, iPosZ:int = 0, nScale:Number = 0 ):Object3D
		{
			var newObject:Object3D = new obj( nScale );
			
			newObject.x = iPosX;
			newObject.y = iPosY;
			newObject.z = iPosZ;
			
			a3Dcontainer.addChild( newObject );
			
			return newObject;
		}
		
		// TODO: Finish these helper functions
		public function CreateCube():void {}
		public function CreateSprite():void {}


		public function Remove():void
		{
			if ( a3Dcamera )
			{
				a3Dcamera = null;
			}
			
			if ( a3Dview )
			{
				if ( a3Dview.parent )
				{
					a3Dview.parent.removeChild( a3Dview );
				}

				a3Dview = null;
			}
			
			if ( a3Dcontainer )
			{
				var children:Vector.<Object3D> = a3Dcontainer.children;
				for ( var i:int = 0; i < children.length; i++ )
				{
					a3Dcontainer.removeChild( children[i] );
					
					delete children[i];
					children[i] = null;
				}
				children = null;
				
				if ( a3Dscene )
				{
					a3Dscene.removeChild( a3Dcontainer );
					a3Dscene = null;
				}

				a3Dcontainer = null;
			}

			Verlocity.stage.removeEventListener( Event.RESIZE, Resize );

			Verlocity.Trace( "Away3D", "Removed Away3D instance successfully." );
		}
	}
}