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

import flexunit.utils.*;

/**
 * A <code>TestResult</code> collects the results of an executing
 * Test. It is an instance of the Collecting Parameter pattern.
 * The test framework distinguishes between <i>failures</i> and <i>errors</i>.
 * A failure is anticipated and checked for with assertions. Errors are
 * unanticipated problems.
 *
 * @see Test
 */
public class TestResult
{
	public var syncToFrame : Boolean = false;
	
	public function TestResult()
	{
		failures = Collection(new ArrayList());
		errors = Collection(new ArrayList());
		listeners = Collection(new ArrayList());

		runTests = 0;
	}

//------------------------------------------------------------------------------

	public function run( testCase : TestCase ) : void
	{
		/*if ( syncToFrame )
			FunctionCallQueue.getInstance().call( this, doRun, [ testCase ] );
		else
		*/
			doRun( testCase );
	}

//------------------------------------------------------------------------------

    //called by the AsyncTestHelper when it has either failed or received the callback
	public function continueRun( testCase : TestCase ) : void
	{
        doContinue( testCase );
	}

//------------------------------------------------------------------------------
	
	private function doRun( testCase : TestCase ) : void
	{
		startTest( testCase );

		testCase.setTestResult(this);

		var protectedTestCase:Protectable = Protectable( new ProtectedStartTestCase( testCase ));

		var startOK : Boolean = doProtected( testCase, protectedTestCase );

		if (startOK)
		{
		    doContinue( testCase );
        }
        else
        {
            endTest( testCase );
        }
	}

//------------------------------------------------------------------------------

	private function doContinue( testCase : TestCase ) : void
	{
        var protectedTestCase : Protectable = Protectable(new ProtectedMiddleTestCase ( testCase ));
        doProtected( testCase, protectedTestCase );
        if (testCase.hasAsync())
        {
            testCase.startAsync();
        }
        else
        {
            doFinish(testCase);
        }
	}

//------------------------------------------------------------------------------

	private function doFinish( testCase : TestCase ) : void
	{
		var protectedTestCase:Protectable = Protectable( new ProtectedFinishTestCase( testCase ));
        doProtected( testCase, protectedTestCase );
        endTest( testCase );
	}

//------------------------------------------------------------------------------

	public function addError( test:Test, error:Error ):void
	{
		errors.addItem( new TestFailure( test, error ) );

		var iter:Iterator = listeners.iterator();
		while ( iter.hasNext() )
		{
			var listener:TestListener = TestListener( iter.next() );
			listener.addError( test, error );
		}
	}

//------------------------------------------------------------------------------

	public function addFailure( test:Test, error:AssertionFailedError ):void
	{
		failures.addItem( new TestFailure( test, error ) );

		var iter:Iterator = listeners.iterator();
		while ( iter.hasNext() )
		{
			var listener:TestListener = TestListener( iter.next() );
			listener.addFailure( test, error );
		}
	}

//------------------------------------------------------------------------------

	public function errorCount():Number
	{
		return errors.length();
	}

//------------------------------------------------------------------------------

	public function errorsIterator():Iterator
	{
		return errors.iterator();
	}

//------------------------------------------------------------------------------

	public function failureCount():Number
	{
		return failures.length();
	}

//------------------------------------------------------------------------------

	public function failuresIterator():Iterator
	{
		return failures.iterator();
	}

//------------------------------------------------------------------------------

	public function shouldStop():Boolean
	{
		return stopTests;
	}

//------------------------------------------------------------------------------

	public function stop( stopTests:Boolean ):void
	{
		this.stopTests = stopTests;
	}

//------------------------------------------------------------------------------

	public function wasSuccessful():Boolean
	{
		return failureCount() == 0 && errorCount() == 0;
	}

//------------------------------------------------------------------------------

	public function addListener( listener:TestListener ):void
	{
		if ( listeners.contains( listener ) == false )
			listeners.addItem( listener );
	}

//------------------------------------------------------------------------------

	public function removeListener( listener:TestListener ):void
	{
		if ( listeners.contains( listener ) )
			listeners.removeItem( listener );
	}

//------------------------------------------------------------------------------

	public function runCount():Number
	{
		return runTests;
	}

//------------------------------------------------------------------------------

	private function doProtected( testCase:Test, protectable:Protectable ):Boolean
	{
        var success : Boolean = false;

		try
		{
			protectable.protect();
			success = true;
		}
		catch ( error:Error )
		{
			if ( error is AssertionFailedError )
				addFailure( testCase, AssertionFailedError( error ) );
			else
				addError( testCase, error );
		}
		return success;
	}


//------------------------------------------------------------------------------

	public function startTest( test:Test ):void
	{
		var count:Number = test.countTestCases();
		runTests = runTests + count;

		var iter:Iterator = listeners.iterator();
	    var listener:TestListener;
		while ( iter.hasNext() )
		{
		    listener = TestListener( iter.next() );
			listener.startTest( test );
		}
	}

//------------------------------------------------------------------------------

	public function endTest( test:Test ):void
	{
		var iter:Iterator = listeners.iterator();
		var listener:TestListener;
		while ( iter.hasNext() )
		{
		    listener = TestListener( iter.next() );
			listener.endTest( test );
		}
	}

//------------------------------------------------------------------------------

	private var stopTests:Boolean;
	private var failures:Collection;
	private var errors:Collection;
	private var listeners:Collection;
	private var runTests:Number;

}

}