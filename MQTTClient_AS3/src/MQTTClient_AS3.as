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
package
{
	//--------------------------------------------------------------------------
	//
	//  Imports
	//
	//--------------------------------------------------------------------------
	import com.godpaper.mqtt.as3.core.MQTTEvent;
	import com.godpaper.mqtt.as3.impl.MQTTSocket;
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

	/**
	 * Pure Action Script 3 that implements the MQTT (Message Queue Telemetry Transport) protocol, a lightweight protocol for publish/subscribe messaging. </br>
	 * AS3 socket is a mechanism used to send data over a network (e.g. the Internet), it is the combination of an IP address and a port. </br>
	 * @see https://github.com/yangboz/as3MQTT
	 * @see https://github.com/yangboz/as3MQTT/wiki
	 *
	 * @author yangboz
	 * @langVersion 3.0
	 * @playerVersion 11.2+
	 * @airVersion 3.2+
	 * Created Nov 20, 2012 10:19:53 AM
	 */
	public class MQTTClient_AS3 extends Sprite
	{
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		private var mqttSocket:MQTTSocket;
		//----------------------------------
		//  CONSTANTS
		//----------------------------------
		//Notice: You need to define a cross domain policy file at your remote server root document, or have a policy file server on the target. 
		private static const MY_HOST:String="test.mosquitto.org"; //You'd better change it to your private ip address! //test.mosquitto.org//16.157.65.23(Ubuntu)//15.185.106.72(hp cs instance)
		private static const MY_PORT:Number=1883; //Socket port.
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
		public function MQTTClient_AS3()
		{
//			Creating a Socket
			this.mqttSocket=new MQTTSocket();
			//Notice: You need to define a cross domain policy file at your remote server root document, or have a policy file server on the target. 
			Security.allowDomain("*");
//			Security.loadPolicyFile("http://www.lookbackon.com/crossdomain.xml");  
			//event listeners
			mqttSocket.addEventListener(MQTTEvent.CONNECT, onConnect); //dispatched when the connection is established
			mqttSocket.addEventListener(MQTTEvent.CLOSE, onClose); //dispatched when the connection is closed
			mqttSocket.addEventListener(IOErrorEvent.IO_ERROR, onError); //dispatched when an error occurs
			mqttSocket.addEventListener(ProgressEvent.SOCKET_DATA, onSocketData); //dispatched when socket can be read
			mqttSocket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecError); //dispatched when security gets in the way
			//try to connect
			mqttSocket.connect(MY_HOST, MY_PORT);
		}

		//--------------------------------------------------------------------------
		//
		//  Public methods
		//
		//--------------------------------------------------------------------------

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
		}

		//
		private function onClose(event:Event):void
		{
			// Security error is thrown if this line is excluded
			trace(event);
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
			trace("MQTT Socket received " + this.mqttSocket.bytesAvailable + " byte(s) of data:");
			// Loop over all of the received data, and only read a byte if there  is one available 
			var data:Vector.<int> = new Vector.<int>();
			while (mqttSocket.bytesAvailable)
			{
				// Read a byte from the socket and display it  
//				data = mqttSocket.readInt();
//				trace(mqttSocket.readUTFBytes(mqttSocket.bytesAvailable).toString());
			}
			trace(data.toString());
		}

	}

}
