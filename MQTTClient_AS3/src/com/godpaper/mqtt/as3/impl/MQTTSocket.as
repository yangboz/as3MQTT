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
package com.godpaper.mqtt.as3.impl
{
	//--------------------------------------------------------------------------
	//
	//  Imports
	//
	//--------------------------------------------------------------------------
	import com.godpaper.mqtt.as3.core.MQTTEvent;
	import com.godpaper.mqtt.as3.core.MQTT_Protocol;
	import com.godpaper.mqtt.as3.utils.UIDUtil;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.Socket;
	import flash.system.Security;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	/** Dispatched when a new MQTT server is connected. */
	[Event(name="mqttConnect", type="flash.events.Event")]
	
	/** Dispatched when a new  MQTT server is closed. */
	[Event(name="mqttClose", type="flash.events.Event")]
	/**
	 * Pure Action Script 3 that implements the MQTT (Message Queue Telemetry Transport) protocol, a lightweight protocol for publish/subscribe messaging. </br>
	 * AS3 socket is a mechanism used to send data over a network (e.g. the Internet), it is the combination of an IP address and a port. </br>
	 * @see http://public.dhe.ibm.com/software/dw/webservices/ws-mqtt/mqtt-v3r1.html
	 * @see http://public.dhe.ibm.com/software/dw/webservices/ws-mqtt/MQTT_V3.1_Protocol_Specific.pdf
	 * @see http://mosquitto.org/download/
	 * @see https://www.ibm.com/developerworks/mydeveloperworks/blogs/messaging/entry/write_your_own_mqtt_client_without_using_any_api_in_minutes1?lang=en 	
	 * 
	 * @author yangboz
	 * @langVersion 3.0
	 * @playerVersion 11.2+
	 * @airVersion 3.2+
	 * Created Nov 22, 2012 4:14:14 PM
	 */   	 
	public class MQTTSocket extends Socket
	{		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		private var socket:Socket; /* holds the socket */
		private var msgid:int = 1;	/* counter for message id */
		public var keepalive:int = 10;	/* default keepalive timmer */
		public var timesinceping:uint;	/* host unix time, used to detect disconects */
//		public var topics:Array = []; /* used to store currently subscribed topics */
		public var topics:Vector.<String> = new Vector.<String>(); /* used to store currently subscribed topics */
		public var debug:Boolean = false;	/* should output debug messages */
//		public var address:String;	/* broker address */
		//Notice: You need to define a cross domain policy file at your remote server root document, or have a policy file server on the target. 
		public var host:String;	/* broker address */
		public var port:Number;	/* broker port */
		/**
		 * The first UTF-encoded string.</br>
		 * The Client Identifier (Client ID) is between 1 and 23 characters long, </br>
		 * and uniquely identifies the client to the server.</br>
		 * It must be unique across all clients connecting to a single server,</br>
		 * and is the key in handling Message IDs messages with QoS levels 1 and 2.</br>
		 * If the Client ID contains more than 23 characters, the server responds to the CONNECT message </br>
		 * with a CONNACK return code 2: Identifier Rejected..</br>
		 */
		public var clientid:String;	/* client id sent to brocker */
		public var will:uint;	/* stores the will of the client */
		public var username:String;	/* stores username */
		public var password:String;	/* stores password */
		public var QoS:int=0;/* stores QoS level */
		/**
		 * The topic name is present in the variable header of an MQTT PUBLISH message.</br>
		 * The topic name is the key that identifies the information channel to which payload data is published.</br>
		 * Subscribers use the key to identify the information channels on which they want to receive published information.</br>
		 * The topic name is a UTF-encoded string. See the section on MQTT and UTF-8 for more information.</br>
		 * Topic name has an upper length limit of 32,767 characters.</br>
		 * */
		public var topicname:String; /* stores topic name */
		//MQTT byte array prepare.
		//@see https://www.ibm.com/developerworks/mydeveloperworks/blogs/messaging/entry/write_your_own_mqtt_client_without_using_any_api_in_minutes1?lang=en
		//First let's construct the MQTT messages that need to be sent:
		private var connectMesage:ByteArray=new ByteArray();
		private var publishMessage:ByteArray=new ByteArray();
//		private var subscribeMessage:ByteArray=new ByteArray();
		private var disconnectMessage:ByteArray=new ByteArray();
		//----------------------------------
		//  CONSTANTS
		//----------------------------------
		
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
		public function MQTTSocket(host:String=null, port:int=0,topicname:String = null,clientid:String = null,username:String = null,password:String = null)
		{
			super(host, port);
			//parameters store
			if(host) this.host = host;
			if(port) this.port = port;
			if(topicname) this.topicname = topicname;
			if(clientid)
			{
				this.clientid = clientid;
			}else
			{
				this.clientid = UIDUtil.createUID();//Assure unique.
			}
			if(username) this.username = username;
			if(password) this.password = password;
			//Notice: You need to define a cross domain policy file at your remote server root document, or have a policy file server on the target. 
			Security.allowDomain("*");
			//			Security.loadPolicyFile("http://www.lookbackon.com/crossdomain.xml");  
			//event listeners
			socket = new Socket(host,port);
			socket.addEventListener(Event.CONNECT, onConnect); //dispatched when the connection is established
			socket.addEventListener(Event.CLOSE, onClose); //dispatched when the connection is closed
			socket.addEventListener(IOErrorEvent.IO_ERROR, onError); //dispatched when an error occurs
			socket.addEventListener(ProgressEvent.SOCKET_DATA, onSocketData); //dispatched when socket can be read
			socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecError); //dispatched when security gets in the way
			//for connection
			this.connectMesage.writeByte(0x10); //Connect
			this.connectMesage.writeByte(0x0C + 0x04); //Remaining Length
			this.connectMesage.writeByte(0x00); //0
			this.connectMesage.writeByte(0x06); //6
			this.connectMesage.writeByte(0x4d); //M
			this.connectMesage.writeByte(0x51); //Q
			this.connectMesage.writeByte(0x49); //I
			this.connectMesage.writeByte(0x73); //S
			this.connectMesage.writeByte(0x64); //D
			this.connectMesage.writeByte(0x70); //P
			this.connectMesage.writeByte(0x03); //Protocol version = 3
			this.connectMesage.writeByte(0x02); //Clean session only
			this.connectMesage.writeByte(0x00); //Keepalive MSB
			this.connectMesage.writeByte(0x3c); //Keepalive LSB = 60
			this.connectMesage.writeByte(0x00); //String length MSB
			this.connectMesage.writeByte(0x02); //String length LSB = 2
			this.connectMesage.writeByte(0x4d); //M
			this.connectMesage.writeByte(0x70); //P .. Let's say client ID = MP
			//for disconnect
			this.disconnectMessage.writeByte(0x0E); //Disconnect// -0x7F+0x5F //Disconnect 
			this.disconnectMessage.writeByte(0x00); //Disconnect
			//for publish
			this.publishMessage.writeByte(0x30); //Publish with QOS 0
			this.publishMessage.writeByte(0x05 + 0x05); //Remaining length
			this.publishMessage.writeByte(0x00); //MSB
			this.publishMessage.writeByte(0x03); //3 bytes of topic
			this.publishMessage.writeByte(0x61); //a
			this.publishMessage.writeByte(0x2F); ///
			this.publishMessage.writeByte(0x62); //b (a/b) is the topic
//			this.publishMessage.writeUTFBytes("HELLO"); // (0x48, 0x45 , 0x4c , 0x4c, 0x4f); //HELLO is the message
			//TODO:will
			//TODO:payload
		}     	
		//--------------------------------------------------------------------------
		//
		//  Public methods
		//
		//--------------------------------------------------------------------------
		public function subscribe(topicname:String,Qos:int=0):void
		{
			//TODO:
		}
		//
		public function publish(content:String,topicname:String,QoS:int=0,retain:String=null):void
		{
			//TODO:
		}
		override public function connect(host:String, port:int):void
		{
			this.host = host;
			this.port = port;
			//
			super.connect(host,port);
		}
		/* disconnect: sends a proper disconect cmd */
		override public function close():void
		{
			socket.writeBytes(this.disconnectMessage, 0, this.disconnectMessage.length);
			socket.close();
			//
			super.close();
			//dispatch event
			this.dispatchEvent(new Event(MQTTEvent.CLOSE,false,false));
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
		//
		private function onConnect(event:Event):void
		{
			trace(event);
			//			socket.writeUTFBytes("GET / HTTP/1.1\n");
			//			socket.writeUTFBytes("Host: hejp.co.uk\n");
			//			socket.writeUTFBytes("\n");
			//			All data values are in big-endian order: higher order bytes precede lower order bytes.
			trace("MQTT byte order:",this.socket.endian);
			if (this.socket.endian != Endian.BIG_ENDIAN)
			{
				throw new Error("Endian failed!");
			}
			trace("MQTT connectMesage.length:", this.connectMesage.length);
			this.socket.writeBytes(this.connectMesage, 0, this.connectMesage.length);
			this.socket.flush();
			//dispatch event
			this.dispatchEvent(new Event(MQTTEvent.CONNECT,false,false));
		}
		
		//
		private function onClose(event:Event):void
		{
			// Security error is thrown if this line is excluded
			trace(event);
			socket.writeBytes(this.disconnectMessage, 0, this.disconnectMessage.length);
			socket.close();
		}
		
		//
		private function onError(event:IOErrorEvent):void
		{
			trace("MQTT IO Error: " + event);
		}
		
		//
		private function onSecError(event:SecurityErrorEvent):void
		{
			trace("MQTT Security Error: " + event);
		}
		
		//
		private function onSocketData(event:ProgressEvent):void
		{
			trace("MQTT Socket received " + this.socket.bytesAvailable + " byte(s) of data:");
			// Loop over all of the received data, and only read a byte if there  is one available 
			var connack:Vector.<int> = new Vector.<int>();
			while (socket.bytesAvailable)
			{
				// Read a byte from the socket and display it  
				connack.push(socket.readByte());
				//				data = socket.readInt();
				//				trace(socket.readUTFBytes(socket.bytesAvailable).toString());
			}
			//			To verify if the client has successfully connected let's receive the CONNACK from the server.
			//			The connect return code is sent in the variable header of a CONNACK message.
			//			This field defines a one byte unsigned return code. 
			//			The meanings of the values, shown in the tables below, are specific to the message type. 
			//			A return code of zero (0) usually indicates success.
			trace(connack.toString());
//			if(connack[0] == MQTT_Protocol.CONNACK && connack[2] == 0x00) 
			if(connack[0] == MQTT_Protocol.CONNACK && connack[2] == MQTT_Protocol.CONNACK_ACCEPTED) 
			{
				trace("MQTT connection success.");
				//Connected ... So let's publish
				this.socket.writeBytes(this.publishMessage,0,this.publishMessage.length);
				this.socket.flush();
			}else
			{
				throw new Error("MQTT connect failed!");
			}
		}
	}
	
}