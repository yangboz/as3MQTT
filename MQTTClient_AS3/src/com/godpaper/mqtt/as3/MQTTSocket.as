/**
 *  GODPAPER Confidential,Copyright 2012. All rights reserved.
 *
 *  Permission is hereby granted, free of charge, to any person obtaining
 *  a copy of this software and associated documentation files (the "Software"),
 *  to deal in the Software without restriction, including without limitation
 *  the rights to use, copy, modify, merge, publish, distribute, sub-license,
 *  and/or sell copies of the Software, and to permit persons to whom the
 *  Software is furnished to do so, subject to the following conditions:
 *
 *  The above copyright notice and this permission notice shall be included
 *  in all copies or substantial portions of the Software.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 *  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 *  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 *  THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 *  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 *  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
 *  IN THE SOFTWARE.
 */
package com.godpaper.mqtt.as3
{
	//--------------------------------------------------------------------------
	//
	//  Imports
	//
	//--------------------------------------------------------------------------
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.net.Socket;
	
	
	/**
	 * MQTTSocket.as class.A simple as3 class to connect/publish/subscribe to an MQTT broker.   	
	 * @see https://github.com/bluerhinos/phpMQTT/blob/master/phpMQTT.php
	 * 
	 * @author yangboz
	 * @langVersion 3.0
	 * @playerVersion 11.2+
	 * @airVersion 3.2+
	 * Created Nov 20, 2012 11:42:04 AM
	 */   	 
	public class MQTTSocket extends EventDispatcher
	{		
		//--------------------------------------------------------------------------
		//
		//  Variables
		//
		//--------------------------------------------------------------------------
		private var socket:Socket; /* holds the socket */
		private var msgid:int = 1;	/* counter for message id */
		public var keepalive:int = 10;	/* default keepalive timmer */
		public var timesinceping:uint;	/* host unix time, used to detect disconects */
		public var topics:Array = []; /* used to store currently subscribed topics */
		public var debug:Boolean = false;	/* should output debug messages */
		public var address:String;	/* broker address */
		public var port:Number;	/* broker port */
		public var clientid:String;	/* client id sent to brocker */
		public var will:uint;	/* stores the will of the client */
		private var username:String;	/* stores username */
		private var password:String;	/* stores password */
		//----------------------------------
		//  CONSTANTS
		//----------------------------------
		
		//--------------------------------------------------------------------------
		//
		//  Public properties
		//
		//-------------------------------------------------------------------------- 
		
		//--------------------------------------------------------------------------
		//
		//  Protected properties
		//
		//-------------------------------------------------------------------------- 
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		public function MQTTSocket(address:String,port:Number,clientid:String,target:IEventDispatcher=null)
		{
//			super(target);
			this.broker(address, port, clientid);
		}     	
		//--------------------------------------------------------------------------
		//
		//  Public methods
		//
		//--------------------------------------------------------------------------
		/* sets the broker details */
		protected function broker(address:String,port:Number,clientid:String)
		{
			this.address = address;
			this.port = port;
			this.clientid = clientid;	
		}
		
		/* connects to the broker
		inputs: $clean: should the client send a clean session flag */
		public function connect($clean = true, $will = NULL, $username = NULL, $password = NULL){
			
			if($will) $this->will = $will;
			if($username) $this->username = $username;
			if($password) $this->password = $password;
			
			$address = gethostbyname($this->address);	
			$this->socket = fsockopen($address, $this->port, $errno, $errstr, 60);
			
			if (!$this->socket ) {
				error_log("fsockopen() $errno, $errstr \n");
				return false;
			}
			
			stream_set_timeout($this->socket, 5);
			stream_set_blocking($this->socket,true);
			
			$i = 0;
			$buffer = "";
			
			$buffer .= chr(0x00); $i++;
			$buffer .= chr(0x06); $i++;
			$buffer .= chr(0x4d); $i++;
			$buffer .= chr(0x51); $i++;
			$buffer .= chr(0x49); $i++;
			$buffer .= chr(0x73); $i++;
			$buffer .= chr(0x64); $i++;
			$buffer .= chr(0x70); $i++;
			$buffer .= chr(0x03); $i++;
			
			//No Will
			$var = 0;
			if($clean) $var+=2;
			
			//Add will info to header
			if($this->will != NULL){
				$var += 4; // Set will flag
				$var += ($this->will['qos'] << 3); //Set will qos
				if($this->will['retain'])	$var += 32; //Set will retain
			}
			
			if($this->username != NULL) $var += 128;	//Add username to header
			if($this->password != NULL) $var += 64;	//Add password to header
			
			$buffer .= chr($var); $i++;
			
			//Keep alive
			$buffer .= chr($this->keepalive >> 8); $i++;
			$buffer .= chr($this->keepalive & 0xff); $i++;
			
			$buffer .= $this->strwritestring($this->clientid,$i);
			
			//Adding will to payload
			if($this->will != NULL){
				$buffer .= $this->strwritestring($this->will['topic'],$i);
				$buffer .= $this->strwritestring($this->will['content'],$i);
			}
			
			if($this->username) $buffer .= $this->strwritestring($this->username,$i);
			if($this->password) $buffer .= $this->strwritestring($this->password,$i);
			
			$head = " ";
			$head{0} = chr(0x10);
			$head{1} = chr($i);
			
			fwrite($this->socket, $head, 2);
			fwrite($this->socket, $buffer);
			
			$string = $this->read(4);
			
			if(ord($string{0})>>4 == 2 && $string{3} == chr(0)){
				if($this->debug) echo "Connected to Broker\n";
			}else{	
				error_log(sprintf("Connection failed! (Error: 0x%02x 0x%02x)\n",
					ord($string{0}),ord($string{3})));
				return false;
			}
			
			$this->timesinceping = time();
			
			return true;
		}
		
		/* read: reads in so many bytes */
		function read($int = 8192 ){
			
			// print_r(socket_get_status($this->socket));
			
			$string="";
			$togo = $int;
			while (!feof($this->socket) && $togo>0) {
				$togo = $int - strlen($string);
				if($togo) $string .= fread($this->socket, $togo);
			}
			
			
			
			
			return $string;
		}
		
		/* subscribe: subscribes to topics */
		function subscribe($topics, $qos = 0){
			$i = 0;
			$buffer = "";
			$id = $this->msgid;
			$buffer .= chr($id >> 8); $i++;
			$buffer .= chr($id % 256); $i++;
			
			foreach($topics as $key => $topic){
				$buffer .= $this->strwritestring($key,$i);
				$buffer .= chr($topic["qos"]); $i++;
				$this->topics[$key] = $topic;
			}
			
			$cmd = 0x80;
			//$qos
			$cmd +=	($qos << 1);
			
			
			$head = chr($cmd);
			$head .= chr($i);
			
			fwrite($this->socket, $head, 2);
			fwrite($this->socket, $buffer, $i);
			$string = $this->read(2);
			
			$bytes = ord(substr($string,1,1));
			$string = $this->read($bytes);
		}
		
		/* ping: sends a keep alive ping */
		function ping(){
			$head = " ";
			$head = chr(0xc0);	
			$head .= chr(0x00);
			fwrite($this->socket, $head, 2);
			if($this->debug) echo "ping sent\n";
		}
		
		/* disconnect: sends a proper disconect cmd */
		function disconnect(){
			$head = " ";
			$head{0} = chr(0xe0);	
			$head{1} = chr(0x00);
			fwrite($this->socket, $head, 2);
		}
		
		/* close: sends a proper disconect, then closes the socket */
		function close(){
			$this->disconnect();
			fclose($this->socket);	
		}
		
		/* publish: publishes $content on a $topic */
		function publish($topic, $content, $qos = 0, $retain = 0){
			
			$i = 0;
			$buffer = "";
			
			$buffer .= $this->strwritestring($topic,$i);
			
			//$buffer .= $this->strwritestring($content,$i);
			
			if($qos){
				$id = $this->msgid++;
				$buffer .= chr($id >> 8); $i++;
				$buffer .= chr($id % 256); $i++;
			}
			
			$buffer .= $content;
			$i+=strlen($content);
			
			
			$head = " ";
			$cmd = 0x30;
			if($qos) $cmd += $qos << 1;
			if($retain) $cmd += 1;
			
			$head{0} = chr($cmd);	
			$head .= $this->setmsglength($i);
			
			fwrite($this->socket, $head, strlen($head));
			fwrite($this->socket, $buffer, $i);
			
		}
		
		/* message: processes a recieved topic */
		public function message($msg){
			$tlen = (ord($msg{0})<<8) + ord($msg{1});
			$topic = substr($msg,2,$tlen);
			$msg = substr($msg,($tlen+2));
			$found = 0;
			foreach($this->topics as $key=>$top){
				if( preg_match("/^".str_replace("#",".*",
					str_replace("+","[^\/]*",
						str_replace("/","\/",
							str_replace("$",'\$',
								$key))))."$/",$topic) ){
					if(function_exists($top['function'])){
						call_user_func($top['function'],$topic,$msg);
						$found = 1;
					}
				}
			}
			
			if($this->debug && !$found) echo "msg recieved but no match in subscriptions\n";
		}
		
		/* proc: the processing loop for an "allways on" client */	
		public function proc(){
			
			if(1){
				$sockets = array($this->socket);
				$w = $e = NULL;
				$cmd = 0;
				if($this->debug) echo "start wait\n";
				
				if(stream_select($sockets, $w, $e, ($this->keepalive/2))){
					if($this->debug) echo "found something\n";
					
					//$byte = fgetc($this->socket);
					if(feof($this->socket)){
						if($this->debug) echo "eof receive going to reconnect for good measure\n";
						fclose($this->socket);
						$this->connect(false);
						if(count($this->topics))
							$this->subscribe($this->topics);	
					}
					
					$byte = $this->read(1);
					$cmd = (int)(ord($byte)/16);
					if($this->debug) echo "Recevid: $cmd\n";
					
					$multiplier = 1;
					$value = 0;
					do{
						$digit = ord($this->read(1));
						$value += ($digit & 127) * $multiplier;
						$multiplier *= 128;
					}while (($digit & 128) != 0);
					
					
					if($this->debug) echo "Fetching: $value\n";
					if($value)
						$string = $this->read($value,"fetch");
					if($cmd){
						switch($cmd){
							case 3:
								$this->message($string);
								break;
						}
						
						$this->timesinceping = time();
					}
					
					
				}else{
					if($this->debug) echo "not found something\n";
					$this->ping();	
				}
				
				if($this->timesinceping<(time()-($this->keepalive*2))){
					if($this->debug) echo "not seen a package in a while, disconnecting\n";
					fclose($this->socket);
					$this->connect(false);
					if(count($this->topics))
						$this->subscribe($this->topics);
				}
				
			}
			return 1;
		}
		
		/* getmsglength: */
		public function getmsglength(&$msg, &$i){
			
			$multiplier = 1;
			$value = 0 ;
			do{
				$digit = ord($msg{$i});
				$value += ($digit & 127) * $multiplier;
				$multiplier *= 128;
				$i++;
			}while (($digit & 128) != 0);
			
			return $value;
		}
		
		
		/* setmsglength: */
		function setmsglength($len){
			$string = "";
			do{
				$digit = $len % 128;
				$len = $len >> 7;
				// if there are more digits to encode, set the top bit of this digit
				if ( $len > 0 )
					$digit = ($digit | 0x80);
				$string .= chr($digit);
			}while ( $len > 0 );
			return $string;
		}
		
		/* strwritestring: writes a string to a buffer */
		function strwritestring($str, &$i){
			$ret = " ";
			$len = strlen($str);
			$msb = $len >> 8;
			$lsb = $len % 256;
			$ret = chr($msb);
			$ret .= chr($lsb);
			$ret .= $str;
			$i += ($len+2);
			return $ret;
		}
		
		function printstr($string){
			$strlen = strlen($string);
			for($j=0;$j<$strlen;$j++){
				$num = ord($string{$j});
				if($num > 31)
					$chr = $string{$j}; else $chr = " ";
				printf("%4d: %08b : 0x%02x : %s \n",$j,$num,$num,$chr);
			}
		}
		//--------------------------------------------------------------------------
		//
		//  Protected methods
		//
		//--------------------------------------------------------------------------
		
		//--------------------------------------------------------------------------
		//
		//  Private methods
		//
		//--------------------------------------------------------------------------
	}
	
}