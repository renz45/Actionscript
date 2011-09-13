package com.Fullsail.events
{
	import flash.events.Event;

	public class VideoPlayerEvent extends Event
	{
		public static var MONITOR_STOP:String = "monitorStop";
		public static var MONITOR_START:String = "monitorStart";
		public static var PUBLISH_STOP:String = "publishStop";
		public static var PUBLISH_START:String = "publishStart";
		
		public function VideoPlayerEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event
		{
			return new VideoPlayerEvent(type,bubbles,cancelable);
		}
		
	}
}