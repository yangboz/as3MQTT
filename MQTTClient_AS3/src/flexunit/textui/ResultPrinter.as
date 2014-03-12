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

package flexunit.textui
{

import flash.utils.*;
import flexunit.framework.*;
import flexunit.utils.*;

public class ResultPrinter implements TestListener
{
    public function ResultPrinter()
    {
        super();
        _progress = "";
    }

//------------------------------------------------------------------------------

    public function print( result:TestResult, runTime:Number ):void
    {
        if ( _progress.length > 0 )
            trace( _progress );

        printHeader(runTime);
        printErrors(result);
        printFailures(result);
        printFooter(result);
    }

//------------------------------------------------------------------------------

    public function printHeader( runTime:Number ):void
    {
        trace( "Time: " + ( runTime / 1000 ) + " seconds" );
    }

//------------------------------------------------------------------------------

    public function printErrors( result:TestResult ):void
    {
        printDefects( result.errorsIterator(), result.errorCount(), "error" );
    }

//------------------------------------------------------------------------------

    public function printFailures( result:TestResult ):void
    {
        printDefects( result.failuresIterator(), result.failureCount(), "failure" );
    }

//------------------------------------------------------------------------------

    public function printDefects( defects:Iterator, count:Number, type:String ):void
    {
        if ( count == 0 )
            return;

        if ( count == 1 )
            trace( "There was " + count + " " + type + ":" );
        else
            trace( "There were " + count + " " + type + "s:");

        for ( var i:Number = 1; defects.hasNext(); i++)
        {
            printDefect( TestFailure( defects.next() ), i );
        }
    }

//------------------------------------------------------------------------------

    private function printDefect( defect:TestFailure, count:Number ):void
    {
        printDefectHeader( defect, count );
        printDefectTrace( defect );
    }

//------------------------------------------------------------------------------

    private function printDefectHeader( defect:TestFailure, count:Number ):void
    {
        trace( count + ") " + defect.failedTest().toString() );
    }

//------------------------------------------------------------------------------

    private function printDefectTrace( defect:TestFailure ):void
    {
        trace( "\t" + defect.exceptionMessage() );
    }

//------------------------------------------------------------------------------

    private function printFooter( result:TestResult ):void
    {
        if ( result.wasSuccessful() )
        {
            trace( "" );
            trace( "OK (" + result.runCount() + " test" + ( result.runCount() == 1 ? "" : "s") + ")" );
        }
        else
        {
            trace( "" );
            trace( "FAILURES!!!" );
            trace( "Tests run: " + result.runCount() +
                         ",  Failures: " + result.failureCount() +
                         ",  Errors: " + result.errorCount() );
        }
       trace( "" );
    }

//------------------------------------------------------------------------------

    public function addError( test:Test, error:Error ):void
    {
        updateProgress( "E" );
    }

//------------------------------------------------------------------------------

    public function addFailure( test:Test, error:AssertionFailedError ):void
    {
        updateProgress( "F" );
    }

//------------------------------------------------------------------------------

    public function endTest( test:Test ):void
    {
    }

//------------------------------------------------------------------------------

    public function startTest( test:Test ):void
    {
        updateProgress( "." );
    }

//------------------------------------------------------------------------------

    private function updateProgress( lr:String ):void
    {
        _progress = _progress + lr;
        if ( _progress.length > 40 )
        {
            trace( _progress );
            _progress = "";
        }
    }

//------------------------------------------------------------------------------

    private var _progress:String;
}

}
