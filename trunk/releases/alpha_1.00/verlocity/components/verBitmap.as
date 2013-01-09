/*
 * ---------------------------------------------------------------
 * Verlocity
 * http://www.verlocityengine.com
 * 
 * This file is subject to the terms and conditions defined in
 * 'license.txt', which is part of this source code package.
 * ---------------------------------------------------------------
 * Component: verBitmap
 * Author: Macklin Guy
 * ---------------------------------------------------------------
*/
package verlocity.components
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import verlocity.utils.ObjectUtil;
	
	import flash.filters.BlurFilter;
	import flash.geom.ColorTransform;

	import verlocity.Verlocity;
	import verlocity.core.Component;
	import verlocity.display.BitmapClip;
	import verlocity.events.EventBitmapClip;

	/**
	 * Handles registration of bitmap assets.
	 * Imports movieclips, sprites, and sprite sheets.
	 */
	// TODO: Tile sheet support
	// TODO: Multiple defined animation label support
	public final class verBitmap extends Component
	{
		private var dictLoadingClips:Dictionary; // loading art clips
		private var dictClips:Dictionary; // registered art clips

		private var bitmap:Bitmap;
		private var bitmapData:BitmapData;
		internal var bitmapRect:Rectangle;

		private var ctColor:ColorTransform;
		private var fBlur:BlurFilter;
		private var pOrigin:Point;

		private var iCurrentEffect:int;
		
		public const EFF_DEFAULT:int = 0;
		public const EFF_LASTING:int = 1;
		public const EFF_EVERLASTING:int = 2;

		/**
		 * Constructor of the component.
		 * @param	sStage
		 */
		public function verBitmap():void
		{
			// Setup component
			// This component is unqiue as it's called manually by verEngine
			super( null, false );
			
			// Component-specific construction
			dictLoadingClips = new Dictionary( true );
			dictClips = new Dictionary( true );
			
			bitmapData = new BitmapData( Verlocity.ScrW, Verlocity.ScrH, false, Verlocity.settings.BGCOLOR );
			bitmap = new Bitmap( bitmapData );
			bitmapRect = bitmapData.rect;
			
			Verlocity.layers.layerBitmap.addChild( bitmap );
		}

		/**
		 * Concommands of the component.
		 */
		protected override function _Concommands():void 
		{
		}
		
		/**
		 * Renders all bitmap entities and particles.
		 */
		internal final function _Render():void
		{
			StartRenderBitmap();

			// Render particles
			Verlocity.particles._RenderParticles();
			Verlocity.particles._RenderEmitters();
			
			EndRenderBitmap();
		}

		/**
		 * Destructor of the component.
		 */
		public override function _Destruct():void
		{	
			// Component-specific destruction
			RemoveAllAssets();
			dictLoadingClips = null;
			dictClips = null;			
			
			// Destroy component
			super._Destruct();
		}

		/*================== COMPONENT ==================*/

		/*------------------- PRIVATE -------------------*/
		/**
		 * Handles when a clip is loaded.
		 * @param	e
		 */
		private final function ClipLoaded( e:EventBitmapClip ):void
		{
			var className:Class = e.bitmapclip.sourceClass;

			Verlocity.Trace( "Registered new clip. " + className, "Bitmap" );

			// Remove from loading cue
			dictLoadingClips[className] = false;
			delete dictLoadingClips[className];

			// Add to register
			dictClips[className] = e.bitmapclip;
		}
		
		/**
		 * Returns a loaded bitmap clip
		 * @param	className The class name of the bitmap clip's display object
		 * @return
		 */
		private final function GetLoadedClip( className:Class ):BitmapClip
		{
			return dictClips[className];
		}

		/*===============================================*/
		
		/*------------------- PUBLIC --------------------*/
		/**
		 * Preloads an asset for bitmap usage.
		 * @param	className The display object's class (must be MovieClip or Sprite)
		 */
		public final function PreloadAsset( className:Class, bAnimated:Boolean = false, iRotationAmount:int = 0 ):void
		{
			if ( dictClips[className] || dictLoadingClips[className] ) { return; }

			Verlocity.Trace( "Registering new clip... " + className, "Bitmap" );

			// Load
			dictLoadingClips[className] = true;

			// Create new bitmap clip
			var bc:BitmapClip = new BitmapClip( null, iRotationAmount );
			bc.sourceClass = className;
			bc.addEventListener( EventBitmapClip.COMPLETE, ClipLoaded );
			
			// Create disp
			var disp:DisplayObject = new className();

			// Gather from movieclip or sprite
			if ( bAnimated )
			{
				bc.importMovieClip( MovieClip( disp ) );
			}
			else
			{
				bc.importSprite( Sprite( disp ) );				
			}
			
			disp = null;
		}

		/**
		 * Returns a bitmap clip that's been preloaded.
		 * @param	className The display object class name
		 * @param	bCreateIfNotFound Should we try to preload it if it hasn't been?
		 * @return
		 */
		public final function GetAsset( className:Class, bCreateIfNotFound:Boolean = true ):BitmapClip
		{
			var bc:BitmapClip = GetLoadedClip( className );

			// Preload it now...
			if ( !bc && bCreateIfNotFound )
			{
				PreloadAsset( className );
				bc = GetLoadedClip( className );
			}
			
			return bc;
		}
		
		/**
		 * Removes an asset from the memory.
		 * @param	className The display asset
		 */
		public final function RemoveAsset( className:Object ):void
		{
			if ( dictLoadingClips[className] )
			{
				BitmapClip( dictLoadingClips[className] ).dispose();
				delete dictLoadingClips[className];
			}
			
			if ( dictClips[className] )
			{
				BitmapClip( dictClips[className] ).dispose();
				delete dictClips[className];
			}
		}
		
		/**
		 * Removes all assets stored in memory.
		 */
		public final function RemoveAllAssets():void
		{
			var className:Object;

			for ( className in dictLoadingClips )
			{
				RemoveAsset( className );
			}

			for ( className in dictClips )
			{
				RemoveAsset( className );
			}
		}
		
		/*public function PreloadSpriteSheet( sName:String, source:BitmapData, iFPS:int = 24, 
											iTileWidth:int = 16, iTileHeight:int = 16 ):void
		{
			if ( bitmapClips[sName] != null ) { return; }

			trace( "Registering new clip... " + sName );
			
			iLoading++;

			// Create new bitmap clip
			var bc:BitmapClip = new BitmapClip();
			bc.addEventListener( EventBitmapClip.COMPLETE, RegisterClipLoaded );
			bc.name = sName;
			bc.frameRate = iFPS;

			// Create tilesheet
			var tiles:Bitmap = new Bitmap( source );
			bc.importTileSheet( tiles.bitmapData, iTileWidth, iTileHeight );
		}*/

		/**
		 * Copies pixel data into the bitmap canvas.
		 * @param	bmd Bitmap data to copy
		 * @param	rect Rectangle of the bitmap to copy
		 * @param	x X position of the copy
		 * @param	y Y position of the copy
		 */
		private var pCopyPoint:Point = new Point();
		public function CopyIntoBitmap( bmd:BitmapData, rect:Rectangle, x:int, y:int ):void
		{
			if ( !bitmap || !bitmapData ) { return; }
			
			if ( !pCopyPoint )
			{
				pCopyPoint = new Point( x, y )
			}
			else
			{
				pCopyPoint.x = x; 
				pCopyPoint.y = y;
			}

			bitmapData.copyPixels( bmd, rect, pCopyPoint, null, null, true );
		}
		
		/**
		 * Draws a pixel into the bitmap canvas.
		 * @param	x The position of the pixel
		 * @param	y The position of the pixel
		 * @param	uiColor The color of the pixel
		 * @param	iSize Add more pixels to increase the size
		 */
		public function SetPixel( x:int, y:int, uiColor:uint, iSize:int = 3 ):void
		{
			bitmapData.setPixel32( x, y, uiColor );

			// This could be a bit better...
			for ( var i:int; i < iSize; i++ )
			{
				bitmapData.setPixel32( x - i, y - i, uiColor );
				bitmapData.setPixel32( x + i, y + i, uiColor );
				bitmapData.setPixel32( x + i, y, uiColor );
				bitmapData.setPixel32( x, y + i, uiColor );
				bitmapData.setPixel32( x - i, y, uiColor );
				bitmapData.setPixel32( x, y - i, uiColor );
			}
		}

		/**
		 * Clears all of the bitmap's canvas.
		 * This should occur before each draw.
		 */
		public function StartRenderBitmap():void
		{
			if ( !bitmap || !bitmapData ) { return; }

			bitmapData.lock();

			// Apply pre-effects
			if ( Verlocity.settings.BITMAP_EFFECTS && 
				!Verlocity.display.IsQualityLow() )
			{
				PreEffects();
				return;
			}

			bitmapData.fillRect( bitmapRect, Verlocity.settings.BGCOLOR );
		}
		
		/**
		 * Finishes all drawing to the bitmap canvas.
		 * This should occur after each draw.
		 */
		public function EndRenderBitmap():void
		{
			if ( !bitmap || !bitmapData ) { return; }

			// Apply post-effects
			if ( Verlocity.settings.BITMAP_EFFECTS && 
				 !( Verlocity.display.IsQualityMedium() || Verlocity.display.IsQualityLow() ) )
			{
				PostEffects();
			}

			bitmapData.unlock();			
		}
		
		/**
		 * Clears the bitmap canvas.
		 */
		public function ClearCanvas():void
		{
			bitmapData.fillRect( bitmapRect, Verlocity.settings.BGCOLOR );
		}
		

		/**
		 * Creates the effects to be applied to the bitmap.
		 */
		private function CreateEffects():void
		{
			pOrigin = new Point( 0,0 );
			fBlur = new BlurFilter( 3, 3, 0 );

			ctColor = new ColorTransform();

			SetEffectPreset( EFF_DEFAULT );
		}

		/**
		 * Applies the pre-effects on the particle bitmap.
		 */
		private function PreEffects():void
		{
			if ( ctColor )
			{
				bitmapData.colorTransform( bitmapRect, ctColor );
			}
		}
		
		/**
		 * Applies the post-effects on the particle bitmap.
		 */
		private function PostEffects():void
		{
			if ( fBlur )
			{
				bitmapData.applyFilter( bitmapData, bitmapRect, pOrigin, fBlur );
			}			
		}
		
		/**
		 * Sets the particle draw effects.
		 * @param	nRedrawSpeed The speed to redraw the particles (0 fast - 1 long).
		 * @param	iBlurX Direction of the blur
		 * @param	iBlurY Direction of the blur
		 */
		public function SetEffects( nRedrawSpeed:Number = .99, iBlurX:int = 3, iBlurY:int = 3 ):void
		{
			ctColor.alphaMultiplier = nRedrawSpeed;
			fBlur.blurX = iBlurX;
			fBlur.blurY = iBlurY;
		}
		
		/**
		 * Sets the effect to a preset.  Use EFF_ constants.
		 * @param	iPreset
		 */
		public function SetEffectPreset( iPreset:int = 0 ):void
		{
			switch( iPreset )
			{
				case EFF_DEFAULT:
					SetEffects( 0 );
				break;

				case EFF_LASTING:
					SetEffects( .65 );
				break;

				case EFF_EVERLASTING:
					SetEffects( .99 );
				break;
			}
		}

		/**
		 * Removes the effects applied to the particles completely
		 */
		public function RemoveEffects():void
		{
			ctColor = null;
			fBlur = null;
			pOrigin = null;
		}
	}
}