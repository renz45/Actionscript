package com.rensel.animation
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.PerspectiveProjection;
	import flash.geom.Point;

	public class Spin3dTransition extends Sprite
	{
		private var _item:Sprite;
		private var _item2:Sprite;
		
		private var _itemContainer:Sprite;
		private var _rotationValue:Number = 0;
		
		private var _spinSpeed:Number = 5;
		private var _direction:Number = 1;
		
		
		public function Spin3dTransition(item:Sprite)
		{
			super();
			_item = item;
			
			init();
		}
		
		private function init():void
		{
			//build an offset container
			_itemContainer = new Sprite;
			
			
			this.addChild(_itemContainer);
			
			_itemContainer.x = -_item.width/2;
			
			this.x = _item.width/2;
			_itemContainer.addChild(_item);
			
			var pp:PerspectiveProjection = new PerspectiveProjection();
			pp.fieldOfView = 20;
			pp.projectionCenter = new Point(_item.width/2,_item.height/2);
			
			this.transform.perspectiveProjection = pp;
			
			
			
		}
		
		private function update(e:Event):void
		{
			_rotationValue += _spinSpeed * _direction;
			this.rotationY += _spinSpeed * _direction;
			
			if(this.rotationY >= 90 && _direction == 1)
			{
				_itemContainer.removeChild(_item);
				_item = _item2;
				_itemContainer.addChild(_item);
				this.rotationY = -this.rotationY;
			}
			
			if(this.rotationY <= -90 && _direction == -1)
			{
				_itemContainer.removeChild(_item);
				_item = _item2;
				_itemContainer.addChild(_item);
				this.rotationY = -this.rotationY;
			}
			
			if(_rotationValue >= 180 || _rotationValue <= -180)
			{
				this.rotationY = 0;
				this.removeEventListener(Event.ENTER_FRAME,update);
				_rotationValue = 0;
			}
			
		}
		
		//*******************public methods ********************//
		public function changeTo(nextItem:Sprite):void
		{
			_item2 = nextItem;
			_rotationValue = 0;
			this.addEventListener(Event.ENTER_FRAME,update);
		}
		
		//*****************GETTERS/SETTERS*******************//
		
		public function get spinSpeed():Number
		{
			return _spinSpeed;
		}
		public function set spinSpeed(speed:Number):void
		{
			_spinSpeed = speed;
		}
		
		/**
		 * sets the direction of the spin takes a value or -1 or 1
		 * 
		 */
		public function get direction():Number
		{
			return _direction;
		}
		public function set direction(direction:Number):void
		{
			if(direction < 0)
			{
				direction = -1;
			}else{
				direction = 1;
			}
			_direction = direction;
		}
		
	}
}