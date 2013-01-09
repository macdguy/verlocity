/*
 Copyright (c) 2007 Eric J. Feminella  <eric@ericfeminella.com>
 All rights reserved.

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is furnished
 to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
 PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

 @internal
*/

/*
 * Modified by Macklin Guy for purposes of usage in Verlocity (2011).
*/
package verlocity.core
{
    import flash.utils.Dictionary;
    import flash.utils.getQualifiedClassName;
    import flash.errors.IllegalOperationError;

    public final class SingletonManager
    {
        /**
         *
         * Defines a static HashMap which contains a reference to all
		 * Singleton class types.
		 *
         * A unique key based on the Singleton class name is added to the
         * map for each type which is to only contain a single instance
         *
         */
        private static const singletons:Dictionary = new Dictionary();

        /**
         *
         * Validates a new Singleton class instance to determine if the
         * class has previously been instantiated, if so, an Exception
         * is thrown, thus indicating that the class is a Singleton and
         * is only intended to have a single instance instantiated
         *
         * @param Singleton class instance which has been instantiated
         *
         */
        public static function Validate( instance:* ):Boolean
        {
			if ( !instance ) { return false; }	

            var className:String = getQualifiedClassName( instance );

            if ( singletons[ className ] )
            {
                throw new IllegalOperationError( "Singleton Exception. Only one instance is allowed for type: " + className );
				return false;
            }

            singletons[ className ] = true;
			return true;
        }
		
		/**
		 * Returns if a Singleton class instance is in the dictionary.
		 * @param	instance Singleton class instance which is currently instanitated
		 * @return
		 */
        public static function IsActive( instance:* ):Boolean
        {
			if ( !instance ) { return false; }

            var className:String = getQualifiedClassName( instance );

            return singletons[ className ];
        }
		
		/**
		 * Removes a Singleton class instance from the dictionary
		 * to allow for recreation.
		 * @param	instance Singleton class instance which has been instantiated
		 * @return
		 */
        public static function Remove( instance:* ):void
        {
			if ( !instance ) { return; }

            var className:String = getQualifiedClassName( instance );

            if ( singletons[ className ] )
            {
				delete singletons[ className ];
            }
        }
    }
}