package com.rensel.filesystem.Events
{
	import flash.events.Event;
	import flash.filesystem.File;
	
	public class DirectoryMonitor_Event extends Event
	{
		public var file:File;
		
		public static const DIRECTORY_CHANGE:String = "directoryChange";
		
		public function DirectoryMonitor_Event(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		override public function clone():Event
		{
			return new DirectoryMonitor_Event(type, bubbles, cancelable);
		}
	}
}