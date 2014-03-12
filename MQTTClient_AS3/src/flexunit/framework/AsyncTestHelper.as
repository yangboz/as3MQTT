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

import flash.events.*;
import flash.utils.*;

public class AsyncTestHelper
{

    public function AsyncTestHelper(testCase : TestCase, testResult : TestResult)
    {
        this.testCase = testCase;
        this.testResult = testResult;
        timer = new Timer(100);
        timer.addEventListener("timer", timerHandler);
    }

//------------------------------------------------------------------------------

    public function startAsync() : void
    {
        loadAsync();
        if (objToPass != null)
        {
            testResult.continueRun(testCase);
        }
        else
        {
            timer.start();
        }
    }

//------------------------------------------------------------------------------

    public function loadAsync() : void
    {
        var async : Object = testCase.getNextAsync();
        func = async.func;
        extraData = async.extraData;
        failFunc = async.failFunc;
        //BUG 114824 WORKAROUND
        timer = new Timer(async.timeout, 1);
        timer.addEventListener("timer", timerHandler);
        //END WORKAROUND
        timer.delay = async.timeout;
    }

//------------------------------------------------------------------------------

    public function runNext() : void
    {
        if (shouldFail)
        {
            if (failFunc != null)
            {
                failFunc(extraData);
            }
            else
            {
                var msg : String = "Asynchronous function did not fire after " + timer.delay + " ms";
                Assert.fail(msg);
            }
        }
        else
        {
            if (extraData != null)
            {
                func(objToPass, extraData);
            }
            else
            {
                func(objToPass);
            }
            func = null;
            objToPass = null;
            extraData = null;
        }
    }

//------------------------------------------------------------------------------

    public function timerHandler(event : TimerEvent) : void
    {
        timer.stop();
        shouldFail = true;
        testResult.continueRun(testCase);
    }

//------------------------------------------------------------------------------

    public function handleEvent(event : Event) : void
    {
        var wasReallyAsync : Boolean = timer.running;
        timer.stop();
        //if we already failed don't do anything
        if (shouldFail)
            return;
        objToPass = event;
        if (wasReallyAsync)
        {
            testResult.continueRun(testCase);
        }
    }

//------------------------------------------------------------------------------

    //IResponder methods here (they'd look similar to handleEvent) ...

//------------------------------------------------------------------------------

    private var testCase : TestCase;
    private var func : Function;
    private var extraData : Object;
    private var failFunc : Function;
    private var testResult : TestResult;

    private var shouldFail : Boolean = false;
    private var objToPass : Object;

    private var timer : Timer;

}

}
