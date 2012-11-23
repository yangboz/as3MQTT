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
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.Socket;
	import flash.system.Security;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.utils.Timer;
//TODO:event metdata declare
//	/** Dispatched when a new MQTT server is connected. */
//	[Event(name="mqttConnect", type="flash.events.Event")]
//	
//	/** Dispatched when a new  MQTT server is closed. */
//	[Event(name="mqttClose", type="flash.events.Event")]
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
	public class MQTTSocket extends EventDispatcher
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
		private var clean:Boolean=true;/* as3 socket fluse auto clean */
		/**
		 * The topic name is present in the variable header of an MQTT PUBLISH message.</br>
		 * The topic name is the key that identifies the information channel to which payload data is published.</br>
		 * Subscribers use the key to identify the information channels on which they want to receive published information.</br>
		 * The topic name is a UTF-encoded string. See the section on MQTT and UTF-8 for more information.</br>
		 * Topic name has an upper length limit of 32,767 characters.</br>
		 * */
		public var topicname:String="RoYan_／"; /* default stores topic name */
		//MQTT byte array prepare.
		//@see https://www.ibm.com/developerworks/mydeveloperworks/blogs/messaging/entry/write_your_own_mqtt_client_without_using_any_api_in_minutes1?lang=en
		//First let's construct the MQTT messages that need to be sent:
		private var connectMessage:MQTT_Protocol;
		private var publishMessage:MQTT_Protocol;
