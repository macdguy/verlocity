/*
 * ---------------------------------------------------------------
 * Verlocity
 * http://www.verlocityengine.com
 * 
 * This file is subject to the terms and conditions defined in
 * 'license.txt', which is part of this source code package.
 * ---------------------------------------------------------------
*/
package verlocity.ents.effects
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;

	import verlocity.ents.DisplayEntity;
	import verlocity.utils.DisplayUtil;

	public class Effect extends DisplayEntity
	{
		protected var bNoAnimation:Boolean;
		private var attachment:DisplayObject;

		/**
		 * Returns the entity base class.
		 */
		public override function get baseClass():Object { return Effect; }
		
		/**
		 * Creates an effect.  An effect is a simple animation that plays then removes after full play-through.
		 * @param	mc The animated movieclip
		 */
		public function Effect( mc:MovieClip = null ):void
		{
			if ( mc )
			{
				display.SetDisplayObject( mc );
			}
			
			Play();
		}

		/**
		 * Updates the effect.
		 */
		public override function _Update():void
		{
			super._Update();

			if ( !bNoAnimation )
			{
				if ( totalFrames == 0 ) { Remove(); return; }

				EffectUpdate();
			}

			AttachmentUpdate();
		}
		
		/**
		 * Checks if the effect needs to be removed after the animation was played.
		 */
		private function EffectUpdate():void
		{
			if ( HasEnded() )
			{
				Stop();
				Remove();
			}
		}
		
		/**
		 * Updates the position of the effect to follow its attachment.
		 */
		private function AttachmentUpdate():void
		{
			if ( attachment )
			{
				SetPos( attachment.x, attachment.y );
			}
		}
		
		/**
		 * Sets the attachment object of this effect (the effect will follow its position).
		 * @param	newAttachment The display object
		 */
		public function SetAttachment( newAttachment:DisplayObject ):void
		{
			attachment = newAttachment;
		}
		
		/**
		 * Removes the attachment.
		 */
		public function RemoveAttachment():void
		{
			attachment = null;
		}

		/**
		 * Remove effect on reset.
		 */
		public override function Reset():void
		{
			super.Reset();

			Remove();
		}
	}
}