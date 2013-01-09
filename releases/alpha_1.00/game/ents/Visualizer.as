package game.ents 
{
	import fl.motion.Color;
	import flash.geom.ColorTransform;
	import verlocity.core.LinkedList;
	import verlocity.core.ListNode;

	import flash.display.Sprite;
	import flash.filters.GlowFilter;
	import flash.display.BlendMode;
	import flash.utils.ByteArray;
	import flash.media.SoundMixer;

	import verlocity.Verlocity;
	import verlocity.ents.DisplayEntity;
	import verlocity.utils.MathUtil;
	import verlocity.utils.ColorUtil;

	public class Visualizer extends DisplayEntity
	{
		private const iNumSprites:int = 60;
		private var llSpriteList:LinkedList;

		private var bytes:ByteArray;
		private var ct:ColorTransform;

		public override function Construct():void
		{
			display.SetDisplayObject( new Sprite() );

			llSpriteList = GenerateSpriteList();
			bytes = new ByteArray();
		}

		public override function Update():void
		{
            SoundMixer.computeSpectrum( bytes, false, 0 );

			var spr:Sprite = new Sprite();

			// Multiple sprite lists
			var node:ListNode = llSpriteList.head;
			while ( node )
			{
				var llList:LinkedList = node.data;
				var node2:ListNode = llList.head;
				
				while ( node2 )
				{
					spr = node2.data;

					// Update sprite
					var rf:Number = bytes.readFloat();
					var scale:Number = Math.max( 0.05, 1 + rf * 100 );

					spr.scaleX = scale;
					spr.scaleY = scale / ( 5 + 1 );
					
					//spr.alpha = MathHelper.Clamp( rf, .05, .1 );  // wastes render resources

					ct = new ColorTransform( 1, 1, 1, MathUtil.Clamp( rf, .15, .6 ) );
						ct.color = Color.interpolateColor( ColorUtil.RGBtoHEX( 130, 0, 162 ), ColorUtil.RGBtoHEX( 255, 0, 0 ), Verlocity.analyzer.AverageVolume );
					spr.transform.colorTransform = ct;

					spr.x += spr.x * rf * 2 + 4;
					
					// Next sprite
					node2 = node2.next;
				}
				
				// Next list
				node = node.next;
			}
		}

		private function GenerateSpriteList():LinkedList
		{
			var llSprites:LinkedList = new LinkedList();

			// Create sprite lists
			for ( var n:int; n < 4; n++ )
			{
				var llSpList:LinkedList = new LinkedList();
				
				// Create sprites
				for ( var i:int; i < iNumSprites; i++ )
				{
					var spr:Sprite = new Sprite();
						spr.graphics.beginFill( 0xFFFFFF );
						spr.blendMode = BlendMode.ADD;
						spr.graphics.drawRect( 0, 0, 5, 1 );
						spr.graphics.endFill();
						spr.y = Verlocity.ScrH / iNumSprites * i;
					addChild( spr );

					llSpList.push( spr );
				}

				llSprites.push( llSpList );
			}

			return llSprites;
		}
	}
}