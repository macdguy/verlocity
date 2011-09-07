/*
	=========================================
			   Verlocity Engine
	=========================================
	|	Developed by Macklin Guy, 2011.		|
	|										|
	|										|
	-----------------------------------------
	VerlocityPreloader.as
	-----------------------------------------
	This class handles the preloading of the
	game and its assets.
*/
package VerlocityEngine 
{
	import flash.events.Event;

	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;

	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.filters.BlurFilter;
	import flash.filters.GlowFilter;
	
	import flash.utils.getDefinitionByName;
	import flash.utils.getTimer;

	public class VerlocityPreloader extends MovieClip
	{
		[Embed(source = "VerlocityContent.swf", symbol = "LoadingWheel")] private var VerlocityLoadingWheel:Class;

		/*
		 *************VARIABLES***************
		*/
		protected var DocumentClass:String;

		private var iProgress:int;

		private const loadFormat:TextFormat = new TextFormat( "_sans", 24, 0xFFFFFF, true );
		private const loadFormatLoad:TextFormat = new TextFormat( "_sans", 18, 0xFFFFFF, true );
		private const loadFormatBytes:TextFormat = new TextFormat( "_sans", 10, 0xFFFFFF );

		private var tfLoadPercent:TextField;
		private var tfLoadText:TextField;
		private var tfLoadBytes:TextField;

		private var sprLoadingBars:Shape;
		private var sprLoadingBarsUnder:Shape;
		private var sprLoadingFill:Shape;

		private var loadingGraphicWheel:Sprite;
		private var fBlur:BlurFilter;
		private var fGlow:GlowFilter;


		/*
		 *************CREATION***************
		*/
		public function VerlocityPreloader():void
		{
			stop();
			CreateLoadGUI();
			
			addEventListener( Event.ENTER_FRAME, Think );
		}

		private function Think( e:Event ):void
		{
            if ( framesLoaded >= totalFrames )
            {
				removeEventListener( Event.ENTER_FRAME, Think );
				RemoveLoadGUI();

                nextFrame();

				StartDocumentClass();
				
				return;
            }

			UpdateLoadGUI();
		}
		
		private function StartDocumentClass():void
		{
			var docClass:Class = getDefinitionByName( DocumentClass ) as Class;

			if ( docClass )
			{
				var doc:Object = new docClass( stage );
			}
		}
		
		protected function CreateLoadGUI():void
		{
			// Loading text
			tfLoadText = new TextField();
				tfLoadText.defaultTextFormat = loadFormatLoad; tfLoadText.selectable = false;
				tfLoadText.text = "LOADING";
				tfLoadText.width = tfLoadText.textWidth + 5;
			tfLoadText.y = ( stage.stageHeight / 2 ) - 45;
			tfLoadText.x = ( stage.stageWidth / 2 ) - ( tfLoadText.width / 2 );
			
			fGlow = new GlowFilter( 0x222222, 1, 12, 12, 4 );
			tfLoadText.filters = [ fGlow ];
			
			
			// Loading percent text
			tfLoadPercent = new TextField();
				tfLoadPercent.defaultTextFormat = loadFormat; tfLoadPercent.selectable = false;
			tfLoadPercent.y = ( stage.stageHeight / 2 ) + 10;
			

			// Loading bytes text
			tfLoadBytes = new TextField();
				tfLoadBytes.defaultTextFormat = loadFormatBytes; tfLoadBytes.selectable = false;
			tfLoadBytes.y = ( stage.stageHeight / 2 ) + 35;


			// Loading graphic
			loadingGraphicWheel = new VerlocityLoadingWheel();
			loadingGraphicWheel.x = ( stage.stageWidth / 2 ); loadingGraphicWheel.y = ( stage.stageHeight / 2 ) - 35;
			
			fBlur = new BlurFilter();
			

			// Bars (to be masked)
			sprLoadingBars = new Shape();
				sprLoadingBars.graphics.beginFill( 0xFFFFFF );
					for ( var i:int = 0; i < 10; i++ )
					{
						sprLoadingBars.graphics.drawRect( i * 12, 0, 10, 10 );
					}
				sprLoadingBars.graphics.endFill();			
			sprLoadingBars.y = ( stage.stageHeight / 2 );
			sprLoadingBars.x = ( stage.stageWidth / 2 ) - ( sprLoadingBars.width / 2 );
			

			// Bars under
			sprLoadingBarsUnder = new Shape();
				sprLoadingBarsUnder.graphics.beginFill( 0x888888 );
					for ( i = 0; i < 10; i++ )
					{
						sprLoadingBarsUnder.graphics.drawRect( i * 12, 0, 10, 10 );
					}
				sprLoadingBarsUnder.graphics.endFill();
			sprLoadingBarsUnder.y = sprLoadingBars.y; sprLoadingBarsUnder.x = sprLoadingBars.x;
			

			// Fill rect
			sprLoadingFill = new Shape();
				sprLoadingFill.graphics.beginFill( 0xFFFFFF );
					sprLoadingFill.graphics.drawRect( 0, 0, 120, 10 );
				sprLoadingFill.graphics.endFill();
			sprLoadingFill.y = sprLoadingBars.y; sprLoadingFill.x = sprLoadingBars.x;
			sprLoadingFill.mask = sprLoadingBars;


			// Add
			addChild( loadingGraphicWheel );
			addChild( tfLoadText );
			addChild( tfLoadPercent );
			addChild( tfLoadBytes );

			addChild( sprLoadingBarsUnder );
			addChild( sprLoadingFill );
			addChild( sprLoadingBars );
		}

		protected function UpdateLoadGUI():void
		{
			iProgress = Math.round( ( loaderInfo.bytesLoaded / loaderInfo.bytesTotal ) * 100 );

			// Update text
			tfLoadPercent.text = iProgress + "%";
			tfLoadPercent.width = tfLoadPercent.textWidth + 5;
			tfLoadPercent.x = ( stage.stageWidth / 2 ) - ( tfLoadPercent.width / 2 );
			
			tfLoadText.alpha = ( Math.sin( getTimer() / 500 ) * 1 ) + 1.5;
			
			//tfLoadBytes.text = BytesToString( loaderInfo.bytesLoaded ) + " / " + BytesToString( loaderInfo.bytesTotal );
			tfLoadBytes.width = tfLoadBytes.textWidth + 5;
			tfLoadBytes.x = ( stage.stageWidth / 2 ) - ( tfLoadBytes.width / 2 );
			
			// Update load bars
			sprLoadingFill.width = ( loaderInfo.bytesLoaded / loaderInfo.bytesTotal ) * sprLoadingBars.width;

			// Rotation of wheel
			loadingGraphicWheel.rotation += iProgress * .1;
				fBlur.blurX = iProgress * .01;
				fBlur.blurY = iProgress * .01;
				fBlur.quality = 3;
			loadingGraphicWheel.filters = [ fBlur ];
		}
		
		protected function RemoveLoadGUI():void
		{
			for ( var i:int = 0; i < numChildren; i++ )
			{
				removeChildAt( i );
				i--;
			}

			tfLoadText = null; 
			tfLoadPercent = null; 
			tfLoadBytes = null; 
			sprLoadingBars = null;
			sprLoadingBarsUnder = null;
			sprLoadingFill = null;
			loadingGraphicWheel = null;

			fBlur = null;
			fGlow = null;
		}
	}
}