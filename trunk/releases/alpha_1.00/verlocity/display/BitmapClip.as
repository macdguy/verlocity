/*
 * ---------------------------------------------------------------
 * Verlocity
 * http://www.verlocityengine.com
 * 
 * This file is subject to the terms and conditions defined in
 * 'license.txt', which is part of this source code package.
 * ---------------------------------------------------------------
 * This class is based on the work of Colby Cheeze.
*/
package verlocity.display
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;

	import verlocity.events.EventBitmapClip;
	import verlocity.utils.MathUtil;

	/**
	 * A bitmap-based animated object with similar properties to a DisplayObject.
	 */
 	public final class BitmapClip extends EventDispatcher
	{
		// Storage of data
		private var vAnims:Vector.<BitmapClipIterator>;
		private var vFrames:Vector.<Array>; // columns = rotation, rows = frames of animations

		private var bHasChanged:Boolean;
		private var bIsStopped:Boolean;

		// Current animation/frame
		private var curAnim:int;
		private var curFrame:int;
		private var curRotationFrame:int;
		private var curAnimIterator:BitmapClipIterator;
		private var curBitmapData:BitmapData;
		private var curBitmapRect:Rectangle;
		private var curBitmapDataTransformed:BitmapData;

		// Properties
		private var iFrameRate:int;
		private var iRotation:int;
		private var iWidth:int;
		private var iHeight:int;
		private var iPosX:int;
		private var iPosY:int;
		private var nScaleX:Number = 1;
		private var nScaleY:Number = 1;
		private var ctColor:ColorTransform;

		// Rotation information
		private var iFramesOfRotation:int;
		private var nDegToRot:Number;

		// Animation
		private var iAnimDelay:int;
		private var ot:int; // old time
		private var nt:int; // new time
		private var ac:int; // accumulator
		
		public var sourceClass:Class;

		/**
		 * Creates a new bitmap clip.
		 * @param	clipToCopy Copy a previously created bitmapclip instead of creating a new one.
		 * @param	framesOfRotation Number of rotations to calculate (more = more memory used).
		 * @param	iFPS The framerate of the clip.
		 */
 		public function BitmapClip( clipToCopy:BitmapClip = null, framesOfRotation:int = 32, iFPS:int = 24 ):void
		{
			if ( clipToCopy )
			{
				reuseClipData( clipToCopy );
				return;
			}

			bIsStopped = false;
			frameRate = iFPS;

			curAnim = 0;
			curFrame = 0;
			curRotationFrame = 0;
			iRotation = 0;
			
			initializeAnim();

			// Limit rotation to only 360 degress
			iFramesOfRotation = MathUtil.Clamp( framesOfRotation, 1, 360 );
			nDegToRot = 360 / iFramesOfRotation;
			
			// Fill up vector of rotational frames
			vFrames = new Vector.<Array>;
			for ( var i:int = 0; i < iFramesOfRotation; i++ )
			{
				vFrames[i] = new Array();
			}
			
			vAnims = new Vector.<BitmapClipIterator>;
		}
		
		/**
		 * Initializes animation timers.
		 */
		private function initializeAnim():void
		{
			ac = 0;
			ot = nt = getTimer();			
		}

		/**
		 * Copys data from a previously created BitmapClip.
		 * @param	bitmapClip
		 */
		public function reuseClipData( bitmapClip:BitmapClip ):void
		{
			initializeAnim();

			// Gather basic information (excluding transforms)
			iWidth = bitmapClip.iWidth;
			iHeight = bitmapClip.iHeight;
			iFrameRate = bitmapClip.iFrameRate;
			iAnimDelay = bitmapClip.iAnimDelay;
			iFramesOfRotation = bitmapClip.iFramesOfRotation;
			nDegToRot = bitmapClip.nDegToRot;

			// Gather current
			curFrame = bitmapClip.curFrame;
			curAnim = bitmapClip.curAnim;
			bIsStopped = bitmapClip.bIsStopped;
			
			// Point to frames
			vFrames = bitmapClip.vFrames;
			
			// Copy animations
			vAnims = new Vector.<BitmapClipIterator>;
			for ( var i:int = 0; i < bitmapClip.vAnims.length; i++ )
			{
				vAnims.push( BitmapClipIterator( bitmapClip.vAnims[i] ).clone() );
			}
			curAnimIterator = vAnims[curAnim];
		}
		
		/**
		 * Plays the clip animation.
		 */
		public function play():void
		{
			bIsStopped = false;
		}
		
		/**
		 * Stops the clip animation.
		 */
 		public function stop():void
		{
			bIsStopped = true;
 		}
		
		/**
		 * Goes to a specified frame (internal only).
		 * @param	frame
		 */
		private function goto( frame:int ):void
		{
			while ( curFrame != frame )
			{
				nextFrame();
			}
		}
		
		/**
		 * Goes to and stops on a specified frame.
		 * @param	frame The frame.
		 */
		public function gotoAndStop( frame:int ):void
		{
			stop();
			goto( MathUtil.Clamp( frame, 1, totalFrames ) );
		}
		
		/**
		 * Goes to and plays on a specified frame.
		 * @param	frame The frame.
		 */
		public function gotoAndPlay( frame:int ):void
		{
			play();
			goto( MathUtil.Clamp( frame - 1, 1, totalFrames ) );
		}

		/**
		 * Goes to the next frame.
		 */
		public function nextFrame():void
		{
			curFrame = curAnimIterator.next();
			bHasChanged = true;
		}

		/**
		 * Goes to the previous frame.
		 */
		public function prevFrame():void
		{
			curFrame = curAnimIterator.prev();
			bHasChanged = true;
		} 

		/**
		 * Updates the animation of the BitmapClip
		 */
 		public function update():void
		{
 			if ( bIsStopped ) { return; }

			if ( totalFrames > 0 )
			{
				// Calculate animation time
				nt = getTimer(); // current time
				ac += nt - ot; // frame offset
				ot = nt; // old time

				// Go to next frame
				if ( ac > iAnimDelay )
				{
					ac = 0;
					nextFrame();
				}
			}
			
			if ( bHasChanged )
			{
				updateBitmapData();
			}
		}
		
		/**
		 * Updates the bitmap data and transforms.
		 */
		public function updateBitmapData():void
		{
			// Update bitmapdata
			curBitmapData = vFrames[curRotationFrame][curFrame];
			curBitmapRect = curBitmapData.rect;
			
			// Remove previous transforms
			if ( curBitmapDataTransformed )
			{
				curBitmapDataTransformed.dispose();
				curBitmapDataTransformed = null;
			}
			
			// Apply new transforms, if needed
			applyScale();
			applyColorTransform();
		}

		/**
		 * Applies a scale transform on the clip.
		 */
		private function applyScale():void
		{
			if ( scaleX == 1 && nScaleY == 1 ) { return; }

			// Let's try creating it...
			try
			{
				curBitmapDataTransformed = new BitmapData( curBitmapData.width * nScaleX, 
														   curBitmapData.height * nScaleY, 
														   true, 0x000000 );
			}
			catch ( error:Error )
			{
				// SERIOUSLY WHY DOES THIS HAPPEN??
				return;
			}

			// Something when really wrong here...
			if ( !curBitmapDataTransformed ) { return; }

			var matrix:Matrix = new Matrix();
			matrix.scale( nScaleX, nScaleY );

			// Draw the scaled version
			curBitmapDataTransformed.lock();
				curBitmapDataTransformed.draw( curBitmapData, matrix ); // freaking resource hog >:(
			curBitmapDataTransformed.unlock();

			// Update bitmap
			curBitmapData = curBitmapDataTransformed;
			curBitmapRect = curBitmapData.rect;
		}
		
		/**
		 * Applies the color transform.
		 */
		private function applyColorTransform():void
		{
			if ( !ctColor ) { return; }

			// Create new transform
			if ( !curBitmapDataTransformed )
			{
				curBitmapDataTransformed = curBitmapData.clone();
			}

			// Apply color
			curBitmapDataTransformed.colorTransform( curBitmapRect, ctColor );

			// Update bitmap
			curBitmapData = curBitmapDataTransformed;
		}
		
		/**
		 * Removes all color/scale transforms.
		 */
		public function removeTransforms():void
		{
			ctColor = null;
			nScaleX = 1;
			nScaleY = 1;
			
			if ( curBitmapDataTransformed )
			{
				curBitmapDataTransformed.dispose();
			}
		}
		
		
 
		/**
		 * Imports a movieclip.
		 * @param	source The movie clip to convert.
		 * @param	startFrame The starting frame to import on.
		 * @param	endFrame The ending frame to stop import on.
		 */
 		public function importMovieClip( source:MovieClip, startFrame:int = 1, endFrame:int = 0 ):void
		{
			// Default to total frames
			if ( endFrame == 0 ) { endFrame = source.totalFrames; }

			var centerX:int;
			var centerY:int;
			var sourceWidth:int = source.width;
			var sourceHeight:int = source.height;

			var bmd:BitmapData;
			var bmdRect:Rectangle;
 			var matrix:Matrix;
			
			var frame:int;

			// Get largest dimension
			source.gotoAndStop( startFrame );
			frame = startFrame;
			while ( frame < endFrame )
			{
				if ( sourceWidth < source.width ) { sourceWidth = source.width; }
				if ( sourceHeight < source.height ) { sourceHeight = source.height; }
				source.nextFrame();

				frame++;
			}

			// == CREATE BITMAP DATA

			if ( iFramesOfRotation > 1 )
			{
				// Get center position
				centerX = ( sourceWidth / 2 ) * Math.SQRT2;
				centerY = ( sourceHeight / 2 ) * Math.SQRT2;

				// Setup matrix
				var maxXY:Number = Math.max( centerX, centerY );
				matrix = new Matrix( 1, 0, 0, 1, maxXY, maxXY );

				// Create bitmap
				var bmdScale:int = Math.ceil( Math.max( sourceWidth, sourceHeight ) * Math.SQRT2 );
				bmd = new BitmapData( bmdScale, bmdScale, true, 0x00000000 );
				bmdRect = bmd.rect;
			}
			else
			{
				// Get center position
				centerX = sourceWidth / 2;
				centerY = sourceHeight / 2;

				// Setup matrix
				matrix = new Matrix( 1, 0, 0, 1, centerX, centerY );

				// Create bitmap
				bmd = new BitmapData( sourceWidth, sourceHeight, true, 0x00000000 );
				bmdRect = bmd.rect;
			}

			// Update width/height
			iWidth = sourceWidth;
			iHeight = sourceHeight;


			// == CREATE ITERATOR

			// Point to the last frame, then add to array of animations
			var clipIterator = new BitmapClipIterator( vFrames[0].length, endFrame - startFrame + 1 );
			vAnims.push( clipIterator );
			if ( vAnims.length == 1 )
			{
				curAnimIterator = vAnims[0];
			}


			// == BEGIN EXTRACTING

			source.gotoAndStop( startFrame );
			frame = startFrame;

 			source.rotation = 0;

			// Add source into container for rotation to draw
			var container:Sprite = new Sprite();
			container.addChild( source );

			// Loop frames
			while ( frame < endFrame )
			{
				// Loop rotations
				var rot:int = 0;
				while ( rot < iFramesOfRotation )
				{
					bmd.fillRect( bmdRect, 0 );
					bmd.draw( container, matrix );
					
					vFrames[rot].push( bmd.clone() );
					
					source.rotation += nDegToRot;
					
					rot++;
				}

				source.nextFrame();
				frame++;
			}

			// == END EXTRACTING
			
			// == DELETE DATA

			container.removeChild( source );
			container = null;
			
			bmd.dispose();
			bmd = null;
			bmdRect = null;
			matrix = null;

 			// Tell everybody that we are done
 			dispatchEvent( new EventBitmapClip( EventBitmapClip.COMPLETE, this ) );
 		}
 		
		/**
		 * Imports a sprite.
		 * @param	source The sprite to import.
		 * @return
		 */
		public function importSprite( source:Sprite ):void
		{
			var centerX:int;
			var centerY:int;
			var sourceWidth:int = source.width;
			var sourceHeight:int = source.height;

			var bmd:BitmapData;
			var bmdRect:Rectangle;
 			var matrix:Matrix;

			// == CREATE BITMAP DATA

			if ( iFramesOfRotation > 1 )
			{
				// Get center position
				centerX = ( sourceWidth / 2 ) * Math.SQRT2;
				centerY = ( sourceHeight / 2 ) * Math.SQRT2;

				// Setup matrix
				var maxXY:Number = Math.max( centerX, centerY );
				matrix = new Matrix( 1, 0, 0, 1, maxXY, maxXY );

				// Create bitmap
				var bmdScale:int = Math.ceil( Math.max( sourceWidth, sourceHeight ) * Math.SQRT2 );
				bmd = new BitmapData( bmdScale, bmdScale, true, 0x00000000 );
				bmdRect = bmd.rect;
			}
			else
			{
				// Get center position
				centerX = sourceWidth / 2;
				centerY = sourceHeight / 2;

				// Setup matrix
				matrix = new Matrix( 1, 0, 0, 1, centerX, centerY );

				// Create bitmap
				bmd = new BitmapData( sourceWidth, sourceHeight, true, 0x00000000 );
				bmdRect = bmd.rect;
			}

			// Update width/height
			iWidth = sourceWidth;
			iHeight = sourceHeight;


			// == CREATE ITERATOR

			// Point to the last frame, then add to array of animations
			var clipIterator = new BitmapClipIterator( vFrames[curRotationFrame].length, 1 );
			vAnims.push( clipIterator );
			if ( vAnims.length == 1 )
			{
				curAnimIterator = vAnims[0];
			}


			// == BEGIN EXTRACTING

 			source.rotation = 0;

			// Add source into container for rotation to draw
			var container:Sprite = new Sprite();
			container.addChild( source );

			// Loop rotations
			var rot:int = 0;
			while ( rot < iFramesOfRotation )
			{
				bmd.fillRect( bmdRect, 0 );
				bmd.draw( container, matrix );

				vFrames[rot].push( bmd.clone() );

				source.rotation += nDegToRot;

				rot++;
			}

			// == END EXTRACTING
			
			// == DELETE DATA

			container.removeChild( source );
			container = null;
			
			bmd.dispose();
			bmd = null;
			bmdRect = null;
			matrix = null;

 			// Tell everybody that we are done
 			dispatchEvent( new EventBitmapClip( EventBitmapClip.COMPLETE, this ) );
		}

		/**
		 * Imports a tilesheet.
		 * @param	source BitmapData containing the tile sheet.
		 * @param	tileWidth Tile width.
		 * @param	tileHeight Tile height.
		 * @param	columnsToCopy Number of columns to copy.
		 * @param	rowsToCopy Number of rows to copy.
		 * @param	startPos The starting position to copy from.
		 * @return
		 */
 		public function importTileSheet( source:BitmapData, tileWidth:int, tileHeight:int, columnsToCopy:int = 0, rowsToCopy:int = 0, startPos:Point = null ):void
		{
			var centerX:int;
			var centerY:int;
			var numRows:int;
			var numCols:int;

			var bmd:BitmapData;
			var bmdRect:Rectangle;
 			var matrix:Matrix;

			var copyRect:Rectangle;
			var zeroPoint:Point = new Point();


 			if ( startPos == null ) { startPos = new Point(); }

			copyRect = new Rectangle( startPos.x, startPos.y, tileWidth, tileHeight );
			
			// Calculate number of column/rows
 			numCols = columnsToCopy;
			numRows = rowsToCopy;
			if ( numCols == 0 ) { numCols = ( source.width - startPos.x ) / tileWidth; }
			if ( numRows == 0 ) { numRows = ( source.height - startPos.y ) / tileHeight; }

			// Update width/height
			iWidth = tileWidth;
			iHeight = tileHeight;

			// == CREATE BITMAP DATA

			if ( iFramesOfRotation > 1 )
			{
				// Get center position
				centerX = ( tileWidth / 2 ) * Math.SQRT2;
				centerY = ( tileHeight / 2 ) * Math.SQRT2;

				// Setup matrix
				var maxXY:Number = Math.max( centerX, centerY );
				matrix = new Matrix( 1, 0, 0, 1, maxXY, maxXY );

				// Create bitmap
				var bmdScale:int = Math.ceil( Math.max( tileWidth, tileHeight ) * Math.SQRT2 );
				bmd = new BitmapData( bmdScale, bmdScale, true, 0x00000000 );
				bmdRect = bmd.rect;
			}
			else
			{
				// Get center position
				centerX = tileWidth / 2;
				centerY = tileHeight / 2;

				// Setup matrix
				matrix = new Matrix( 1, 0, 0, 1, centerX, centerY );

				// Create bitmap
				bmd = new BitmapData( tileWidth, tileHeight, true, 0x00000000 );
				bmdRect = bmd.rect;
			}


			// == CREATE ITERATOR

			// Point to the last frame, then add to array of animations
			var clipIterator = new BitmapClipIterator( vFrames[curRotationFrame].length, numCols * numRows );
			vAnims.push( clipIterator );
			if ( vAnims.length == 1 )
			{
				curAnimIterator = vAnims[0];
			}


			// == BEGIN EXTRACTING

			var container:Sprite = new Sprite();
			var bitmap:Bitmap = new Bitmap( new BitmapData( tileWidth, tileHeight, true, 0x00000000 ), "auto", true );

			bitmap.x = -( tileWidth / 2 );
			bitmap.y = -( tileHeight / 2 );
			
			var bmpHolder:Sprite = new Sprite();
			
			bmpHolder.addChild( bitmap );
			container.addChild( bmpHolder );
			
			var i:int, j:int, k:int;
			while ( i < numRows )
			{
				copyRect.y = i * tileHeight + startPos.y;
				
				j = 0;
				while ( j < numCols )
				{
					copyRect.x = j * tileWidth + startPos.x;
					
					bitmap.bitmapData.fillRect( bitmap.bitmapData.rect, 0x00000000 );
					bitmap.bitmapData.copyPixels( source, copyRect, zeroPoint );
					
					k = 0;
					while ( k < iFramesOfRotation )
					{
						bmd.fillRect( bmdRect, 0x00000000 );
						bmd.draw( container, matrix );
						
						vFrames[k].push( bmd.clone() );
						
						bmpHolder.rotation += nDegToRot;
						
						k++;
					}
					j++;
				}
				i++;
			}

			// == END EXTRACTING
			
			// == DELETE DATA
			
			container.removeChild( bmpHolder );
			container = null;
			
			bmpHolder.removeChild( bitmap );
			bmpHolder = null;
			
			bitmap.bitmapData.dispose();
			
			bmd.dispose();
			bmd = null;
			bmdRect = null;
			matrix = null;
			copyRect = null;
			zeroPoint = null;


			// Tell everybody that we are done
 			dispatchEvent( new EventBitmapClip( EventBitmapClip.COMPLETE, this ) );
 		}

		/**
		 * Disposes of all data
		 * @param	bReleaseMemory Should we dipose of all bitmap data references?
		 */
		public function dispose( bReleaseMemory:Boolean = true ):void
		{
			if ( bReleaseMemory && curBitmapData )
			{
				curBitmapData.dispose();
			}
			
			if ( curBitmapDataTransformed )
			{
				curBitmapDataTransformed.dispose();
			}
			curBitmapDataTransformed = null;
			
			curBitmapData = null;

			curBitmapRect = null;
			curAnimIterator = null;
			ctColor = null;

			vAnims = null;
			vFrames = null;
		}
		
		/**
		 * Returns the current bitmap data.
		 */
		public function get bitmapData():BitmapData { return curBitmapData; }
		
		/**
		 * Returns the current bitmap data rectangle.
		 */
		public function get bitmapRect():Rectangle { return curBitmapRect; }

		/**
		 * Sets the frame rate of the clip.
		 */
 		public function set frameRate( fps:int ):void
		{
			if ( fps <= 0 )
			{
				iFrameRate = 0;
				iAnimDelay = 0;
				bIsStopped = true;
				return;
			}

			iFrameRate = fps;
			iAnimDelay = 1000 / fps;
			bIsStopped = false;
		}
		
		/**
		 * Returns the frame rate of the clip.
		 */
 		public function get frameRate():int { return iFrameRate; }

		/**
		 * Sets the rotation of the clip.
		 */
		public function set rotation( degree:int ):void
		{
			// Make sure value is between 0-360
			degree %= 360;
			if ( degree < 0 )
			{
				degree += 360;
			}

			iRotation = degree;
			curRotationFrame = Math.round( iRotation / nDegToRot );
			
			// We've reached the max frame, set to 0
			if ( curRotationFrame >= iFramesOfRotation )
			{
				curRotationFrame = 0;
			}

			// Update bitmap data
			bHasChanged = true;
		}
		
		/**
		 * Returns the rotation of the clip.
		 */
		public function get rotation():int { return iRotation; }
		
		/**
		 * Sets the current animation index.
		 */
		public function set currentAnimation( anim:int ):void
		{
			// No need to change animations, as there aren't any others
			if ( vAnims.length == 1 ) { return; }

			// Clamp animation index
			anim = MathUtil.Clamp( anim, 0, vAnims.length - 1 );

			// Set animation
			curAnim = anim;
			curAnimIterator = BitmapClipIterator( vAnims[ curAnim ] );

			// Update bitmap data
			bHasChanged = true;
		}
		
		/**
		 * Returns the current animation index.
		 */
		public function get currentAnimation():int { return curAnim; }
		
		/**
		 * Returns the total animations stored.
		 */
		public function get totalAnimations():int { return vAnims.length; }

		/**
		 * Returns the current frame.
		 */
 		public function get currentFrame():int { return curAnimIterator.currentFrame }

		/**
		 * Returns the total frames.
		 */
 		public function get totalFrames():int { return curAnimIterator.totalFrames; }
		
		/**
		 * Returns the width of the clip.
		 */
 		public function get width():int { return iWidth; }
		
		/**
		 * Sets the width of the clip.
		 * This can reduce preformance.
		 */
		public function set width( iSetWidth:int ):void
		{
			nScaleX = MathUtil.Clamp( iSetWidth / iWidth, 0, 10 );
		}
		
		/**
		 * Returns the height of the clip.
		 */
		public function get height():int { return iHeight; }
		
		/**
		 * Sets the height of the clip.
		 * This can reduce preformance.
		 */
		public function set height( iSetHeight:int ):void
		{
			nScaleY = MathUtil.Clamp( iSetHeight / iHeight, 0, 10 );
		}
		
		/**
		 * Returns the current X scale of the clip.
		 */
		public function get scaleX():Number { return nScaleX; }
		
		/**
		 * Sets the X scale of the clip.  You can only scale up to 10x.
		 * This can reduce preformance.
		 */
		public function set scaleX( nScale:Number ):void
		{
			nScaleX = MathUtil.Clamp( nScale, 0, 10 );
		}
		
		/**
		 * Returns the current Y scale of the clip.
		 */
		public function get scaleY():Number { return nScaleY; }
		
		/**
		 * Sets the Y scale of the clip.  You can only scale up to 10x.
		 * This can reduce preformance.
		 */
		public function set scaleY( nScale:Number ):void
		{
			nScaleY = MathUtil.Clamp( nScale, 0, 10 );
		}

		/**
		 * Returns the current X position of the clip.
		 */
		public function get x():int { return iPosX; }
		
		/**
		 * Sets the X position of the clip.
		 */
		public function set x( iPos:int ):void
		{
			iPosX = iPos;
		}

		/**
		 * Returns the current Y position of the clip.
		 */
		public function get y():int { return iPosY; }
		
		/**
		 * Sets the Y position of the clip.
		 */
		public function set y( iPos:int ):void
		{
			iPosY = iPos;
		}
		
		/**
		 * Sets the color transform of the clip.
		 */
		public function set colorTransform( transform:ColorTransform ):void
		{
			ctColor = transform;
		}
		
		/**
		 * Returns the color transform of the clip.
		 */
		public function get colorTransform():ColorTransform
		{
			return ctColor;
		}
 	}
}

