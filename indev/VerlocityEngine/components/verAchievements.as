/*
	=========================================
			   Verlocity Engine
	=========================================
	|	Developed by Macklin Guy, 2011.		|
	|										|
	|										|
	-----------------------------------------
	verAchievements.as
	-----------------------------------------
	This component handles achievements.
*/
package VerlocityEngine.components 
{
	import VerlocityEngine.Verlocity;
	import VerlocityEngine.VerlocityLanguage;

	public class verAchievements extends Object
	{
		//********* VERLOCITY COMPONENT HEADER *********//
		/************************************************/
		public function IsValid():Boolean { return wasCreated; }
		private var wasCreated:Boolean;
		
		public function verAchievements():void
		{
			if ( wasCreated ) { throw new Error( VerlocityLanguage.T( "ComponentLoadFail" ) ); return; } wasCreated = true;
			Construct();
			Concommands();
		}
		/************************************************/
		/************************************************/
		
		/*
		 ****************COMPONENT VARS******************
		*/
		private var objAcheivements:Object;

		private const ACHI_DISPNAME:int = 0;
		private const ACHI_DESC:int = 1;
		private const ACHI_DATA:int = 2;
		private const ACHI_MAX:int = 3;
		private const ACHI_UNLOCKED:int = 4;
		
		
		/*
		 **************COMPONENT CREATION****************
		*/
		private function Construct():void
		{
			objAcheivements = new Object();
		}

		/*
		 *************COMPONENT CONCOMMANDS**************
		*/
		private function Concommands():void
		{
			if ( !Verlocity.console ) { return; }

			Verlocity.console.Register( "achi_set", function( achievement:String ):void
			{
				if ( !Get( achievement ) ) { Verlocity.console.Output( "Achievement not valid.  Use achi_list to list all." ); return; }
				if ( IsUnlocked( achievement ) ) { Verlocity.console.Output( "Achievement already unlocked!" ); return; }

				Set( achievement );
			}, "Unlock an achievement." );

			Verlocity.console.Register( "achi_info", function( achievement:String ):void
			{
				if ( !Get( achievement ) ) { Verlocity.console.Output( "Achievement not valid.  Use achi_list to list all." ); return; }

				Verlocity.console.Output( "Achievement: " + Get( achievement )[ ACHI_DISPNAME ] + " | " +
					GetValue( achievement ) + "/" + GetRequired( achievement ) + " | " +
					Get( achievement )[ ACHI_DESC ] );
				
			}, "Gets information about an achievement." );

			Verlocity.console.Register( "achi_list", function():void
			{
				var aList:Array = new Array();

				for ( var sAchievement:String in objAcheivements )
				{
					aList.push( sAchievement );
				}

				Verlocity.console.Output( "Achievements: " + aList.toString() );

				aList.length = 0; aList = null;
			}, "Lists all the registered achievements." );
		}
		
		
		/*
		 *************COMPONENT FUNCTIONS****************
		*/
		
		/*------------------ PRIVATE ------------------*/		
		private function AchievementUnlocked( sName:String ):void
		{
			objAcheivements[sName][ ACHI_UNLOCKED ] = true;
			
			var sDisplayName:String = objAcheivements[sName][ ACHI_DISPNAME ];
			var sDesc:String = objAcheivements[sName][ ACHI_DESC ];

			Verlocity.layers.layerVerlocity.addChild( new verGUIAchievement( sDisplayName, sDesc ) );

			Verlocity.Trace( "Achievements", "Achievement unlocked! " + sDisplayName );
		}

		private function CheckAchievementStatus( sName:String ):void
		{
			if ( objAcheivements[sName][ ACHI_DATA ] >= objAcheivements[sName][ ACHI_MAX ] )
			{
				AchievementUnlocked( sName );
			}
		}
		
		private function IsValidAch( sName:String ):Boolean
		{
			// Check if the achievement exists.
			if ( objAcheivements[sName] == null )
			{
				return false;
			}

			// Check if we already unlocked the achievement.
			if ( objAcheivements[sName][ ACHI_UNLOCKED ] )
			{
				return false;
			}

			return true;
		}


		/*------------------ PUBLIC -------------------*/
		public function Register( sName:String, sDisplayName:String, sDesc:String, iUnlocksAt:int = 1 ):void
		{
			if ( objAcheivements[sName] != null )
			{
				Verlocity.Trace( "Achievements", VerlocityLanguage.T( "GenericDuplicate" ) );
				return;
			}

			objAcheivements[sName] = new Array( sDisplayName, sDesc, 0, iUnlocksAt, false );
			
			Verlocity.Trace( "Achievements", sName + VerlocityLanguage.T( "GenericAddSuccess" ) );
		}

		public function Unlock( sName:String ):void
		{
			if ( !IsValidAch( sName ) ) { return; }

			objAcheivements[sName][ ACHI_DATA ] = objAcheivements[sName][ ACHI_MAX ];
			AchievementUnlocked( sName );
		}

		public function Set( sName:String, iAmount:int = 1 ):void
		{
			if ( !IsValidAch( sName ) ) { return; }

			objAcheivements[sName][ ACHI_DATA ] = iAmount;
			CheckAchievementStatus( sName );
		}

		public function Increase( sName:String, iAmount:int = 1 ):void
		{
			if ( !IsValidAch( sName ) ) { return; }

			var oldData:int = objAcheivements[sName][ ACHI_DATA ];
			objAcheivements[sName][ ACHI_DATA ] = oldData + iAmount;

			CheckAchievementStatus( sName );
		}

		public function Reset( sName:String ):void
		{
			if ( !IsValidAch( sName ) ) { return; }
			
			objAcheivements[sName][ ACHI_DATA ] = 0;
			objAcheivements[sName][ ACHI_UNLOCKED ] = false;
		}
		
		public function IsUnlocked( sName:String ):Boolean
		{
			if ( objAcheivements[sName] == null ) { return false; }
			
			return objAcheivements[sName][ ACHI_UNLOCKED ];
		}
		
		public function GetValue( sName:String ):int
		{
			if ( objAcheivements[sName] == null ) { return -1; }

			return objAcheivements[sName][ ACHI_DATA ];
		}
		
		public function GetRequired( sName:String ):int
		{
			if ( objAcheivements[sName] == null ) { return -1; }

			return objAcheivements[sName][ ACHI_MAX ];
		}
		
		public function GetPercent( sName:String ):Number
		{
			if ( objAcheivements[sName] == null ) { return 0; }

			return objAcheivements[sName][ ACHI_DATA ] / objAcheivements[sName][ ACHI_MAX ];
		}
		
		public function Get( sName:String ):Array
		{
			return objAcheivements[sName];
		}
	}
}


