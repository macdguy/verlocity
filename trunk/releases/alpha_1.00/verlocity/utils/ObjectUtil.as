/*
 * ---------------------------------------------------------------
 * Verlocity
 * http://www.verlocityengine.com
 * 
 * This file is subject to the terms and conditions defined in
 * 'license.txt', which is part of this source code package.
 * ---------------------------------------------------------------
*/
package verlocity.utils 
{
	import flash.utils.getQualifiedSuperclassName;
	import flash.utils.getQualifiedClassName;
	import flash.utils.describeType;

	public final class ObjectUtil 
	{
		/**
		 * Returns if an object is valid (checks for IsValid function).
		 * @param	obj
		 * @return
		 */
		public static function IsValid( obj:Object ):Boolean
		{
			if ( !obj ) { return false; }

			if ( "_IsValid" in obj )
			{
				return obj._IsValid();
			}
			
			if ( "IsValid" in obj )
			{
				return obj.IsValid();
			}

			return false;
		}
		
		/**
		 * Returns if the object is undefined.
		 * @param	obj
		 * @return
		 */
		public static function IsUndefined( obj:Object ):Boolean
		{
			return obj is undefined;
		}

		/**
		 * Returns if the object is null.
		 * @param	obj
		 * @return
		 */
		public static function IsNull( obj:Object ):Boolean
		{
			return obj === null;
		}
		
		/**
		 * Returns if a class is extending from another class.
		 * @param	class1 Class
		 * @param	class2 Class that it could be extending from
		 * @return
		 */
		public static function IsExtending( class1:Class, class2:Class ):Boolean
		{
			var xmlList:XMLList = describeType( class2 )..extendsClass;
			var sQualified:String = getQualifiedClassName( class1 );

			return xmlList.( @type == sQualified ).length() != 0;
		}
		
		/**
		 * Returns the constructor class of an object
		 * @param	obj The object
		 * @return
		 */
		public static function GetClass( obj:Object ):Class
		{
			return obj.constructor;
		}

		/**
		 * Returns if the object contains the method
		 * @param	obj The object
		 * @param	methodName The method name
		 * @return
		 */
		public static function HasMethod( obj:Object, methodName:String ):Boolean
		{
            if ( obj.hasOwnProperty( methodName ) )
			{
				return obj[methodName] is Function;
			}

            return false;
        }

		/**
		 * Returns if an object is empty.
		 * @param	obj The object
		 * @return
		 */
		public static function IsEmpty( obj:* ):Boolean
		{
			if ( obj == undefined ) { return true; }

			if ( obj is Number ) { return isNaN( obj ); }

			if ( obj is Array || obj is String )
			{
				return obj.length == 0;
			}

			if ( obj is Object )
			{
				for ( var prop:String in obj )
				{
					return false;
				}
				return true;
			}

			return false;
		}
	}
}