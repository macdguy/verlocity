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
	verCamera.as
	-----------------------------------------
	This class handles the camera in Verlocity.
*/

package VerlocityEngine.components
{
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import VerlocityEngine.base.ents.verBEnt;

	import flash.geom.Rectangle;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import fl.motion.Color;
	import fl.motion.AdjustColor;
	import flash.geom.ColorTransform;
	import flash.filters.ColorMatrixFilter;

	import VerlocityEngine.Verlocity;
	import VerlocityEngine.VerlocityLanguage;
	import VerlocityEngine.util.angleHelper;
	import VerlocityEngine.util.colorHelper;
	import VerlocityEngine.util.mathHelper;

	public final class verCamera extends Object
	{
		//********* VERLOCITY COMPONENT HEADER *********//
		/************************************************/
		public function IsValid():Boolean { return wasCreated; }
		private var wasCreated:Boolean;
		
		public function verCamera():void
		{
			if ( wasCreated ) { throw new Error( VerlocityLanguage.T( "ComponentLoadFail" ) ); return; } wasCreated = true;
			Construct();
		}
		/************************************************/
		/************************************************/
		
		/*
		 ****************COMPONENT VARS******************
		*/
		private var sprCamera:Sprite;
		private var sCameraViewArea:Shape;
		private var pCenter:Point;
		private var nZoom:Number;
		
		private var ctColor:ColorTransform;
		private var cTint:Color;
		private var aColor:AdjustColor;
		private var cmFilter:ColorMatrixFilter;

		private var pGoto:Point;

		private var entFollow:verBEnt;
		private var entOffsetX:int;
		private var entOffsetY:int;

		private var bEasing:Boolean;
		private var iEasingSpeed:int;
		
		private var iShakeDuration:int;
		private var nShakeForce:Number;
		private var pBeforeShake:Point;
		
		
		/*
		 **************COMPONENT CREATION****************
		*/
		private function Construct():void
		{
			sprCamera = new Sprite();
			
			sCameraViewArea = new Shape();
			sCameraViewArea.graphics.beginFill( 0, 0 );
				sCameraViewArea.graphics.drawRect( 0, 0, Verlocity.ScrW, Verlocity.ScrH );
			sCameraViewArea.graphics.endFill();

			sprCamera.mask = sCameraViewArea;
			
			pCenter = new Point( sCameraViewArea.width / 2, sCameraViewArea.height / 2 );

			bEasing = true;
			iEasingSpeed = 30;
			
			nZoom = 1;
		}


		/*
		 ****************COMPONENT LOOP******************
		*/
		public function Think():void
		{
			if ( pGoto )
			{
				if ( sprCamera.x != pCenter.x - pGoto.x || sprCamera.y != pCenter.y - pGoto.y )
				{
					if ( bEasing )
					{
						sprCamera.x -= mathHelper.Ease( sprCamera.x, pCenter.x - pGoto.x, iEasingSpeed );
						sprCamera.y -= mathHelper.Ease( sprCamera.y, pCenter.y - pGoto.y, iEasingSpeed );
					}
					else
					{
						sprCamera.x = mathHelper.Approach( sprCamera.x, pCenter.x - pGoto.x, 2 );
						sprCamera.y = mathHelper.Approach( sprCamera.y, pCenter.y - pGoto.y, 2 );
					}
				}
				else
				{
					pGoto = null;
				}
			}
			
			if ( entFollow && !pGoto )
			{
				if ( bEasing )
				{
					sprCamera.x -= mathHelper.Ease( sprCamera.x, pCenter.x - ( entFollow.x + ( entOffsetX / nZoom ) ) * nZoom, iEasingSpeed );
					sprCamera.y -= mathHelper.Ease( sprCamera.y, pCenter.y - ( entFollow.y + ( entOffsetY / nZoom ) ) * nZoom, iEasingSpeed );
				}
				else
				{
					SetCenterPos( ( entFollow.x + ( entOffsetX / nZoom ) ) * nZoom, ( entFollow.y + ( entOffsetY / nZoom ) ) * nZoom );
				}
			}

			if ( pBeforeShake )
			{
				HandleShake();
			}
		}
		
		
		/*
		 *************COMPONENT FUNCTIONS***************
		*/
		
		/*------------------ PRIVATE ------------------*/
		internal function Get():Sprite { return sprCamera; }
		internal function GetView():Shape { return sCameraViewArea; }
		
		private function HandleShake():void
		{
			if ( iShakeDuration > Verlocity.engine.CurTime() )
			{
				if ( Math.random() > .5 )
				{
					if ( Math.random() > .5 )
					{
						sprCamera.x -= Math.sin( Verlocity.engine.CurTime() / 100 ) * nShakeForce;
					}
					else
					{
						sprCamera.y -= Math.sin( Verlocity.engine.CurTime() / 100 ) * nShakeForce;
					}
				}
				else
				{
					if ( Math.random() > .5 ) 
					{
						sprCamera.x += Math.sin( Verlocity.engine.CurTime() / 100 ) * nShakeForce;
					}
					else
					{
						sprCamera.y += Math.sin( Verlocity.engine.CurTime() / 100 ) * nShakeForce;
					}
				}
			}
			else
			{
				if ( sprCamera.x != pBeforeShake.x || sprCamera.y != pBeforeShake.y )
				{
					sprCamera.x -= mathHelper.Ease( sprCamera.x, pBeforeShake.x, 30 );
					sprCamera.y -= mathHelper.Ease( sprCamera.y, pBeforeShake.y, 30 );
				}
				else
				{
					pBeforeShake = null;
				}
			}
		}


		/*------------------ PUBLIC -------------------*/
		public function Add( disp:DisplayObject, bAddToBottom:Boolean = false ):void
		{
			if ( bAddToBottom )
			{
				sprCamera.addChildAt( disp, 0 );
			}
			else
			{
				sprCamera.addChild( disp );				
			}
		}
		
		public function SetLayer( sLayer:String ):void
		{
			Verlocity.layers.Insert( sprCamera, sLayer );
			Verlocity.layers.Insert( sCameraViewArea, sLayer );
		}
		
		public function RemoveAll():void
		{
			for ( var i:int = 0; i < sprCamera.numChildren; i++ )
			{
				sprCamera.removeChildAt( i );
			}
		}
		
		public function Reset():void
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

		public function get width():Number { return sprCamera.width; }
		public function get height():Number { return sprCamera.height; }
		public function get x():Number { return sprCamera.x; }
		public function get y():Number { return sprCamera.y; }
		public function set x( nPosX:Number ):void { sprCamera.x = nPosX; }
		public function set y( nPosY:Number ):void { sprCamera.y = nPosY; }
		public function get zoom():Number { return nZoom; }
		public function set zoom( nSetZoom:Number ):void { nZoom = nSetZoom; sprCamera.scaleX = sprCamera.scaleY = nZoom; }

		public function SetCenterPos( iPosX:int, iPosY:int ):void
		{
			sprCamera.x = pCenter.x - iPosX;
			sprCamera.y = pCenter.y - iPosY;
		}

		public function ResetPos():void
		{
			sprCamera.x = 0; sprCamera.y = 0;
		}
		
		public function Follow( ent:verBEnt, iOffsetX:int = 0, iOffsetY:int = 0, bEase:Boolean = true, iEaseSpeed:int = 30 ):void
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
		
		public function StopFollowing():void
		{
			entFollow = null;
		}
		
		public function MoveTo( pPoint:Point, bEase:Boolean = true, iEaseSpeed:int = 30 ):void
		{
			pGoto = pPoint;
			bEasing = bEase;
			iEasingSpeed = iEaseSpeed;
		}
		
		public function StopMoveTo():void
		{
			pGoto = null;
		}
		
		public function Rotate( nRot:Number ):void
		{
			var m:Matrix = sprCamera.transform.matrix;
				m.tx -= pCenter.x;
				m.ty -= pCenter.y;
				m.rotate( angleHelper.DegreeToRad( nRot ) );
				m.tx += pCenter.x;
				m.ty += pCenter.y;
			sprCamera.transform.matrix = m;
		}
		
		public function SetZoom( nSetZoom:Number ):void
		{
			nZoom = nSetZoom;
			sprCamera.scaleX = sprCamera.scaleY = nZoom;
		}
		
		public function Shake( iDuration:int, nForce:Number ):void
		{
			pBeforeShake = new Point( sprCamera.x, sprCamera.y );
			
			nShakeForce = nForce;
			iShakeDuration = Verlocity.engine.CurTime() + iDuration;
		}
		
		public function StopShaking():void
		{
			iShakeDuration = -1;
		}
		
		public function AdjustColors( nBrightness:Number, nContrast:Number, nHue:Number, nSaturation:Number ):void
		{
			if ( !aColor ) { aColor = new AdjustColor(); }
			if ( !cmFilter ) { cmFilter = new ColorMatrixFilter() }
			
			aColor.brightness = nBrightness;
			aColor.contrast = nContrast;
			aColor.hue = nHue;
			aColor.saturation = nSaturation;
			
			cmFilter.matrix = aColor.CalculateFinalFlatArray();

			sprCamera.filters = [ cmFilter ];
		}
		
		public function RemoveFilters():void
		{
			aColor = null;
			cmFilter = null;
			sprCamera.filters = null;
		}

		public function SetColor( r:int, g:int, b:int, alpha:Number = 1 ):void
		{
			if ( !ctColor ) { ctColor = new ColorTransform(); }

			var newColor:uint = colorHelper.RGBtoHEX( r, g, b );

			ctColor.color = newColor;
			ctColor.alphaMultiplier = alpha;
			sprCamera.transform.colorTransform = ctColor;
		}
		
		public function ResetColor():void
		{
			ctColor = null;
			sprCamera.transform.colorTransform = new ColorTransform();
		}
		
		public function SetTint( amount:Number, r:int = 255, g:int = 255, b:int = 255 ):void
		{
			if ( !cTint ) { cTint = new Color(); }

			var newColor:uint = colorHelper.RGBtoHEX( r, g, b );
			
			cTint.setTint( newColor, amount );
			sprCamera.transform.colorTransform = cTint;	
		}

		public function RemoveTint():void
		{
			if ( cTint )
			{
				cTint.alphaMultiplier = 0;
				cTint = null;
				sprCamera.transform.colorTransform = new ColorTransform();
			}
		}
		
		public function SetMask( mask:DisplayObject ):void
		{
			sprCamera.mask = mask;
		}

		public function SetMaskPos( iPosX:int, iPosY:int ):void
		{
			sprCamera.mask.x = iPosX; sprCamera.mask.y = iPosY;
		}

		public function ResetMask():void
		{
			sprCamera.mask = sCameraViewArea;

			sCameraViewArea.x = 0; sCameraViewArea.y = 0;
		}

	}
}