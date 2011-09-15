/*
	=========================================
			   Verlocity Engine
	=========================================
	|	Developed by Macklin Guy, 2011.		|
	|										|
	|										|
	-----------------------------------------
	verLayers.as
	-----------------------------------------
	This class stores and handles all the layers.
*/
package VerlocityEngine.components 
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;
	import flash.geom.Point;

	import VerlocityEngine.Verlocity;
	import VerlocityEngine.VerlocityLanguage;
	import VerlocityEngine.VerlocitySettings;
	import VerlocityEngine.base.verBLayer;

	public class verLayers
	{
		//********* VERLOCITY COMPONENT HEADER *********//
		/************************************************/
		public function IsValid():Boolean { return wasCreated; }
		private var wasCreated:Boolean;
		
		public function verLayers():void
		{
			if ( wasCreated ) { throw new Error( VerlocityLanguage.T( "ComponentLoadFail" ) ); return; } wasCreated = true;
			Construct();
		}
		/************************************************/
		/************************************************/
		
		/*
		 ****************COMPONENT VARS******************
		*/
		internal var layerVerlocity:Sprite;
		internal var layerUI:Sprite;

		internal var layerContained:Sprite;
		internal const sCutoff:Shape = new Shape();
		internal var layerScrFX:Sprite;

		internal var layerMain:Sprite;
		internal var layerState:Sprite;

		private var sprBackground:Sprite;

		private var objLayers:Object;
		
		
		/*
		 **************COMPONENT CREATION****************
		*/
		private function Construct():void
		{
			objLayers = new Object();

			// Cutoff mask
			sCutoff.graphics.beginFill( 0, 0 );
				sCutoff.graphics.drawRect( 0, 0, Verlocity.ScrW, Verlocity.ScrH );
			sCutoff.graphics.endFill();
			Verlocity.stage.addChildAt( sCutoff, 0 );

			// Container layer
			layerContained = new Sprite();
			layerContained.mask = sCutoff;
			Verlocity.stage.addChildAt( layerContained, 0 );

			// Verlocity layer for verConsole, verAchievements, VerlocityMessages, and splash.
			layerVerlocity = new Sprite();
			layerContained.addChildAt( layerVerlocity, 0 );

			// UI layer for verUI
			layerUI = new Sprite();
				layerUI.graphics.beginFill( 0x000000, 0 );
					layerUI.graphics.drawRect( 0, 0, Verlocity.ScrW, Verlocity.ScrH );
				layerUI.graphics.endFill();
			layerContained.addChildAt( layerUI, 0 );

			// ScreenFX layer for verScreenFX
			layerScrFX = new Sprite();
			layerContained.addChildAt( layerScrFX, 0 );


			// -- START OF USER CONTROLLED --

				// Main layer for anything not part of the camera.
				layerMain = new Sprite();
				layerContained.addChildAt( layerMain, 0 );

				// verCamera support.
				layerContained.addChildAt( Verlocity.camera.Get(), 0 );
				layerContained.addChildAt( Verlocity.camera.GetView(), 0 );

			// -- END OF USER CONTROLLED --


			// Layer for states (ie. cutscenes).
			layerState = new Sprite();
			layerContained.addChildAt( layerState, 0 );

			// Background
			sprBackground = new Sprite();
				BGColor( VerlocitySettings.BGCOLOR );
			Verlocity.stage.addChildAt( sprBackground, 0 );
		}

		/*
		 *************COMPONENT FUNCTIONS***************
		*/
		
		/*------------------ PRIVATE ------------------*/
		/*------------------ PUBLIC -------------------*/
		public function Create( sName:String, layer:verBLayer = null, bAddToCamera:Boolean = true, iPosX:int = 0, iPosY:int = 0 ):verBLayer
		{
			if ( objLayers[sName] != null )
			{
				Verlocity.Trace( "Layers", VerlocityLanguage.T( "GenericDuplicate" ) );
				return null;
			}

			if ( layer == null )
			{
				layer = new verBLayer();
			}
			else
			{
				Verlocity.ents.RegisterContained( layer );
			}

			objLayers[sName] = layer;
			objLayers[sName].name = sName;
			
			objLayers[sName].x = iPosX;
			objLayers[sName].y = iPosY;


			if ( bAddToCamera )
			{
				Verlocity.camera.Add( objLayers[sName], true );
			}
			else
			{
				layerMain.addChildAt( objLayers[sName], 0 );
			}

			Verlocity.Trace( "Layers", sName + VerlocityLanguage.T( "GenericAddSuccess" ) );
			
			return objLayers[sName];
		}

		public function Get( sName:String ):verBLayer
		{
			return objLayers[sName];
		}
		
		public function Insert( obj:DisplayObject, sName:String ):void
		{
			if ( objLayers[sName] == null )
			{
				Verlocity.Trace( "Layers", sName + VerlocityLanguage.T( "GenericMissing" ) );
				return;
			}

			objLayers[sName].addChild( obj );
		}
		
		public function Remove( sName:String ):void
		{
			if ( objLayers[sName] == null )
			{
				Verlocity.Trace( "Layers", sName + VerlocityLanguage.T( "GenericMissing" ) );
				return;
			}

			if ( objLayers[sName].parent )
			{
				objLayers[sName].parent.removeChild( objLayers[sName] );
			}

			delete objLayers[sName];
			objLayers[sName] = null;
			
			Verlocity.Trace( "Layers", VerlocityLanguage.T( "GenericRemove" ) + sName );
		}
		
		public function RemoveAll():void
		{
			for ( var currentLayer:String in objLayers )
			{
				if ( objLayers[currentLayer] && objLayers[currentLayer].parent )
				{
					objLayers[currentLayer].parent.removeChild( objLayers[currentLayer] );
				}
			}

			objLayers = new Object();
			
			Verlocity.Trace( "Layers", VerlocityLanguage.T( "GenericRemoveAll" ) );
		}
		
		public function BGColor( uiColor:uint, nAlpha:Number = 1 ):void
		{
			sprBackground.graphics.clear();
			
			sprBackground.graphics.beginFill( uiColor, nAlpha );
				sprBackground.graphics.drawRect( 0, 0, Verlocity.ScrW, Verlocity.ScrH );
			sprBackground.graphics.endFill();
		}
		
		public function SendToTop( sName:String ):void
		{
			if ( objLayers[sName] == null )
			{
				Verlocity.Trace( "Layers", sName + VerlocityLanguage.T( "GenericMissing" ) );
				return;
			}

			objLayers[sName].parent.setChildIndex( objLayers[sName], 0 );
		}
		
		public function Parallax( aLayers:Array, nScrollX:Number = 0.0, nScrollY:Number = 0.0, nScrollZ:Number = 0.0 ):void
		{
			if ( aLayers.length < 2 ) { return; }

			// Check if the first exists
			if ( objLayers[ aLayers[0] ] == null )
			{
				Verlocity.Trace( "Layers", objLayers[ aLayers[0] ] + VerlocityLanguage.T( "GenericMissing" ) );
				return;
			}

			// Offset the first
			objLayers[ aLayers[0] ].x -= nScrollX;
			objLayers[ aLayers[0] ].y -= nScrollY;
			
			// Get the correct current center position
			var pCenterScr:Point = new Point( Verlocity.ScrW / 2, Verlocity.ScrH / 2 );
			
			// Get the localized version of the position
			var pCenter:Point = objLayers[ aLayers[0] ].globalToLocal( pCenterScr );
			ScaleLayer( aLayers[0], nScrollZ, pCenter.x, pCenter.y );

			// Offset the rest
			for ( var i:int = 1; i < aLayers.length; i++ )
			{
				// Check if the layers are valid
				if ( objLayers[ aLayers[i] ] == null )
				{
					Verlocity.Trace( "Layers", objLayers[ aLayers[i] ] + VerlocityLanguage.T( "GenericMissing" ) );
					return;
				}
				
				objLayers[ aLayers[i] ].x -= nScrollX / ( i + 1 );
				objLayers[ aLayers[i] ].y -= nScrollY / ( i + 1 );

				// Get the localized version of the position
				pCenter = objLayers[ aLayers[i] ].globalToLocal( pCenterScr );
				ScaleLayer( aLayers[i], nScrollZ / ( i + 1 ), pCenter.x, pCenter.y );
			}
		}
		
		public function ScaleLayer( sName:String, nAddScale:Number, iCenterX:int, iCenterY:int ):void
		{
			if ( nAddScale == 0 ) { return; }

			if ( objLayers[sName] == null )
			{
				Verlocity.Trace( "Layers", sName + VerlocityLanguage.T( "GenericMissing" ) );
				return;
			}
			
			objLayers[sName].ScaleAround( iCenterX, iCenterY,
										  objLayers[sName].scaleX + nAddScale,
										  objLayers[sName].scaleY + nAddScale );
		}
		
		public function Scroll( sName:String, nScrollX:Number = 0, iScrollWidth:int = 0, nScrollY:Number = 0, iScrollHeight:int = 0 ):void
		{
			if ( objLayers[sName] == null )
			{
				Verlocity.Trace( "Layers", sName + VerlocityLanguage.T( "GenericMissing" ) );
				return;
			}

			objLayers[sName].x -= nScrollX;
			if ( iScrollWidth > 0 && objLayers[sName].x <= -iScrollWidth )
			{
				objLayers[sName].x = 0;
			}

			objLayers[sName].y -= nScrollY;
			if ( iScrollHeight > 0 && objLayers[sName].y <= -iScrollHeight )
			{
				objLayers[sName].y = 0;
			}
		}
	}
}