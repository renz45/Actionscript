package com.rensel.soundUtils
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	
	[Event(type="flash.events.Event",name="soundComplete")]
	
	public class SFX extends EventDispatcher
	{
		private var _sc:SoundChannel;
		private var _st:SoundTransform;
		private var _snd:Sound;
		
		private var _volume:Number;
		private var _currentVolume:Number;
		private var _mute:Boolean = false;
		private var _position:Number;
		private var _isPlaying:Boolean = false;
		private var _sndLength:Number;
		private var _stopped:Boolean = true;
		private var _loop:Boolean;
		
		private static var sounds:Array;
		private static var isMuted:Boolean = false;
		
		/**
		 * This public static function initializes the functions that control all instances of SFX at once. 
		 * 
		 */		
		public static function initAll():void
		{
			sounds = [];
		}
		/**
		 * This public static function will stop all instances of SFX 
		 * 
		 */		
		public static function allStop():void
		{
			for each(var s:SFX in sounds)
			{
				s.stop();
			}
		}
		/**
		 * Mutes all SFX classes in use, init all must be ran first before this will work. 
		 * 
		 */		
		public static function allMute():void
		{
			for each(var s:SFX in sounds)
			{
				s.mute();
				if(!isMuted)
				{
					isMuted = true;
				}else{
					isMuted = false;
				}
			}
		}
		/**
		 * This public static function returns the muted state as a boolean, used for determining the muteAll state for toggle buttons. 
		 * @return 
		 * 
		 */		
		public static function get isAllMuted():Boolean
		{
			return isMuted;
		}
		
		
		
		
		/**
		 * Custom class for loading sounds. Arguments are the file path and default volume. 
		 * @param path
		 * @param defaultVolume
		 * 
		 */		
		public function SFX(path:String,defaultVolume:Number = 1,loop:Boolean = false)
		{
			_loop = loop;
			
			_snd = new Sound(new URLRequest(path));
			
			_snd.addEventListener(Event.COMPLETE,sndLoad_CompleteHandler);
			
			if(sounds)
			{
				sounds.push(this);
			}
			
			_sc = new SoundChannel();
			_st = new SoundTransform(defaultVolume);
			_volume = defaultVolume;
			_position = 0;
			
		}
		
		private function soundComplete_Handler(evt:Event):void
		{
		//	trace("NEXT");
			if(_loop)
			{
				this.stop();
				this.play();
			}
			
			var e:Event = new Event(Event.SOUND_COMPLETE);
			this.dispatchEvent(e);
		}
		
		private function sndLoad_CompleteHandler(evt:Event):void
		{
			_sndLength = _snd.length;
		}
		/**
		 * Public method plays the sound 
		 * 
		 */		
		public function play():void
		{
			if(!_isPlaying)
			{
				_sc = _snd.play(_position,0,_st);
				_isPlaying = true;
				//trace("added");
				_sc.addEventListener(Event.SOUND_COMPLETE,soundComplete_Handler);
			}
			
			
			
		}
		/**
		 * Public method will toggle a paused and play state, saving the position on pause and resumes if the sound is already paused 
		 * 
		 */		
		public function playPauseToggle():void
		{
			if(_isPlaying)
			{
				_position = _sc.position;
				_sc.stop();
				_isPlaying = false;
				//trace("remove");
				_sc.removeEventListener(Event.SOUND_COMPLETE,soundComplete_Handler);
			}else{
				this.play();
			}
		}
			
		/**
		 * public method toggles the sound from the current level to 0 
		 * 
		 */		 
		public function mute():void
		{
			if(!_mute)
			{
				_currentVolume = _volume;
				this.volume = 0;
				_mute = true;
			}else{
				this.volume = _currentVolume;
				_mute = false;
			}
			
		}
		 /**
		 * Public method stops the sound and returns the pointer to the beginning of the song. 
		 * 
		 */	
		public function stop():void
		{
			//trace(_sc.position);
			_sc.stop();
			_position = 0;
			_isPlaying = false;
			//trace(_sc.position);
		}
		/**
		 *	Volume getter/setter returns and accepts values between 0 and 1 
		 * @param vol
		 * 
		 */		
		public function set volume(vol:Number):void
		{
			_volume = vol;
			
			if(_volume > 1)
			{
				_volume = 1;
			}
			if(_volume < 0)
			{
				_volume = 0;
			}
			
			_st.volume = _volume;
			
			_sc.soundTransform = _st;
		}
		/**
		 * @private 
		 * @return 
		 * 
		 */		
		public function get volume():Number
		{
			return _volume;
		}
		/**
		 * position value getter and setter, accepts a number between 1 and 0. 
		 * @param pos
		 * 
		 */		
		public function set position(pos:Number):void
		{
			if(pos > 1)
			{
				this.position = 1;
			}
			if(pos < 0)
			{
				this.position = 0;
			}
			var skipTo:Number = pos * _sndLength;
			_sc.stop();
			
			if(_isPlaying)
			{
				_sc = _snd.play(skipTo,0,_st);
				//trace("add2");
				_sc.addEventListener(Event.SOUND_COMPLETE,soundComplete_Handler);
			}else{
				_position = skipTo;
				//trace("remove2");
				_sc.removeEventListener(Event.SOUND_COMPLETE,soundComplete_Handler);
			}
		}
		/**
		 * public method that returns a position value either in milliseconds or a percent. Evoked by using SFX.getPosition().milliSeconds or
		 * SFX.getPosition.percent. 
		 * @return 
		 * 
		 */		
		public function getPosition():Object
		{
			var position:Object = {percent:0, milliSeconds:0}
			if(_isPlaying)
			{
				position.percent = _sc.position / _sndLength;
				position.milliSeconds = _sc.position;
				return position;
				//return _sc.position / _sndLength;
			}else{
				position.percent = _position / _sndLength;
				position.milliSeconds = _position;
				return position;
				//return _position / _sndLength;
			}
			
		}
		/**
		 * returns the total length of the sound container in the SFX 
		 * @return 
		 * 
		 */		
		public function get duration():Number
		{
			return _sndLength;
		}
		/**
		 * public method returns the left peak 
		 * @return 
		 * 
		 */		
		public function get leftPeak():Number
		{
			return _sc.leftPeak;
		}
		/**
		 * public method returns the right peak 
		 * @return 
		 * 
		 */
		public function get rightPeak():Number
		{
			return _sc.rightPeak;
		}
		

	}
}