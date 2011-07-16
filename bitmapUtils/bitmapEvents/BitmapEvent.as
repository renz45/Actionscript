package com.rensel.bitmapUtils.bitmapEvents
{
	import flash.events.Event;

	public class BitmapEvent extends Event
	{
		public static const COLOR_CHANGE:String = "colorChange";
		
		public var color:int;
		
		public function BitmapEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event
		{
			return new BitmapEvent(type, bubbles, cancelable);
		}
		
	}
}