/*
 * ---------------------------------------------------------------
 * Verlocity
 * http://www.verlocityengine.com
 * 
 * This file is subject to the terms and conditions defined in
 * 'license.txt', which is part of this source code package.
 * ---------------------------------------------------------------
*/
package verlocity.events
{
	import flash.events.Event;
	import verlocity.display.BitmapClip;

	/**
	 * Handles the events of a BitmapClip
	 */
	public final class EventBitmapClip extends Event
	{
		public static const COMPLETE:String = "OnLoaded";
		private var bitmapClip:BitmapClip;

		/**
		 * Creates a bitmap clip event handler
		 * @param	type Event type
		 * @param	data Bitmapclip that had an event
		 */
		public function EventBitmapClip( type:String, data:BitmapClip ):void
		{
			bitmapClip = data;
			super( type );
		}
		
		/**
		 * Returns the bitmapclip that the event occured
		 */
		public function get bitmapclip():BitmapClip { return bitmapClip; }
	}
}