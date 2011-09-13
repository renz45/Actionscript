 package {
	import com.Fullsail.componants.VideoMonitor;
	import com.Fullsail.componants.VideoSelector;
	import com.Fullsail.drawing.DrawingArea;
	import com.Fullsail.events.VideoPlayerEvent;
	import com.Fullsail.mainProject.Project;
	import com.Fullsail.ui.MenuBar;
	
	import flash.events.NetStatusEvent;
	import flash.events.SyncEvent;
	import flash.net.NetConnection;
	import flash.net.SharedObject;
	
	import lib.projectBase;
	
	import libs.testMc;
	
	[SWF(width = "960", height = "600", frameRate = "30", backgroundColor = "0xFFFFFF")]
 
	public class Main extends projectBase
	{
		private var _appURL:String;
		
		private var _vs:VideoSelector;
		private var _vm:VideoMonitor;
		private var _drawingCanvas:DrawingArea; 
		private var _menu:MenuBar;
		
		private var _nc:NetConnection;
		private var _username:String;
		
		private var _drawingSO:SharedObject;
		private var _usersSO:SharedObject;
		private var _serverUserID:int;
		
		private var _streamName:String;
		
		private var test:testMc;
		
		public function Main()
		{
		 	super();
		        
		   _appURL = "rtmp://172.30.25.9/SMS_Project_test5" 
		   _username = "Adam";    
		     
		   init();     
		           
		}
		
		private function init():void
		{
			var project:Project = new Project(_appURL,_username);
			this.addChild(project);
	
		}
		
		
	}
}
