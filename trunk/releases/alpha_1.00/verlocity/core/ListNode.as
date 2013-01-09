/*
 * ---------------------------------------------------------------
 * Verlocity
 * http://www.verlocityengine.com
 * 
 * This file is subject to the terms and conditions defined in
 * 'license.txt', which is part of this source code package.
 * ---------------------------------------------------------------
*/
package verlocity.core
{
	public final class ListNode extends Object
	{
		public var data:*;
		public var priority:int;

		public var previous:ListNode;
		public var next:ListNode;
		public var nextsorted:ListNode;

		/**
		 * Creates a linked list node that holds data.
		 * @param	setdata The data to hold
		 */
		public function ListNode( setdata:*, prior:int = 0 ):void
		{
			next = previous = null;
			data = setdata;
			priority = prior;
		}
	}
}