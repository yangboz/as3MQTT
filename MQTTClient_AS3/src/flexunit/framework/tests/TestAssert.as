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

public class TestAssert extends TestCase
{
    public static function suite() : TestSuite
    {
        var suite : TestSuite = new TestSuite();
        suite.addTest(new TestAssert("testFail"));
        suite.addTest(new TestAssert("testAssertEquals"));
        suite.addTest(new TestAssert("testAssertEqualsNull"));
        suite.addTest(new TestAssert("testAssertNullNotEqualsString"));
        suite.addTest(new TestAssert("testAssertStringNotEqualsNull"));
        suite.addTest(new TestAssert("testAssertNullNotEqualsNull"));
        suite.addTest(new TestAssert("testAssertNull"));
        suite.addTest(new TestAssert("testAssertNotNull"));
        suite.addTest(new TestAssert("testAssertTrue"));
        suite.addTest(new TestAssert("testAssertFalse"));
        suite.addTest(new TestAssert("testAssertStictlyEquals"));
        suite.addTest(new TestAssert("testAssertStrictlyEqualsNull"));
        suite.addTest(new TestAssert("testAssertNullNotStrictlyEqualsString"));
        suite.addTest(new TestAssert("testAssertStringNotStrictlyEqualsNull"));
        suite.addTest(new TestAssert("testAssertNullNotStrictlyEqualsNull"));
        return suite;
    }

    public function TestAssert(name : String = null)
    {
        super(name);
    }

    public function testFail():void
    {
        try 
        {
            fail();
        } 
        catch ( e : AssertionFailedError ) 
        {
            return;
        }
        throw new AssertionFailedError("fail uncaught");
    }

//------------------------------------------------------------------------------

    public function testAssertEquals():void
    {
        var  o : Object = new Object();
        Assert.assertEquals( o, o );
        Assert.assertEquals( "5", 5 );
        try 
        {
            Assert.assertEquals( new Object(), new Object() );
        } 
        catch ( e : AssertionFailedError )  
        {
            return;
        }
        fail();
    }

//------------------------------------------------------------------------------

    public function testAssertEqualsNull():void 
    {
        Assert.assertEquals( null, null );
    }

//------------------------------------------------------------------------------

    public function testAssertNullNotEqualsString():void 
    {
        try 
        {
            Assert.assertEquals( null, "foo" );
            fail();
        }
        catch ( e : AssertionFailedError ) 
        {
        }
    }

//------------------------------------------------------------------------------

    public function testAssertStringNotEqualsNull():void 
    {
        try 
        {
            Assert.assertEquals( "foo", null );
            fail();
        }
        catch ( e : AssertionFailedError ) 
        {
            Assert.assertEquals( "expected:<foo> but was:<null>", e.message );
        }
    }

//------------------------------------------------------------------------------

    public function testAssertNullNotEqualsNull():void 
    {
        try 
        {
            Assert.assertEquals( null, new Object() );
        }
        catch ( e : AssertionFailedError ) 
        {
            Assert.assertEquals( "expected:<null> but was:<[object Object]>", e.message );
            return;
        }
        fail();
    }

//------------------------------------------------------------------------------

    public function testAssertNull():void 
    {
        try 
        {
            Assert.assertNull( new Object() );
        }
        catch ( e : AssertionFailedError ) 
        {
            return;
        }
        fail();
    }

//------------------------------------------------------------------------------

    public function testAssertNotNull():void 
    {
        try 
        {
            Assert.assertNotNull( null );
        }
        catch ( e : AssertionFailedError ) 
        {
            return;
        }
        fail();
    }

//------------------------------------------------------------------------------

    public function testAssertTrue():void
    {
        try 
        {
            Assert.assertTrue( false );
        }
        catch ( e : AssertionFailedError ) 
        {
            return;
        }
        fail();
    }

//------------------------------------------------------------------------------

    public function testAssertFalse():void
    {
        try 
        {
            Assert.assertFalse( true );
        }
        catch ( e : AssertionFailedError ) 
        {
            return;
        }
        fail();
    }

//------------------------------------------------------------------------------

    public function testAssertStictlyEquals():void 
    {
        var  o : Object = new Object();
        Assert.assertStrictlyEquals( o, o );
        try 
        {
            Assert.assertStrictlyEquals( "5", 5 );
        } 
        catch ( e : AssertionFailedError )  
        {
            return;
        }
        fail();
    }
    
//------------------------------------------------------------------------------

    public function testAssertStrictlyEqualsNull():void 
    {
        Assert.assertStrictlyEquals( null, null );
    }
    
//------------------------------------------------------------------------------

    public function testAssertNullNotStrictlyEqualsString():void 
    {
        try 
        {
            Assert.assertStrictlyEquals( null, "foo" );
            fail();
        }
        catch ( e : AssertionFailedError ) 
        {
        }
    }

//------------------------------------------------------------------------------

    public function testAssertStringNotStrictlyEqualsNull():void 
    {
        try 
        {
            Assert.assertStrictlyEquals( "foo", null );
            fail();
        }
        catch ( e : AssertionFailedError ) 
        {
            Assert.assertEquals( "expected:<foo> but was:<null>", e.message );
        }
    }

//------------------------------------------------------------------------------

    public function testAssertNullNotStrictlyEqualsNull():void 
    {
        try 
        {
            Assert.assertStrictlyEquals( null, new Object() );
        }
        catch ( e : AssertionFailedError ) 
        {
            Assert.assertEquals( "expected:<null> but was:<[object Object]>", e.message );
            return;
        }
        fail();
    }
}

}