/*
 * ---------------------------------------------------------------
 * Verlocity
 * http://www.verlocityengine.com
 * 
 * This file is subject to the terms and conditions defined in
 * 'license.txt', which is part of this source code package.
 * ---------------------------------------------------------------
*/
package verlocity.ents
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.display.DisplayObjectContainer;

	import fl.motion.Color;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	import flash.geom.Point;

	import verlocity.Verlocity;
	import verlocity.ents.Entity;
	import verlocity.ents.DynamicEntity;
	import verlocity.display.DisplayHolder;
	import verlocity.logic.ElapsedTrigger;
	import verlocity.display.Layer;
	import verlocity.sound.SoundObject;
	import verlocity.utils.DisplayUtil;
	import verlocity.utils.ColorUtil;
	import verlocity.utils.ObjectUtil;
	import verlocity.utils.AngleUtil;
	import verlocity.utils.MathUtil;

	/**
	 * A display entity.
	 * This is the typical entity class to use when displaying artwork.
	 */
	public class DisplayEntity extends DynamicEntity
	{
		/**
		 * Creates a new display entity.
		 */
		public function DisplayEntity()
		{
			super();

			// Setup a new display holder
			_disp = new DisplayHolder( this );
		}

		/**
		 * Called each engine tick, do not override this.
		 * DO NOT CALL MANUALLY - THIS IS HANDLED BY verEnts!
		 */
		public override function _Update():void 
		{
			super._Update();

			TimedRemoveUpdate();
			RemoveOnUpdate();
		}
		
		/**
		 * Returns if this entity base contains display functionality (will not Init until spawned).
		 */
		public override function get _IsDisplay():Boolean { return true; }

		/**
		 * Returns the entity base class.
		 */
		public override function get baseClass():Object { return DisplayEntity; }
		
		/*
			 ===================
			======= HOOKS =======
			 ===================
			Override these functions for your own needs.
			They will be called appropriately.
		*/

		/**
		 * Called when the entity is repawned with the Respawn function
		*/
		protected function OnRespawn():void {}

		
		/*
			 =====================
			======= DISPLAY =======
			 =====================
		*/
		private var _disp:DisplayHolder;
		
		// Transforms
		private var nScale:Number = 1;
		private var nScaleX:Number = 1;
		private var nScaleY:Number = 1;
		private var iRotation:int;
		private var iWidth:int;
		private var iHeight:int;

		/**
		 * Returns the display holder.
		 * You can set a new artwork using this.
		 */
		public function get display():DisplayHolder { return _disp; }
		
		/**
		 * Sets up the collision bounds.
		 */
		public function SetupCollision():void
		{
			if ( !IsCollisionEnabled() ) { return; }

			// Setup the collsion rect based on bounds
			SetCollisionRect( _disp.bounds, _disp.bounds.x, _disp.bounds.y );
		}

		/**
		 * Removes all displays of the entity.
		 */
		public function RemoveDisplay():void
		{
			_disp.Dispose();
		}
		
		/**
		 * Returns if the display is a specified base class.
		 * @param	cClassName The class to check if the display matches
		 */
		public function DisplayIs( cClassName:Class ):Boolean
		{
			return _disp.Is( cClassName );
		}
		


		/*
			 ======================
			======= SPAWNING =======
			 ======================
		*/
		protected var bIsSpawned:Boolean;
		protected var lLayer:Layer;
		
		/**
		 * Internal function for setting the layer
		 * @param	layer
		 * @param	bSpawnOnBottom
		 */
		private function SetLayer( layer:Layer, bSpawnOnBottom:Boolean = false ):void
		{
			// Spawn
			if ( _disp.displayObj )
			{
				if ( bSpawnOnBottom )
				{
					layer.addChildAt( _disp.displayObj, 0 );
				}
				else
				{
					layer.addChild( _disp.displayObj );
				}
			}

			// Set layer
			lLayer = layer;
		}

		/**
		 * Spawns the entity into a layer and calls Init.
		 * This is required to display the artwork.
		 * You can only call this function once.  To swap layers, use the SwapLayer function.
		 * @param	sSetLayer The name of the layer to insert the entity in.
		 * @param	bSpawnOnBottom Should the entity spawn on the bottom or on the top?
		 */
		public function Spawn( sSetLayer:String, bSpawnOnBottom:Boolean = false ):void
		{
			if ( !_disp.IsValid() ) { return; }
			if ( bIsSpawned ) { return; }

			bIsSpawned = true;

			// Get the layer
			var layer:Layer = Verlocity.layers.Get( sSetLayer );

			// Determine if layer is valid
			if ( !layer ) { Verlocity.Trace( "Unable to spawn entity! Check if spawn layer is valid!", "Ents" ); return; }
			
			// Set the layer
			SetLayer( layer, bSpawnOnBottom );


			// Setup defaults
			nInitialX = x;
			nInitialY = y;

			// Start entity
			Init();
			EnableUpdate();
			Play();
		}
		
		/**
		 * Returns if the entity was spawned.
		 */
		public function IsSpawned():Boolean
		{
			return bIsSpawned;
		}
		
		/**
		 * Calls DeInit then Init.
		 * Resets the health and position of the entity.
		 */
		public function Respawn():void
		{
			DeInit();
			Init();

			Reset();

			OnRespawn();
		}
		
		/**
		 * Swaps the current layer of the entity.
		 * Must be spawned already!
		 * @param	sSetLayer The layer to swap this entity to.
		 * @param	bSpawnOnBottom Should the entity spawn on the bottom or on the top?
		 */
		public function SwapLayer( sSetLayer:String, bSpawnOnBottom:Boolean = false ):void
		{
			if ( !_disp.IsValid() ) { return; }
			if ( !bIsSpawned ) { return; }

			// Get the layer
			var layer:Layer = Verlocity.layers.Get( sSetLayer );

			// Determine if layer is valid
			if ( !layer ) { Verlocity.Trace( "Unable to spawn entity! Check if spawn layer is valid!", "Ents" ); return; }
			
			// Set the layer
			SetLayer( layer, bSpawnOnBottom );
		}

		/**
		 * A getter that returns the layer the entity is currently in.
		 */
		public function get currentLayer():Layer { return lLayer; }

		/**
		 * A getter that returns the layer name the entity is currently in.
		 */
		public function get currentLayerName():String { return lLayer.name; }


		/*
			 =====================
			======= GETTERS =======
			 =====================
		*/

		/**
		 * Sets the position of the display entity.
		 */
		public override function set x( nSetPos:Number ):void
		{
			// Update calculated position
			super.x = nSetPos;

			// Update display
			if ( _disp.displayObj )
			{
				_disp.displayObj.x = nPosX;
			}
		}

		/**
		 * Sets the position of the display entity.
		 */
		public override function set y( nSetPos:Number ):void
		{
			// Update calculated position
			super.y = nSetPos;

			// Update display
			if ( _disp.displayObj )
			{
				_disp.displayObj.y = nPosY;
			}
		}

		/**
		 * Returns the rotation of the display entity
		 */
		public function get rotation():int { return iRotation; }
		
		/**
		 * Sets the rotation of the display entity.
		 */
		public function set rotation( iRot:int ):void
		{
			iRotation = iRot;

			// Update display
			if ( _disp.displayObj )
			{
				_disp.displayObj.rotation = iRotation;
			}
		}

		/**
		 * Returns the width of the display entity.
		 */
		public function get width():int { return iWidth; }

		/**
		 * A getter that returns the width divided by two (center of x).
		 */
		public function get halfWidth():Number { return width / 2; }
		
		/**
		 * Sets the width of the display entity.
		 */
		public function set width( iSetWidth:int ):void
		{
			iWidth = iSetWidth;
			UpdateCollisionRect( NaN, NaN, NaN, NaN, iWidth );

			// Update display
			if ( _disp.displayObj )
			{
				_disp.displayObj.width = iWidth;
			}
		}

		/**
		 * Returns the height of the display entity.
		 */
		public function get height():int { return iHeight; }
		
		/**
		 * A getter that returns the height divided by two (center of y).
		 */
		public function get halfHeight():Number { return height / 2; }
		
		/**
		 * Sets the height of the display entity.
		 */
		public function set height( iSetHeight:int ):void
		{
			iHeight = iSetHeight;
			UpdateCollisionRect( NaN, NaN, NaN, NaN, NaN, iHeight );

			// Update display
			if ( _disp.displayObj )
			{
				_disp.displayObj.height = iHeight;
			}
		}
		
		/**
		 * Returns the X scale of the display entity.
		 */
		public function get scaleX():Number { return nScaleX; }
		
		/**
		 * Sets the X scale of the display entity.
		 */
		public function set scaleX( nSetScale:Number ):void
		{
			nScaleX = nSetScale;
			UpdateCollisionRect( NaN, NaN, nScaleX );

			// Update display
			if ( _disp.displayObj )
			{
				_disp.displayObj.scaleX = nScaleX;
			}
		}

		/**
		 * Returns the Y scale of the display entity.
		 */
		public function get scaleY():Number { return nScaleY; }

		/**
		 * Sets the Y scale of the display entity.
		 */
		public function set scaleY( nSetScale:Number ):void
		{
			nScaleY = nSetScale;
			UpdateCollisionRect( NaN, NaN, NaN, nScaleY );

			// Update display
			if ( _disp.displayObj )
			{
				_disp.displayObj.scaleY = nScaleY;
			}
		}

		/**
		 * Returns the graphics object. 
		 * Works for: DisplayObject.
		 */
		public function get graphics():Graphics
		{
			if ( !_disp.displayObj ) { return null; }

			if ( _disp.IsDrawable() )
			{
				return Sprite( _disp.displayObj ).graphics;
			}

			return null;
		}

		/**
		 * Returns the bounds of the display entity
		 */
		public function get bounds():Rectangle { return _disp.bounds; }


		/*
			 ============================
			======= POSITION/SCALE =======
			 ============================
		*/

		/**
		 * Sets the scale of the entity.
		 * WARNING: BitmapClips will render slower!
		 * @param	nScale The scale to scale the entity to (this effects both X and Y scales).
		 * @usage	Example usage: ent.SetScale( 2 );
		*/
		public function SetScale( nSetScale:Number ):void
		{
			nScale = nSetScale;
			scaleX = nScale; scaleY = nScale;
		}

		/**
		 * Returns the current scale of the entity.
		 */
		public function GetScale():Number
		{
			return nScale;
		}
		
		/**
		 * Resets the scale of the entity to defaults (1).
		 */		
		public function ResetScale():void
		{
			SetScale( 1 );
		}

		/**
		 * Sets the rotation of the entity.
		 * @param	iRot Amount of rotation (0-360).
		 */
		public function SetRotation( iRot:int ):void
		{
			rotation = iRot;
		}

		/**
		 * Returns the angle of rotation as a unit vector.
		 */
		public function GetAngle():Point
		{
			return AngleUtil.AngleOfRotation( rotation );
		}


		/*
			 ===================
			======= COLOR =======
			 ===================
		*/
		protected var uiColor:uint;
		protected var ctColor:ColorTransform;
		protected var cTint:Color;
		protected var nAlpha:Number = 1;

		/**
		 * Sets the color of the entity.
		 * @param	newColor The color to set to (hex).
		 * @param	nAlpha The alpha (transparency).
		 */
		public function SetColor( color:uint, nAlpha:Number = 1 ):void
		{
			if ( !_disp.IsValid() ) { return; }

			// Set color
			uiColor = color;

			// Update display
			if ( _disp.displayObj )
			{
				if ( !ctColor ) { ctColor = new ColorTransform(); }

				ctColor.color = uiColor;
				ctColor.alphaMultiplier = nAlpha;

				_disp.displayObj.transform.colorTransform = ctColor;
			}
		}

		/**
		 * Sets the color of the entity with RGB.
		 * @param	r Red amount (0-255).
		 * @param	g Green amount (0-255).
		 * @param	b Blue amount (0-255).
		 * @param	nAlpha The alpha (transparency).
		 */
		public function SetColorRGB( r:int = 255, g:int = 255, b:int = 255, nAlpha:Number = 1 ):void
		{
			SetColor( ColorUtil.RGBtoHEX( r, g, b ), nAlpha );
		}

		/**
		 * Returns the color of the entity.
		 * Defaults to white (0xFFFFFF).
		 */
		public function GetColor():uint
		{
			return uiColor || 0xFFFFFF;
		}
		
		/**
		 * Sets the tint of the entity.
		 * @param	newColor The color of the tint (hex).
		 * @param	amount The amount of tint to apply.
		 */
		public function SetTint( color:uint, amount:Number ):void
		{
			if ( !_disp.IsValid() ) { return; }

			// Set tint
			if ( !cTint ) { cTint = new Color(); }
			cTint.setTint( color, amount );
			
			SetColor( cTint.tintColor );
		}

		/**
		 * Sets the tint of the entity with RGB.
		 * @param	amount The amount of tint to apply.
		 * @param	r Red amount (0-255).
		 * @param	g Green amount (0-255).
		 * @param	b Blue amount (0-255).
		 */
		public function SetTintRGB( amount:Number, r:int = 255, g:int = 255, b:int = 255 ):void
		{
			SetTint( amount, ColorUtil.RGBtoHEX( r, g, b ) );
		}

		/**
		 * Removes any tinting applied.
		 */
		public function RemoveTint():void
		{
			if ( !_disp.IsValid() ) { return; }
			if ( !cTint ) { return; }
			
			cTint = new Color();
			cTint.setTint( uiColor, 0 );
			
			SetColor( cTint.tintColor );
			
			cTint = null;
		}

		/**
		 * Sets the overall transparency of the entity.
		 * @param	nSetAlpha
		 */
		public function SetAlpha( nSetAlpha:Number ):void
		{
			if ( !_disp.IsValid() ) { return; }
			
			nAlpha = nSetAlpha;
			
			// Update display
			if ( _disp.displayObj )
			{
				// Update color transform
				if ( ctColor )
				{
					ctColor.alphaMultiplier = nAlpha;
					_disp.displayObj.transform.colorTransform = ctColor;
				}
				else
				{
					_disp.displayObj.alpha = nAlpha;
				}
			}
		}

		/**
		 * Returns the overall transparency of the entity.
		 * @return
		 */
		public function GetAlpha():Number 
		{
			return nAlpha;
		}
		
		/**
		 * Fades between two colors (hex).
		 * @param	oldColor Original color
		 * @param	newColor New color
		 * @param	amount The amount of blending to occur (0-1).
		 */
		public function FadeColors( oldColor:uint, newColor:uint, amount:Number = 1 ):void
		{
			if ( !_disp.IsValid() ) { return; }

			SetColor( Color.interpolateColor( oldColor, newColor, amount ) );
		}
		
		/**
		 * Fades between two RGB values.
		 * @param	oldR Original red amount (0-255).
		 * @param	oldG Original green amount (0-255).
		 * @param	oldB Original blue amount (0-255).
		 * @param	newR New red amount (0-255).
		 * @param	newG New green amount (0-255).
		 * @param	newB New blue amount (0-255).
		 * @param	amount The amount of blending to occur (0-1).
		 */
		public function FadeColorsRGB( oldR:int, oldG:int, oldB:int, newR:int, newG:int, newB:int, amount:Number = 1 ):void
		{
			if ( !_disp.IsValid() ) { return; }

			var oldColor:uint = ColorUtil.RGBtoHEX( oldR, oldG, oldB );
			var newColor:uint = ColorUtil.RGBtoHEX( newR, newG, newB );
			
			FadeColors( oldColor, newColor, amount );
		}

		/**
		 * Removes the color transforms, tinting, and alpha changes applied to the entity.
		 */
		public function RemoveAllColorProperties():void
		{
			if ( !_disp.IsValid() ) { return; }

			// Remove all the color data
			uiColor = NaN;
			ctColor = null;
			cTint = null;
			nAlpha = 1;

			// Update display
			if ( _disp.displayObj )
			{
				_disp.displayObj.transform.colorTransform = new ColorTransform();
				_disp.displayObj.alpha = 1;
			}
		}
		
		/**
		 * Sets the filters of the display object.
		 * @param	... filters
		 */
		public function SetFilters( ... filters ):void
		{
			if ( !_disp.IsValid() ) { return; }

			// Update display
			if ( _disp.displayObj )
			{
				_disp.displayObj.filters = filters;
			}
		}
		
		/**
		 * Removes the filters of the display object.
		 */
		public function RemoveFilters():void
		{
			if ( !_disp.IsValid() ) { return; }

			if ( _disp.displayObj )
			{
				_disp.displayObj.filters = null;
			}
		}

		/**
		 * Draws a simple rectangle in the display object.
		 * Color is based on the set color of the entity, unless specified.
		 * @param	drawX X position to start the rectangle at.
		 * @param	drawY Y position to start the rectangle at.
		 * @param	drawWidth Width of the rectangle.
		 * @param	drawHeight Height of the rectangle.
		 * @param	nAlpha Alpha of the rectangle fill.
		 * @param	uiColor Fill color (defaults to color of entity).
		 */
		public function DrawRect( drawX:int, drawY:int, drawWidth:Number, drawHeight:Number, nAlpha:Number = 1, uiColor:uint = NaN ):void
		{
			if ( !_disp.IsValid() ) { return; }

			// Get default entity color
			var color:uint = GetColor();
			if ( isNaN( uiColor ) ) { color = uiColor; }

			if ( !graphics ) { return; }

			graphics.beginFill( color, nAlpha );
			graphics.drawRect( drawX, drawY, drawWidth, drawHeight );
			graphics.endFill();
		}

		/**
		 * Clears the graphics of the display object of the entity.
		 */
		public function Clear():void
		{
			if ( !_disp.IsValid() ) { return; }

			if ( graphics )
			{
				graphics.clear();
			}
		}
		
		protected var _bitmapData:BitmapData;
		protected var _bitmap:Bitmap;
		protected var _bitmapDataRect:Rectangle;
		protected var _bitmapDrawRect:Rectangle;

		/**
		 * Creates a bitmap canvas for graphic drawing.  Only works if there's a DisplayObject to this entity.
		 * @param	iWidth The width of the bitmap
		 * @param	iHeight The height of the bitmap
		 * @param	bOverrideDisplay Should we remove the display object of this entity and replace with the drawable bitmap?
		 */
		public function CreateDrawableBitmap( iWidth:int, iHeight:int, bOverrideDisplay:Boolean = false ):void
		{
			_bitmapData = new BitmapData( iWidth, iHeight, true, 0 );
			_bitmap = new Bitmap( _bitmapData );
			_bitmapDataRect = _bitmapData.rect;
			_bitmapDrawRect = new Rectangle();

			if ( bOverrideDisplay )
			{
				//SetDisplayObject( _bitmap );
				return;
			}
			
			if ( !_disp.displayObj )
			{
				RemoveDrawableBitmap();
				return;
			}

			DisplayObjectContainer( _disp.displayObj ).addChild( _bitmap );
		}
		
		/**
		 * Removes the bitmap drawable, if it exists.
		 */
		public function RemoveDrawableBitmap():void
		{
			if ( _bitmap )
			{
				DisplayUtil.RemoveFromParent( _bitmap );
				_bitmap = null;
			}

			if ( _bitmapData )
			{
				_bitmapData.dispose();
			}

			_bitmapData = null;
			_bitmapDataRect = null;
			_bitmapDrawRect = null;
		}

		/**
		 * Draws a simple rectangle in the bitmap canvas.
		 * Color is based on the set color of the entity, unless specified.
		 * @param	drawX X position to start the rectangle at.
		 * @param	drawY Y position to start the rectangle at.
		 * @param	drawWidth Width of the rectangle.
		 * @param	drawHeight Height of the rectangle.
		 * @param	uiColor Fill color (defaults to color of entity).
		 */
		public function BitmapDrawRect( drawX:int, drawY:int, drawWidth:Number, drawHeight:Number, uiColor:uint = NaN ):void
		{
			if ( !_bitmapData ) { return; }

			_bitmapDrawRect.x = drawX;
			_bitmapDrawRect.y = drawY;
			_bitmapDrawRect.width = drawWidth;
			_bitmapDrawRect.height = drawHeight;

			_bitmapData.fillRect( _bitmapDrawRect, uiColor );
		}


		/*
			 =============================
			======= REMOVAL/CLEANUP =======
			 =============================
		*/
		private var etRemoveDelay:ElapsedTrigger;
		protected var bIsBeingRemoved:Boolean;
		private var bFadeRemove:Boolean;
		private var nFadeSpeed:Number;

		/**
		 * Sets the time the entity should be removed in.  Useful for bullets or timed entities.
		 * @param	iMiliSecs The amount of time before to object is removed (in milliseconds)
		 * @param	bFadeOut If set, the entity will fade out when being removed.
		 * @param	nSetFadeSpeed The speed the entity will fade out at.
		 */
		public function SetRemoveTime( iMilliSecs:int, bFadeOut:Boolean = false, nSetFadeSpeed:Number = 0.05 ):void
		{
			etRemoveDelay = new ElapsedTrigger( iMilliSecs );
			bFadeRemove = bFadeOut;
			nFadeSpeed = nSetFadeSpeed;
		}

		/**
		 * Removes the entity with a fading effect.
		 * @param	nSetFadeSpeed The speed the entity will fade out at.
		 */
		public function FadeRemove( nSetFadeSpeed:Number = 0.05 ):void
		{
			if ( bIsBeingRemoved ) { return; }

			SetRemoveTime( 0, true, nSetFadeSpeed );
		}

		/**
		 * Handles the fade removal of the entity,
		 * @private
		 */
		private function TimedRemoveUpdate():void
		{
			if ( !etRemoveDelay || !etRemoveDelay.IsTriggered() ) { return; }

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

		/**
		 * Returns if the entity is being fade removed.
		 * @return
		 */
		public function IsBeingRemoved():Boolean { return bIsBeingRemoved; }

		/*
			 =============================
			========== ANIMATION ==========
			 =============================
		*/
		private var bIsPlaying:Boolean;
		private var bWasPlaying:Boolean;
		
		/**
		 * Sets the display object to a specific frame.  Internal function for organization.
		 * @param	frame String or numberical index of a frame
		 * @param	bPlayAnim Defines if the animation should begin playing upon setting
		 * @private
		 */
		private function Goto( frame:int, bPlayAnim:Boolean ):void
		{
			if ( bPlayAnim )
			{
				if ( _disp.IsMovieClip() )
				{
					MovieClip( _disp.displayObj ).gotoAndPlay( frame );
				}
			}
			else
			{
				if ( _disp.IsMovieClip() )
				{
					MovieClip( _disp.displayObj ).gotoAndStop( frame );
				}
			}

			bIsPlaying = bPlayAnim;
		}

		/**
		 * Sets the display object to a specific frame number.
		 * @param	sString The frame number to set the clip to.
		 * @param	bPlayAnim Set this to false if you want the animation to not play after being set.
		*/
		public function SetFrame( iFrame:int, bPlayAnim:Boolean = true ):void
		{
			if ( !_disp.IsValid() ) { return; }

			Goto( iFrame, bPlayAnim );
		}

		/**
		 * Sets the display object to a specific labeled frame.
		 * @param	sString The frame label to set the movieclip to.
		 * @param	bPlayAnim Set this to false if you want the animation to not play after being set.
		*/
		public function SetFrameLabel( sString:String, bPlayAnim:Boolean = true ):void
		{
			if ( !_disp.IsValid() ) { return; }
			if ( _disp.IsMovieClip() ) { return; }
		
			if ( bPlayAnim )
			{
				MovieClip( _disp.displayObj ).gotoAndPlay( sString );
			}
			else
			{
				MovieClip( _disp.displayObj ).gotoAndStop( sString );
			}
		}

		/**
		 * Sets the display object (if it's a MovieClip) to a random frame.
		 * @param	bPlayAnim Set this to true if you want the animation to play after being set.
		 * @usage	Example usage: ent.SetRandomFrame()
		*/
		public function SetRandomFrame( bPlayAnim:Boolean = false ):void
		{
			if ( !_disp.IsValid() ) { return; }

			var i:int = MathUtil.Rand( 1, totalFrames );

			Goto( i, bPlayAnim );
		}
		
		/**
		 * Plays the display object.
		 */
		public function Play():void
		{
			if ( !_disp.IsValid() ) { return; }
			
			if ( _disp.IsMovieClip() )
			{
				MovieClip( _disp.displayObj ).play();
			}
			
			bIsPlaying = true;
		}

		/**
		 * Stops the display object.
		 */
		public function Stop():void
		{
			if ( !_disp.IsValid() ) { return; }

			if ( _disp.IsMovieClip() )
			{
				MovieClip( _disp.displayObj ).stop();
			}

			bIsPlaying = false;
		}

		/**
		 * Pauses the display object.
		 */
		public function Pause():void
		{
			if ( !_disp.IsValid() ) { return; }
			
			bWasPlaying = bIsPlaying;

			Stop();
		}

		/**
		 * Resumes the display object.
		 */
		public function Resume():void
		{
			if ( !_disp.IsValid() ) { return; }
			
			if ( bWasPlaying )
			{
				Play();
			}

			bWasPlaying = false;
		}
		
		/**
		 * Returns if the animation for the display object has ended.
		 * @return
		 */
		public function HasEnded():Boolean
		{
			return currentFrame >= totalFrames - 1;
		}

		/**
		 * Returns if the display object is currently playing.
		 */
		public function IsPlaying():Boolean
		{
			return bIsPlaying;
		}

		/**
		 * Returns the current frame of the display object.
		 */
		public function get currentFrame():int
		{
			if ( !_disp.IsValid() ) { return -1; }
			
			if ( _disp.IsMovieClip() )
			{
				MovieClip( _disp.displayObj ).currentFrame;
			}

			return -1;
		}

		/**
		 * Returns the total frames of the display object.
		 */
		public function get totalFrames():int
		{
			if ( !_disp.IsValid() ) { return -1; }

			if ( _disp.IsMovieClip() )
			{
				MovieClip( _disp.displayObj ).totalFrames;
			}
			
			return -1;
		}

		/**
		 * Returns the current frame label of the display object.
		 */
		public function get currentFrameLabel():String
		{
			if ( !_disp.IsValid() ) { return null; }

			return MovieClip( _disp.displayObj ).currentFrameLabel;
		}

		private var iRemoveOn:int = -1;

		/**
		 * Sets the display entity to automatically remove upon reaching a frame.
		 * This is useful for playing an animation, such as a death animation.
		 * @param	iFrameToRemoveOn
		 */
		public function RemoveOnFrame( iFrameToRemoveOn:int = -1 ):void
		{
			if ( !_disp.IsValid() ) { return; }
			
			if ( iFrameToRemoveOn == -1 )
			{
				iRemoveOn = totalFrames;
			}
			
			iRemoveOn = iFrameToRemoveOn;
		}

		/**
		 * Checks if we should remove the entity after the remove on frame.
		 */
		private function RemoveOnUpdate():void
		{
			if ( !_disp.IsValid() ) { return; }
			if ( iRemoveOn == -1 ) { return; }

			if ( currentFrame >= iRemoveOn )
			{
				Remove();
			}
		}

		/**
		 * Resets the entity to its original values.
		 */
		public override function Reset():void
		{
			super.Reset();

			RemoveAllColorProperties();
			ResetScale();

			Goto( 1, bIsPlaying );
		}

		/**
		 * Cleans the entity's data.
		 * DO NOT CALL MANUALLY - THIS IS HANDLED BY verEnts!
		*/
		public override function _Dispose():void
		{
			super._Dispose();

			RemoveAllColorProperties();
			Clear();
			RemoveDrawableBitmap();
			RemoveDisplay();

			bIsSpawned = false;

			etRemoveDelay = null;
			bIsBeingRemoved = false;
			bFadeRemove = false;
			nFadeSpeed = NaN;
			
			bIsPlaying = false;
			bWasPlaying = false;
		}
	}
}