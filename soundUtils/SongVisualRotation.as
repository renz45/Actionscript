package com.rensel.soundUtils
{
	import com.rensel.utils.MathUtil;
	
	import flash.display.Sprite;
	/**
	 * Custom class that takes the right or left peak of a sound and translates it into a circular rotation.
	 * The arguments are a rotational element, this will be what rotates to the music.
	 * An offSet value, this adjusts the base speed, increasing this will make the rotations faster overall.
	 * A directionForward boolean sets the base direction of the motion. 
	 * @author adamrensel
	 * 
	 */	
	public class SongVisualRotation
	{
		private var _peakValue:Number;
		
		private var _pos:Number;
		private var _speed:Number = 1;
		private var _dir:Number = 1; 
		private var _offSet:int;
		
		private var _currentPosition:Number = 0;
		private var _currentDirection:Number = 1;
		private var _currentSpeed:Number = 2;
		private var _directionForward:Number = 1;
		
		private var _rotation:Number = 0;
		
		private var _sp:Sprite;
		
		public function SongVisualRotation(rotationalElement:Sprite,offSet:int = 0,directionForward:Boolean = true)
		{
			_offSet = offSet;
			_sp = rotationalElement;
			if(directionForward)
			{
				_directionForward = -1;
			}
			
		}
		
		private function reset():void
		{
			if(_rotation > 90)
			{
				_rotation -= 10; 
				_sp.rotation = _rotation;
			}
			
			if(_rotation < 90)
			{
				_rotation += 10;
				_sp.rotation = _rotation;
			}
			
			//trace("sp " + _sp.rotation);
			//trace(_rotation);
			
		}
		
		private function updateValues():void
		{
				_currentDirection = _dir; 
				_currentPosition = ((_pos * .1) * 360) * _dir;
				if(_speed == 0)
				{
					_speed = 3;
				}
				_currentSpeed = (_speed * _dir) * _offSet;
			
			
			//trace("cd " + _currentDirection);
			//trace("cp " + _currentPosition);
			//trace("cs " + _currentSpeed);
		}
		
		private function update():void
		{
			//trace("dir " + _dir);
			//trace("pos " + _pos);
			
			//trace("goto pos " + (_pos * .1) * 360);
			
			if(_currentDirection > 0 && _rotation >= _currentPosition)
			{
				updateValues();
				//trace(1);
			}
			
			if(_currentDirection < 0 && _rotation <= _currentPosition)
			{
				updateValues();
				//trace(1-2);
			}
			
			_rotation += _currentSpeed;
			_sp.rotation = _rotation;
			//trace(_rotation);
		}
		/**
		 * This public setter takes an input from a sound object, the left or right peak and converts it to circular motion 
		 * @param peak
		 * 
		 */		
		public function set Peak(peak:Number):void
		{
			_peakValue = peak;
			//trace("peak " + peak);
			if(_peakValue > 0)
			{
				_pos = MathUtil.getNumberFrom(peak,2);
				//trace("pos " + _pos);
				_speed = MathUtil.getNumberFrom(peak,3);
				//trace("speed " + _speed % 3)
				_dir = MathUtil.getNumberFrom(peak,4);
				//trace("dir " + _dir % 2);
				if(_dir % 2 == 0)
				{
					_dir = -1 * _directionForward;
				}else{
					_dir = 1 * _directionForward;
				}
				
				this.update();
			}else{
				reset();
			}
		}

	}
}