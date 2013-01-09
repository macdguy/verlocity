/*
 * ---------------------------------------------------------------
 * Verlocity
 * http://www.verlocityengine.com
 * 
 * This file is subject to the terms and conditions defined in
 * 'license.txt', which is part of this source code package.
 * ---------------------------------------------------------------
*/
package verlocity.display.gui
{
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import verlocity.utils.DisplayUtil;

	import flash.utils.getTimer;

	import verlocity.Verlocity;

	public class RealTimeStats extends Sprite
	{	
		private var iDelay:int;

		private var fpsFormat:TextFormat = new TextFormat( "_sans", 24, 0xFFFFFF );
		private var fpsText:TextField;

		private var statFormat:TextFormat = new TextFormat( "_sans", 10, 0xFFFFFF );
		private var statText:TextField;
		
		private var sprAnalyzer:Sprite;

		private var nBeat:Number = 0;

		public function RealTimeStats( sStage:Stage ):void
		{
			// FPS (top left)
			fpsText = new TextField();
				fpsText.x = 15; fpsText.y = 10;
				fpsText.width = 30; fpsText.height = 28;
				fpsText.selectable = false; fpsText.defaultTextFormat = fpsFormat;
				fpsText.background = true; fpsText.backgroundColor = 0x000000;
			sStage.addChild( fpsText );

			// Stats
			statText = new TextField();
				statText.width = 100; statText.height = 125;
				statText.x = Verlocity.ScrW - statText.width - 5; statText.y = 1;
				statText.selectable = false; statText.defaultTextFormat = statFormat;
				statText.background = true; statText.backgroundColor = 0x222222;
			addChild( statText );
			
			// Analyzer
			sprAnalyzer = new Sprite();
				sprAnalyzer.x = statText.x;	sprAnalyzer.y = 44;
			addChild( sprAnalyzer );
			
			graphics.beginFill( 0xFFCC00 );
				graphics.drawRect( Verlocity.ScrW - statText.width - 6, 0, 1, 125 );
			graphics.endFill();

			addEventListener( Event.ENTER_FRAME, Update );
		}
		
		/**
		 * Updates the real-time stats.
		 * @param	e
		 */
		private function Update( e:Event ):void
		{
			if ( Verlocity.IsValid( Verlocity.stats ) )
			{
				fpsText.text = String( Verlocity.stats.FPS );
			}

			// Only update when visible
			if ( !visible ) { return; }

			var sFormattedText:String = "";

			// Stats (FPS, Memory, MS)
			if ( Verlocity.IsValid( Verlocity.stats ) )
			{
				sFormattedText = "FPS: " + Verlocity.stats.FPS + " / " + 
										   Verlocity.settings.FRAMERATE + "\n" +
								 "MEM: " + Verlocity.stats.Memory + "\n" + 
								 "MS: " + Verlocity.stats.MS + "\n";
			}
			
			// State
			if ( Verlocity.IsValid( Verlocity.state ) )
			{
				sFormattedText = sFormattedText +
								 "State: " + Verlocity.state.GetName() + "\n";
			}
			
			// Entities
			if ( Verlocity.IsValid( Verlocity.ents ) )
			{
				sFormattedText = sFormattedText +
								 "Entities: " + Verlocity.ents.CountAll() + "\n";
			}
			
			// Sound
			if ( Verlocity.IsValid( Verlocity.sound ) )
			{
				sFormattedText = sFormattedText +
								 "Sounds: " + Verlocity.sound.CountAll() + "\n";
			}
			
			// Soundscape
			if ( Verlocity.IsValid( Verlocity.soundscape ) )
			{
				sFormattedText = sFormattedText +
								 "SScape: " + Verlocity.soundscape.GetName() + "\n";
			}

			// Sound analyzer
			if ( Verlocity.IsValid( Verlocity.analyzer ) )
			{
				if ( !Verlocity.analyzer._IsNotUpdating() )
				{
					sFormattedText = sFormattedText +
										"Beat: ";

					// Analyzer
					sprAnalyzer.graphics.clear();

					// Beat
					sprAnalyzer.graphics.beginFill( 0xFFFFFF );
						if ( Verlocity.analyzer.Beat() )
						{
							nBeat = 1;
							sprAnalyzer.graphics.beginFill( 0xFF0000 );
						} 
						else
						{
							if ( nBeat > 0 ) { nBeat -= .05 }
						}
						sprAnalyzer.graphics.drawRect( 30, 55, 40 * nBeat, 5 );
					sprAnalyzer.graphics.endFill();

					// FFT
					sprAnalyzer.graphics.beginFill( 0xFFFFFF );
						var i:int = 0;
						while ( i < Verlocity.analyzer.GetFrequency().length )
						{
							sprAnalyzer.graphics.drawRect( 8 + ( 2 * i ), 80, 1, -10 * Verlocity.analyzer.GetFrequency()[i] );
							i++;
						}
					sprAnalyzer.graphics.endFill();
				}
				else
				{				
					sFormattedText = sFormattedText +
									"Analyzer off!";

					sprAnalyzer.graphics.clear();
				}
			}

			// Update text
			statText.text = sFormattedText;
		}
		
		/**
		 * Clears all data related to the real-time stats.
		 */
		public function Dispose():void
		{
			iDelay = NaN;

			DisplayUtil.RemoveFromParent( fpsText );
			fpsText = null;
			fpsFormat = null;

			statText = null;
			statFormat = null;
			
			sprAnalyzer = null;
			nBeat = NaN;

			removeEventListener( Event.ENTER_FRAME, Update );
		}
	}
}