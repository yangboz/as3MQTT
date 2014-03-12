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

import flexunit.framework.*;

public class TestTestCase extends TestCase
{

    public static function suite() : TestSuite
    {
        var suite : TestSuite = new TestSuite();
        suite.addTest(new TestTestCase("testCaseToString"));
        suite.addTest(new TestTestCase("testError"));
        suite.addTest(new TestTestCase("testRunAndTearDownFails"));
        suite.addTest(new TestTestCase("testSetupFails"));
        suite.addTest(new TestTestCase("testSuccess"));
        suite.addTest(new TestTestCase("testFailure"));
        suite.addTest(new TestTestCase("testTearDownAfterError"));
        suite.addTest(new TestTestCase("testTearDownFails"));
        suite.addTest(new TestTestCase("testTearDownSetupFails"));
        suite.addTest(new TestTestCase("testWasRun"));
        suite.addTest(new TestTestCase("testExceptionRunningAndTearDown"));
        //suite.addTest(new TestTestCase("testNoArgTestCasePasses"));
        suite.addTest(new TestTestCase("testNamelessTestCase"));
        return suite;
    }


    public function TestTestCase(name : String = null)
    {
        super(name);
    }

    public function testCaseToString() : void
    {
        Assert.assertEquals( "testCaseToString (flexunit.framework.tests::TestTestCase)", toString() );
    }

//------------------------------------------------------------------------------

    public function testError() : void
    {
        var error : ErrorTestCase = new ErrorTestCase("throwError");
        verifyError( error );
    }

//------------------------------------------------------------------------------

    public function testRunAndTearDownFails() : void
    {
        var fails : TearDownErrorTestCase = new TearDownErrorTestCase("throwError");
        //MATT: because of the asynchronous support an error in tearDown will now be an additional
        //error instead of overwriting the error that was thrown in the test run
        verifyError( fails, 2 );
        Assert.assertTrue( fails.expectedResult );
    }

//------------------------------------------------------------------------------

    public function testSetupFails() : void
    {
        var fails : SetupErrorTestCase = new SetupErrorTestCase( "throwError" )
        verifyError( fails, 1 );
    }

//------------------------------------------------------------------------------

    public function testSuccess() : void
    {
        var success : TestCase = new SuccessTestCase( "testSuccess" )
        verifySuccess( success );
    }

//------------------------------------------------------------------------------

    public function testFailure() : void
    {
        var failure : TestCase = new FailureTestCase( "testFailure" )
        verifyFailure( failure );
    }

//------------------------------------------------------------------------------

    public function testTearDownAfterError() : void
    {
        var fails : TearDownTestCase = new TearDownTestCase("throwError");
        verifyError( fails );
        Assert.assertTrue( fails.expectedResult );
    }

//------------------------------------------------------------------------------

    public function testTearDownFails() : void
    {
        var fails : TearDownErrorTestCase = new TearDownErrorTestCase( "testSuccess" )
        verifyError( fails );
    }

//------------------------------------------------------------------------------

    public function testTearDownSetupFails() : void
    {
        var fails : SetupErrorTearDownTestCase = new SetupErrorTearDownTestCase("testSuccess");
        verifyError( fails );
        Assert.assertFalse( fails.expectedResult );
    }

//------------------------------------------------------------------------------

    public function testWasRun() : void
    {
        var test : SuccessTestCase = new SuccessTestCase("testSuccess");
        test.run();
        Assert.assertTrue( test.expectedResult );
    }



//------------------------------------------------------------------------------

    public function testExceptionRunningAndTearDown() : void
    {
        var t : TestCase = new TearDownErrorTestCase("testSuccess");
        var result : TestResult = new TestResult();
        t.runWithResult( result );
        var failure : TestFailure = TestFailure ( result.errorsIterator().next() );
        Assert.assertEquals( "tearDown", failure.thrownException().message );
    }

//------------------------------------------------------------------------------

//MATT: since the automatic test creation doesn't work anymore and we've verified other no-arg tests (in SuccessTestCase)
//we should be cool without this one
/*
    public function testNoArgTestCasePasses() : void
    {
        var t : Test = new TestSuite( NoArgTestCase );
        var result : TestResult = new TestResult();
        
        t.runWithResult(  result );

        Assert.assertEquals( 1, result.runCount() );
        Assert.assertEquals( 0, result.failureCount() );
        Assert.assertEquals( 0, result.errorCount() );

    }
*/

//------------------------------------------------------------------------------

    public function testNamelessTestCase() : void
    {
        var test : TestCase = new TestCase();
        var result : TestResult = test.run();
        Assert.assertEquals( "runCount", 1, result.runCount() );
        Assert.assertEquals( "failures", 1, result.failureCount() );
        Assert.assertEquals( "errors", 0, result.errorCount()  );
        Assert.assertEquals( "No test method to run",
            TestFailure(result.failuresIterator().next()).thrownException().message );
        /*
        try
        {
            t.run();
            fail();
        }
        catch ( e: AssertionFailedError )
        {
        }
        */
    }

//------------------------------------------------------------------------------

    private function verifyError( test : TestCase , errorCount : int = 1) : void
    {
        var result : TestResult = test.run();
        Assert.assertEquals( 1, result.runCount() );
        Assert.assertEquals( 0, result.failureCount() );
        Assert.assertEquals( errorCount, result.errorCount()  );
    }
    
//------------------------------------------------------------------------------

    private function  verifyFailure( test : TestCase ) : void
    {
        var result : TestResult = test.run();
        Assert.assertEquals( 1,  result.runCount() );
        Assert.assertEquals( 1, result.failureCount()  );
        Assert.assertEquals( 0, result.errorCount() );
    }

//------------------------------------------------------------------------------

    private function  verifySuccess( test : TestCase ) : void
    {
        var result : TestResult = test.run();
        Assert.assertEquals( 1, result.runCount() );
        Assert.assertEquals( 0, result.failureCount() );
        Assert.assertEquals( 0, result.errorCount() );
    }
    
}

}