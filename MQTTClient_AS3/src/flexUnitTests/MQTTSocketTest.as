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
package flexUnitTests
{
	//--------------------------------------------------------------------------
	//
	//  Imports
	//
	//--------------------------------------------------------------------------
//	import com.godpaper.mqtt.as3.core.MQTTEvent;
	import com.godpaper.mqtt.as3.impl.MQTTSocket;
	
	import flexunit.framework.Assert;
	
	/**
	 * MQTTSocketTest.as class.   	
	 * @author yangboz
	 * @langVersion 3.0
	 * @playerVersion 11.2+
	 * @airVersion 3.2+
	 * Created Dec 24, 2012 9:37:13 AM
	 */
	public class MQTTSocketTest
	{		
		private var mqttSocket:MQTTSocket;
		private static const MY_HOST:String="test.mosquitto.org"; //You'd better change it to your private ip address! //test.mosquitto.org//16.157.65.23(Ubuntu)//15.185.106.72(hp cs instance)
		private static const MY_PORT:Number=1883; //Socket port.
		private static const MY_USERNAME:String="test";
		private static const MY_PASSWORD:String="test";
		private static const MY_TOPIC_NAME:String="test";
		[Before]
		public function setUp():void
		{
			this.mqttSocket = new MQTTSocket(MY_HOST,MY_PORT,MY_USERNAME,MY_PASSWORD,MY_TOPIC_NAME);
			trace("trace(this.mqttSocket.isConnect):",this.mqttSocket.isConnect);
		}
		
		[After]
		public function tearDown():void
		{
			trace("trace(this.mqttSocket.isConnect):",this.mqttSocket.isConnect);
			this.mqttSocket = null;
		}
		
		[BeforeClass]
		public static function setUpBeforeClass():void
		{
		}
		
		[AfterClass]
		public static function tearDownAfterClass():void
		{
		}
		
		[Test]
		public function testClose():void
		{
//			Assert.fail("Test method Not yet implemented");
			this.mqttSocket.close();
			Assert.assertEquals(this.mqttSocket.isConnect,false);
		}
		
		[Test]
		public function testConnect():void
		{
			this.mqttSocket.connect(MY_HOST,MY_PORT);
			//TODO:Wait a minutes to MQTTSocket connection..
//			Assert.fail("Test method Not yet implemented");
			Assert.assertEquals(this.mqttSocket.isConnect,false);//At once, the connection will not be connected.
		}
		
		[Test]
		public function testMQTTSocket():void
		{
//			Assert.fail("Test method Not yet implemented");
			Assert.assertNotNull(this.mqttSocket);
		}
		
		[Test]
		public function testPublish():void
		{
			Assert.fail("Test method Not yet implemented");
		}
		
		[Test]
		public function testSubscribe():void
		{
			Assert.fail("Test method Not yet implemented");
		}
		
		[Test]
		public function testUnsubscribe():void
		{
			Assert.fail("Test method Not yet implemented");
		}
	}
}