import flash.display.Sprite;
import flash.events.Event;

import flash.text.TextField;
import flash.text.TextFormat;
import flash.utils.getTimer;

import VerlocityEngine.Verlocity;

internal class verGUIAchievement extends Sprite
{
	private const txtFormat:TextFormat = new TextFormat( "Arial Bold", 24 );
	private var iLifeTime:int;

	public function verGUIAchievement( sName:String, sDesc:String ):void
	{
		var iWidth:int = 255;
		var iHeight:int = 75;

		x = Verlocity.ScrW - iWidth;
		y = Verlocity.ScrH - iHeight;

		graphics.beginFill( 0x333333, .5 );
			graphics.drawRect( 0, 0, iWidth, iHeight );
		graphics.endFill();
		
		graphics.beginFill( 0xE68C32, 1 );
			graphics.drawRect( 4, 4, iWidth - 8, iHeight - 8 );
		graphics.endFill();
		
		graphics.beginFill( 0x222222, 1 );
			graphics.drawRect( 6, 6, iWidth - 12, iHeight - 12 );
		graphics.endFill();
		

		var achName:TextField = new TextField();
		achName.x = 8; achName.y = 4;
			achName.textColor = 0xFFFFFF;
			achName.width = iWidth - 6;
			achName.scaleX = 2; achName.scaleY = 2;
			achName.setTextFormat( txtFormat );
			achName.selectable = false;
			achName.text = sName;
		addChild( achName );

		var achDesc:TextField = new TextField();
		achDesc.x = 10; achDesc.y = 35;
			achDesc.width = iWidth - 8; achDesc.height = iHeight - 8;
			achDesc.textColor = 0xCCCCCC;
			achDesc.scaleX = 1.15; achDesc.scaleY = 1.15;
			achDesc.setTextFormat( txtFormat );
			achDesc.selectable = false;
			achDesc.text = sDesc;
		addChild( achDesc );

		iLifeTime = getTimer() + 5000;

		addEventListener( Event.ENTER_FRAME, Think, false, 0, true );
	}
		
	private function Think( e:Event ):void
	{
		if ( iLifeTime > getTimer() ) { return; }

		if ( alpha > 0 )
		{
			alpha -= .025;
			y += .75;
			return;
		}

		parent.removeChild( this );	
		removeEventListener( Event.ENTER_FRAME, Think );
	}
}