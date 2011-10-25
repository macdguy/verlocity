/*
	This file is subject to the terms and conditions defined in
    file 'license.txt', which is part of this source code package.
*/

package VerlocityEngine.base.ents
{
	import VerlocityEngine.Verlocity;
	import flash.display.DisplayObject;

	public class verBEffect extends verBEnt
	{
		private var effAttachment:DisplayObject;
		protected var bNoAnimation:Boolean;

		public override function InternalThink():void
		{
			super.InternalThink();

			if ( !bNoAnimation )
			{
				if ( totalFrames == 0 ) {  Remove(); return; }

				EffectThink();
			}

			AttachmentThink();
		}
		
		private function EffectThink():void
		{
			if ( totalFrames > 0 && ( currentFrame + 1 ) >= totalFrames )
			{
				stop();
				Remove();
			}	
		}
		
		private function AttachmentThink():void
		{
			if ( effAttachment )
			{
				SetPos( effAttachment.x, effAttachment.y );
			}
		}
		
		public function SetAttachment( newAttachment:DisplayObject ):void
		{
			effAttachment = newAttachment;
		}
		
		public function RemoveAttachment():void
		{
			effAttachment = null;
		}
	}
}