/*
	This file is subject to the terms and conditions defined in
    file 'license.txt', which is part of this source code package.
*/

package VerlocityEngine.base
{
	import VerlocityEngine.Verlocity;
	import flash.display.DisplayObject;
	import VerlocityEngine.helpers.ElapsedTrigger;
	
	import flash.geom.Point;
	import flash.geom.Matrix;

	import flash.geom.ColorTransform;
	import fl.motion.Color;
	
	import VerlocityEngine.util.mathHelper;
	import VerlocityEngine.util.colorHelper;
	import VerlocityEngine.util.angleHelper;

	public class verBScreenObject extends verBMovieClip
	{
		protected var uiColor:uint;
		protected var ctColor:ColorTransform = new ColorTransform( 1, 1, 1, 1 );
		protected var cTint:Color = new Color();

		protected var bIsBeingRemoved:Boolean;
		protected var RemoveDelay:ElapsedTrigger;
		protected var bFadeRemove:Boolean;
		protected var nFadeSpeed:Number;

		public function verBScreenObject():void
		{
			mouseEnabled = false; mouseChildren = false; // This optimizes screen objects a bit.
		}

		/*
			 ===================
			======= HOOKS =======
			 ===================
			Override these functions for your own needs.
			They will be called appropriately.
		*/
		protected function OnRemove():void { }
		
		
		/*
			 =======================
			======= PROTECTION =======
			 =======================
		*/
		protected var bIsProtected:Boolean;
		public function SetProtected( bProtected:Boolean = true ):void
		{
			bIsProtected = bProtected;
		}

		public function IsProtected():Boolean
		{
			return bIsProtected;
		}

		/*
			 ============================
			======= POSITION/SCALE =======
			 ============================
		*/

		protected var previousX:Number = 0;
		protected var previousY:Number = 0;

		/**
		 * Sets the X and Y position of the screen object.
		 * @param	iPosX The X position to set the screen object to.
		 * @param	iPosY The Y position to set the screen object to.
		 * @usage	Example usage: scrobj.SetPos( 125, 25 );
		*/
		public function SetPos( iPosX:int, iPosY:int ):void
		{
			previousX = x; previousY = x;
			x = iPosX; y = iPosY;
		}

		public override function set x (value:Number):void { previousX = x; super.x = value; }
		public override function set y (value:Number):void { previousY = y; super.y = value; }
		
		public function HasMoved():Boolean
		{
			return previousX != x || previousY != y;
		}

		/**
		 * Sets the scale of the screen object.
		 * @param	nScale The scale to scale the screen object to (this effects both X and Y scales).
		 * @usage	Example usage: scrobj.SetScale( 2 );
		*/
		protected var nScale:Number = 1;

		public function SetScale( nSetScale:Number ):void
		{
			nScale = nSetScale;

			scaleX = nScale; scaleY = nScale;
		}
		
		public function GetScale():Number
		{
			return nScale;
		}
		
		public function SetRotation( iRot:int ):void
		{
			rotation = iRot;
		}
		
		public function GetAngle():Point
		{
			return angleHelper.AngleOfRotation( rotation );
		}
		
		public function GetMouseRotation():Number
		{
			return angleHelper.Rotation( absX, absY, Verlocity.input.Mx, Verlocity.input.My );
		}

		/*
		 * ScaleAround and RotateAround are credited to Tim Whitlock
		 * http://timwhitlock.info/blog/2008/04/13/scale-rotate-around-an-arbitrary-centre/
		*/
		public function ScaleAround( offsetX:Number, offsetY:Number, absScaleX:Number, absScaleY:Number ):void
		{ 
			// scaling will be done relatively 
			var relScaleX:Number = absScaleX / scaleX;
			var relScaleY:Number = absScaleY / scaleY;

			// map vector to centre point within parent scope 
			var AC:Point = new Point( offsetX, offsetY );
			AC = localToGlobal( AC );
			AC = parent.globalToLocal( AC );

			// current registered postion AB 
			var AB:Point = new Point( x, y );

			// CB = AB - AC, this vector that will scale as it runs from the centre 
			var CB:Point = AB.subtract( AC );
			CB.x *= relScaleX;
			CB.y *= relScaleY;

			// recaulate AB, this will be the adjusted position for the clip 
			AB = AC.add( CB );

			// set actual properties 
			scaleX *= relScaleX;
			scaleY *= relScaleY;
			x = AB.x;
			y = AB.y;
		}

		public function RotateAround( offsetX:Number, offsetY:Number, toDegrees:Number ):void
		{ 
			var relDegrees:Number = toDegrees - ( rotation % 360 ); 
			var relRadians:Number = Math.PI * relDegrees / 180; 

			var M:Matrix = new Matrix( 1, 0, 0, 1, 0, 0 );
			M.rotate( relRadians ); 

			// map vector to centre point within parent scope 
			var AC:Point = new Point( offsetX, offsetY ); 
			AC = localToGlobal( AC ); 
			AC = parent.globalToLocal( AC ); 

			// current registered postion AB 
			var AB:Point = new Point( this.x, this.y ); 

			// point to rotate, offset position from virtual centre
			var CB:Point = AB.subtract( AC ); 

			// rotate CB around imaginary centre  
			// then get new AB = AC + CB 
			CB = M.transformPoint( CB ); 
			AB = AC.add( CB ); 

			// set real values on clip 
			rotation = toDegrees; 
			x = AB.x; 
			y = AB.y; 
		}


		/**
		 * Returns the absolute Y position.
		 * @usage	Example usage: scrobj.absY;
		*/		
		public function get absX():int
		{
			if ( parent )
			{
				return parent.localToGlobal( new Point( x, y ) ).x;
			}
			
			return x;
		}

		/**
		 * Returns the absolute Y position.
		 * @usage	Example usage: scrobj.absY;
		*/		
		public function get absY():int
		{
			if ( parent )
			{
				return parent.localToGlobal( new Point( x, y ) ).y;
			}
			
			return y;
		}
		
		public function get centerX():int
		{
			return width / 2;
		}

		public function get centerY():int
		{
			return height / 2;
		}


		/**
		 * Cleans the entity's data.
		 * @usage	Example usage: ent.Dispose();
		*/
		public function Dispose():void
		{
			if ( !bIsDead ) { Remove(); }

			stop();
			graphics.clear();
			filters = null;

			nScale = NaN;
			bIsBeingRemoved = false;

			uiColor = NaN;
			ctColor = null;
			cTint = null;

			RemoveDelay = null;
			bFadeRemove = false;
			nFadeSpeed = NaN;
		}

		public function SetColor( newColor:uint, nAlpha:Number = 1 ):void
		{
			ctColor.color = newColor;
			ctColor.alphaMultiplier = alpha;
			transform.colorTransform = ctColor;

			uiColor = newColor;
			newColor = NaN;
		}

		public function SetColorRGB( r:int, g:int, b:int, nAlpha:Number = 1 ):void
		{
			SetColor( colorHelper.RGBtoHEX( r, g, b ), nAlpha );
		}

		public function GetColor():uint
		{
			return uiColor || 0xFFFFFF;
		}
		
		public function SetTint( amount:Number, r:int = 255, g:int = 255, b:int = 255 ):void
		{
			var newColor:uint = colorHelper.RGBtoHEX( r, g, b );
			
			cTint.setTint( newColor, amount );
			transform.colorTransform = cTint;	

			newColor = NaN;
		}

		public function RemoveTint():void
		{
			cTint.alphaMultiplier = 0;
			transform.colorTransform = cTint;
		}

		public function SetAlpha( alpha:Number ):void
		{
			ctColor.alphaMultiplier = alpha;
			transform.colorTransform = ctColor;
		}
		
		public function GetAlpha():Number
		{
			return ctColor.alphaMultiplier;
		}
		
		public function FadeColors( oldR:int, oldG:int, oldB:int, newR:int, newG:int, newB:int, step:Number = 1 ):void
		{
			var oldColor:uint = colorHelper.RGBtoHEX( oldR, oldG, oldB );
			var newColor:uint = colorHelper.RGBtoHEX( newR, newG, newB );

			ctColor.color = Color.interpolateColor( oldColor, newColor, step );
			transform.colorTransform = ctColor;
		}

		public function DrawRect( drawX:int, drawY:int, drawWidth:Number, drawHeight:Number ):void
		{
			graphics.beginFill( GetColor() );
			graphics.drawRect( drawX, drawY, drawWidth, drawHeight );
			graphics.endFill();
		}

		public function SetRemoveTime( iMiliSecs:int, bFadeOut:Boolean = false, nSetFadeSpeed:Number = .05 ):void
		{
			RemoveDelay = new ElapsedTrigger( iMiliSecs );
			bFadeRemove = bFadeOut;
			nFadeSpeed = nSetFadeSpeed;
		}
		


		/*
			 =============================
			======= CLEANUP/REMOVAL =======
			 =============================
		*/
		protected var bIsDead:Boolean;

		/**
		 * Marks the screen object for removal.
		 * @usage	Example usage: scrobj.Remove();
		*/
		public function Remove():void
		{
			if ( bIsDead ) { return; }

			bIsDead = true;
			OnRemove();
		}

		/**
		 * Returns if the screen object is dead.  Used to automatically clean remove the screen object.
		 * @usage	Example usage: scrobj.IsDead();
		*/
		public function IsDead():Boolean
		{
			return bIsDead;
		}

		public function FadeRemove( nSetFadeSpeed:Number = .05 ):void
		{
			if ( bIsBeingRemoved ) { return; }

			SetRemoveTime( 0, true, nSetFadeSpeed );
		}

		protected function TimedRemoveThink():void
		{
			if ( !RemoveDelay || !RemoveDelay.IsTriggered() ) { return; }

			if ( !bIsBeingRemoved ) { bIsBeingRemoved = true; }

			if ( bFadeRemove )
			{
				if ( GetAlpha() > 0 )
				{
					SetAlpha( GetAlpha() - nFadeSpeed );
					return;
				}
			}

			Remove();
		}


		/*
			 =============================
			========== ANIMATION ==========
			 =============================
		*/
		/**
		 * Sets the movieclip to a specific labeled frame.
		 * @param	sString The frame label to set the movieclip to.
		 * @param	bPlayAnim Set this to false if you want the animation to not play after being set.
		 * @usage	Example usage: scrobj.SetFrame( "label", true );
		*/
		public function SetFrame( sString:String, bPlayAnim:Boolean = true ):void
		{
			switch( bPlayAnim )
			{
				case true: gotoAndPlay( sString );
				case false: gotoAndStop( sString );
			}
		}

		/**
		 * Sets the movieclip to a random frame.
		 * @usage	Example usage: scrobj.SetRandomFrame()
		*/		
		public function SetRandomFrame():void
		{
			var i:int = mathHelper.Rand( 1, totalFrames );
			gotoAndStop( i );
		}


		
		public function Clear():void
		{
			graphics.clear();
		}
		
		
	}
}