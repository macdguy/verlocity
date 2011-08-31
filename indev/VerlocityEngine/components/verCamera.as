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
	import flash.geom.ColorTransform;	

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
		
		private var ctColor:ColorTransform = new ColorTransform( 1, 1, 1, 1 );
		private var cTint:Color = new Color();
		
		private var pGoto:Point;
		private var entFollow:verBEnt;
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
		}


		/*
		 ****************COMPONENT LOOP******************
		*/
		public function Think():void
		{
			if ( pGoto )
			{
				if ( sprCamera.x != pCenter.x - pGoto.x && sprCamera.y != pCenter.y - pGoto.y )
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
					sprCamera.x -= mathHelper.Ease( sprCamera.x, pCenter.x - entFollow.absX, iEasingSpeed );
					sprCamera.y -= mathHelper.Ease( sprCamera.y, pCenter.y - entFollow.absY, iEasingSpeed );
				}
				else
				{
					SetPos( entFollow.absX, entFollow.absY );
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
				if ( sprCamera.x != 0 || sprCamera.y != 0 )
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
		
		public function RemoveAll():void
		{
			for ( var i:int = 0; i < sprCamera.numChildren; i++ )
			{
				sprCamera.removeChildAt( i );
			}
		}

		public function SetPos( iPosX:int, iPosY:int ):void
		{
			sprCamera.x = pCenter.x - iPosX;
			sprCamera.y = pCenter.y - iPosY;
		}

		public function ResetPos():void
		{
			sprCamera.x = 0; sprCamera.y = 0;
		}
		
		public function Follow( ent:verBEnt, bEase:Boolean = true, iEaseSpeed:int = 30 ):void
		{
			entFollow = ent;
			bEasing = bEase;
			iEasingSpeed = iEaseSpeed;
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
		
		public function Zoom( nZoom:Number ):void
		{
			sprCamera.scaleX = nZoom; sprCamera.scaleY = nZoom;
		}
		
		public function Shake( iDuration:int, nForce:Number ):void
		{
			pBeforeShake = new Point( sprCamera.x, sprCamera.y );
			
			nShakeForce = nForce;
			iShakeDuration = Verlocity.engine.CurTime() + iDuration;
		}

		public function SetColor( r:int, g:int, b:int, alpha:Number = 1 ):void
		{
			var newColor:uint = colorHelper.RGBtoHEX( r, g, b );

			ctColor.color = newColor;
			ctColor.alphaMultiplier = alpha;
			sprCamera.transform.colorTransform = ctColor;
		}
		
		public function SetTint( amount:Number, r:int = 255, g:int = 255, b:int = 255 ):void
		{
			var newColor:uint = colorHelper.RGBtoHEX( r, g, b );
			
			cTint.setTint( newColor, amount );
			sprCamera.transform.colorTransform = cTint;	
		}

		public function RemoveTint():void
		{
			cTint.alphaMultiplier = 0;
			sprCamera.transform.colorTransform = cTint;
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