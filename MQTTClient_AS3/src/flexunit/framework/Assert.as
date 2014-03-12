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

/** 
 * Base class containing static assert methods.
 */
public class Assert
{
	public function Assert()
	{
	}

//------------------------------------------------------------------------------

	public static function assertEquals(... rest):void
	{
		if ( rest.length == 3 )
			failNotEquals( rest[0], rest[1], rest[2] );
		else
			failNotEquals( "", rest[0], rest[1] );
	}

//------------------------------------------------------------------------------

	private static function failNotEquals( message:String, expected:Object, actual:Object ):void
	{
		if ( expected != actual )
		   failWithUserMessage( message, "expected:<" + expected + "> but was:<" + actual + ">" );
	}

//------------------------------------------------------------------------------

	public static function assertStrictlyEquals(... rest):void
	{
		if ( rest.length == 3 )
			failNotStrictlyEquals( rest[0], rest[1], rest[2] );
		else
			failNotStrictlyEquals( "", rest[0], rest[1] );
	}

//------------------------------------------------------------------------------

	private static function failNotStrictlyEquals( message:String, expected:Object, actual:Object ):void
	{
		if ( expected !== actual )
		   failWithUserMessage( message, "expected:<" + expected + "> but was:<" + actual + ">" );
	}

//------------------------------------------------------------------------------

	public static function assertTrue(... rest):void
	{
		if ( rest.length == 2 )
			failNotTrue( rest[0], rest[1] );
		else
			failNotTrue( "", rest[0] );
	}

//------------------------------------------------------------------------------

	private static function failNotTrue( message:String, condition:Boolean ):void
	{
		if ( !condition )
		   failWithUserMessage( message, "expected true but was false" );
	}

//------------------------------------------------------------------------------

	public static function assertFalse(... rest):void
	{
		if ( rest.length == 2 )
			failTrue( rest[0], rest[1] );
		else
			failTrue( "", rest[0] );
	}

//------------------------------------------------------------------------------

	private static function failTrue( message:String, condition:Boolean ):void
	{
		if ( condition )
		   failWithUserMessage( message, "expected false but was true" );
	}

//------------------------------------------------------------------------------

	public static function assertNull(... rest):void
	{
		if ( rest.length == 2 )
			failNotNull( rest[0], rest[1] );
		else
			failNotNull( "", rest[0] );
	}

//------------------------------------------------------------------------------

	private static function failNull( message:String, object:Object ):void
	{
		if ( object == null )
		   failWithUserMessage( message, "object was null: " + object );
	}

//------------------------------------------------------------------------------

	public static function assertNotNull(... rest):void
	{
		if ( rest.length == 2 )
			failNull( rest[0], rest[1] );
		else
			failNull( "", rest[0] );
	}

//------------------------------------------------------------------------------

	private static function failNotNull( message:String, object:Object ):void
	{
		if ( object != null )
		   failWithUserMessage( message, "object was not null: " + object );
	}

//------------------------------------------------------------------------------

    //TODO: undefined has lost most of its meaning in AS3, we could probably just use the null test
	public static function assertUndefined(... rest):void
	{
		if ( rest.length == 2 )
			failNotUndefined( rest[0], rest[1] );
		else
			failNotUndefined( "", rest[0] );
	}

//------------------------------------------------------------------------------

    //TODO: undefined has lost most of its meaning in AS3, we could probably just use the null test
	private static function failUndefined( message:String, object:Object ):void
	{
		if ( object == null )
		   failWithUserMessage( message, "object was undefined: " + object );
	}

//------------------------------------------------------------------------------

    //TODO: undefined has lost most of its meaning in AS3, we could probably just use the null test
	public static function assertNotUndefined(... rest):void
	{
		if ( rest.length == 2 )
			failUndefined( rest[0], rest[1] );
		else
			failUndefined( "", rest[0] );
	}

//------------------------------------------------------------------------------

    //TODO: undefined has lost most of its meaning in AS3, we could probably just use the null test
	private static function failNotUndefined( message:String, object:Object ):void
	{
		if ( object != null )
		   failWithUserMessage( message, "object was not undefined: " + object );
	}

//------------------------------------------------------------------------------

	public static function fail( failMessage:String = ""):void
	{
		throw new AssertionFailedError( failMessage );
	}

//------------------------------------------------------------------------------

	private static function failWithUserMessage( userMessage:String, failMessage:String ):void
	{
		if ( userMessage.length > 0 )
			userMessage = userMessage + " - ";

		throw new AssertionFailedError( userMessage + failMessage );
	}

}

}