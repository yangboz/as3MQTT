/*
	Adobe Systems Incorporated(r) Source Code License Agreement
	Copyright(c) 2005 Adobe Systems Incorporated. All rights reserved.
	
	Please read this Source Code License Agreement carefully before using
	the source code.
	
	Adobe Systems Incorporated grants to you a perpetual, worldwide, non-exclusive, 
	no-charge, royalty-free, irrevocable copyright license, to reproduce,
	prepare derivative works of, publicly display, publicly perform, and
	distribute this source code and such derivative works in source or 
	object code form without any attribution requirements.  
	
	The name "Adobe Systems Incorporated" must not be used to endorse or promote products
	derived from the source code without prior written permission.
	
	You agree to indemnify, hold harmless and defend Adobe Systems Incorporated from and
	against any loss, damage, claims or lawsuits, including attorney's 
	fees that arise or result from your use or distribution of the source 
	code.
	
	THIS SOURCE CODE IS PROVIDED "AS IS" AND "WITH ALL FAULTS", WITHOUT 
	ANY TECHNICAL SUPPORT OR ANY EXPRESSED OR IMPLIED WARRANTIES, INCLUDING,
	BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
	FOR A PARTICULAR PURPOSE ARE DISCLAIMED.  ALSO, THERE IS NO WARRANTY OF 
	NON-INFRINGEMENT, TITLE OR QUIET ENJOYMENT.  IN NO EVENT SHALL MACROMEDIA
	OR ITS SUPPLIERS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
	EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, 
	PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
	OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
	WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR 
	OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOURCE CODE, EVEN IF
	ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
package flexunit.framework
{

import flash.utils.*;

/**
 * The Base Class for test cases. A Test case defines the fixture in which to run multiple tests. 
 * @description 
 * Each test runs in its own fixture so there can be no side effects among test runs.
 * Here is an example:
 * <code>
 * import samples.com.iterationtwo.Money;
 * import flexunit.framework.TestCase;
 * 
 * class samples.test.com.iterationtwo.TestMoney extends TestCase
 * {
 *     ...
 * }
 * </code>
 *
 * For each test, implement a method which interacts
 * with the fixture. Verify the expected results using the assertions
 * residing in the base class <code>Assert</code>.
 * <code>
 *  public function testAddMoney()
 *  {
 *     var dollars1:Number = 3;
 *     var cents1:Number = 50;
 *     var money1:Money = new Money( dollars1, cents1 );
 *
 *     var dollars2:Number = 3;
 *     var cents2:Number = 20;
 *     var money2:Money = new Money( dollars2, cents2 );
 *
 *     var money3:Money = money1.addMoney( money2 )
 *
 *     assertNotNull( "money was null", money3 );
 *     assertNotUndefined( "money was undefined", money3 );
 *
 *     assertEquals( "Dollars should be 6", 6, money3.dollars );
 *     assertEquals( "Cents should be 70", 70, money3.cents );
 *  } 
 * </code>
 * You can also specify <code>setUp()</code> and <code>tearDown()</code> methods
 * to initialize and clean-up tests.
 * <code>
 * import samples.com.iterationtwo.Money;
 * import flexunit.framework.TestCase;
 * 
 * class samples.test.com.iterationtwo.TestMoneyWithSetUpTearDown extends TestCase
 * {
 *    public function setUp():void
 *    {
 *       money = new Money( 3, 50 );
 *    }
 * 
 *    public function tearDown():void
 *    {
 *       money = null;
 *    }
 *
 *    private var money:Money;
 * }
 * </code>
 * The tests to be run can be collected into a <code>TestSuite</code> and run using a a <code>TestRunner</code>.
 *
 * The AS3 version has been extended to allow asynchronous tests.  This means that an individual test method
 * will not be considered complete until any subsequent asynchronous calls that have been specified have completed.
 * Adding an asynchronous callback is easy, simply call the addAsync method passing in the callback method and the
 * time in which it is expected to complete.  You can also pass any data you want carried through the call.  addAsync
 * will return a function capable of handling generic events which you can then set as the event listener on an object.
 * E.g.,
 * <code>
 *   public function testAsync():void
 *   {
 *      var myDispatcher : ValueDispatcher = new ValueDispatcher();
 *      var helper : Function = addAsync(eventHandler, 200, "foo");
 *      myDispatcher.addEventListener("value", helper);
 *      myDispatcher.dispatchValue("foo", 100); //the dispatcher should send a value in 100 ms
 *   }
 *
 *   //the expected is the extra data that was passed in addAsync above
 *   public function eventHandler(event : ValueEvent, expected : String)
 *   {
 *      var actual : String = event.value;
 *      assertEquals(expected, actual);
 *   }
 * <code>
 *
 *
 * @see flexunit.flexui.TestRunner 
 * @see Assert
 * @see TestSuite
 * @see TestResult
 *
 */ 
 
