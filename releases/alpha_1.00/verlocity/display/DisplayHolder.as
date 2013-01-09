/*
 * ---------------------------------------------------------------
 * Verlocity
 * http://www.verlocityengine.com
 * 
 * This file is subject to the terms and conditions defined in
 * 'license.txt', which is part of this source code package.
 * ---------------------------------------------------------------
*/
package verlocity.display
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.display.Bitmap;
	import flash.geom.Rectangle;

	import verlocity.ents.DisplayEntity;
	import verlocity.utils.DisplayUtil;
	import verlocity.utils.ObjectUtil;

	/**
	 * The display holder class holds multiple display types for entities.
	 * 
	 * This class is used to make it easier to switch between different mediums on the go.
	 * 
	 * Using any of the set functions will override the original artwork medium.  It is suggested to call only one function
	 * to set the medium and artwork of the holder.
	 */
	public class DisplayHolder extends Object
	{
		private var ent:DisplayEntity // Entity that is using this
		private var dispSource:Class; // Source of display
		private var dispType:Class; // Type of display class
		private var rBounds:Rectangle = new Rectangle(); // Bounds of displays

		private var _dispObj:DisplayObject;
		
		/**
		 * Creates a new display holder.
		 * @param	parentEnt The display entity that is in control of this.
		 */
		public function DisplayHolder( parentEnt:DisplayEntity ):void
		{
			ent = parentEnt;
		}

		/**
		 * Sets native Flash DisplayObject as the main display.
		 * This will override all displays this holder contains.
		 * @param	dispObject The display object of this entity.
		 */
		public function SetDisplayObject( dispObject:DisplayObject ):void
		{
			if ( !dispObject ) { return; }
			
			// Remove current displays
			Dispose();

			// Get display source
			dispSource = ObjectUtil.GetClass( Object( dispObject ) );
			
			// Get display base (for DisplayIs)
			if ( dispObject is Shape ) { dispType = Shape; }
			if ( dispObject is Sprite ) { dispType = Sprite; }
			if ( dispObject is MovieClip ) { dispType = MovieClip; }
			if ( dispObject is Bitmap ) { dispType = Bitmap; }

			// Gather data
			ent.width = dispObject.width;
			ent.height = dispObject.height;
			ent.scaleX = dispObject.scaleX;
			ent.scaleY = dispObject.scaleY;
			ent.rotation = dispObject.rotation;
			rBounds = dispObject.getBounds( dispObject );
			
			// Set new display object
			_dispObj = dispObject;
			
			// Set to the entity position
			_dispObj.x = ent.x;
			_dispObj.y = ent.y;

			// Disable mouse children/button mode
			if ( IsMovieClip() )
			{
				MovieClip( _dispObj ).mouseEnabled = false;
				MovieClip( _dispObj ).mouseChildren = false;
				MovieClip( _dispObj ).buttonMode = false;
			}
				
			// Disable button mode
			if ( Is( Sprite ) )
			{
				Sprite( _dispObj ).buttonMode = false;
			}

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
			return Boolean( _dispObj );
		}

		/**
		 * Returns if the display is a movieclip.
		 * @return
		 */
		public function IsMovieClip():Boolean
		{
			return _dispObj && Is( MovieClip );
		}

		/**
		 * Returns if the display is a drawable DisplayObject.
		 * @return
		 */
		public function IsDrawable():Boolean
		{
			return _dispObj && ( Is( Sprite ) || Is( Shape ) || Is( MovieClip ) );
		}

		/**
		 * Disposes all display data.
		 */
		public function Dispose():void
		{
			if ( _dispObj )
			{
				DisplayUtil.RemoveFromParent( _dispObj );
				_dispObj = null;
			}

			dispSource = null;
			dispType = null;
		}

		/**
		 * Returns Flash display object.
		 */
		public function get displayObj():DisplayObject { return _dispObj; }

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