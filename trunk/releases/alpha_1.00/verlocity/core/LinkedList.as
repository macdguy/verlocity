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
	/**
	 * An extremely efficient linked list data structure with radix sorting built in.
	 */
	public final class LinkedList extends Object
	{
		private var iLength:uint;

		private var headNode:ListNode;
		private var tailNode:ListNode;

		private var sortedHeadNode:ListNode;

		/**
		 * Creates a linked list.
		 * @param	iNum The number of entries to fill when first created
		 * @param	defaultData The data to fill the entires with
		 */
		public function LinkedList( iNum:int = 0, defaultData:* = null ):void
		{
			headNode = tailNode = null;
			iLength = iNum;

			// Fill list
			if ( iNum > 0 )
			{
				for ( var i:int = 0; i < iNum; ++i)
				{
					push( defaultData, Math.random() * 5 );
				}
			}
		}
		
		/**
		 * Pushes a new node at the top of the list.
		 * @param	data The data of the node
		 * @param	prior The priority of the node (for sorting).
		 * @param	autoSort Automatically sorts after new pushed data.
		 * @param	sortBy Automatically sort by this property.
		 * @return
		 */
		public function push( data:*, prior:int = 0, autoSort:Boolean = false, sortBy:String = "priority" ):ListNode
		{			
			var node:ListNode = new ListNode( data, prior );

			if ( headNode )
			{
				headNode.previous = node;
				node.next = headNode;
				headNode = node;
 			}
			else
			{
				headNode = tailNode = node;
			}

			iLength++;

			if ( autoSort ) { sort( sortBy ); }

			return headNode;
		}
		
		/**
		 * Appends a new node at the bottom of the list.
		 * @param	data The data of the node
		 * @param	prior The priority of the node (for sorting).
		 * @return
		 */
		public function append( data:*, prior:int = 0 ):ListNode
		{			
			var node:ListNode = new ListNode( data, prior );

			if ( tailNode )
			{
				tailNode.next = node;
				tailNode.next.previous = tailNode;
				tailNode = tailNode.next;
			}
			else
			{
				headNode = tailNode = node;
			}
			
			iLength++;
			return tailNode;
		}

		/**
		 * Removes a node from the linked list.
		 * @param	node The node to remove
		 */
		public function splice( node:ListNode ):void
		{
			// Remove node data
			if ( node == headNode )
			{
 				removeHead();
			}
			else
			{
				node.previous.next = node.next;
			}
 
			if ( node == tailNode )
			{
 				removeTail();
 			}
			else
			{
				node.next.previous = node.previous;
			}
 
			iLength--;
		}
		
		/**
		 * Removes the first matching node with the matching data from the linked list.
		 * @param	data The data to find and remove
		 */
		public function spliceData( data:* ):void
		{
			var node:ListNode = headNode;

			while( node )
			{
				if ( node.data == data )
				{
					splice( node );
				}

				node = node.next;
			}
		}

		/**
		 * Removes the head.
		 */
		public function removeHead():void
		{
			var node:ListNode = headNode;
 
			if ( headNode )
			{
 				headNode = headNode.next;
 
				if ( headNode)
				{
					headNode.previous = null;
				}
 
				iLength--;
 			}
		}

		/**
		 * Removes the tail.
		 */
		public function removeTail():void
		{
			var node:ListNode = tailNode;
 
			if ( tailNode )
			{
				tailNode = tailNode.previous;
 
				if ( tailNode )
				{
					tailNode.next = null;
				}
 
				iLength--;
			}
		}

		/**
		 * Sorts the linked list by a specified property and stores in the "sort" property.
		 * Based on Radix sorting method by Rob Bateman (http://www.infiniteturtles.co.uk).
		 * @param	sProperty The property to sort by.
		 */
		public function sort( property:String = "priority" ):void
		{
			var q0:Vector.<ListNode> = new Vector.<ListNode>( 256, true );
			var q1:Vector.<ListNode> = new Vector.<ListNode>( 256, true );

			var i:int, k:int;
			var f:ListNode = head;
			var p:ListNode, c:ListNode;
			
			c = f;
			while ( c )
			{
				c.nextsorted = q0[k = ( 255 & c[property] )];
				q0[k] = c;
				c = c.next;
			}

			i = 256;
			while ( i-- )
			{
				c = q0[i];
				while ( c )
				{
					p = c.nextsorted;
					c.nextsorted = q1[k = ( 65280 & c[property] ) >> 8];
					q1[k] = c;
					sortedHeadNode = c;

					c = p;
				}
			}
			
			i = 0;
			k = 0;
		}
		
		/**
		 * Returns a string list of all the elements in the linked list.
		 * @return
		 */
		public function list():String
		{
			var node:ListNode = headNode;
			
			var text:String = "";
			
			while ( node )
			{
				text += String( node.data ) + " ";
				
				node = node.next;
			}

			return text;
		}
		
		/**
		 * Removes all the linked list nodes.
		 */
		public function clear():void
		{
			var node:ListNode = headNode;

			while( node )
			{
				splice( node );
				node = node.next;
			}
		}
		
		/**
		 * Diposes of all data of the list.
		 */
		public function dispose():void
		{
			clear();
			headNode = null;
			tailNode = null;
			sortedHeadNode = null;
		}
		
		/**
		 * Returns the head node of the list.
		 */
		public function get head():ListNode
		{
			return headNode;
		}

		/**
		 * Returns the sorted head node of the list.
		 */
		public function get headsorted():ListNode
		{
			return sortedHeadNode;
		}
		
		/**
		 * Returns the length of the linked list.
		 */
		public function get length():uint
		{
			var node:ListNode = headNode;
			var i:int;

			while( node )
			{
				i++;
				node = node.next;
			}

			return i;
		}
	}
}