public class TestCase extends Assert implements Test
{

//------------------------------------------------------------------------------

/** 
 * The TestCase constructor. If you provide a contstructor in a <code>TestCase</code> subclass,
 * you should ensure that this constructor is called.
 * @param The name of the test method to be called in the test run.
 */
    public function TestCase( methodName : String = null)
    {
        super();
        this.methodName = methodName;
        asyncMethods = new Array();
    }

//------------------------------------------------------------------------------

/**
 * Creates a new <code>TestResult</code> and runs the tests, populating that <code>TestResult</code>
 * with the results.
 */
    public function run() : TestResult
    {
        var result : TestResult = new TestResult();
        runWithResult( result );
        
        return result;
    }

//------------------------------------------------------------------------------

/**
 * Runs the tests, populating the <code>result</code> parameter.
 * @param The TestResult instance to be populated
 */
    public function runWithResult( result:TestResult ):void
    {
        result.run( this );
    }


//------------------------------------------------------------------------------

/**
 * Runs <code>setUp()</code>
 */
    public function runStart():void
    {
        setUp();
    }

//------------------------------------------------------------------------------

/**
 * Runs the normal test method or the next asynchronous method
 */
    public function runMiddle():void
    {
        runTestOrAsync();
    }

//------------------------------------------------------------------------------

/**
 * Runs <code>tearDown()</code>
 */
    public function runFinish():void
    {
        asyncTestHelper = null;
        tearDown();
    }

//------------------------------------------------------------------------------

/** 
 * Empty implementation of <code>setUp()</code>. Can be overridden in test class.
 */
    public function setUp():void
    {
    }

//------------------------------------------------------------------------------

/** 
 * Empty implementation of <code>tearDown()</code>. Can be overridden in test class.
 */
    public function tearDown():void
    {
    }

//------------------------------------------------------------------------------

/**
 * The number of test cases in this test class.
 * @return A Number representation the count of test cases in this test class. Always returns 1 for <code>TestCase</code>
 */
    public function countTestCases():Number
    {
        return 1;
    }
    
//------------------------------------------------------------------------------

/** 
 * A string representation of the test case
 * @return A string representation of the test class name and the test method name.
 */
    public function toString():String
    {
        return methodName + " (" + className + ")";
    }
    
//------------------------------------------------------------------------------

/** 
 * Returns the the fully qualified class name
 * @return The fully qualified class name
 */
    public function get className():String
    {
        return(describeType(this).attribute("name").toString());
    }
    
//------------------------------------------------------------------------------

/** 
 * Runs the test or if there is an AsynchronousTestHelper runs the next asynchronous method
 */
    private function runTestOrAsync() : void
    {
        if (methodName == null || methodName == "")
        {
            fail("No test method to run");
        }

        if (asyncTestHelper != null)
        {
            asyncTestHelper.runNext();
        }
        else
        {
            this[ methodName ]();
        }
    }
    
//------------------------------------------------------------------------------

/**
 * Add an asynchronous check point to the test.
 * This method will return an event handler function.
 *
 * @param func the Function to execute when things have been handled
 * @param timeout if the function isn't called within this time the test is considered a failure
 * @param passThroughData data that will be passed to your function (only if non-null) as the 2nd argument
 * @param failFunc a Function that will be called if the asynchronous function fails to execute, useful if perhaps the failure to
 *     execute was intentional or if you want a specific failure message
 * @return the Function that can be used as an event listener
 */
    public function addAsync(func : Function, timeout : int, passThroughData : Object = null, failFunc : Function = null) : Function
    {
        if (asyncTestHelper == null)
        {
            asyncTestHelper = new AsyncTestHelper(this, testResult);
        }
        asyncMethods.push({func: func, timeout: timeout, extraData: passThroughData, failFunc: failFunc});
        return asyncTestHelper.handleEvent;
    }

//------------------------------------------------------------------------------

/**
 * Returns true if there are any asynchronous methods remaining to be called
 */
    public function hasAsync() : Boolean
    {
        return asyncMethods.length > 0;
    }

//------------------------------------------------------------------------------

/**
 * Called by the TestResult to kick off wait for the next asynchronous method
 */
     public function startAsync() : void
    {
        asyncTestHelper.startAsync();
    }

//------------------------------------------------------------------------------
/**
 * The AsyncTestHelper will call this when it's ready for to start the next async.  It's possible that
 * it will need to get access to it even before async has been started if the call didn't actually end
 * up being asynchronous.
 */
    public function getNextAsync() : Object
    {
        return asyncMethods.shift();
    }

//------------------------------------------------------------------------------

/**
 * Called by the TestResult to pass along so that it can be passed for async
 */
    public function setTestResult(result : TestResult) : void
    {
        testResult = result;
    }

//------------------------------------------------------------------------------

	public function getTestMethodNames() : Array
	{
		if(methodNames == null)
		{
			methodNames = new Array();
			
			var type:XML = describeType(this);
			var names:XMLList = type.method.@name;
			
			for(var i:uint = 0; i < names.length(); i++)
			{
				if( isTestMethod( String(names[i]) ) )
					methodNames.push( String(names[i]) );
			}
		}
		
		return methodNames;
	}
	
	private function isTestMethod( name:String ) : Boolean
	{
			//var pattern:RegExp = /test*/;
			//var result:Object = pattern.exec(name);
			if(name.indexOf("test",0) != 0) {
				return false;
			}
			return true;
	}
	
//------------------------------------------------------------------------------	
	
/**
 *	An array of all the test methods for this test case.
 */	
	private var methodNames : Array;
	
/** 
 * The method name of the individual test to be run
 */
    public var methodName : String;
    private var asyncMethods : Array;
    private var asyncTestHelper : AsyncTestHelper;
    private var testResult : TestResult;
}

}