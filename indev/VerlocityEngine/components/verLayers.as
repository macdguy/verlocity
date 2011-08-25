/*
	=========================================
			   Verlocity Engine
	=========================================
	|	Developed by Macklin Guy, 2011.		|
	|										|
	|										|
	-----------------------------------------
	verScreen.as
	-----------------------------------------
	This class stores and handles all the layers.
*/
package VerlocityEngine.components 
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.ColorTransform;

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

			// Verlocity layer for verConsole, verAchievements, VerlocityMessages, and splash.
			layerVerlocity = new Sprite();
			Verlocity.stage.addChildAt( layerVerlocity, 0 );

			// UI layer for verUI
			layerUI = new Sprite();
				layerUI.graphics.beginFill( 0x000000, 0 );
					layerUI.graphics.drawRect( 0, 0, Verlocity.ScrW, Verlocity.ScrH );
				layerUI.graphics.endFill();
			Verlocity.stage.addChildAt( layerUI, 0 );

			// ScreenFX layer for verScreenFX
			layerScrFX = new Sprite();
			Verlocity.stage.addChildAt( layerScrFX, 0 );


			// -- START OF USER CONTROLLED --

				// Main layer for anything not part of the camera.
				layerMain = new Sprite();
				Verlocity.stage.addChildAt( layerMain, 0 );

				// verCamera support.
				Verlocity.stage.addChildAt( Verlocity.camera.Get(), 0 );
				Verlocity.stage.addChildAt( Verlocity.camera.GetView(), 0 );

			// -- END OF USER CONTROLLED --


			// Layer for states (ie. cutscenes).
			layerState = new Sprite();
			Verlocity.stage.addChildAt( layerState, 0 );

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
		public function Create( sName:String, layer:verBLayer = null, bAddToCamera:Boolean = true, iPosX:int = 0, iPosY:int = 0 )
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
			Get( sName ).addChild( obj );
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
		
		public function ListAllLayers():void
		{
			for ( var i:int = 0; i < Verlocity.stage.numChildren; i++ )
			{
				Verlocity.Trace( "Layers", Verlocity.stage.getChildAt( i ).toString() );
			}
		}
		
		public function SendToTop( layer:verBLayer ):void
		{
			layer.parent.setChildIndex( layer, 0 );
		}
	}
}