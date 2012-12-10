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
		public static const PROTOCOL_NAME:String="MQIsdp";
		public static const PROTOCOL_VERSION:Number=3;

		/* Message types */
		public static const CONNECT:uint=0x10;
		public static const CONNACK:uint=0x20;
		public static const PUBLISH:uint=0x30;
		public static const PUBACK:uint=0x40;
		public static const PUBREC:uint=0x50;
		public static const PUBREL:uint=0x60;
		public static const PUBCOMP:uint=0x70;
		public static const SUBSCRIBE:uint=0x80;
		public static const SUBACK:uint=0x90;
		public static const UNSUBSCRIBE:uint=0xA0;
		public static const UNSUBACK:uint=0xB0;
		public static const PINGREQ:uint=0xC0;
		public static const PINGRESP:uint=0xD0;
		public static const DISCONNECT:uint=0xE0;
		//
		public static const CONNACK_ACCEPTED:uint=0;
		public static const CONNACK_REFUSED_PROTOCOL_VERSION:int=1;
		public static const CONNACK_REFUSED_IDENTIFIER_REJECTED:int=2;
		public static const CONNACK_REFUSED_SERVER_UNAVAILABLE:int=3;
		public static const CONNACK_REFUSED_BAD_USERNAME_PASSWORD:int=4;
		public static const CONNACK_REFUSED_NOT_AUTHORIZED:int=5;

		public static const MQTT_MAX_PAYLOAD:int=268435455;

		protected var fixHead:ByteArray;
		protected var varHead:ByteArray;
		
		protected var messageType:uint;
		protected var dup:uint;
		protected var qos:uint;
		protected var retain:uint;
		protected var remainingLength:uint;
		
		///* stores the will of the client {willFlag,willQos,willRetainFlag} */
		public static var WILL:Array;
		/* static block */
		{
			WILL = [];
			//fake manual writing (big-endian)
			WILL['qos'] = 0x01;
			WILL['retain'] = 0x01;
		}
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
		//
		public function writeBody(body:ByteArray):void
		{
			this.position=1;
			this.writeByte(body.length);
			this.writeBytes(body);
		}
		
		public function writeType(value:uint):void
		{
			this.position = 0;
			this.writeByte(value);
			this.writeByte(0x00);
			
			messageType = value & 0xF0;
			dup = (value >> 3) & 0x01;
			qos = (value >> 1) & 0x03;
			retain = value & 0x01;
		}
		
		//
		public function writeMessageType(value:uint):void
		{
			messageType = value;
			this.position=0;
			this.writeByte(messageType + (dup << 3) + (qos << 1) + retain);
		}
		
		public function writeDUP(value:uint):void
		{
			dup = value;
			this.position=0;
			this.writeByte(messageType + (dup << 3) + (qos << 1) + retain);
		}
		
		public function writeQoS(value:uint):void
		{
			qos = value;
			this.position=0;
			this.writeByte(messageType + (dup << 3) + (qos << 1) + retain);
		}
		
		public function writeRETIAN(value:uint):void
		{
			retain = value;
			this.position=0;
			this.writeByte(messageType + (dup << 3) + (qos << 1) + retain);
		}
		
		//
		public function readVarHead():ByteArray
		{
			this.position=0;
			if (varHead == null && this.length > 2)
			{
				varHead=new ByteArray();

				this.readBytes(varHead, 2);
			}
			return varHead;
		}

		//
		public function readyMessageType():uint
		{
			this.position=0;
			return this.readUnsignedByte() & 0xF0;
		}
		
		public function readDUP():uint
		{
			this.position=0;
			return this.readUnsignedByte() >> 3 & 0x01;
		}
		
		public function readyQoS():uint
		{
			this.position=0;
			return this.readUnsignedByte() >> 1 & 0x03;
		}
		
		public function readyRETAIN():uint
		{
			this.position=0;
			return this.readUnsignedByte() & 0x01;
		}
		
		public function readRemainingLength():uint
		{
			this.position = 1;
			return this.readUnsignedByte();
		}
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