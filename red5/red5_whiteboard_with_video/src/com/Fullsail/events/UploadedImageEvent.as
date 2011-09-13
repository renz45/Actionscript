package com.Fullsail.events
{
	import flash.display.Loader;
	import flash.events.Event;
	
	public class UploadedImageEvent extends Event
	{
		public static const UPLOADED:String = "uploaded";
		public static const SAVE:String = "save";
		public var image:Loader;
		public function UploadedImageEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			image = new Loader();
		}
		
		override public function clone():Event
		{
			return new UploadedImageEvent(type, bubbles, cancelable);
		}
	}
}