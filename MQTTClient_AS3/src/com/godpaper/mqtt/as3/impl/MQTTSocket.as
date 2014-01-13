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
	import com.godpaper.as3.utils.LogUtil;
	import com.godpaper.mqtt.as3.core.MQTTEvent;
	import com.godpaper.mqtt.as3.core.MQTT_Protocol;
	import com.godpaper.mqtt.as3.utils.UIDUtil;
	
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
	
	import mx.logging.ILogger;

//event metdata declare
	/** Dispatched when a new MQTT server is connected. */
	[Event(name="mqttConnect", type="com.godpaper.mqtt.as3.core.MQTTEvent")]

	/** Dispatched when a new  MQTT server is closed. */
	[Event(name="mqttClose", type="com.godpaper.mqtt.as3.core.MQTTEvent")]

	/** Dispatched when a new MQTT server is messag-ed. */
	[Event(name="mqttMessage", type="com.godpaper.mqtt.as3.core.MQTTEvent")]

	/** Dispatched when a new  MQTT server is error-ed. */
	[Event(name="mqttError", type="com.godpaper.mqtt.as3.core.MQTTEvent")]
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
		private var msgid:int=1; /* counter for message id */
		public var keepalive:int=10; /* default keepalive timmer */
		public var timesinceping:uint; /* host unix time, used to detect disconects */
//		public var topics:Array = []; /* used to store currently subscribed topics */
		public var topics:Vector.<String>=new Vector.<String>(); /* used to store currently subscribed topics */
		public var debug:Boolean=false; /* should output debug messages */
//		public var address:String;	/* broker address */
		//Notice: You need to define a cross domain policy file at your remote server root document, or have a policy file server on the target. 
		public var host:String; /* broker address */
		public var port:Number; /* broker port */
		/**
		 * The first UTF-encoded string.</br>
		 * The Client Identifier (Client ID) is between 1 and 23 characters long, </br>
		 * and uniquely identifies the client to the server.</br>
		 * It must be unique across all clients connecting to a single server,</br>
		 * and is the key in handling Message IDs messages with QoS levels 1 and 2.</br>
		 * If the Client ID contains more than 23 characters, the server responds to the CONNECT message </br>
		 * with a CONNACK return code 2: Identifier Rejected..</br>
		 */
		public var clientid:String; /* client id sent to brocker */
		public var will:Array; /* stores the will of the client {willFlag,willQos,willRetainFlag} */
		public var username:String; /* stores username */
		public var password:String; /* stores password */
//		public var QoS:int=0; /* stores QoS level */ conflict with param of function
		public var cleanSession:Boolean=true; /* as3 socket fluse auto clean */
		/**
		 * The topic name is present in the variable header of an MQTT PUBLISH message.</br>
		 * The topic name is the key that identifies the information channel to which payload data is published.</br>
		 * Subscribers use the key to identify the information channels on which they want to receive published information.</br>
		 * The topic name is a UTF-encoded string. See the section on MQTT and UTF-8 for more information.</br>
		 * Topic name has an upper length limit of 32,767 characters.</br>
		 * */
		//The topic name is present in the variable header of an MQTT PUBLISH message.
		public var topicname:String="RoYan_／"; /* default stores topic name */
		//MQTT byte array prepare.
		//@see https://www.ibm.com/developerworks/mydeveloperworks/blogs/messaging/entry/write_your_own_mqtt_client_without_using_any_api_in_minutes1?lang=en
		//First let's construct the MQTT messages that need to be sent:
		private var connectMessage:MQTT_Protocol;
		private var publishMessage:MQTT_Protocol;
		private var pubrelMessage:MQTT_Protocol;
		private var subscribeMessage:MQTT_Protocol;
		private var unsubscribeMessage:MQTT_Protocol;
		private var disconnectMessage:MQTT_Protocol;
		private var pingMessage:MQTT_Protocol;
		//The Keep Alive timer is present in the variable header of a MQTT CONNECT message.
		private var keep_alive_timer:Timer; //Set to 10 seconds (0x000A).
		private var servicing:Boolean; /*service indicator*/
		//----------------------------------
		//  CONSTANTS
		//----------------------------------
		private static const MAX_LEN_UUID:int=23;
		private static const MAX_LEN_TOPIC:int=7;
		private static const MAX_LEN_USERNAME:int=12;
		//Topic level separator
		public static const TOPIC_LEVEL_SEPARATOR:String = "/";
		//Multi-level wildcard
		public static const TOPIC_M_LEVEL_WILDCARD:String = "#";
		//Single-level wildcard
		public static const TOPIC_S_LEVEL_WILDCARD:String = "+";
		//as3Logger
		private static const LOG:ILogger=LogUtil.getLogger(MQTTSocket);

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
		/**
		 * 
		 * @param host The MQTT broker host name.
		 * @param port The MQTT broker host port.
		 * @param topicname The MQTT broker default topic name.
		 * @param clientid The MQTT broker client ID.
		 * @param username Position: bits 6 of the Connect flags byte.
		 * @param password Position: bits 7 of the Connect flags byte.
		 * @param willRetain Position: bit 5 of the Connect flags byte.
		 * @param willQos Position: bits 4 and 3 of the Connect flags byte.
		 * @param willFlag Position: bit 2 of the Connect flags byte. 
		 * @param cleanSession Position: bit 1 of the Connect flags byte.
		 * 
		 */		
