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
	import flash.display.Sprite;
	import flash.net.Socket;
	import flash.system.Security;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	
	/**
	 * Pure Action Script 3 that implements the MQTT (Message Queue Telemetry Transport) protocol, a lightweight protocol for publish/subscribe messaging. </br>
	 * AS3 socket is a mechanism used to send data over a network (e.g. the Internet), it is the combination of an IP address and a port. </br>
	 * @see http://public.dhe.ibm.com/software/dw/webservices/ws-mqtt/mqtt-v3r1.html
	 * @see http://public.dhe.ibm.com/software/dw/webservices/ws-mqtt/MQTT_V3.1_Protocol_Specific.pdf
	 * @see http://mosquitto.org/download/
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
		private var mqttSocket:Socket;
		//----------------------------------
		//  CONSTANTS
		//----------------------------------
		//Notice: You need to define a cross domain policy file at your remote server root document, or have a policy file server on the target. 
		private static const TOKUDU_HOST:String = "16.157.65.23";//You'd better change it to your private ip address! 
		private static const TOKUDU_PORT:Number = 1883;//Socket port.
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
			this.mqttSocket = new Socket();
			//
			Security.allowDomain("*");
			//
			mqttSocket.addEventListener(Event.CONNECT, onConnect);//dispatched when the connection is established
			mqttSocket.addEventListener(Event.CLOSE, onClose);//dispatched when the connection is closed
			mqttSocket.addEventListener(IOErrorEvent.IO_ERROR, onError);//dispatched when an error occurs
			mqttSocket.addEventListener(ProgressEvent.SOCKET_DATA, onResponse);//dispatched when socket can be read
			mqttSocket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecError);//dispatched when security gets in the way
			//
			mqttSocket.connect(TOKUDU_HOST,TOKUDU_PORT);
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
		private function onConnect(event:Event):void {
			trace(event);
//			mqttSocket.writeUTFBytes("GET / HTTP/1.1\n");
//			mqttSocket.writeUTFBytes("Host: hejp.co.uk\n");
//			mqttSocket.writeUTFBytes("\n");
		}
		
		private function onClose(event:Event):void {
			// Security error is thrown if this line is excluded
			trace(event);
			mqttSocket.close();
		}
		
		private function onError(event:IOErrorEvent):void {
			trace("IO Error: "+event);
		}
		
		private function onSecError(event:SecurityErrorEvent):void {
			trace("Security Error: "+event);
		}
		
		private function onResponse(event:ProgressEvent):void {
			trace(event);
			if (mqttSocket.bytesAvailable>0) {
				trace(mqttSocket.readUTFBytes(mqttSocket.bytesAvailable));
			}
		}
	}
	
}