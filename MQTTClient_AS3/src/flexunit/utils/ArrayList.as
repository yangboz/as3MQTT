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

package flexunit.utils
{

public class ArrayList implements Collection
{

	public function ArrayList()
	{
		items = new Array();
	}

//------------------------------------------------------------------------------

	public function addItem( item:Object ):Boolean
	{
		if ( item == null )
			return false;

		items.push( item );
		return true;
	}

//------------------------------------------------------------------------------

	public function clear():void
	{
		items = new Array();
	}

//------------------------------------------------------------------------------

	public function contains(item:Object):Boolean
	{
		return ( getItemIndex( item ) > -1 );
	}

//------------------------------------------------------------------------------

	public function getItemAt(index:Number):Object
	{
		return ( items[ index ] );
	}

//------------------------------------------------------------------------------

	public function iterator():Iterator
	{
		return ( Iterator( new CollectionIterator( this )));
	}

//------------------------------------------------------------------------------

	public function length():Number
	{
		return items.length;
	}

//------------------------------------------------------------------------------

	public function isEmpty():Boolean
	{
		return ( items.length == 0 );
	}

//------------------------------------------------------------------------------

	public function removeItem( item:Object ):Boolean
	{
	   var itemIndex:Number = getItemIndex( item );
		if ( itemIndex < 0 )
			return false;

		items.splice( itemIndex, 1 );
		return true;
	}

//------------------------------------------------------------------------------

	public function toArray() : Array
	{
		return items;
	}
	
//------------------------------------------------------------------------------

	private function getItemIndex( item:Object ):Number
	{
		for ( var i:uint=0; i<items.length; i++ )
		{
			if ( items[ i ] == item )
				return i;
		}
		return -1;
	}

//------------------------------------------------------------------------------

	private var items:Array;
}

}