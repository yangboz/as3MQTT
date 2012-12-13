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
		protected var payLoad:ByteArray;
		
		protected var type:uint;
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
		public function writeType(value:int):void
		{
			type = value;
			writeMessageType(type + (dup << 3) + (qos << 1) + retain);
		}
		
		public function writeDUP(value:int):void
		{
			dup = value;
			writeMessageType(type + (dup << 3) + (qos << 1) + retain);
		}
		
		public function writeQoS(value:int):void
		{
			qos = value;
			writeMessageType(type + (dup << 3) + (qos << 1) + retain);
		}
		
		public function writeRETAIN(value:int):void
		{
			retain = value;
			writeMessageType(type + (dup << 3) + (qos << 1) + retain);
		}
		
		public function writeRemainingLength(value:int):void
		{
			remainingLength = value;
			writeMessageType(type + (dup << 3) + (qos << 1) + retain);
		}
		
		public function readType():uint
		{
			this.position=0;
			return this.readUnsignedByte() & 0xF0;
		}
		
		public function readDUP():uint
		{
			this.position=0;
			return this.readUnsignedByte() >> 3 & 0x01;
		}
		
		public function readQoS():uint
		{
			this.position=0;
			return this.readUnsignedByte() >> 1 & 0x03;
		}
		
		public function readRETAIN():uint
		{
			this.position=0;
			return this.readUnsignedByte() & 0x01;
		}
		
		public function readRemainingLength():uint
		{
			this.position = 1;
			return this.readUnsignedByte();
		}
		
		public function writeMessageType(value:int):void//Fix Head
		{
			this.position = 0;
			
			if( fixHead == null )
				fixHead = new ByteArray();
			
			this.position = 0;
			this.writeByte(value);
			this.writeByte(remainingLength);
			this.readBytes(fixHead);
			
			type = value & 0xF0;
			dup = (value >> 3) & 0x01;
			qos = (value >> 1) & 0x03;
			retain = value & 0x01;
		}
		
		public function writeMessageValue(value:*):void//Variable Head
		{
			this.position = 2;
			this.writeBytes(value);
			this.serialize();
			writeMessageType( type + (dup << 3) + (qos << 1) + retain );
		}
		
		public function readMessageType():ByteArray
		{
			return fixHead;
		}
		
		public function readMessageValue():ByteArray
		{
			return varHead;
		}
		
		public function readPayLoad():ByteArray
		{
			return payLoad;
		}
		
		public function serialize():void
		{
			type 	= this.readType();
			dup 	= this.readDUP();
			qos 	= this.readQoS();
			retain	= this.readRETAIN();
			
			fixHead = new ByteArray();
			varHead = new ByteArray();
			payLoad = new ByteArray();
			
			this.position = 0;
			this.readBytes(fixHead, 0, 2);
			
			this.position = 2;
			switch( type ){
				case CONNECT://Remaining Length is the length of the variable header (12 bytes) and the length of the Payload
					this.readBytes(varHead, 0 , 12);
					this.readBytes(payLoad);
					
					remainingLength = varHead.length + payLoad.length;
					break;
				case PUBLISH://Remaining Length is the length of the variable header plus the length of the payload
					var index:int = (this.readUnsignedByte() << 8) + this.readUnsignedByte();//the length of variable header
					this.readBytes(varHead, 0 , index);
					this.readBytes(payLoad);
					
					remainingLength = varHead.length + payLoad.length;
					break;
				case SUBSCRIBE://Remaining Length is the length of the payload
				case SUBACK://Remaining Length is the length of the payload
				case UNSUBSCRIBE://Remaining Length is the length of the payload
					this.readBytes(varHead, 0 , 2);
					this.readBytes(payLoad);
					
					remainingLength = varHead.length + payLoad.length;
					break;
				default://Remaining Length is the length of the variable header (2 bytes)
					this.readBytes(varHead, 0);
					
					remainingLength = varHead.length;
					break;
			}
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