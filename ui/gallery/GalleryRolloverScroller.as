package com.rensel.ui.gallery
{
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;

	[Event(name="complete",type="flash.events.Event")]
	
	public class GalleryRolloverScroller extends Sprite
	{
		
		private var _dir:Number = 1;
		private var _speed:Number = .8;
		private var _mouseIsOverNav:Boolean = false;
		private var _scrollSpeed:Number = 1;
		private var _rollOverBounds:Number = 400;
		private var _scrollingSpeedOffset:Number = .04;
		private var _decel:Number = .1;
		private var _slides:Array;
		private var _padding:Number;
		private var _mouseMiddle:Boolean = false;
		private var _freeze:Boolean = false;
		
		///////////////
		
		private var _moveTo:Number = 0;
		private var _itemToMove:DisplayObject;
		
		///////////////
		
		private var _array:Array;
		private var _xPos:Number;
		private var _yPos:Number;
		private var _hitBoxX:Number;
		private var _hitBoxY:Number;
		private var _hitBoxWidth:Number;
		private var _hitBoxHeight:Number;
		private var _rev:Number = 1;
		private var _galleryWidth:Number;
		private var _galleryHeight:Number;
		
		
		/**
		 * This class creates a scrolling gallery type display that scrolls progressivly faster depending on when the mouse is located in the rollOver Bounds.
		 * The list of params for this class is huge, it's as follows:
		 * 
		 * 	galleryHeight/galleryWidth - this params control the mask which masks the gallery, as well as the actual height and width.
		 * 	itemArray -  this is a list of display objects which are displayed in the gallery.
		 * 	itemsStartingXpos/itemsStartingYpos - is the point where the items sit within the mask.
		 * 	hitBoxX/hitBoxY - position of the hitbox
		 * 	hitBoxWidth/hitBoxHeight - Width and Height of the hit box.
		 * 	reverseDirection - Boolean,makes the gallery scroll in the opposite direction.
		 * 	speed - default speed(this doesnt really matter what its set at since the speed is determined where the mouse is at)
		 * 	scrollSpeed - This is the speed at which the gallery scrolls on its own.(set to 0 to make it only scroll on the mouseOver)
		 * 	rollOverBounds - this is the range from each edge of the gallery where the movement starts.
		 * 	scrollingSpeedOffset - this is how fast the scrolling actually goes.
		 * 	deceleration - this sets how fast the gallery coasts to a stop.
		 * 
		 * This class requires the public function update to be placed into an enterframe in order to make the gallery work.
		 * 	
		 * @param itemArray
		 * @param itemsStartingXpos
		 * @param itemsStartingYpos
		 * @param hitBoxX
		 * @param hitBoxY
		 * @param hitBoxWidth
		 * @param hitBoxHeight
		 * @param reverseDirection
		 * @param speed
		 * @param 
		 * @param scrollSpeed
		 * @param rollOverBounds
		 * @param scrollingSpeedOffset
		 * @param 
		 * @param deceleration
		 * @param 
		 * 
		 */		
		public function GalleryRolloverScroller(galleryHeight:Number,galleryWidth:Number,itemArray:Array,padding:Number = 5,itemsStartingXpos:Number = 0,itemsStartingYpos:Number = 0,hitBoxX:Number = 0,
		hitBoxY:Number = 0,hitBoxWidth:Number = 300,hitBoxHeight:Number = 100,reverseDirection:Boolean = false,speed:Number = .8,
		scrollSpeed:Number = 1,rollOverBounds:Number = 300,scrollingSpeedOffset:Number = .04,deceleration:Number = .1)
		{
			super();
			
			_array = itemArray;
			_xPos = itemsStartingXpos;
			_yPos = itemsStartingYpos;
			_hitBoxX = hitBoxX;
			_hitBoxY = hitBoxY;
			_hitBoxWidth = hitBoxWidth;
			_hitBoxHeight = hitBoxHeight;
			_galleryWidth = galleryWidth;
			_galleryHeight = galleryHeight;
			_padding = padding;
			
			_speed = speed;
			_scrollSpeed = scrollSpeed;
			_rollOverBounds = rollOverBounds;
			_scrollingSpeedOffset = scrollingSpeedOffset;
			_decel = deceleration;
			
			if(reverseDirection)
			{
				_rev = -1;
			}else{
				_rev = 1;
			}
			init();
		}
		
		private function init():void
		{	
			//create mask
			var mask:Sprite = new Sprite();
			mask.graphics.beginFill(0x000000);
			mask.graphics.drawRect(0,0,_galleryWidth,_galleryHeight);
			mask.graphics.endFill();
			this.mask = mask;
			
			for(var i:int = 0; i < _array.length; i++)
			{
				_array[i].y = _yPos;
				//trace((_array[i] as MovieClip).currentFrame + " -------- " + _array[i].width); 
				_array[i].x = (i * (_array[i].width + _padding)) + _xPos;
				this.addChild(_array[i]);
			}
			
			//draw hitbox
			this.graphics.beginFill(0x000000,0);
			this.graphics.drawRect(_hitBoxX,_hitBoxY,_hitBoxWidth,_hitBoxHeight);
			this.graphics.endFill();
			
			this.addEventListener(MouseEvent.ROLL_OUT,slides_MouseOutHandler);
			this.addEventListener(MouseEvent.MOUSE_MOVE,slides_MouseMoveHandler);
		}
		private function slides_MouseOutHandler(evt:MouseEvent):void
		{
			_mouseIsOverNav = false;
			_mouseMiddle = false;
		}
		private function slides_MouseMoveHandler(evt:MouseEvent):void
		{
			if(!_freeze)
			{
				if(this.mask.mouseX < _rollOverBounds)
				{
					_mouseMiddle = false;
					_mouseIsOverNav = true;
					_dir = 1
					_speed = ((mask.mouseX - _rollOverBounds) * -1) * _scrollingSpeedOffset;
				}else if(this.mask.mouseX > this.mask.width - _rollOverBounds)
				{
					_mouseMiddle = false;
					_mouseIsOverNav = true
					_dir = -1;
					_speed = (((this.mask.width - _rollOverBounds) - mask.mouseX) * -1) * _scrollingSpeedOffset;
				}else{
					_mouseMiddle = true;
				}
			}
		}
		//runs after the moveTo activities are complete
		private function imDoneMoving():void
		{
			var e:Event = new Event(Event.COMPLETE);
			this.dispatchEvent(e);
		}
		
		/**
		 * this public function must be placed into an enterframe to run this class.(more efficiant than adding an enterframe to this class) 
		 * 
		 */		
		public function update():void
		{
			if(!_freeze || _moveTo > 0)
			{
				if(_moveTo > 0)
				{
					//these statements snap the gallery to the moveTo point when it gets close so there is no over/under shoot.
					if(_itemToMove.x + _speed > _moveTo && _dir == 1)
					{
						var finish:Number = _moveTo - _itemToMove.x;
						for each(var s2:DisplayObject in _array)
						{
							s2.x += finish;
						}	
					}else if(_itemToMove.x - _speed < _moveTo && _dir == -1)
					{
						var finish2:Number = _itemToMove.x - _moveTo;
						for each(var s3:DisplayObject in _array)
						{
							s3.x += finish2;
						}
					}
					//these 2 statements cut off the moveTo actions when the moveTo point is reached
					if(_itemToMove && _dir == -1 && _itemToMove.x - _moveTo <= 0)
					{
						
						_moveTo = 0;
						_speed = _scrollSpeed;
						imDoneMoving();
					}else if(_itemToMove && _dir == 1 &&  _moveTo - _itemToMove.x <= 0)
					{
						_moveTo = 0;
						_speed = _scrollSpeed;
						imDoneMoving();
					}
				}
				// loops through the item array and moves each item the specified distance to create a scrolling effect.
				for each(var s:DisplayObject in _array)
				{
					s.x += _dir * _speed * _rev;
	
				}
				//these 2 statements control the looping of the array when the end is reached, it takes the item at the opposite end and places it
				//to the end that is at the edge.
				if(_array[0].x > -100 && _dir == 1)
				{
					_array.unshift(_array[_array.length - 1]);
					_array.pop();
					_array[0].x = (_array[1].x - _array[0].width);
				}
				
				
				if(_array[_array.length - 1].x < this.stage.stageWidth + 100 && _dir == -1)
				{
					_array.push(_array[0]);
					_array.shift();
					_array[_array.length - 1].x = _array[_array.length - 2].x + _array[_array.length - 1].width;
	
				}
				
				//controls deceleration and the stopping of scrolling when the mouse is near the middle
				if(_mouseMiddle)
				{
					_speed -= _decel;
					
					if(_speed < 0 )
					{
						_speed = 0;
					}
				}else{
					if(!_mouseIsOverNav && _speed > _scrollSpeed)
					{
						_speed -= _decel;
					}
					
					if(_speed < _scrollSpeed )
					{
						_speed = _scrollSpeed + _decel;
					}	
				}
				
				
			}
			
			
			
		}
		/**
		 * Public method that will freeze the gallery(similar to the freeze() method) and move to the specified x position. The method needs
		 * a reference object in the gallery to move to the point and a speed of the movement for the speed property. When the moveTo method 
		 * reaches it's position specified, the gallery will dispatch a Event.COMPLETE event. 
		 * @param referenceItem
		 * @param xPos
		 * @param speed
		 * 
		 */		
		public function moveTo(referenceItem:DisplayObject,xPos:Number,speed:Number):void
		{
			
			if(!_freeze)
			{
				_freeze = true;	
			}
			_moveTo = xPos;
			_speed = speed;
			_itemToMove = referenceItem;
			
			if(_moveTo < _itemToMove.x)
			{
				_dir = -1;
			}else{
				_dir = 1;
			}
		}
		/**
		 * Public method that allows you to access the items inside the gallery so public functions, add/remove child can be performed on them. 
		 * @param items
		 * 
		 */		
		public function set items(items:Array):void
		{
			_array = items;
		}
		/**
		 * @private 
		 * @return 
		 * 
		 */		
		public function get items():Array
		{
			return _array;
		}
		/**
		 * Freeze will freeze the update function, calling this function toggles between on and off. 
		 * 
		 */		
		public function freeze():void
		{
			if(!_freeze)
			{
				_freeze = true;
			}else{
				_freeze = false;
			}
		}
	
		
	}
}