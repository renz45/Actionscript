package com.Fullsail.events
{
	import flash.events.Event;
	
	public class SliderEvent extends Event
	{
		public static const CHANGE:String = "change";
		public static const START:String = "change";
		public static const COMPLETE:String = "change";
		
		public var percent:Number;
		
		public function SliderEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			percent = 0;
		}
		
		override public function clone():Event
		{
			return new SliderEvent(type, bubbles, cancelable);
		}
	}
}