import verlocity.utils.MathUtil;

internal class BitmapClipIterator extends Object
{
	private var iIndex:int;
	private var iStartIndex:int;
	private var iLastIndex:int;
	
	private var bIsAnimated:Boolean;
	private var iNumFrames:int;
	
	/**
	 * Creates a new bitmapclip iterator for frame counting
	 * @param	iStart
	 * @param	iNum
	 */
	public function BitmapClipIterator( iStart:int, iNum:int )
	{
		iStartIndex = MathUtil.Clamp( iStart, 0, iNum );
		iIndex = iStartIndex;
		iLastIndex = iNum + iStartIndex - 1;

		iNumFrames = iNum;
		
		if ( iNum > 1 )
		{
			bIsAnimated = true;
		}
	}
	
	/**
	 * Next frame
	 * @return
	 */
	public function next():int
	{
		iIndex++;
		
		if ( iIndex > iLastIndex )
		{
			iIndex = iStartIndex;
		}
		
		return iIndex;
	}
	
	/**
	 * Previous frame
	 * @return
	 */
	public function prev():int
	{
		iIndex--;
		
		if ( iIndex < iStartIndex )
		{
			iIndex = iLastIndex;
		}
		
		return iIndex;
	}
	
	/**
	 * Resets to the start index
	 */
	public function reset():void
	{
		iIndex = iStartIndex;
	}
	
	/**
	 * Returns the current frame
	 */
	public function get currentFrame():int
	{
		return iIndex - iStartIndex + 1;
	}
	
	/**
	 * Returns the total frames
	 */
	public function get totalFrames():int
	{
		return iNumFrames;
	}
	
	/**
	 * Creates a new iterator based on this one
	 */
	public function clone():BitmapClipIterator
	{
		return new BitmapClipIterator( iStartIndex, iLastIndex - iStartIndex );
	}
}