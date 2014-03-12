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

package flexunit.flexui
{

import flash.utils.*;
import flexunit.framework.*;
import flexunit.runner.*;

public class TestRunner extends BaseTestRunner
{
    public function TestRunner( writer : IFlexWriter, listener:TestListener=null )
    {
    	this.writer = writer;
        this.listener = listener;
    }

//------------------------------------------------------------------------------

    public static function run( test:Test, writer : IFlexWriter, listener:TestListener=null):TestResult
    {
        return new TestRunner(writer, listener).doRun( test );
    }
    
//------------------------------------------------------------------------------

    private function doRun( test:Test ):TestResult
    {
        result = new TestResult();
        result.addListener(this);
        if(listener)
            result.addListener(listener);

        startTime = getTimer();
        totalTestCount = test.countTestCases();
        numTestsRun = 0;
        test.runWithResult( result );

        return result;
    }

//------------------------------------------------------------------------------

	override public function testStarted( test : Test ) : void
	{
		currentTestFailed = false;
		writer.onTestStart( test );
	}

//------------------------------------------------------------------------------

	override public function testEnded( test : Test ) : void
	{
		if( !currentTestFailed )
			writer.onSuccess( test );
			
   		writer.onTestEnd( test );
   		
        if (++numTestsRun == totalTestCount)
        {		
	    	endTime = getTimer();
	        runTime = endTime - startTime;
	        writer.onAllTestsEnd();
        }
	}

//------------------------------------------------------------------------------

	override public function testError( test : Test, error : Error ) : void
	{
		currentTestFailed = true;
		writer.onError( test, error );
	}

//------------------------------------------------------------------------------

	override public function testFailure( test : Test, error : AssertionFailedError ) : void
	{
		currentTestFailed = true;
		writer.onFailure( test, error );
	}
	
//------------------------------------------------------------------------------

    private var startTime : int;
    private var endTime : int;
    private var runTime : int;
    private var totalTestCount : int;
    private var numTestsRun : int;
    private var result:TestResult;
    private var listener:TestListener;
    private var writer:IFlexWriter;
    private var currentTestFailed:Boolean;
}
	
}