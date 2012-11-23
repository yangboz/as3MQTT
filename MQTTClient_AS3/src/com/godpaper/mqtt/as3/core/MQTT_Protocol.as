/**
 *  GODPAPER Confidential,Copyright 2012. All rights reserved.
 *
 *  Permission is hereby granted, free of charge, to any person obtaining
 *  a copy of this software and associated documentation files (the "Software"),
 *  to deal in the Software without restriction, including without limitation
 *  the rights to use, copy, modify, merge, publish, distribute, sub-license,
 *  and/or sell copies of the Software, and to permit persons to whom the
 *  Software is furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included
 *  in all copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 *  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 *  THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 *  IN THE SOFTWARE.
 */
package com.godpaper.mqtt.as3.core
{
	import flash.utils.ByteArray;

	//--------------------------------------------------------------------------
	//
	//  Imports
	//
	//--------------------------------------------------------------------------
	
	/**
	 * MQTT_Protocol.as class.   
	 * @see http://public.dhe.ibm.com/software/dw/webservices/ws-mqtt/MQTT_V3.1_Protocol_Specific.pdf	
	 * @author yangboz
	 * @langVersion 3.0
	 * @playerVersion 11.2+
	 * @airVersion 3.2+
	 * Created Nov 20, 2012 10:49:53 AM
	 */   	 
	public class MQTT_Protocol extends ByteArray
	{		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  CONSTANTS
		//----------------------------------
		/* For version 3 of the MQTT protocol */
		/* Mosquitto MQTT Javascript/Websocket client */
		/* Provides complete support for QoS 0. 
		* Will not cause an error on QoS 1/2 packets.
		*/
		public static const PROTOCOL_NAME:String =  "MQIsdp";
		public static const PROTOCOL_VERSION:Number = 3;
		
		/* Message types */
		public static const CONNECT:uint = 0x10;
		public static const CONNACK:uint = 0x20;
		public static const PUBLISH:uint = 0x30;
		public static const PUBACK:uint = 0x40;
		public static const PUBREC:uint = 0x50;
		public static const PUBREL:uint = 0x60;
		public static const PUBCOMP:uint = 0x70;
		public static const SUBSCRIBE:uint = 0x80;
		public static const SUBACK:uint = 0x90;
		public static const UNSUBSCRIBE:uint = 0xA0;
		public static const UNSUBACK:uint = 0xB0;
		public static const PINGREQ:uint = 0xC0;
		public static const PINGRESP:uint = 0xD0;
		public static const DISCONNECT:uint = 0xE0;
		
		public static const CONNACK_ACCEPTED:uint = 0;
		public static const CONNACK_REFUSED_PROTOCOL_VERSION:int = 1;
		public static const CONNACK_REFUSED_IDENTIFIER_REJECTED:int = 2;
		public static const CONNACK_REFUSED_SERVER_UNAVAILABLE:int = 3;
		public static const CONNACK_REFUSED_BAD_USERNAME_PASSWORD:int = 4;
		public static const CONNACK_REFUSED_NOT_AUTHORIZED:int = 5;
		
		public static const MQTT_MAX_PAYLOAD:int = 268435455;
		//--------------------------------------------------------------------------
		//
		//  Public properties
		//
		//-------------------------------------------------------------------------- 
		
		//--------------------------------------------------------------------------
		//
		//  Protected properties
		//
		//-------------------------------------------------------------------------- 
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		    	
		//--------------------------------------------------------------------------
		//
		//  Public methods
		//
		//--------------------------------------------------------------------------
		public function writeBody(body:ByteArray):void
		{
			this.position = 1;
			this.writeByte(body.length);
			this.writeBytes(body);
		}
		
		public function writeType(type:int):void
		{
			this.position = 0;
			this.writeByte(type);
			this.writeByte(0x00);
		}
		
		public function isConnack():Boolean
		{
			this.position = 0;
			var params:Array = [this.readByte(), this.readByte(), this.readByte(), this.readByte()];
			return ( params[0] == CONNACK ) && params[3] ==0;
		}
		
		//		public function isPuback():Boolean
		//		{
		//			this.position = 0;
		//			return this.readUnsignedByte() == PUBACK;
		//		}
		//		
		//		public function isSuback():Boolean
		//		{
		//			this.position = 0;
		//			return this.readUnsignedByte() == SUBACK;
		//		}
		//		
		//		public function isUnsuback():Boolean
		//		{
		//			this.position = 0;
		//			return this.readUnsignedByte() == UNSUBACK;
		//		}
		//		
		//		public function isPingResp():Boolean
		//		{
		//			this.position = 0;
		//			return this.readUnsignedByte() == PINGRESP;
		//		}
		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------
		
		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------
	}
	
}