//		public function MQTTSocket(host:String=null, port:int=1883, topicname:String=null, clientid:String=null, username:String=null, password:String=null,willRetain:Boolean=true,willQos:Boolean=true,willFlag:Boolean=true,cleanSession:Boolean=true)
		public function MQTTSocket(host:String=null, port:int=1883,username:String=null, password:String=null, topicname:String=null, clientid:String=null, will:Boolean=true,cleanSession:Boolean=true)
		{
			//parameters store
			if (host)
				this.host=host; //TODO:ip and hostname regexp test or match function.
			if (port)
				this.port=port;
			if (topicname)
			{
				if (topicname.length > MAX_LEN_TOPIC)
					throw new Error("Out of range ".concat(MAX_LEN_TOPIC, "!"));
				var pattern:RegExp = /\/|\+|\#/;
				if (topicname.search(pattern) != -1)
					throw new Error("Illegal topic name,include: ".concat(TOPIC_LEVEL_SEPARATOR,TOPIC_M_LEVEL_WILDCARD,TOPIC_S_LEVEL_WILDCARD));
				this.topicname=topicname;
			}
			if (clientid)
			{
				if (clientid.length > MAX_LEN_UUID)
					throw new Error("Out of range ".concat(MAX_LEN_UUID, "!"));
				this.clientid=clientid;
			}
			else
			{
				this.clientid=UIDUtil.createUID(); //Assure unique. and cut off the string length to 16.
				this.clientid=this.shortenString(this.clientid, MAX_LEN_UUID);
			}
			//Any out of range issue???
			//It is recommended that user names are kept to 12 characters or
			//fewer, but it is not required.
			if (username)
			{
				if (username.length > MAX_LEN_USERNAME)
					throw new Error("Out of range ".concat(MAX_LEN_USERNAME, "!"));
				this.username=username;
			}
			if (password)
			{
				if (password.length > MAX_LEN_USERNAME)
					throw new Error("Out of range ".concat(MAX_LEN_USERNAME, "!"));
				this.password=password;
			}
			//			this.publishMessage.writeUTFBytes("HELLO"); // (0x48, 0x45 , 0x4c , 0x4c, 0x4f); //HELLO is the message
			//Will flag/Qos/Retain
			if (will)
				this.will = MQTT_Protocol.WILL;
			//Clean Session flag,Set (1).
			if (cleanSession)
				this.cleanSession = cleanSession;
			//Notice: You need to define a cross domain policy file at your remote server root document, or have a policy file server on the target. 
			Security.allowDomain("*");
			//			Security.loadPolicyFile("http://www.lookbackon.com/crossdomain.xml");  
			//event listeners
			socket=new Socket(host, port);
			socket.addEventListener(Event.CONNECT, onConnect); //dispatched when the connection is established
			socket.addEventListener(Event.CLOSE, onClose); //dispatched when the connection is closed
			socket.addEventListener(IOErrorEvent.IO_ERROR, onError); //dispatched when an error occurs
			socket.addEventListener(ProgressEvent.SOCKET_DATA, onSocketData); //dispatched when socket can be read
			socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecError); //dispatched when security gets in the way
			//Timer for ping function.
			//If a client does not receive a PINGRESP message within a Keep Alive time period after
			//sending a PINGREQ, it should close the TCP/IP socket connection.
			keep_alive_timer=new Timer(keepalive / 2 * 1000);
			keep_alive_timer.addEventListener(TimerEvent.TIMER, onPing);

		}

		//--------------------------------------------------------------------------
		//
		//  Public methods
		//
		//--------------------------------------------------------------------------
		//
		public function subscribe(topicnames:Vector.<String>, Qoss:Vector.<int>, QoS:int=0):void
		{
			//subscribe list store,and subscribe to socket server.
			var bytes:ByteArray = new ByteArray();
			
			if( QoS ) msgid++;
			bytes.writeByte(msgid >> 8);
			bytes.writeByte(msgid % 256);
			
			var i:int;
			var pattern:RegExp = /\/|\+|\#/;
			
			for(i = 0; i < topicnames.length; i++){
				if (topicnames[i].search(pattern) != -1)
					throw new Error("Illegal topic name,include: ".concat(TOPIC_LEVEL_SEPARATOR,TOPIC_M_LEVEL_WILDCARD,TOPIC_S_LEVEL_WILDCARD));
				if (topicnames[i].length > MAX_LEN_TOPIC)
					throw new Error("Out of range ".concat(MAX_LEN_TOPIC, "!"));
				
				writeString(bytes, topicnames[i]);
				bytes.writeByte(Qoss[i]);
			}
			//TODO:send subscribe message
			var type:int=MQTT_Protocol.SUBSCRIBE;
				type += (QoS << 1);
			this.subscribeMessage=new MQTT_Protocol();
			this.subscribeMessage.writeMessageType(type);
			this.subscribeMessage.writeMessageValue(bytes);
			//
			socket.writeBytes(this.subscribeMessage);
			socket.flush();
			
			LOG.info("Subscribe sent");
		}
		
		public function unsubscribe(topicnames:Vector.<String>, QoS:int=0):void
		{
			//unubscribe list store,and unubscribe to socket server.
			var bytes:ByteArray = new ByteArray();
			if( QoS ) msgid++;
				bytes.writeByte(msgid >> 8);
				bytes.writeByte(msgid % 256);
			var pattern:RegExp = /\/|\+|\#/;
			var i:int;
			for(i = 0; i < topicnames.length; i++){
				if (topicnames[i].search(pattern) != -1)
					throw new Error("Illegal topic name,include: ".concat(TOPIC_LEVEL_SEPARATOR,TOPIC_M_LEVEL_WILDCARD,TOPIC_S_LEVEL_WILDCARD));
				if (topicnames[i].length > MAX_LEN_TOPIC)
					throw new Error("Out of range ".concat(MAX_LEN_TOPIC, "!"));
				
				writeString(bytes, topicnames[i]);
			}
			//TODO:send unubscribe message
			var type:int=MQTT_Protocol.UNSUBSCRIBE;
			if (QoS)
				type+=QoS << 1;
			this.unsubscribeMessage=new MQTT_Protocol();
			this.unsubscribeMessage.writeMessageType(type);
			this.unsubscribeMessage.writeMessageValue(bytes);
			//
			
			socket.writeBytes(this.unsubscribeMessage);
			socket.flush();

			LOG.info("UnSsbscribe sent");
		}
		
		//
		public function publish(topicname:String, content:String, QoS:int=0, retain:int=0):void
		{
			var pattern:RegExp = /\/|\+|\#/;
			if (topicname.search(pattern) != -1)
				throw new Error("Illegal topic name,include: ".concat(TOPIC_LEVEL_SEPARATOR,TOPIC_M_LEVEL_WILDCARD,TOPIC_S_LEVEL_WILDCARD));
			//TODO:socket sever response detect.
			var bytes:ByteArray=new ByteArray();
			writeString(bytes, topicname);
			//
			if (QoS)
			{
				msgid++;
				bytes.writeByte(msgid >> 8);
				bytes.writeByte(msgid % 256);
			}
			//
			writeString(bytes, content);
			//
			var type:int=MQTT_Protocol.PUBLISH;
				type += (QoS << 1);
			if (retain)
				type += 1;
			this.publishMessage=new MQTT_Protocol();
			this.publishMessage.writeMessageType(type);
			this.publishMessage.writeMessageValue(bytes);
			//
			LOG.info("MQTT publishMessage.length:{0}", this.publishMessage.length);
			this.socket.writeBytes(this.publishMessage, 0, this.publishMessage.length);
			this.socket.flush();
			
			//
			LOG.info("Publish sent");
		}

		public function connect(host:String=null, port:int=0):void
		{
			if (host)
				this.host=host; //TODO:ip and hostname regexp test or match function.
			if (port)
				this.port=port;
			//
			socket.connect(this.host, this.port);
		}

		/* disconnect: sends a proper disconect command */
		public function close():void
		{
			if (this.disconnectMessage == null)
			{
				this.disconnectMessage=new MQTT_Protocol();
				this.disconnectMessage.writeType(MQTT_Protocol.DISCONNECT);
			}
			socket.writeBytes(this.disconnectMessage);
			socket.flush();
			socket.close();
			//dispatch event
			this.dispatchEvent(new MQTTEvent(MQTTEvent.CLOSE, false, false));
		}

		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------
		protected function writeString(bytes:ByteArray, str:String):void
		{
			var len:int=str.length;
			var msb:int=len >> 8;
			var lsb:int=len % 256;
			bytes.writeByte(msb);
			bytes.writeByte(lsb);
			bytes.writeMultiByte(str, 'utf-8');
		}

		//
		protected function onConnect(event:Event):void
		{
			//			trace(event);
			//			socket.writeUTFBytes("GET / HTTP/1.1\n");
			//			socket.writeUTFBytes("Host: hejp.co.uk\n");
			//			socket.writeUTFBytes("\n");
			//			All data values are in big-endian order: higher order bytes precede lower order bytes.
			LOG.info("MQTT byte order:{0}", this.socket.endian);
			if (this.socket.endian != Endian.BIG_ENDIAN)
			{
				throw new Error("Endian failed!");
			}
			if (this.connectMessage == null)
			{
				this.connectMessage=new MQTT_Protocol();
				var bytes:ByteArray=new ByteArray();
				bytes.writeByte(0x00); //0
				bytes.writeByte(0x06); //6
				bytes.writeByte(0x4d); //M
				bytes.writeByte(0x51); //Q
				bytes.writeByte(0x49); //I
				bytes.writeByte(0x73); //S
				bytes.writeByte(0x64); //D
				bytes.writeByte(0x70); //P
				bytes.writeByte(0x03); //Protocol version = 3
				//Connect flags
				var type:int=0;
				if (cleanSession)
					type+=2;
				//			Will flag is set (1)
				//			Will QoS field is 1
				//			Will RETAIN flag is clear (0)
				if (will)//(willFlag,willQos,willRetain)
				{
					type+=4;
					type+=this.will['qos'] << 3;
					if (this.will['retain'])
						type+=32;
				}
				if (username)
					type+=128;
				if (password)
					type+=64;
				bytes.writeByte(type); //Clean session only
				//Keep Alive timer
				bytes.writeByte(keepalive >> 8); //Keepalive MSB
				bytes.writeByte(keepalive & 0xff); //Keepaliave LSB = 60
				writeString(bytes, clientid);
				writeString(bytes, username ? username : "");
				writeString(bytes, password ? password : "");
				this.connectMessage.writeMessageType(MQTT_Protocol.CONNECT); //Connect
				this.connectMessage.writeMessageValue(bytes); //Connect
			}
			//
			LOG.info("MQTT connectMesage.length:{0}", this.connectMessage.length);
			this.socket.writeBytes(this.connectMessage, 0, this.connectMessage.length);
			this.socket.flush();
			//dispatch event
			//just TCP/IP connection not MQTT connection
			//this.dispatchEvent(new MQTTEvent(MQTTEvent.CONNECT, false, false));
		}

		//
		protected function onClose(event:Event):void
		{
			// Security error is thrown if this line is excluded
			//dispatch event
			this.dispatchEvent(new MQTTEvent(MQTTEvent.CLOSE, false, false));
			//TODO:Other dispose staff
			keep_alive_timer.stop();
		}

		//
		protected function onError(event:IOErrorEvent):void
		{
			LOG.error("MQTT IO Error: {0}", event);
			//dispatch event
			this.dispatchEvent(new MQTTEvent(MQTTEvent.ERROR, false, false));
		}

		//
		protected function onSecError(event:SecurityErrorEvent):void
		{
			LOG.error("MQTT Security Error: {0}", event);
			//dispatch event
			this.dispatchEvent(new MQTTEvent(MQTTEvent.ERROR, false, false));
		}

		//
		protected function onPing(event:TimerEvent):void
		{
			if (this.pingMessage == null)
			{
				this.pingMessage=new MQTT_Protocol();
				
				this.pingMessage.writeMessageType(MQTT_Protocol.PINGREQ);
				this.pingMessage.writeMessageValue(new ByteArray);
			}
			LOG.info("MQTT pingMessage.length:{0}", this.pingMessage.length);
			socket.writeBytes(this.pingMessage, 0, this.pingMessage.length);
			
			socket.flush();
			LOG.info("Ping sent.");
		}

		//
		protected function onSocketData(event:ProgressEvent):void
		{
			LOG.info("MQTT Socket received {0}{1}", this.socket.bytesAvailable, " byte(s) of data.");
			// Loop over all of the received data, and only read a byte if there  is one available 
			
			while( socket.bytesAvailable ){
				//FixHead
				var result:MQTT_Protocol=new MQTT_Protocol();
					result.writeMessageFromBytes(socket);
				
				LOG.info("Protocol Type:{0}", result.readType().toString(16));
				LOG.info("Protocol Length:{0}", result.length);
				LOG.info("Protocol DUP:{0}", result.readDUP());
				LOG.info("Protocol QoS:{0}", result.readQoS());
				LOG.info("Protocol RETAIN:{0}", result.readRETAIN());
				LOG.info("Protocol RemainingLength:{0}", result.readRemainingLength());
				LOG.info("Protocol Variable Header Length:{0}", result.readMessageValue().length);
				LOG.info("Protocol PayLoad Length:{0}", result.readPayLoad().length);
				
				switch (result.readType())
				{
					case MQTT_Protocol.CONNACK:
						onConnack(result);
						LOG.info("Acknowledge connection request");
						break;
					case MQTT_Protocol.PUBLISH:
						onPublish(result);
						LOG.info("Publish message");
						break;
					case MQTT_Protocol.PUBACK:
						onPuback(result);
						LOG.info("Publish acknowledgment");
						break;
					case MQTT_Protocol.PUBREC:
						onPubrec(result);
						LOG.info("Assured publish received(part1)");
						break;
//					case MQTT_Protocol.PUBREL:
//						onPubrel(result);
//						LOG.info("Assured publish release(part2)");
//						break;
					case MQTT_Protocol.PUBCOMP:
						onPubcomp(result);
						LOG.info("Assured publish complete(part3)");
						break;
					case MQTT_Protocol.SUBSCRIBE:
						onSubscribe(result);
						LOG.info("Subscribe to named topics");
						break;
					case MQTT_Protocol.SUBACK:
						onSuback(result);
						LOG.info("Subscription acknowledgement");
						break;
					case MQTT_Protocol.UNSUBSCRIBE:
						onUnsubscribe(result);
						LOG.info("Subscription acknowledgement");
						break;
					case MQTT_Protocol.UNSUBACK:
						onUnsuback(result);
						LOG.info("Unsubscribe acknowledgement");
						break;
					case MQTT_Protocol.PINGREQ:
						onPingreq(result);
						LOG.info("PING request");
						break;
					case MQTT_Protocol.PINGRESP:
						onPingresp(result);
						LOG.info("PING response");
						break;
					case MQTT_Protocol.DISCONNECT:
						onDisconnect(result);
						LOG.info("Client is Disconnecting");
						break;
					default:
						LOG.info("Reserved");
						break;
				}
			}
		}

		//The CONNACK message is the message sent by the server in response to a CONNECT request from a client.
		protected function onConnack(packet:MQTT_Protocol):void
		{
			var varHead:ByteArray=packet.readMessageValue()
				varHead.position=1;
			switch (varHead.readUnsignedByte())
			{
				case 0x00:
					LOG.debug("Socket connected");
					servicing=true;
					keep_alive_timer.start();
					//dispatch event
					this.dispatchEvent(new MQTTEvent(MQTTEvent.CONNECT, false, false,"Socket connected"));
					break;
				case 0x01:
					LOG.debug("Connection Refused: unacceptable protocol version");
					//dispatch event
					this.dispatchEvent(new MQTTEvent(MQTTEvent.ERROR, false, false, "Connection Refused: unacceptable protocol version"));
					break;
				case 0x02:
					LOG.debug("Connection Refused: identifier rejected");
					//dispatch event
					this.dispatchEvent(new MQTTEvent(MQTTEvent.ERROR, false, false, "Connection Refused: identifier rejected"));
					break;
				case 0x03:
					LOG.debug("Connection Refused: server unavailable");
					//dispatch event
					this.dispatchEvent(new MQTTEvent(MQTTEvent.ERROR, false, false, "Connection Refused: server unavailable"));
					break;
				case 0x04:
					LOG.debug("Connection Refused: bad user name or password");
					//dispatch event
					this.dispatchEvent(new MQTTEvent(MQTTEvent.ERROR, false, false, "Connection Refused: bad user name or password"));
					break;
				case 0x05:
					LOG.debug("Connection Refused: not authorized");
					//dispatch event
					this.dispatchEvent(new MQTTEvent(MQTTEvent.ERROR, false, false, "Connection Refused: not authorized"));
					break;
				default:
					LOG.debug("Reserved for future use");
					break;
			}
		}

		//TODO:
		protected function onPublish(packet:MQTT_Protocol):void
		{
			//Fixed header
			//Variable header
			//Payload
			//Actions
			var varHead:ByteArray=packet.readMessageValue();
			var length:uint = (varHead.readUnsignedByte() << 8) + varHead.readUnsignedByte();
			var topicName:String = varHead.readMultiByte(length, "utf8");
			var messageId:uint = (varHead.readUnsignedByte() << 8) + varHead.readUnsignedByte();
			var payLoad:ByteArray = packet.readPayLoad();
			length = (payLoad.readUnsignedByte() << 8) + payLoad.readUnsignedByte();
			var topicContent:String = payLoad.readMultiByte(length, "utf8");
			
			LOG.info("Publish Message ID {0}", messageId);
			LOG.info("Publish TopicName {0}", topicName);
			LOG.info("Publish TopicContent {0}", topicContent);
		}

		//A PUBACK message is the response to a PUBLISH message with QoS level 1. A PUBACK
		//		message is sent by a server in response to a PUBLISH message from a publishing client,
		//		and by a subscriber in response to a PUBLISH message from the server.
		protected function onPuback(packet:MQTT_Protocol):void
		{
			//Fixed header
			switch(packet.readRemainingLength()){
				case 0x02:
					//Variable header
					var varHead:ByteArray = packet.readMessageValue();
					var messageId:uint = (varHead.readUnsignedByte() << 8) + varHead.readUnsignedByte();
					LOG.info("Puback Message ID {0}", messageId)
					break;
				default:
					break;
			}
			//Payload
			//Actions
		}

		//TODO:
		protected function onPubrec(packet:MQTT_Protocol):void
		{
			//Fixed header
			switch(packet.readRemainingLength()){
				case 0x02:
					//Variable header
					var varHead:ByteArray = packet.readMessageValue();
					var messageId:uint = (varHead.readUnsignedByte() << 8) + varHead.readUnsignedByte();
					LOG.info("Pubrec Message ID {0}", messageId)
					
					var bytes:ByteArray=new ByteArray();
					writeString(bytes, topicname);
					//
					msgid++;
					bytes.writeByte(messageId >> 8);
					bytes.writeByte(messageId % 256);
					var type:int=MQTT_Protocol.PUBREL;
					type += (2 << 1);
					this.pubrelMessage=new MQTT_Protocol();
					this.pubrelMessage.writeMessageType(type);
					this.pubrelMessage.writeMessageValue(bytes);
					//
					LOG.info("Assured publish release(part2)");
					LOG.info("MQTT pubrelMessage.length:{0}", this.pubrelMessage.length);
					this.socket.writeBytes(this.pubrelMessage, 0, this.pubrelMessage.length);
					this.socket.flush();
					break;
				default:
					break;
			}
			//Payload
			//Actions
		}

		//TODO:
		protected function onPubrel(packet:MQTT_Protocol):void
		{
			//Fixed header
			switch(packet.readRemainingLength()){
				case 0x02:
					//Variable header
					var varHead:ByteArray = packet.readMessageValue();
					var messageId:uint = (varHead.readUnsignedByte() << 8) + varHead.readUnsignedByte();
					LOG.info("Pubrel Message ID {0}", messageId)
					break;
				default:
					break;
			}
			//Payload
			//Actions
		}

		//TODO:
		protected function onPubcomp(packet:MQTT_Protocol):void
		{
			//Fixed header
			switch(packet.readRemainingLength()){
				case 0x02:
					//Variable header
					var varHead:ByteArray = packet.readMessageValue();
					var messageId:uint = (varHead.readUnsignedByte() << 8) + varHead.readUnsignedByte();
					LOG.info("Pubcomp Message ID {0}", messageId)
					break;
				default:
					break;
			}
			//Payload
			//Actions
		}

		//TODO:
		protected function onSubscribe(packet:MQTT_Protocol):void
		{
			//Fixed header
			//Variable header
			//Payload
			//Actions
			var varHead:ByteArray=packet.readMessageValue();
			varHead.position=1;
			switch (varHead.readUnsignedByte())
			{
				case 0x00:
					break;
				default:
					break;
			}
		}

		//TODO:
		protected function onSuback(packet:MQTT_Protocol):void
		{
			//Fixed header
			var payloadLen:int = packet.readRemainingLength();
			//Variable header
			var varHead:ByteArray = packet.readMessageValue();
			var messageId:uint = (varHead.readUnsignedByte() << 8) + varHead.readUnsignedByte();
			LOG.info("Suback Message ID {0}", messageId)
			//Payload
			var payload:ByteArray = packet.readPayLoad();
			var i:int;
			for( i = 0; i < payload.length; i++){
				var qos:int = payload.readUnsignedByte() & 0x03;
				LOG.info("Suback Topic {0} QoS {0}", i, qos);
			}
			//Actions
		}

		//TODO:
		protected function onUnsubscribe(packet:MQTT_Protocol):void
		{
			//Fixed header
			//Variable header
			//Payload
			//Actions
			var varHead:ByteArray=packet.readMessageValue();
			varHead.position=1;
			switch (varHead.readUnsignedByte())
			{
				case 0x00:
					break;
				default:
					break;
			}
		}

		//TODO:
		protected function onUnsuback(packet:MQTT_Protocol):void
		{
			//Fixed header
			switch(packet.readRemainingLength()){
				case 0x02:
					//Variable header( 2 bytes)
					var varHead:ByteArray = packet.readMessageValue();
					var messageId:uint = (varHead.readUnsignedByte() << 8) + varHead.readUnsignedByte();
					LOG.info("Unsuback Message ID {0}", messageId)
					break;
				default:
					break;
			}
			
			//Payload
			//Actions
		}

		//TODO:
		protected function onPingreq(packet:MQTT_Protocol):void
		{
			//Only Fixed header
			switch (packet.readRemainingLength())
			{
				case 0x00:
					break;
				default:
					break;
			}
			//Variable header
			//Payload
			//Actions
		}

		//TODO:
		protected function onPingresp(packet:MQTT_Protocol):void
		{
			//Only Fixed header
			switch (packet.readRemainingLength())
			{
				case 0x00:
					break;
				default:
					break;
			}
			//Variable header
			//Payload
			//Actions
		}
		
		//TODO:
		protected function onDisconnect(packet:MQTT_Protocol):void
		{
			//Only Fixed header
			switch (packet.readRemainingLength())
			{
				case 0x00:
					break;
				default:
					break;
			}
			//Variable header
			//Payload
			//Actions
		}
		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------




		//
		private function shortenString(str:String, len:int):String
		{
			var result:String=str;
			if (str.length > len)
			{
				result=str.substr(0, len);
			}
			return result;
		}
	}

}
