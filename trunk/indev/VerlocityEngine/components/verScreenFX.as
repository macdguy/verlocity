/*
	This file is subject to the terms and conditions defined in
    file 'license.txt', which is part of this source code package.
*/

/*
	=========================================
			   Verlocity Engine
	=========================================
	|	Developed by Macklin Guy, 2011.		|
	|										|
	|										|
	-----------------------------------------
	verScreenFX.as
	-----------------------------------------
	This class handles screen FX.  These are seperate from entity-based effects, 
	as they are designed to take up the entire screen or parts of the screen statically.
*/

package VerlocityEngine.components 
{
	import VerlocityEngine.base.verBScrFX;

	import VerlocityEngine.Verlocity;
	import VerlocityEngine.VerlocityLanguage;

	public final class verScreenFX extends Object
	{
		//********* VERLOCITY COMPONENT HEADER *********//
		/************************************************/		
		public function IsValid():Boolean { return wasCreated; }
		private var wasCreated:Boolean;

		public function verScreenFX():void
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
		private var vScrFX:Vector.<verBScrFX>;


		/*
		 **************COMPONENT CREATION****************
		*/
		private function Construct():void
		{
			vScrFX = new Vector.<verBScrFX>();
		}

		/*
		 *************COMPONENT CONCOMMANDS**************
		*/
		private function Concommands():void
		{
			if ( !Verlocity.console ) { return; }

			Verlocity.console.Register( "sfx_remove_all", function():void
			{
				RemoveAll( false );
			}, "Removes all screen FX (non-protected)." );
		}


		/*
		 ****************COMPONENT LOOP******************
		*/
		public function Think():void
		{
			var iLength:int = vScrFX.length;
			if ( iLength <= 0 ) { return; } 

			var i:int = iLength - 1;
			var refCurrent:verBScrFX;

			while( i >= 0 )
			{
				refCurrent = vScrFX[i];

				if ( refCurrent.IsDead() )
				{
					refCurrent.Destruct();
					refCurrent.Dispose();

					Verlocity.layers.layerScrFX.removeChild( refCurrent );

					delete vScrFX[i];
					vScrFX[i] = null;
					vScrFX.splice( i, 1 );
				}
				else
				{
					if ( refCurrent.totalFrames > 1 && ( refCurrent.currentFrame + 1 ) >= refCurrent.totalFrames )
					{
						refCurrent.Remove();
					}
					else
					{
						refCurrent.Think();
					}
				}

				refCurrent = null;
				i--;
			}
		}


		/*
		 *************COMPONENT FUNCTIONS***************
		*/

		/*------------------ PRIVATE ------------------*/

		/*------------------ PUBLIC -------------------*/
		public function Create( scrFX:verBScrFX, bOnTop:Boolean = false, bProtected:Boolean = false ):*
		{
			vScrFX[ vScrFX.length ] = scrFX;
			
			Verlocity.layers.layerScrFX.addChild( scrFX );

			if ( bOnTop )
			{
				var iNum:int = Verlocity.layers.layerScrFX.numChildren;

				if( iNum > 0 )
				{
					Verlocity.layers.layerScrFX.setChildIndex( scrFX, iNum - 1 );
				}
			}

			scrFX.SetProtected( bProtected );

			return scrFX;
		}
		
		public function RemoveAll( bRemoveProtected:Boolean = false ):void
		{
			var iLength:int = vScrFX.length;
			if ( iLength <= 0 ) { return; } 

			var i:int = iLength - 1;
			var refCurrent:verBScrFX;

			while( i >= 0 )
			{
				refCurrent = vScrFX[i];
				
				if ( bRemoveProtected || !refCurrent.IsProtected() )
				{
					refCurrent.Remove();
				}

				refCurrent = null;
				i--;
			}

			Verlocity.Trace( "ScrFX", VerlocityLanguage.T( "GenericRemoveAll" ) );
		}

	}

}