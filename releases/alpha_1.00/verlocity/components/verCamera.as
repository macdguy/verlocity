/*
 * ---------------------------------------------------------------
 * Verlocity
 * http://www.verlocityengine.com
 * 
 * This file is subject to the terms and conditions defined in
 * 'license.txt', which is part of this source code package.
 * ---------------------------------------------------------------
 * Component: verCamera
 * Author: Macklin Guy
 * ---------------------------------------------------------------
*/
package verlocity.components
{
	import flash.display.Stage;	
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import verlocity.ents.DynamicEntity;
	import verlocity.utils.DisplayUtil;
	import verlocity.utils.GraphicsUtil;

	import flash.geom.Rectangle;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import fl.motion.Color;
	import fl.motion.AdjustColor;
	import flash.geom.ColorTransform;
	import flash.filters.ColorMatrixFilter;

	import verlocity.Verlocity;
	import verlocity.core.Component;
	import verlocity.utils.AngleUtil;
	import verlocity.utils.ColorUtil;
	import verlocity.utils.MathUtil;

	/**
	 * A simple 2D DisplayObject-based camera.
	 * Contains following, zoom, shake, tintint, and masking.
	 * Useful for scrolling games and cutscenes.
	 * By default, newly created layers (see verLayers) are placed
	 * into the camera.
	 */
	public final class verCamera extends Component
	{
		private var sprCamera:Sprite;
		private var sCameraViewArea:Shape;
		private var pCenter:Point;
		private var nZoom:Number;
		
		private var ctColor:ColorTransform;
		private var cTint:Color;
		private var aColor:AdjustColor;
		private var cmFilter:ColorMatrixFilter;

		private var pGoto:Point;

		private var entFollow:DynamicEntity;
		private var entOffsetX:int;
		private var entOffsetY:int;

		private var bEasing:Boolean;
		private var iEasingSpeed:int;
		private var bIsEasingX:Boolean;
		private var bIsEasingY:Boolean;
		
		private var iShakeDuration:int;
		private var nShakeForce:Number;
		private var pBeforeShake:Point;

		/**
		 * Constructor of the component.
		 * @param	sStage
		 */
		public function verCamera( sStage:Stage ):void
		{
			// Setup component
			super( sStage, true );
			
			// Component-specific construction
			sprCamera = new Sprite();
			
			sCameraViewArea = new Shape();
			sCameraViewArea.graphics.beginFill( 0, 0 );
				GraphicsUtil.DrawScreenRect( sCameraViewArea.graphics );
			sCameraViewArea.graphics.endFill();

			sprCamera.mask = sCameraViewArea;
			
			pCenter = new Point( sCameraViewArea.width / 2, sCameraViewArea.height / 2 );

			bEasing = true;
			iEasingSpeed = 30;
			
			nZoom = 1;
		}

		/**
		 * Concommands of the component.
		 */
		protected override function _Concommands():void 
		{
			Verlocity.console.Register( "camera_reset", function():void
			{
				Reset();
			}, "Resets the camera." );
		}
		
		/**
		 * Updates the camera
		 */
		protected override function _Update():void
		{
			if ( pGoto )
			{
				GotoThink();
			}
			
			if ( entFollow && !pGoto )
			{
				FollowThink()
			}

			if ( pBeforeShake )
			{
				ShakeThink();
			}
		}

		/**
		 * Destructor of the component.
		 */
		public override function _Destruct():void
		{	
			// Component-specific destruction
			RemoveAll();
			Reset();

			DisplayUtil.RemoveFromParent( sprCamera );
			sprCamera = null;

			DisplayUtil.RemoveFromParent( sCameraViewArea );
			sCameraViewArea = null;

			pCenter = null;
			nZoom = NaN;
		
			ctColor = null;
			cTint = null;
			aColor = null;
			cmFilter = null;

			pGoto = null;

			entFollow = null;
			entOffsetX = entOffsetY = NaN;

			bEasing = false;
			iEasingSpeed = NaN;
			bIsEasingX = bIsEasingY = false;
		
			iShakeDuration = nShakeForce = NaN;
			pBeforeShake = null;
			
			// Destroy component
			super._Destruct();
		}

		/*================== COMPONENT ==================*/

		/*------------------- PRIVATE -------------------*/
		/**
		 * Returns the camera sprite
		 * @return
		 */
		internal final function _Get():Sprite { return sprCamera; }
		
		/**
		 * Returns the camera view area
		 * @return
		 */
		internal final function _GetView():Shape { return sCameraViewArea; }

		/**
		 * Handles moving towards a point
		 */
		private final function GotoThink():void
		{
			if ( sprCamera.x != pCenter.x - pGoto.x || sprCamera.y != pCenter.y - pGoto.y )
			{
				if ( bEasing )
				{
					var newX:int = pCenter.x - pGoto.x;
					var newY:int = pCenter.y - pGoto.y;
						
					if ( Math.abs( sprCamera.x - newX ) > 1 )
					{
						sprCamera.x -= MathUtil.Ease( sprCamera.x, newX, iEasingSpeed );
						bIsEasingX = true;
					} else { bIsEasingX = false; }
						
					if ( Math.abs( sprCamera.y - newY ) > 1 )
					{
						sprCamera.y -= MathUtil.Ease( sprCamera.y, newY, iEasingSpeed );
						bIsEasingY = true;
					} else { bIsEasingY = false; }
					
					return;
				}
				
				sprCamera.x = MathUtil.Approach( sprCamera.x, pCenter.x - pGoto.x, 2 );
				sprCamera.y = MathUtil.Approach( sprCamera.y, pCenter.y - pGoto.y, 2 );
				
				return;
			}

			if ( pGoto ) { pGoto = null; }
		}
		
		/**
		 * Handles following
		 */
		private final function FollowThink():void
		{
			if ( bEasing )
			{
				var newFX:int = pCenter.x - ( entFollow.x + ( entOffsetX / nZoom ) ) * nZoom;
				var newFY:int = pCenter.y - ( entFollow.y + ( entOffsetY / nZoom ) ) * nZoom;
				
				if ( Math.abs( sprCamera.x - newFX ) > 1 )
				{
					sprCamera.x -= MathUtil.Ease( sprCamera.x, newFX, iEasingSpeed );
					bIsEasingX = true;
				} else { bIsEasingX = false; }
					
				if ( Math.abs( sprCamera.y - newFY ) > 1 )
				{
					sprCamera.y -= MathUtil.Ease( sprCamera.y, newFY, iEasingSpeed );
					bIsEasingY = true;
				} else { bIsEasingY = false; }
				
				return;
			}

			SetCenterPos( ( entFollow.x + ( entOffsetX / nZoom ) ) * nZoom, ( entFollow.y + ( entOffsetY / nZoom ) ) * nZoom );
		}

		/**
		 * Handles shaking
		 */
		private final function ShakeThink():void
		{
			if ( iShakeDuration > Verlocity.CurTime() )
			{
				if ( Math.random() > .5 )
				{
					if ( Math.random() > .5 ) {	sprCamera.x -= Math.sin( Verlocity.CurTime() / 100 ) * nShakeForce;
					} else { sprCamera.y -= Math.sin( Verlocity..CurTime() / 100 ) * nShakeForce;	}
				}
				else
				{
					if ( Math.random() > .5 ) { sprCamera.x += Math.sin( Verlocity.CurTime() / 100 ) * nShakeForce;
					} else { sprCamera.y += Math.sin( Verlocity.CurTime() / 100 ) * nShakeForce; }
				}
				
				return;
			}

			// Move to position before shake
			if ( sprCamera.x != pBeforeShake.x || sprCamera.y != pBeforeShake.y )
			{
				sprCamera.x -= MathUtil.Ease( sprCamera.x, pBeforeShake.x, 30 );
				sprCamera.y -= MathUtil.Ease( sprCamera.y, pBeforeShake.y, 30 );
				return;
			}

			if ( pBeforeShake ) { pBeforeShake = null; }
		}

		/*===============================================*/
		
		/*------------------- PUBLIC --------------------*/
		/**
		 * Adds a display object to the camera.
		 * @param	disp The display object
		 * @param	bAddToBottom Add to the bottom?
		 */
		public final function Add( disp:DisplayObject, bAddToBottom:Boolean = false ):void
		{
			if ( !disp ) { return; }

			if ( bAddToBottom ) 
			{
				sprCamera.addChildAt( disp, 0 );
			}
			else
			{
				sprCamera.addChild( disp );				
			}
		}
		
		/**
		 * Sets the layer the camera is in.
		 * @param	sLayer
		 */
		public final function SetLayer( sLayer:String ):void
		{
			Verlocity.layers.addChild( sprCamera, sLayer );
			Verlocity.layers.addChild( sCameraViewArea, sLayer );
		}
		
		/**
		 * Removes all display objects in the camera.
		 */
		public final function RemoveAll():void
		{
			DisplayUtil.RemoveAllChildren( sprCamera );
		}
		
		/**
		 * Resets all the properties of the camera.
		 */		
		public final function Reset():void
		{
			ResetMask();
			ResetColor();
			RemoveTint();
			RemoveFilters();
			
			StopFollowing();
			StopMoveTo();
			StopShaking();

			SetZoom( 1 );
			Rotate( 0 );
			ResetPos();
		}

		/**
		 * Returns the width of the camera.
		 */
		public final function get width():int { return sprCamera.width; }
		
		/**
		 * Returns the height of the camera.
		 */
		public final function get height():int { return sprCamera.height; }
		
		/**
		 * Returns the X position of the camera.
		 */
		public final function get x():int { return sprCamera.x; }
		
		/**
		 * Returns the Y position of the camera.
		 */
		public final function get y():int { return sprCamera.y; }
		
		/**
		 * Sets the X position of the camera.
		 */
		public final function set x( iPosX:int ):void { sprCamera.x = iPosX; }
		
		/**
		 * Sets the Y position of the camera.
		 */
		public final function set y( iPosY:int ):void { sprCamera.y = iPosY; }
		
		/**
		 * Returns the zoom of the camera.
		 */
		public final function get zoom():Number { return nZoom; }
		
		/**
		 * Sets the zoom of the camera.
		 */
		public final function set zoom( nSetZoom:Number ):void { nZoom = nSetZoom; sprCamera.scaleX = sprCamera.scaleY = nZoom; }

		/**
		 * Returns the brightness of the camera.
		 */
		public final function get brightness():Number { return _nBrightness; }

		/**
		 * Sets the brightness of the camera.
		 */
		public final function set brightness( nBrightness:Number ):void { AdjustColors( nBrightness ); }

		/**
		 * Returns the contrast of the camera.
		 */
		public final function get contrast():Number { return _nContrast; }

		/**
		 * Sets the contrast of the camera.
		 */
		public final function set contrast( nContrast:Number ):void { AdjustColors( NaN, nContrast ); }

		/**
		 * Returns the hue of the camera.
		 */
		public final function get hue():Number { return _nHue; }

		/**
		 * Sets the hue of the camera.
		 */
		public final function set hue( nHue:Number ):void { AdjustColors( NaN, NaN, nHue ); }
		
		/**
		 * Returns the saturation of the camera.
		 */
		public final function get saturation():Number { return _nSaturation; }

		/**
		 * Sets the saturation of the camera.
		 */
		public final function set saturation( nSaturation:Number ):void { AdjustColors( NaN, NaN, NaN, nSaturation ); }

		/**
		 * Returns if the camera is easing on the X axis.
		 */
		public final function get IsEasingX():Boolean { return bIsEasingX; }
		
		/**
		 * Returns if the camera is easing on the Y axis.
		 */
		public final function get IsEasingY():Boolean { return bIsEasingY; }
		
		/**
		 * Returns if the camera is easing.
		 */
		public final function get IsEasing():Boolean { return bIsEasingX || bIsEasingY; }

		/**
		 * Centers the camera on a position.
		 * @param	iPosX The X position
		 * @param	iPosY The Y position
		 */
		public final function SetCenterPos( nPosX:Number, nPosY:Number ):void
		{
			sprCamera.x = pCenter.x - nPosX;
			sprCamera.y = pCenter.y - nPosY;
		}

		/**
		 * Resets the camera's position to its default (0,0).
		 */
		public final function ResetPos():void
		{
			sprCamera.x = 0; sprCamera.y = 0;
		}
		
		/**
		 * Sets the camera to follows an entity.
		 * @param	ent The dynamic entity to follow
		 * @param	iOffsetX Offset the camera
		 * @param	iOffsetY Offset the camera
		 * @param	bEase Should the camera ease?
		 * @param	iEaseSpeed The speed the easing is preformed at
		 */
		public final function Follow( ent:DynamicEntity, iOffsetX:int = 0, iOffsetY:int = 0, bEase:Boolean = true, iEaseSpeed:int = 30 ):void
		{
			entFollow = ent;
			entOffsetX = iOffsetX;
			entOffsetY = iOffsetY;
			
			bEasing = bEase;
			iEasingSpeed = iEaseSpeed;
			
			if ( bEasing )
			{
				SetCenterPos( ( entFollow.x + ( entOffsetX / nZoom ) ) * nZoom, ( entFollow.y + ( entOffsetY / nZoom ) ) * nZoom );
			}
		}
		
		/**
		 * Stops the camera from following an entity
		 */
		public final function StopFollowing():void
		{
			entFollow = null;
		}
		
		/**
		 * Moves the camera to a specific point
		 * @param	pPoint The point to move towards
		 * @param	bEase Should the camera ease?
		 * @param	iEaseSpeed The speed at which the camera eases at
		 */
		public final function MoveTo( pPoint:Point, bEase:Boolean = true, iEaseSpeed:int = 30 ):void
		{
			pGoto = pPoint;
			bEasing = bEase;
			iEasingSpeed = iEaseSpeed;
		}
		
		/**
		 * Stops moving the camera to a specific point (if MoveTo was called)
		 */
		public final function StopMoveTo():void
		{
			pGoto = null;
		}
		
		/**
		 * Rotates the camera around its center
		 * @param	iRot Degree to rotate
		 */
		public final function Rotate( iRot:int ):void
		{
			var m:Matrix = sprCamera.transform.matrix;
				m.tx -= pCenter.x;
				m.ty -= pCenter.y;
				m.rotate( AngleUtil.DegreeToRad( iRot ) );
				m.tx += pCenter.x;
				m.ty += pCenter.y;
			sprCamera.transform.matrix = m;
		}
		
		/**
		 * Zooms the camera
		 * @param	nSetZoom Amount to zoom
		 */
		public final function SetZoom( nSetZoom:Number ):void
		{
			nZoom = nSetZoom;
			sprCamera.scaleX = sprCamera.scaleY = nZoom;
		}
		
		/**
		 * Shakes the camera
		 * @param	iDuration Duration of the shake
		 * @param	nForce The force of the shake
		 */
		public final function Shake( iDuration:int, nForce:Number ):void
		{
			pBeforeShake = new Point( sprCamera.x, sprCamera.y );
			
			nShakeForce = nForce;
			iShakeDuration = Verlocity.CurTime() + iDuration;
		}
		
		/**
		 * Stop shaking the camera
		 */
		public final function StopShaking():void
		{
			iShakeDuration = -1;
		}
		
		/**
		 * Adjusts the camera's colors
		 * @param	nBrightness Adjust the brightness
		 * @param	nContrast Adjust the contrast
		 * @param	nHue Adjust the hue (color)
		 * @param	nSaturation Adjust the saturation
		 */
		private var _nBrightness:Number;
		private var _nContrast:Number;
		private var _nHue:Number;
		private var _nSaturation:Number;

		public final function AdjustColors( nBrightness:Number = NaN, nContrast:Number = NaN, nHue:Number = NaN, nSaturation:Number = NaN ):void
		{
			if ( !aColor ) { aColor = new AdjustColor(); }
			if ( !cmFilter ) { cmFilter = new ColorMatrixFilter() }
			
			if ( !isNaN( nBrightness ) ) { aColor.brightness = nBrightness; _nBrightness = nBrightness; }
			if ( !isNaN( nContrast ) ) { aColor.contrast = nContrast; _nContrast = nContrast; }
			if ( !isNaN( nHue ) ) { aColor.hue = nHue; _nHue = nHue; }
			if ( !isNaN( nSaturation ) ) { aColor.saturation = nSaturation; _nSaturation = nSaturation; }
			
			cmFilter.matrix = aColor.CalculateFinalFlatArray();

			sprCamera.filters = [ cmFilter ];
		}
		
		/**
		 * Removes all filters on the camera
		 */
		public final function RemoveFilters():void
		{
			aColor = null;
			cmFilter = null;
			sprCamera.filters = null;
		}

		/**
		 * Sets the camera to a specific color
		 * @param	r Red
		 * @param	g Green
		 * @param	b Blue
		 * @param	alpha Alpha
		 */
		public final function SetColor( r:int, g:int, b:int, alpha:Number = 1 ):void
		{
			if ( !ctColor ) { ctColor = new ColorTransform(); }

			var newColor:uint = ColorUtil.RGBtoHEX( r, g, b );

			ctColor.color = newColor;
			ctColor.alphaMultiplier = alpha;
			sprCamera.transform.colorTransform = ctColor;
		}
		
		/**
		 * Resets the camera's color to its default
		 */
		public final function ResetColor():void
		{
			ctColor = null;
			sprCamera.transform.colorTransform = new ColorTransform();
		}
		
		/**
		 * Sets the tint of the camera
		 * @param	amount Amount of tinting
		 * @param	r Red
		 * @param	g Green
		 * @param	b Blue
		 */
		public final function SetTint( amount:Number, r:int = 255, g:int = 255, b:int = 255 ):void
		{
			if ( !cTint ) { cTint = new Color(); }

			var newColor:uint = ColorUtil.RGBtoHEX( r, g, b );
			
			cTint.setTint( newColor, amount );
			sprCamera.transform.colorTransform = cTint;	
		}

		/**
		 * Removes the tint of the camera
		 */
		public final function RemoveTint():void
		{
			if ( cTint )
			{
				cTint.alphaMultiplier = 0;
				cTint = null;
				sprCamera.transform.colorTransform = new ColorTransform();
			}
		}
		
		/**
		 * Sets the viewable mask of the camera
		 * @param	mask The mask
		 */
		public final function SetMask( mask:DisplayObject ):void
		{
			sprCamera.mask = mask;
		}

		/**
		 * Sets the position of the mask
		 * @param	iPosX
		 * @param	iPosY
		 */
		public final function SetMaskPos( iPosX:int, iPosY:int ):void
		{
			sprCamera.mask.x = iPosX; sprCamera.mask.y = iPosY;
		}

		/**
		 * Resets the masking to its default (ie. removes custom mask)
		 */
		public final function ResetMask():void
		{
			sprCamera.mask = sCameraViewArea;

			sCameraViewArea.x = 0; sCameraViewArea.y = 0;
		}
	}
}