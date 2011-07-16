package com.rensel.ui.controllers
{
	import com.rensel.ui.controllers.controllerEvents.SpinnerEvent;
	import com.rensel.utils.Convert;
	import com.rensel.utils.MathUtil;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	[Event(type="com.rensel.ui.controllers.controllerEvents.SpinnerEvent",name="spinnerMove")]
	
	/**
	 * this class provides control to spinners, where you can click and drag on a circular interface element and get a percentage between 2
	 * set bounds in degrees(0-360, don't use negative values) the boundsStart value is where the degrees will start at 0. This class requires 
	 * and starting and ending angle which restricts the movement of the spinner, as well as a hitbox element which the user will click on drag 
	 * upon. The rotating obj item is the object that is doing the rotating, the pointer if you will.
	 * 
	 * The zero point is the right side, 3:00 O'Clock 
	 * 
	 * This class dispatches a custom spinnerEvent with the value attached to it.
	 * 
	 * The bounds start value gives a default location to where the pointer will start at. 
	 * @author adamrensel
	 * 
	 */
	public class Spinner extends EventDispatcher
	{
		private var _hitBox:Sprite;
		private var _rotatingObj:DisplayObject;
		private var _mouseDown:Boolean = false;
		
		private var _totalRange:Number;
		private var _boundsStart:Number;
		private var _boundsEnd:Number;
		private var _angle:Number;
		
		
		public function Spinner(hitBox:Sprite,rotatingObj:DisplayObject,defaultRotationDeg:Number = 0,boundsStart:Number = 0,boundsEnd:Number = 360)
		{
			super(); 
			
			_hitBox = hitBox;
			_rotatingObj = rotatingObj;
			_angle = defaultRotationDeg;
			_rotatingObj.rotation = _angle;
			
			//_totalRange = Math.abs(boundsStart) + Math.abs(boundsMax);
			_totalRange = boundsStart - boundsEnd;
			_boundsStart = boundsStart;
			_boundsEnd = boundsEnd;
		
			//trace(boundsStart);
			//trace(boundsMax);
			init();
			
			sendValue();
		}
		
		private function init():void
		{
			_hitBox.buttonMode = true;
			_hitBox.mouseChildren = false;
			
			_hitBox.addEventListener(MouseEvent.MOUSE_DOWN,hitBoxMouse_DownHandler);
			_hitBox.parent.addEventListener(MouseEvent.MOUSE_UP,hitBoxMouse_UpHandler);
			_hitBox.addEventListener(MouseEvent.MOUSE_OUT,hitBoxMouse_OutHandler);
			_hitBox.addEventListener(MouseEvent.MOUSE_OVER,hitBoxMouse_OverHandler);

		}
		
		private function getAngle(point1:Point,point2:Point):Number
		{
			var radians:Number = Math.atan2(point2.y - point1.y, point2.x - point1.x);
			
			return Convert.radiansToDegrees(radians);
		}
		
		private function hitBoxMouse_OutHandler(evt:MouseEvent):void
		{
			_hitBox.removeEventListener(MouseEvent.MOUSE_MOVE,hitBoxMouse_MoveHandler);
			//trace("out"); 
		}
		
		private function hitBoxMouse_OverHandler(evt:MouseEvent):void
		{
			if(_mouseDown)
			{
				_hitBox.addEventListener(MouseEvent.MOUSE_MOVE,hitBoxMouse_MoveHandler);
				//trace("in and down");
			}
			//trace("in");
		}
		
		private function hitBoxMouse_DownHandler(evt:MouseEvent):void
		{
			updateSpinner();
			_hitBox.addEventListener(MouseEvent.MOUSE_MOVE,hitBoxMouse_MoveHandler);
			_mouseDown = true;
			//trace("down");
		}
		
		private function hitBoxMouse_UpHandler(evt:MouseEvent):void
		{
			_hitBox.removeEventListener(MouseEvent.MOUSE_MOVE,hitBoxMouse_MoveHandler);
			_mouseDown = false;
			//trace("up");
		}
		
		private function hitBoxMouse_MoveHandler(evt:MouseEvent):void
		{
			updateSpinner();
			//trace(_mouseDown);
		}
		
		private function updateSpinner():void
		{
			var angle:Number = getAngle(new Point(_hitBox.mouseX,_hitBox.mouseY),new Point(_rotatingObj.x,_rotatingObj.y)) + 180;
			 
			//trace((angle - _boundsStart) / (_boundsStart - _boundsEnd));
			if(_boundsStart > _boundsEnd)
			{
				if(angle < _boundsStart && angle > _boundsEnd)
				{
					_angle = angle;
					//trace(_angle);
				}
				if(angle > _boundsStart)
				{
					_angle = _boundsStart;
				}
				if(angle < _boundsEnd)
				{
					_angle = _boundsEnd;
				}
				_rotatingObj.rotation = _angle;
			}
			
			if(_boundsStart < _boundsEnd)
			{
				if(angle > _boundsStart && angle < _boundsEnd)
				{
					_angle = angle;
					//trace(_angle);
				}
				if(angle < _boundsStart)
				{
					_angle = _boundsStart;
				}
				if(angle > _boundsEnd)
				{
					_angle = _boundsEnd;
				}
				_rotatingObj.rotation = _angle;
			}
			
			sendValue();
		}
		
		private function sendValue():void
		{
			var e:SpinnerEvent = new SpinnerEvent(SpinnerEvent.SPINNER_MOVE);
			e.value = Math.abs((_angle - _boundsStart) / (_boundsStart - _boundsEnd));
			//trace(e.value);
			this.dispatchEvent(e);
		}
		/**
		 * Property accepts a percent value between 0-1
		 * @param value
		 * 
		 */		
		public function set value(value:Number):void
		{
			if(value >=0 && value <=1)
			{
				var change:Number = _totalRange * value;
			
				if(_boundsStart > _boundsEnd)
				{
					_angle = _boundsStart - change;
				}
				if(_boundsStart < _boundsEnd)
				{
					_angle = _boundsStart - change;
				
				}
				_rotatingObj.rotation = _angle;
				sendValue();
			}
		}
		/**
		 * @private 
		 * @return 
		 * 
		 */		
		public function get value():Number
		{
			return Math.abs((_angle - _boundsStart) / (_boundsStart - _boundsEnd));
		}
		/**
		 * public method that allows the rotation to be set without dispatching the SPINNER_MOVE event 
		 * @param value
		 * 
		 */		
		public function set playValue(value:Number):void
		{
			if(value >=0 && value <=1)
			{
				var change:Number = _totalRange * value;
			
				if(_boundsStart > _boundsEnd)
				{
					_angle = _boundsStart - change;
				}
				if(_boundsStart < _boundsEnd)
				{
					_angle = _boundsStart - change;
				
				}
				_rotatingObj.rotation = _angle;
				//sendValue();
			}
		}
		
	}
}