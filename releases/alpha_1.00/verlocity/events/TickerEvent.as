package verlocity.events
{
	import flash.events.Event;

	public final class TickerEvent extends Event
	{
		public static const TICK : String = "tick";

		private var m_interval : Number;
	
		function TickerEvent( a_interval : Number )
		{
			super( TICK, false, false );
			m_interval = a_interval;
		}
	
		public function get interval() : Number { return m_interval; }
	}
}