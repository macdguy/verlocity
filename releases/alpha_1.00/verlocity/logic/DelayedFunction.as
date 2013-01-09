/*
 * ---------------------------------------------------------------
 * Verlocity
 * http://www.verlocityengine.com
 * 
 * This file is subject to the terms and conditions defined in
 * 'license.txt', which is part of this source code package.
 * ---------------------------------------------------------------
*/
package verlocity.logic 
{
	import flash.display.Shape;
	import flash.events.Event;
	import verlocity.Verlocity;

	public final class DelayedFunction
	{
		private var fFunction:Function;
		private var iDelay:int;
		private var sUpdateShape:Shape;

		public function DelayedFunction( iSetDelayTime:int, fSetFunction:Function ):void
		{
			if ( !Verlocity.IsValid( Verlocity.engine ) ) { return; }

			fFunction = fSetFunction;
			iDelay = Verlocity.CurTime() + iSetDelayTime;

			if ( Verlocity.IsValid( Verlocity.engine ) )
			{
				Verlocity.engine.Hook( this );
			}
			else
			{
				sUpdateShape = new Shape();
				sUpdateShape.addEventListener( Event.ENTER_FRAME, _Update );
			}
		}
		
		private function _Update( e:Event ):void
		{
			Update();
		}

		public function Update():void
		{
			if ( Verlocity.CurTime() > iDelay )
			{
				CallFunction();
			}
		}
		
		private function CallFunction():void
		{
			if ( Boolean( fFunction ) )
			{
				fFunction();
			}
			
			fFunction = null;
			iDelay = 0;

			if ( sUpdateShape )
			{
				sUpdateShape.removeEventListener( Event.ENTER_FRAME, _Update );
				sUpdateShape = null;
			}

			if ( Verlocity.IsValid( Verlocity.engine ) )
			{
				Verlocity.engine.UnHook( this );
			}
			
			delete this;
		}
	}
}