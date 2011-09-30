/*
	This file is subject to the terms and conditions defined in
    file 'license.txt', which is part of this source code package.
*/

package VerlocityEngine.base 
{
	import flash.display.MovieClip;

	public class verBMovieClip extends MovieClip
	{
		private var bIsPlaying:Boolean;
		private var wasPlaying:Boolean;
		
		public function verBMovieClip():void
		{
			bIsPlaying = true;
		}

		public override function play():void
		{
			super.play();

			bIsPlaying = true;
		}
		
		public override function stop():void
		{
			super.stop();

			bIsPlaying = false;
		}

		public function get playing():Boolean
		{
			return bIsPlaying;
		}
		
		public function pause():void
		{
			if ( playing ) { wasPlaying = true; }

			stop();
			pauseChildren( true );
		}
		
		public function resume():void
		{
			if ( wasPlaying )
			{
				play();
			}

			wasPlaying = false;
			pauseChildren( false );
		}
		
		private function pauseChildren( bPause:Boolean = true ):void
		{
			if ( numChildren <= 0 ) { return; }

			var i:int = 0;
			while ( i < numChildren )
			{
				if ( getChildAt( i ) is verBMovieClip )
				{
					var childvermc:verBMovieClip = verBMovieClip( getChildAt( i ) );

					if ( bPause )
					{
						childvermc.pause();
					}
					else
					{
						childvermc.resume();
					}

					childvermc = null;
				}
				else if ( getChildAt( i ) is MovieClip )
				{
					var childmc:MovieClip = MovieClip( getChildAt( i ) );
					
					if ( bPause )
					{
						childmc.stop();
					}
					else
					{
						if ( childmc.currentFrame > 0 && childmc.currentFrame != childmc.totalFrames )
						{
							childmc.play();
						}
					}
					
					childmc = null;					
				}

				i++;
			}
		}
	}
}