package com.Fullsail.componants
{
	import com.Fullsail.video.VideoPlayer;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.net.NetConnection;
	
	[Event(name="publishStart",type="com.Fullsail.events.VideoPlayerEvent")]
	[Event(name="publishStop",type="com.Fullsail.events.VideoPlayerEvent")]
	public class VideoMonitor extends Sprite
	{
		private var _vp:VideoPlayer;
		
		private var _appURL:String;
		private var _nc:NetConnection;
		private var _streamName:String
		
		public var _videoContainer:MovieClip;
		
		public function VideoMonitor(appURL:String,netConnection:NetConnection,streamName:String)
		{
			super();
			
			_appURL = appURL;
			_nc = netConnection;
			_streamName = streamName;
			
			
			init();
		}
		
		private function init():void
		{
			_vp = new VideoPlayer(_appURL,_nc);
			this.addChild(_vp);
		
		}
		
		
		
		//********************CALLBACKS*********************//
		
		public function record():void
		{
			trace("trying to start recording");
			trace("streamname: "+ _streamName);
			_vp.record(_streamName,"live");
			_vp.width = 250;
			_vp.height = 166;
			_vp.volume = 0;
		}//end startCameraHandler
		
		public function stopStream():void
		{
			_vp.stop();
		}//end stopCameraHandler
	}
}