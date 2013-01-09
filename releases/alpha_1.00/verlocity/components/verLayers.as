/*
 * ---------------------------------------------------------------
 * Verlocity
 * http://www.verlocityengine.com
 * 
 * This file is subject to the terms and conditions defined in
 * 'license.txt', which is part of this source code package.
 * ---------------------------------------------------------------
 * Component: verLayers
 * Author: Macklin Guy
 * ---------------------------------------------------------------
*/
package verlocity.components
{
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.utils.Dictionary;
	import flash.geom.Point;

	import verlocity.Verlocity;
	import verlocity.core.Component;
	import verlocity.display.Layer;
	import verlocity.utils.DisplayUtil;
	import verlocity.utils.GraphicsUtil;

	/**
	 * Stores and handles all the layers and graphics.
	 * This is the main way you add content to the screen.
	 * 
	 * Note: When creating layers, know that they stack in order that you call them. 
	 * In other words create the HUD then Gameplay to have the HUD layer go on top of the Gameplay layer.
	 */
	public final class verLayers extends Component
	{
		private var dictLayers:Dictionary;

		private var screenSpace:Layer;
		private var sScreenRect:Shape;
		private var sprBackground:Sprite;

		private var iCurrentLayerIndex:int;

		internal var layerVerlocity:Layer;
		internal var layerUI:Layer;
		public var layerDraw:Layer;
		internal var layerScrFX:Layer;
		internal var layerBitmap:Layer;
		internal var layerMain:Layer;

		/**
		 * Constructor of the component.
		 * @param	sStage
		 */
		public function verLayers( sStage:Stage ):void
		{
			// Setup component
			super( sStage );
			
			// Component-specific construction

			// Setup to store the layers
			dictLayers = new Dictionary();

			// Screen rect
			sScreenRect = new Shape();
				sScreenRect.graphics.beginFill( 0, 0 );
				sScreenRect.graphics.drawRect( 0, 0, Verlocity.ScrW, Verlocity.ScrH );
				sScreenRect.graphics.endFill();
				sScreenRect.name = "Screen Rect";
			stage.addChildAt( sScreenRect, 0 );

			// Screen space
			screenSpace = new Layer();
				screenSpace.mask = sScreenRect;
				screenSpace.name = "Screen Space";
			stage.addChildAt( screenSpace, 0 );

			// Verlocity layer for verConsole, verAchievements, VerlocityMessages, and splash.
			layerVerlocity = new Layer();
			screenSpace.addChildAt( layerVerlocity, 0 );

			// UI layer for verUI
			layerUI = new Layer();
				layerUI.Fill( 0x000000, 0 );
				layerUI.name = "Layer UI";
			screenSpace.addChildAt( layerUI, 0 );

			// Drawable layer
			layerDraw = new Layer();
				layerDraw.name = "Layer Draw";
			screenSpace.addChildAt( layerDraw, 0 );

			// ScreenFX layer for screen FX
			layerScrFX = new Layer();
				layerScrFX.name = "Layer ScreenFX";
			screenSpace.addChildAt( layerScrFX, 0 );

			// -- START OF USER CONTROLLED --

				// verCamera support.
				if ( Verlocity.IsValid( Verlocity.camera ) )
				{
					screenSpace.addChildAt( Verlocity.camera._Get(), 0 );
					screenSpace.addChildAt( Verlocity.camera._GetView(), 0 );
				}

				// Main layer for anything not part of the camera.
				layerMain = new Layer();
					layerMain.name = "Layer Main";
				screenSpace.addChildAt( layerMain, 0 );

				// Bitmap layer
				layerBitmap = new Layer();
					layerBitmap.name = "Layer Bitmap";
				screenSpace.addChildAt( layerBitmap, 0 );

			// -- END OF USER CONTROLLED --

			// Background
			sprBackground = new Sprite();
				BGColor( Verlocity.settings.BGCOLOR );
				sprBackground.name = "Sprite Background";
			screenSpace.addChildAt( sprBackground, 0 );
		}
		
		/**
		 * Destructor of the component.
		 */
		public override function _Destruct():void
		{
			// Destroy component
			super._Destruct();
			
			// Component-specific destruction
			
			RemoveAll();
			dictLayers = null;

			// Remove screen space
			screenSpace.stage.removeChild( screenSpace );
			DisplayUtil.RemoveAllChildren( screenSpace );
			screenSpace = null;

			// Remove screen rect
			sScreenRect.stage.removeChild( sScreenRect );
			sScreenRect = null;

			// Remove background
			sprBackground = null;

			// Remove verlocity layer
			DisplayUtil.RemoveAllChildren( layerVerlocity );
			layerVerlocity = null;
			
			// Remove UI layer
			DisplayUtil.RemoveAllChildren( layerUI );
			layerUI = null;
			
			// Remove screen FX layer
			DisplayUtil.RemoveAllChildren( layerScrFX );
			layerScrFX = null;
			
			// Remove draw layer
			DisplayUtil.RemoveAllChildren( layerDraw );
			layerDraw = null;
			
			// Remove main layer
			DisplayUtil.RemoveAllChildren( layerMain );
			layerMain = null;
		}
		
		/*================== COMPONENT ==================*/

		/*------------------- PRIVATE -------------------*/

		/*===============================================*/
		
		/*------------------- PUBLIC --------------------*/
		/**
		 * Creates a layer and returns it.  Layers are created at the bottom of the display list.
		 * @param	sName The name of the layer.
		 * @param	bAddToCamera Should we add this layer to the camera?
		 * @param	bHoldsdisplayObjects Should the layer contain display objects?  Turn this off if you are only using bitmap rendering.
		 * @param	bgArt Optional background art the layer has.
		 * @param	iPosX The x position of the layer.
		 * @param	iPosY The y position of the layer.
		 * @return
		 */
		public final function Create( sName:String, bAddToCamera:Boolean = true, bgArt:DisplayObject = null, iPosX:int = 0, iPosY:int = 0 ):Layer
		{
			if ( !dictLayers ) { return null; }
			if ( dictLayers[sName] ) { Verlocity.Trace( Verlocity.lang.T( "GenericDuplicate" ), "Layers" ); return null; }


			// Create a new layer
			var newLayer:Layer = new Layer( sName, iPosX, iPosY );
			newLayer.name = sName;

			// Register the layer
			dictLayers[sName] = newLayer;
			iCurrentLayerIndex++;

			// Add to the camera
			if ( bAddToCamera && Verlocity.IsValid( Verlocity.camera ) )
			{
				Verlocity.camera.Add( newLayer, true );
				return newLayer;
			}
			else // Add to main
			{
				layerMain.addChildAt( newLayer, 0 );
			}

			// Add the background art
			if ( bgArt ) { newLayer.addChild( bgArt ); }

			Verlocity.Trace( sName + Verlocity.lang.T( "GenericAddSuccess" ), "Layers" );
			return newLayer;
		}

		/**
		 * Returns a layer based on its name.
		 * @param	sName The name of the layer.
		 * @return
		 */
		public final function Get( sName:String ):Layer
		{
			if ( !dictLayers ) { return null; }

			return dictLayers[sName];
		}

		/**
		 * Returns if a layer is valid.
		 * @param	sName The name of the layer.
		 * @return
		 */
		public final function IsValidLayer( sName:String ):Boolean
		{
			if ( !dictLayers ) { return false; }

			if ( dictLayers[sName] == null )
			{
				Verlocity.Trace( sName + Verlocity.lang.T( "GenericMissing" ), "Layers" );
				return false;
			}
			
			return true;
		}
		
		/**
		 * Resets all layers to their original position and scale.
		 */
		public final function ResetAll():void
		{
			if ( !dictLayers ) { return; }

			// Loop through and reset them
			for ( var currentLayer:String in dictLayers )
			{
				if ( IsValidLayer( currentLayer ) )
				{
					Layer( dictLayers[currentLayer] ).Reset();
				}
			}
		}
		
		/**
		 * Sends a layer to the top of the display.
		 * @param	sName The name of the layer.
		 */
		public final function SendToTop( sName:String ):void
		{
			if ( !dictLayers ) { return; }

			if ( IsValidLayer( sName ) )
			{
				var layer:Layer = dictLayers[sName];

				// Update container display position
				layer.parent.addChild( layer );
			}
		}
		
		/**
		 * Sends a layer to the bottom of the display.
		 * @param	sName The name of the layer.
		 */
		public final function SendToBottom( sName:String ):void
		{
			if ( IsValidLayer( sName ) )
			{
				var layer:Layer = dictLayers[sName];

				// Update container display position
				layer.parent.addChildAt( layer, 0 );
			}
		}
		
		/**
		 * Removes a layer.
		 * @param	sName The name of the layer.
		 */
		public final function Remove( sName:String ):void
		{
			if ( !dictLayers ) { return; }

			if ( IsValidLayer( sName ) )
			{
				var layer:Layer = dictLayers[sName];
				layer._Dispose();

				// Delete memory
				dictLayers[sName] = null;
				delete dictLayers[sName];
				
				Verlocity.Trace( Verlocity.lang.T( "GenericRemove" ) + sName, "Layers" );
			}
		}
		
		/**
		 * Removes all layers.
		 */
		public final function RemoveAll():void
		{
			if ( !dictLayers ) { return; }

			// Loop through and remove them
			for ( var currentLayer:String in dictLayers )
			{
				Remove( currentLayer );
			}

			// Create a new dictionary
			dictLayers = new Dictionary();

			Verlocity.Trace( Verlocity.lang.T( "GenericRemoveAll" ), "Layers" );
		}
		
		/**
		 * Inserts a display object into a layer.
		 * @param	dispObj The display object to insert.
		 * @param	sName The name of the layer.
		 */
		public final function addChild( dispObj:DisplayObject, sName:String ):void
		{
			if ( IsValidLayer( sName ) )
			{
				Layer( dictLayers[sName] ).addChild( dispObj );
			}
		}
		
		/**
		 * Removes a display object from a layer
		 * @param	dispObj The display object to remove.
		 * @param	sName The name of the layer.
		 */
		public final function removeChild( dispObj:DisplayObject, sName:String ):void
		{
			if ( IsValidLayer( sName ) )
			{
				Layer( dictLayers[sName] ).removeChild( dispObj );				
			}			
		}
		
		/**
		 * Sets the background color.
		 * @param	uiColor The color to set to.
		 * @param	nAlpha The alpha to set to (note: this will blend with the default Flash background)
		 */
		public final function BGColor( uiColor:uint, nAlpha:Number = 1 ):void
		{
			sprBackground.graphics.clear();
			
			sprBackground.graphics.beginFill( uiColor, nAlpha );
				GraphicsUtil.DrawScreenRect( sprBackground.graphics );
			sprBackground.graphics.endFill();
		}
		
		/**
		 * Preforms a parallaxing effect between a select layers.
		 * @param	aLayers The array of names of layers (requires two or more).
		 * @param	nScrollX The X scroll direction.
		 * @param	nScrollY The Y scroll direction.
		 * @param	nScrollZ The Z scroll direction (warning: really small numbers will lead to visable issues).
		 */
		public final function Parallax( aLayers:Array, nScrollX:Number = 0.0, nScrollY:Number = 0.0, nScrollZ:Number = 0.0 ):void
		{
			if ( !dictLayers ) { return; }

			// Do we have more than one layer?
			if ( aLayers.length < 2 ) { return; }

			// Check if the first exists
			if ( IsValidLayer( aLayers[0] ) )
			{
				// Offset the first
				dictLayers[ aLayers[0] ].x -= nScrollX;
				dictLayers[ aLayers[0] ].y -= nScrollY;
				
				// Make z scroll a bit more unstandable
				nScrollZ /= 1000;
				
				// Get the correct current center position
				var pCenterScr:Point = Verlocity.ScrCenter;

				// Get the localized version of the position
				var pCenter:Point = dictLayers[ aLayers[0] ].globalToLocal( pCenterScr );
				
				// Scale the layer
				ScaleLayer( aLayers[0], nScrollZ, pCenter );

				// The rest of the layers
				for ( var i:int = 1; i < aLayers.length; i++ )
				{
					// Check if the layer is valid
					if ( IsValidLayer( aLayers[i] ) )
					{
						// Offset the layer
						dictLayers[ aLayers[i] ].x -= nScrollX / ( i + 1 );
						dictLayers[ aLayers[i] ].y -= nScrollY / ( i + 1 );

						// Get the localized version of the position
						pCenter = dictLayers[ aLayers[i] ].globalToLocal( pCenterScr );
						
						// Scale the layer
						ScaleLayer( aLayers[i], nScrollZ / ( i + 1 ), pCenter );
					}
				}
			}
		}
		
		/**
		 * Scales a layer and its contents from a center position.
		 * @param	sName The name of the layer.
		 * @param	nAddScale The additive scale to set.
		 * @param	pCenter The center point.
		 */
		public final function ScaleLayer( sName:String, nAddScale:Number, pCenter:Point ):void
		{
			if ( !dictLayers ) { return; }

			if ( nAddScale == 0 ) { return; }

			if ( IsValidLayer( sName ) )
			{
				DisplayUtil.ScaleAround( dictLayers[sName], pCenter.x, pCenter.y,
										 dictLayers[sName].scaleX + nAddScale,
										 dictLayers[sName].scaleY + nAddScale );
			}
		}
		
		/**
		 * Scrolls a layer infinitly.
		 * @param	sName The name of the layer.
		 * @param	nScrollX How far to scroll horizontally.
		 * @param	iScrollWidth The width of the scroll space (where to loop the layer).
		 * @param	nScrollY How far to scroll vertically.
		 * @param	iScrollHeight The height of the scroll space (where to loop the layer).
		 */
		public final function Scroll( sName:String, nScrollX:Number = 0, iScrollWidth:int = 0, nScrollY:Number = 0, iScrollHeight:int = 0 ):void
		{
			if ( !dictLayers ) { return; }
		
			if ( IsValidLayer( sName ) )
			{
				// Scroll horizontally
				dictLayers[sName].x -= nScrollX;
				if ( iScrollWidth > 0 && dictLayers[sName].x <= -iScrollWidth )
				{
					dictLayers[sName].x = 0;
				}

				// Scroll vertically
				dictLayers[sName].y -= nScrollY;
				if ( iScrollHeight > 0 && dictLayers[sName].y <= -iScrollHeight )
				{
					dictLayers[sName].y = 0;
				}
			}
		}
	}
}