//		private var subscribeMessage:ByteArray=new ByteArray();
		private var disconnectMessage:MQTT_Protocol;
		private var pingMessage:MQTT_Protocol;
		
		private var timer:Timer;
		private var servicing:Boolean;/*service indicator*/
		//----------------------------------
		//  CONSTANTS
		//----------------------------------
		private static const MAX_LEN_UUID:int = 16;
		private static const MAX_LEN_TOPIC:int = 7;
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
			//parameters store
			if(host) this.host = host;//TODO:ip and hostname regexp test or match function.
			if(port) this.port = port;
			if(topicname) 
			{
				if(this.topicname.length>MAX_LEN_TOPIC) throw new Error("Out of range ".concat(MAX_LEN_TOPIC,"!"));
				this.topicname = topicname;
			}
			if(clientid)
			{
				if(this.clientid.length>MAX_LEN_UUID) throw new Error("Out of range ".concat(MAX_LEN_UUID,"!"));
				this.clientid = clientid;
			}else
			{
				this.clientid = UIDUtil.createUID();//Assure unique. and cut off the string length to 16.
				this.clientid = this.shortenString(this.clientid,MAX_LEN_UUID);
			}
			//Any out of range issue???
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
			//Timer for ping function.
			timer = new Timer(keepalive / 2 * 1000);
			timer.addEventListener(TimerEvent.TIMER, onPing);
			
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
			//subscribe list store,and subscribe to socket server.
			if(topicname.length>MAX_LEN_TOPIC) throw new Error("Out of range ".concat(MAX_LEN_TOPIC,"!"));
			if(this.topics.indexOf(topicname)==-1)
			{
				this.topics.push(topicname);
			}
			//TODO:send subscribe message
		}
		//
		public function publish(content:String,topicname:String,QoS:int=0,retain:String=null):void
		{
			//TODO:socket sever response detect.
			var bytes:ByteArray = new ByteArray();
			writeString(bytes, topicname);
						
			if( QoS )
			{
				msgid++;
				bytes.writeByte(msgid >> 8);
				bytes.writeByte(msgid % 256 );
			}
						
			writeString(bytes, content);
					
			var type:int = MQTT_Protocol.PUBLISH;
			if( QoS ) type += QoS << 1;
			if( retain ) type += 1;
			this.publishMessage = new MQTT_Protocol();
			this.publishMessage.writeType(type);
			this.publishMessage.writeBody(bytes);
						
			socket.writeBytes(this.publishMessage);
			socket.flush();
					
			trace( "Publish sent" );
		}
	    public function connect(host:String=null, port:int=0):void
		{
			if(host) this.host = host;//TODO:ip and hostname regexp test or match function.
			if(port) this.port = port;
			//
			socket.connect(this.host,this.port);
		}
		/* disconnect: sends a proper disconect cmd */
		public function close():void
		{
			if(this.disconnectMessage == null)
			{
				this.disconnectMessage = new MQTT_Protocol();
				this.disconnectMessage.writeType(MQTT_Protocol.DISCONNECT);
			}
			socket.writeBytes(this.disconnectMessage, 0, this.disconnectMessage.length);
			socket.flush();
			socket.close();
			//dispatch event
			this.dispatchEvent(new MQTTEvent(MQTTEvent.CLOSE,false,false));
		}
		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------
		protected function writeString(bytes:ByteArray, str:String):void
		{
			var len:int = str.length;
			var msb:int = len >>8;
			var lsb:int = len % 256;
			bytes.writeByte(msb);
			bytes.writeByte(lsb);
			bytes.writeMultiByte(str, 'utf-8');
		}
		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------
		//
		private function onConnect(event:Event):void
		{
//			trace(event);
			//			socket.writeUTFBytes("GET / HTTP/1.1\n");
			//			socket.writeUTFBytes("Host: hejp.co.uk\n");
			//			socket.writeUTFBytes("\n");
			//			All data values are in big-endian order: higher order bytes precede lower order bytes.
			trace("MQTT byte order:",this.socket.endian);
			if (this.socket.endian != Endian.BIG_ENDIAN)
			{
				throw new Error("Endian failed!");
			}
			if(this.connectMessage == null){
				this.connectMessage = new MQTT_Protocol();
				var bytes:ByteArray = new ByteArray();
					bytes.writeByte(0x00); //0
					bytes.writeByte(0x06); //6
					bytes.writeByte(0x4d); //M
					bytes.writeByte(0x51); //Q
					bytes.writeByte(0x49); //I
					bytes.writeByte(0x73); //S
					bytes.writeByte(0x64); //D
					bytes.writeByte(0x70); //P
					bytes.writeByte(0x03); //Protocol version = 3
				var type:int = 0;
				if( clean ) type += 2;
				if( will )
				{
					type += 4;
					type += will['qos'] << 3;
					if( will['retain'] ) type += 32;
				}
				if( username ) type += 128;
				if( password ) type += 64;
					bytes.writeByte(type); //Clean session only
					bytes.writeByte(keepalive >> 8); //Keepalive MSB
					bytes.writeByte(keepalive & 0xff); //Keepaliave LSB = 60
					writeString(bytes, clientid);
					writeString(bytes, username?username:"");
					writeString(bytes, password?password:"");
				this.connectMessage.writeType(MQTT_Protocol.CONNECT); //Connect
				this.connectMessage.writeBody(bytes); //Connect
			}
			
			trace("MQTT connectMesage.length:", this.connectMessage.length);
			this.socket.writeBytes(this.connectMessage, 0, this.connectMessage.length);
			this.socket.flush();
			//dispatch event
			this.dispatchEvent(new MQTTEvent(MQTTEvent.CONNECT,false,false));
		}
		
		//
		private function onClose(event:Event):void
		{
			// Security error is thrown if this line is excluded
			//dispatch event
			this.dispatchEvent(new MQTTEvent(MQTTEvent.CLOSE,false,false));
		}
		
		//
		private function onError(event:IOErrorEvent):void
		{
			trace("MQTT IO Error: " + event);
			//dispatch event
			this.dispatchEvent(new MQTTEvent(MQTTEvent.ERROR,false,false));
		}
		
		//
		private function onSecError(event:SecurityErrorEvent):void
		{
			trace("MQTT Security Error: " + event);
			//dispatch event
			this.dispatchEvent(new MQTTEvent(MQTTEvent.ERROR,false,false));
		}
		
		//
		private function onSocketData(event:ProgressEvent):void
		{
			trace("MQTT Socket received " + this.socket.bytesAvailable + " byte(s) of data:");
			// Loop over all of the received data, and only read a byte if there  is one available 
			var result:MQTT_Protocol = new MQTT_Protocol();
			socket.readBytes(result);
			
			switch(result.readUnsignedByte()){
				case MQTT_Protocol.CONNACK:
					result.position = 3;
					if(result.isConnack())
					{
						trace( "Socket connected" );
						servicing = true;
						//dispatchEvent();
						this.dispatchEvent(new MQTTEvent(MQTTEvent.MESSGE,false,false,result.toString()));
						//
						timer.start();
					}else{
						trace( "Connection failed!" );
						//dispatchEvent();
						this.dispatchEvent(new MQTTEvent(MQTTEvent.ERROR,false,false));
					}
					break;
				case MQTT_Protocol.PUBACK:
					trace( "Publish Acknowledgment" );
					break;
				case MQTT_Protocol.SUBACK:
					trace( "Subscribe Acknowledgment" );
					break;
				case MQTT_Protocol.UNSUBACK:
					trace( "Unsubscribe Acknowledgment" );
					break;
				case MQTT_Protocol.PINGRESP:
					trace( "Ping Response" );
					break;
				default:
					trace( "Others." );
			}
		}
		//
		private function onPing(event:TimerEvent):void
		{
			if(this.pingMessage == null)
			{
				this.pingMessage = new MQTT_Protocol();
				this.pingMessage.writeType(MQTT_Protocol.PINGREQ);
			}
			socket.writeBytes(this.pingMessage);
			socket.flush();
			trace("Ping sent");
		}
		//
		private function shortenString(str:String,len:int):String
		{
			var result:String = str;
			if(str.length>len)
			{
				result = str.substr(0,len);	
			}
			return result;
		}
	}
	
}