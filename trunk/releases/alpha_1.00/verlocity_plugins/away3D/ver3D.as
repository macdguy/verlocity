/*
 * ---------------------------------------------------------------
 * Verlocity
 * http://www.verlocityengine.com
 * 
 * This file is subject to the terms and conditions defined in
 * 'license.txt', which is part of this source code package.
 * ---------------------------------------------------------------
 * Component: ver3D for PluginAway3D
 * Author: Macklin Guy
 * ---------------------------------------------------------------
*/
package verlocity_plugins.away3D
{
	import flash.display.Stage;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Vector3D;

	import away3d.cameras.Camera3D;
	import away3d.containers.View3D;
	import away3d.containers.Scene3D;
	import away3d.containers.ObjectContainer3D;
	import away3d.loaders.Obj;

	import away3d.core.base.Vertex;
	import away3d.core.utils.Cast;
	import away3d.core.render.Renderer;
	import away3d.core.base.Object3D;
	import away3d.primitives.LineSegment;
	import away3d.primitives.Cube;
	import away3d.primitives.data.CubeMaterialsData;
	import away3d.primitives.Skybox6;
	import away3d.materials.WireframeMaterial;
	import away3d.materials.ColorMaterial;
	import away3d.materials.BitmapMaterial;
	import away3d.materials.Material;
	import away3d.materials.TransformBitmapMaterial;
	import away3d.sprites.Sprite3D;
	import away3d.lights.PointLight3D;

	import verlocity.Verlocity;
	import verlocity.core.Component;

	/**
	 * Provides easy Away3D 3.6.0 instancing and support.
	 *
	 * Simply setups up Away3D support with additional
	 * functions that allow for easy API access to the 3D engine.
	 * Verlocity is mainly a 2D engine, as such, this component
	 * is designed for 3D effects for backgrounds and 3D sprites.
	 * This only provides one single 3D scene, camera, and view.
	 */
	public final class ver3D extends Component
	{
		private var bInitialized:Boolean;
		private var a3Dscene:Scene3D;
		private var a3Dcamera:Camera3D;
		private var a3Dview:View3D; 
		private var a3Dcontainer:ObjectContainer3D;

		/**
		 * Constructor of the component.
		 * @param	sStage
		 */
		public function ver3D( sStage:Stage ):void
		{
			// Setup component
			super( sStage, true, true, false );
			
			// Component-specific construction
		}

		/**
		 * Updates the 3D rendering.
		 */
		protected override function _Update():void 
		{
			if ( a3Dcamera ) { a3Dcamera.update(); }
			if ( a3Dview ) { a3Dview.render(); }
		}

		/**
		 * Concommands of the component.
		 */
		protected override function _Concommands():void 
		{
			Verlocity.console.Register( "a3D_remove", function():void
			{
				Remove();
			}, "Removes the 3D instance." );
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
		 * Handles resizing
		 * @param	e
		 */
		private final function Resize( e:Event = null ):void
		{
			if ( !a3Dview ) { return; }

			a3Dview.x = Verlocity.ScrW / 2;
			a3Dview.y = Verlocity.ScrH / 2;
		}
		
		/**
		 * Creates X, Y, and Z axis debug lines
		 */
		private final function CreateDebugAxis():void
		{
			var origin:Vertex = new Vertex( 0, 0, 0 );

			CreateLine( origin, new Vertex( 100, 0, 0 ), 0xFF0000 );
			CreateLine( origin, new Vertex( 0, 100, 0 ), 0x00FF00 );
			CreateLine( origin, new Vertex( 0, 0, 100 ), 0x0000FF );
		}

		/*===============================================*/
		
		/*------------------- PUBLIC --------------------*/
		/**
		 * Creates the 3D scene.
		 * @param	sLayer Layer the 3D should be rendered in
		 * @param	bZOrderFix Enables z order fix (very costly)
		 */
		public final function Create( sLayer:String, bZOrderFix:Boolean = false ):void
		{
			if ( !Verlocity.IsValid( Verlocity.layers ) ) { return; }

			if ( bInitialized ) { return; }

			if ( !Verlocity.layers.IsValidLayer( sLayer ) )
			{
				Verlocity.Trace( "Unable to create 3D! Check if layer is valid!", "Away3D" );
				return;
			}
			
			bInitialized = true;

			// Create a new scene
			a3Dscene = new Scene3D();

			// Create a new camera
			a3Dcamera = new Camera3D( { zoom: 25, focus: 30, x:0, y:0, z:0 } );
			ResetCamera();
     
			// Create a new view
			a3Dview = new View3D( { scene:a3Dscene, camera:a3Dcamera } );
			a3Dview.renderer = Renderer.BASIC;

			// Center the viewport
			a3Dview.x = Verlocity.ScrW / 2;
			a3Dview.y = Verlocity.ScrH / 2;
			Verlocity.layers.addChild( a3Dview, sLayer );
			
			// Create a container
			a3Dcontainer = new ObjectContainer3D();
			a3Dscene.addChild( a3Dcontainer );

			// Draw debug
			if ( Verlocity.settings.DEBUG_A3D )
			{
				CreateDebugAxis();
			}

			// Apply z order
			if ( bZOrderFix ) { ZOrderFix( true ); }

			// Resizing
			stage.addEventListener( Event.RESIZE, Resize );

			// Render
			_SetUpdating( true );

			Verlocity.Trace( "Created Away3D instance successfully.", "Away3D" );
		}

		/**
		 * Returns the 3D camera
		 */
		public final function get camera():Camera3D { return a3Dcamera; }
		
		/**
		 * Returns the 3D view
		 */
		public final function get view():View3D { return a3Dview; }
		
		/**
		 * Returns the 3D container
		 */
		public final function get container():ObjectContainer3D { return a3Dcontainer; }

		/**
		 * Creates and returns bitmap data from an image class
		 * @param	materialClass
		 * @return
		 */
		public final function CastBitmapData( materialClass:Class ):BitmapData
		{
			return Cast.bitmap( materialClass );
		}
		
		/**
		 * Enables Z order sorting fix.
		 * This fix is VERY taxing!
		 * @param	bEnabled Enable/disable Z order fix.
		 */
		public final function ZOrderFix( bEnabled:Boolean ):void
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
		
		/**
		 * Creates and displays a new 3D model
		 * @param	objClass 3D model class
		 * @param	vPos 3D position
		 * @param	nScale Scale of model
		 * @return
		 */
		public final function CreateModel( objClass:Class, vPos:Vector3D, nScale:Number = 1 ):Object3D
		{
			var obj:Object3D = new objClass( nScale );

			obj.x = vPos.x;
			obj.y = vPos.y;
			obj.z = vPos.z;
			
			a3Dcontainer.addChild( obj );

			return obj;
		}

		/**
		 * Creates and displays a 3D cube
		 * @param	vPos Position of cube
		 * @param	nWidth Width of cube
		 * @param	nHeight Height of cube
		 * @param	nDepth Depth of cube
		 * @param	cubeMaterial Material of cube
		 */
		public final function CreateCube( vPos:Vector3D, nWidth:Number, nHeight:Number, nDepth:Number, cubeMaterial:Material ):Cube
		{
			var cube:Cube = new Cube( { material: cubeMaterial, width: nWidth, height: nHeight, depth: nDepth } );
			
			cube.x = vPos.x;
			cube.y = vPos.y;
			cube.z = vPos.z;
			
			a3Dcontainer.addChild( cube );
			
			return cube;
		}

		/**
		 * Creates and displays a 3D sprite
		 * @param	vPos Position of the sprite
		 * @param	material Material of the sprite
		 * @param	nWidth Width of the sprite
		 * @param	nHeight Height of the sprite
		 * @param	nScale Scale of the sprite
		 * @param	nRot Rotation of the sprite
		 * @param	sAlign Alignment of the sprite
		 * @return
		 */
		public final function CreateSprite( vPos:Vector3D, material:Material, nWidth:Number, nHeight:Number, nScale:Number = 1, nRot:Number = 0, sAlign:String = "center" ):Sprite3D
		{
			var sprite:Sprite3D = new Sprite3D( material, nWidth, nHeight, nRot, sAlign, nScale );
		
			sprite.x = vPos.x;
			sprite.y = vPos.y;
			sprite.z = vPos.z;

			a3Dcontainer.addSprite( sprite );
			
			return sprite;
		}
		
		/**
		 * Creates and displays a 3D line
		 * @param	vStartPos Start position
		 * @param	vEndPos End position
		 * @param	uiColor Color
		 */
		public final function CreateLine( vStartPos:Vertex, vEndPos:Vertex, uiColor:uint = 0x00000 ):LineSegment
		{
			var line:LineSegment = new LineSegment( { material: MatWireframe( uiColor, 2 ) } );
				line.start = vStartPos;
				line.end = vEndPos;
			a3Dcontainer.addChild( line );
			
			return line;
		}

		/**
		 * Creates and displays a 3D skybox (this is taxing)
		 * @param	skyMaterial
		 * @return
		 */
		public final function CreateSkybox( skyMaterial:Material ):Skybox6
		{
			var skybox:Skybox6 = new Skybox6( skyMaterial );

			a3Dcontainer.addChild( skybox );
			
			return skybox;
		}
		
		/**
		 * Creates and returns a 3D point light (taxing)
		 * @param	vPos Position of the light
		 * @param	nBrightness Brightness of the light
		 * @param	uiColor Color of the light
		 * @return
		 */
		public final function CreatePointLight( vPos:Vector3D, nBrightness:Number, uiColor:uint ):PointLight3D
		{
			var light:PointLight3D = new PointLight3D( { x: vPos.x, 
														 y: vPos.y, 
														 z: vPos.z, 
														 brightness: nBrightness } );
			light.color = uiColor;

			a3Dcontainer.addLight( light );
			
			return light;
		}
		
		/**
		 * Creates and returns a 3D bitmap material
		 * @param	materialClass Material image
		 */
		public final function MatBitmap( materialClass:Class ):BitmapMaterial
		{
			return new BitmapMaterial( CastBitmapData( materialClass ) );
		}
		
		/**
		 * Creates and returns a wireframe material
		 * @param	uiColor
		 * @param	nWidth
		 */
		public final function MatWireframe( uiColor:uint, nWidth:Number = 2 ):WireframeMaterial
		{
			return new WireframeMaterial( uiColor, { width: nWidth } );
		}
		
		/**
		 * Creates and returns a solid color material
		 * @param	uiColor
		 */
		public final function MatColor( uiColor:uint ):ColorMaterial
		{
			return new ColorMaterial( uiColor );
		}
		
		/**
		 * Creates and returns a 3D transform bitmap material
		 * @param	materialClass Material image
		 * @param	bRepeat Does it repeat
		 * @param	nScaleX Scale of material x tile
		 * @param	nScaleY Scale of material Y tile
		 * @return
		 */
		public final function MatTransform( materialClass:Class, bRepeat:Boolean = true, nScaleX:Number = 1, nScaleY:Number = 1 ):TransformBitmapMaterial
		{
			return new TransformBitmapMaterial( CastBitmapData( materialClass ), { 
												repeat: bRepeat, 
												scaleX: nScaleX, 
												scaleY: nScaleY } );
		}
		
		/**
		 * Creates and returns a material cube (a material with seperate textures per side)
		 * @param	topMat Top material
		 * @param	bottomMat Bottom material
		 * @param	frontMat Front material
		 * @param	leftMat Left material
		 * @param	rightMat Right material
		 * @param	backMat Back material
		 * @return
		 */
		public final function MatCube( topMat:Material = null, bottomMat:Material = null, frontMat:Material = null, leftMat:Material = null, rightMat:Material = null, backMat:Material = null ):CubeMaterialsData
		{
			return new CubeMaterialsData( { top: topMat,
											bottom: bottomMat, 
											front: frontMat, 
											left: leftMat, 
											right: rightMat, 
											back: backMat } );
		}
		
		/**
		 * Resets the position and angle of the camera.
		 */
		public final function ResetCamera():void
		{
			if ( !a3Dcamera ) { return; }

			a3Dcamera.x = 0;
			a3Dcamera.y = 0;			
			a3Dcamera.z = -300;
			a3Dcamera.lookAt( new Vector3D( 0, 30, 0 ) );
		}
		
		/**
		 * Moves the camera by different amounts.
		 * @param	vMoveAmounts
		 */
		public final function MoveCamera( vPos:Vector3D ):void
		{
			if ( !a3Dcamera ) { return; }

			a3Dcamera.moveRight( vPos.x );
			a3Dcamera.moveUp( vPos.y );
			a3Dcamera.moveForward( vPos.z );
		}

		/**
		 * Removes all 3D objects from the container/scene
		 */
		public final function RemoveAllObjects():void
		{
			if ( !a3Dcontainer ) { return; }

			var children:Vector.<Object3D> = a3Dcontainer.children;
			for ( var i:int = 0; i < children.length; i++ )
			{
				a3Dcontainer.removeChild( children[i] );
					
				delete children[i];
				children[i] = null;
			}
			children = null;
		}


		/**
		 * Removes the 3D scene completely.
		 */
		public final function Remove():void
		{
			// Remove camera
			if ( a3Dcamera )
			{
				a3Dcamera = null;
			}
			
			// Remove view
			if ( a3Dview )
			{
				if ( a3Dview.parent )
				{
					a3Dview.parent.removeChild( a3Dview );
				}

				a3Dview = null;
			}
			
			// Remove container and children
			if ( a3Dcontainer )
			{
				RemoveAllObjects();

				if ( a3Dscene )
				{
					a3Dscene.removeChild( a3Dcontainer );
					a3Dscene = null;
				}

				a3Dcontainer = null;
			}

			stage.removeEventListener( Event.RESIZE, Resize );
			
			_SetUpdating( false );
			bInitialized = false;

			Verlocity.Trace( "Removed Away3D instance successfully.", "Away3D" );
		}
	}
}