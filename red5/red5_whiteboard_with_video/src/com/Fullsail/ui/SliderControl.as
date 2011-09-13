package com.Fullsail.ui
{
	import com.Fullsail.events.SliderEvent;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
 
 	[Event(name="change", type="com.fullsail.events.SliderEvent")]
	/**
	 * This <b>SliderControl</b> is a basic slider that can be used for such things as volume or size control of objects. Very reusable! 
	 * @author lucaslea
	 * 
	 */ 	
	public class SliderControl extends EventDispatcher
	{
		private var _track:Sprite;
		private var _handle:Sprite;
		private var _percent:Number;
		private var _vertical:Boolean;
		/**
		 * Creates an instance of the SliderControl. 
		 * 
		 */		
		public function SliderControl(vertical:Boolean = false)
		{
			super();
			_percent = 1;
			_vertical = vertical;
		}
		private function updateSlider():void
		{
			_handle.x = (_track.width - _handle.width)*_percent;
		}
		private function onDown(event:MouseEvent):void
		{
			if (vertical)
			{
				_handle.startDrag(false, new Rectangle(0,0,0,(_track.height - _handle.height)));
			}
			else
			{
				_handle.startDrag(false, new Rectangle(0,0,(_track.width - _handle.width),0));
			}
			_handle.stage.addEventListener(MouseEvent.MOUSE_UP,onUp);
			
			_handle.addEventListener(Event.ENTER_FRAME,onFrame);
		}
		private function onUp(event:MouseEvent):void
		{
			_handle.stage.removeEventListener(MouseEvent.MOUSE_UP,onUp);
			_handle.removeEventListener(Event.ENTER_FRAME,onFrame);
			_handle.stopDrag();
		}
		private function onFrame(event:Event):void
		{
			var prc:Number;
			if (vertical)
			{
				prc = _handle.y/(_track.height - _handle.height);
			}
			else
			{
				prc = _handle.x/(_track.width - _handle.width);
			}
			
			if(prc != _percent)
			{
				_percent = prc;
				var evt:Event = new SliderEvent(SliderEvent.CHANGE);
				this.dispatchEvent(evt);
			}
		}
		
		/**
		 * Makes the handle and track on the slider. 
		 * @param handle A Sprite for your handle object.
		 * @param track Another Sprite for your track object.
		 * 
		 */		
		public function makeAssets(handle:Sprite, track:Sprite):void
		{
			_track = track;
			_handle = handle;
			
			_handle.addEventListener(MouseEvent.MOUSE_DOWN,onDown);
		}
		/**
		 * @private 
		 * @param value
		 * 
		 */		
		public function set percent(value:Number):void
		{
			if(value > 1)
			{
				value == 1;
			}
			else if(value < 0)
			{
				value == 0;
			}
			_percent = value;
			updateSlider();
		}
		/**
		 * The percent is how far along the track the handle is sitting.
		 * @return 
		 * 
		 */		
		public function get percent():Number
		{
			return _percent;
		}
		
		public function set vertical(value:Boolean):void
		{
			_vertical = value;
		}
		public function get vertical():Boolean
		{
			return _vertical;
		}
		
	}
}