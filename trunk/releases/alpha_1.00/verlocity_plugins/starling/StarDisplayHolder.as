/*
 * ---------------------------------------------------------------
 * Verlocity
 * http://www.verlocityengine.com
 * 
 * This file is subject to the terms and conditions defined in
 * 'license.txt', which is part of this source code package.
 * ---------------------------------------------------------------
*/
package verlocity_plugins.starling
{
	import flash.geom.Rectangle;
	import flash.display.Bitmap;

	import starling.display.DisplayObject;
	import starling.display.MovieClip;
	import starling.display.Image;
	import starling.textures.Texture;

	import verlocity_plugins.starling.StarDisplayEntity;

	/**
	 * The display holder class holds multiple display types for entities.
	 * 
	 * This class is used to make it easier to switch between different mediums on the go.
	 * 
	 * Using any of the set functions will override the original artwork medium.  It is suggested to call only one function
	 * to set the medium and artwork of the holder.
	 */
	public class StarDisplayHolder extends Object
	{
		private var ent:StarDisplayEntity // Entity that is using this
		private var dispSource:Class; // Source of display
		private var dispType:Class; // Type of display class
		private var rBounds:Rectangle = new Rectangle(); // Bounds of displays

		private var _displayObj:DisplayObject;
		
		/**
		 * Creates a new display holder.
		 * @param	parentEnt The display entity that is in control of this.
		 */
		public function StarDisplayHolder( parentEnt:StarDisplayEntity ):void
		{
			ent = parentEnt;
		}

		/**
		 * Sets Starling Image as the main display.
		 * This will override all displays this holder contains.
		 * @param	embedClass The class for an embeded bitmap asset.
		 */
		public function SetTexture( embedClass:Class ):void
		{
			var data:Object = new embedClass();
			
			if ( data is Bitmap )
			{
				SetDisplayObject( Image.fromBitmap( data as Bitmap ) );
			}
		}

		/**
		 * Sets a Starling display object to the display.
		 * This is only used internally.
		 * @param	dispObject
		 */
		private function SetDisplayObject( dispObject:DisplayObject ):void
		{
			if ( !dispObject ) { return; }
			
			// Remove current displays
			Dispose();
			
			// Get display base (for DisplayIs)
			if ( dispObject is Image ) { dispType = Image; }
			if ( dispObject is MovieClip ) { dispType = MovieClip; }

			// Gather data
			ent.width = dispObject.width;
			ent.height = dispObject.height;
			ent.scaleX = dispObject.scaleX;
			ent.scaleY = dispObject.scaleY;
			ent.rotation = dispObject.rotation;
			rBounds = dispObject.getBounds( dispObject );
			
			// Set new display object
			_displayObj = dispObject;
			
			// Set to the entity position
			_displayObj.x = ent.x;
			_displayObj.y = ent.y;

			// Setup collision
			if ( dispType )
			{
				ent.SetupCollision();
			}
		}

		/**
		 * Returns if the display is a specified base class.
		 * @param	cClassName The class to check if the display matches
		 */
		public function Is( cClassName:Class ):Boolean
		{
			return dispType == cClassName;
		}
		
		/**
		 * Returns if the display holder has a proper valid display.
		 * @return
		 */
		public function IsValid():Boolean
		{
			return Boolean( _displayObj );
		}

		/**
		 * Returns if the display is a starling movieclip.
		 * @return
		 */
		public function IsMovieClip():Boolean
		{
			return _displayObj && Is( MovieClip );
		}

		/**
		 * Returns if the display is a starling transformable.
		 * @return
		 */
		public function IsTransformable():Boolean
		{
			return _displayObj && ( Is( MovieClip ) || Is( Image ) );
		}

		/**
		 * Disposes all display data.
		 */
		public function Dispose():void
		{	
			if ( _displayObj )
			{
				_displayObj.removeFromParent( true );
				_displayObj = null;
			}

			dispSource = null;
			dispType = null;
		}

		/**
		 * Returns Starling display object.
		 */
		public function get displayObj():DisplayObject { return _displayObj; }

		/**
		 * Returns the artwork source class name
		 */
		public function get sourceClass():Class { return dispSource; }

		/**
		 * Returns the display type class
		 */
		public function get type():Class { return dispType; }

		/**
		 * Returns the bounds of the display
		 */
		public function get bounds():Rectangle { return rBounds; }
	}
}