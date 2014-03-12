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

public class TestTestListener extends TestCase implements TestListener
{
    public static function suite() : TestSuite
    {
        var suite : TestSuite = new TestSuite();
        suite.addTest(new TestTestListener("testError"));
        suite.addTest(new TestTestListener("testFailure"));
        suite.addTest(new TestTestListener("testStartStop"));
        return suite;
    }

    public function TestTestListener(name : String = null)
    {
        super(name);
    }

	public function addError( test : Test , e : Error ) : void
	{
		errorCount++;
	}

//------------------------------------------------------------------------------

	public function addFailure( test : Test , e : AssertionFailedError ) : void
	{
		failureCount++;
	}
	
//------------------------------------------------------------------------------

	public function startTest( test : Test ) : void 
	{
		startCount++;
	}

//------------------------------------------------------------------------------

	public function endTest( test : Test ) : void 
	{
		endCount++;
	}
	
//------------------------------------------------------------------------------

	override public function setUp() : void
	{
		result = new TestResult();
		result.addListener( TestListener(this) );
	
		startCount = 0;
		endCount = 0;
		failureCount = 0;
		errorCount = 0;
	}
	
//------------------------------------------------------------------------------
	
	public function testError():void 
	{
		var test : TestCase = new ErrorTestCase( "throwError" )
		test.runWithResult( result );
		Assert.assertEquals("error", 1, errorCount );
		Assert.assertEquals("end", 1, endCount );
		Assert.assertEquals("failure", 0, failureCount);
	}

//------------------------------------------------------------------------------
	
	public function testFailure():void 
	{
		var test : TestCase = new FailureTestCase( "testFailure" )
		test.runWithResult( result );
		Assert.assertEquals("failure", 1, failureCount );
		Assert.assertEquals("end", 1, endCount );
		Assert.assertEquals("error", 0, errorCount);
	}

//------------------------------------------------------------------------------
	
	public function testStartStop():void 
	{
		var test : TestCase = new SuccessTestCase( "testSuccess" )
		test.runWithResult( result );
		Assert.assertEquals("start", 1, startCount );
		Assert.assertEquals("end", 1, endCount );
		Assert.assertEquals("error", 0, errorCount);
		Assert.assertEquals("failure", 0, failureCount);
	}

//------------------------------------------------------------------------------
	
	private var result : TestResult;
	private var startCount : Number;
	private var endCount : Number;
	private var failureCount : Number;
	private var errorCount : Number;

}

}