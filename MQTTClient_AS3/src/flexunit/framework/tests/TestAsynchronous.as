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

package flexunit.framework.tests
{
import flexunit.framework.TestCase;
import flexunit.framework.TestSuite;
import flexunit.framework.TestResult;
import flexunit.framework.Assert;


import flash.events.Event;

import flash.utils.Timer;

public class TestAsynchronous extends TestCase
{

    public static function suite() : TestSuite
    {
        var suite: TestSuite = new TestSuite();

        suite.addTest(new TestAsynchronous("testInTimePass"));
        suite.addTest(new TestAsynchronous("testInTimeFail"));
        suite.addTest(new TestAsynchronous("testTooLatePass"));
        suite.addTest(new TestAsynchronous("testTooLateFail"));
        suite.addTest(new TestAsynchronous("testSecondInTimePass"));
        suite.addTest(new TestAsynchronous("testSecondInTimeFail"));
        suite.addTest(new TestAsynchronous("testSecondTooLatePass"));
        suite.addTest(new TestAsynchronous("testSecondTooLateFail"));
        suite.addTest(new TestAsynchronous("testNotReallyAsynchronousPass"));
        suite.addTest(new TestAsynchronous("testNotReallyAsynchronousFail"));
        suite.addTest(new TestAsynchronous("testTimeoutFunctionPass"));
        suite.addTest(new TestAsynchronous("testTimeoutFunctionFail"));

        //see notes below for why these aren't run
        //uncommented to run.
        suite.addTest(new TestAsynchronous("testInTimeError"));
        suite.addTest(new TestAsynchronous("testTooLateError"));

        return suite;
    }

    public function TestAsynchronous(name : String = null)
    {
        super(name);
    }

    public function testInTimePass() : void
    {
        var test : TestCase = new AsynchronousTestCase("testInTimePass");
        var result : TestResult = test.run();
        initAsync(result, 1, 0, 0);
    }

    public function testInTimeFail() : void
    {
        var test : TestCase = new AsynchronousTestCase("testInTimeFail");
        var result : TestResult = test.run();
        initAsync(result, 1, 1, 0);
    }

    //this test won't be run right now because the Error that is thrown propagates up and creates a dialog
    //and if the dialog isn't closed in time it screws up the timer in here.  however if you run it manaully and close
    //the dialog in time it should be ok
    public function STOPtestInTimeError() : void
    {
        var test : TestCase = new AsynchronousTestCase("testInTimeError");
        var result : TestResult = test.run();
        initAsync(result, 1, 1, 0);
    }

    public function testTooLatePass() : void
    {
        var test : TestCase = new AsynchronousTestCase("testTooLatePass");
        var result : TestResult = test.run();
        initAsync(result, 1, 1, 0);
    }

    public function testTooLateFail() : void
    {
        var test : TestCase = new AsynchronousTestCase("testTooLateFail");
        var result : TestResult = test.run();
        initAsync(result, 1, 1, 0);
    }

    //this test won't be run right now because the Error that is thrown propagates up and creates a dialog
    //and if the dialog isn't closed in time it screws up the timer in here.  however if you run it manaully and close
    //the dialog in time it should be ok
    public function STOPtestTooLateError() : void
    {
        var test : TestCase = new AsynchronousTestCase("testTooLateError");
        var result : TestResult = test.run();
        initAsync(result, 1, 1, 0);
    }

    public function testSecondInTimePass() : void
    {
        var test : TestCase = new AsynchronousTestCase("testSecondInTimePass");
        var result : TestResult = test.run();
        initAsync(result, 1, 0, 0);
    }

    public function testSecondInTimeFail() : void
    {
        var test : TestCase = new AsynchronousTestCase("testSecondInTimeFail");
        var result : TestResult = test.run();
        initAsync(result, 1, 1, 0);
    }

    public function testSecondTooLatePass() : void
    {
        var test : TestCase = new AsynchronousTestCase("testSecondTooLatePass");
        var result : TestResult = test.run();
        initAsync(result, 1, 1, 0);
    }

    public function testSecondTooLateFail() : void
    {
        var test : TestCase = new AsynchronousTestCase("testSecondTooLateFail");
        var result : TestResult = test.run();
        initAsync(result, 1, 1, 0);
    }

    public function testTimeoutFunctionPass() : void
    {
        var test : TestCase = new AsynchronousTestCase("testTimeoutFunctionPass");
        var result : TestResult = test.run();
        initAsync(result, 1, 0, 0);
    }

    public function testTimeoutFunctionFail() : void
    {
        var test : TestCase = new AsynchronousTestCase("testTimeoutFunctionFail");
        var result : TestResult = test.run();
        initAsync(result, 1, 1, 0);
    }

    public function testNotReallyAsynchronousPass() : void
    {
        var test : TestCase = new AsynchronousTestCase("testNotReallyAsynchronousPass");
        var result : TestResult = test.run();
        initAsync(result, 1, 0, 0);
    }

    public function testNotReallyAsynchronousFail() : void
    {
        var test : TestCase = new AsynchronousTestCase("testNotReallyAsynchronousFail");
        var result : TestResult = test.run();
        initAsync(result, 1, 1, 0);
    }

    public function shouldBeRun(event : Event, passedData : Object) : void
    {
        var result : TestResult = passedData.result;

        var expectedRun : int = passedData.expectedRun;
        var expectedFail : int = passedData.expectedFail;
        var expectedError : int = passedData.expectedError;

        Assert.assertEquals("run", expectedRun, result.runCount());
        Assert.assertEquals("fail",expectedFail, result.failureCount());
        Assert.assertEquals("error", expectedError, result.errorCount());
    }

    private function initAsync(result : TestResult, expectedRun : int, expectedFail : int, expectedError : int):void
    {
        var data : Object = new Object();
        data.result = result;
        data.expectedRun = expectedRun;
        data.expectedFail = expectedFail;
        data.expectedError = expectedError;
        var t : Timer = new Timer(1000, 1);
        var helper : Function = addAsync(shouldBeRun, 1500, data, function():void { fail('shouldBeRun did not fire')} );
        t.addEventListener("timer", helper);
        t.start();
    }

}

}