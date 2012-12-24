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
	import com.godpaper.mqtt.as3.core.MQTTEvent;
	
	import flexunit.framework.Assert;
	
	/**
	 * MQTTEventTest.as class.   	
	 * @author yangboz
	 * @langVersion 3.0
	 * @playerVersion 11.2+
	 * @airVersion 3.2+
	 * Created Dec 24, 2012 9:36:44 AM
	 */
	public class MQTTEventTest
	{		
		//
		private var event:MQTTEvent;
		//
		[Before]
		public function setUp():void
		{
			this.event = new MQTTEvent(MQTTEvent.CONNECT,false,false,"testABC");
		}
		
		[After]
		public function tearDown():void
		{
			this.event = null;
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
		public function testClone():void
		{
//			Assert.fail("Test method Not yet implemented");
			Assert.assertEquals(this.event.clone().type,MQTTEvent.CONNECT);
		}
		
		[Test]
		public function testMQTTEvent():void
		{
//			Assert.fail("Test method Not yet implemented");
			Assert.assertEquals(this.event.type,MQTTEvent.CONNECT);
			Assert.assertEquals(this.event.message,"testABC");
		}
	}
}