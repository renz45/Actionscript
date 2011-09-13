package com.Fullsail.mainProject
{
	
	import com.Fullsail.componants.VideoMonitor;
	import com.Fullsail.componants.VideoSelector;
	import com.Fullsail.drawing.DrawingArea;
	import com.Fullsail.events.ColorPickerEvent;
	import com.Fullsail.events.VideoPlayerEvent;
	import com.Fullsail.ui.ColorPicker;
	import com.Fullsail.ui.MenuBar;
	import com.fs.ui.controllers.Slider;
	import com.quietless.bitmap.BitmapSnapshot;
	
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SyncEvent;
	import flash.net.FileReference;
	import flash.net.NetConnection;
	import flash.net.SharedObject;
	import flash.text.TextField;
	
	import lib.projectBase;
	
	//image upload isnt working, from what I can tell you can't transfer an image acrossed a sharedObject...I tried converting the image to a bytearray
	//and transfering the bytearray and reassembling it.  It didn't appear to work.  The only way I can think of is to upload the picture to the webserver
	//and pass the url of the picture to the other clients through the shared object and than load the image externally.
	//I will give the external image functionality a try if there is time.  But if I get the image to work then the eraser I am currently using will
	//draw white on the picture, the only way to get eraser and drawing to work on top of a picture is to draw using bitmap data.  The eraser is created
	//by using a matrix with a blending mode filter of... its either delete or erase.  The drawing requires a matrix as well with this method.

	public class Project extends projectBase
	{
		private var _appURL:String;
		
		private var _vs:VideoSelector;
		private var _vm:VideoMonitor;
		private var _drawingCanvas:DrawingArea; 
		private var _menu:MenuBar;
		private var _isErasing:Boolean = false;
		private var _currentColor:uint = 0x000000;
		
		private var _nc:NetConnection;
		private var _username:String;
		
		private var _drawingSO:SharedObject;
		private var _usersSO:SharedObject;
		//private var _imageSO:SharedObject;
		private var _serverUserID:int;
		
		private var _streamName:String;
		
		private var _volumeSlider:Slider;
		private var _strokeSlider:Slider;
		private var _colorPicker:ColorPicker;
		private var _fileRef:FileReference;
		private var _loader:Loader;
		
		public function Project(appURL:String,username:String)
		{
			super();
			
			_appURL = appURL;
		   _username = username;   
		     
		   init(); 
		}
		
		private function init():void
		{
			//initialize the netConnection
			_nc = new NetConnection();
			_nc.client = this;
			_nc.connect(_appURL,_username);
			_nc.addEventListener(NetStatusEvent.NET_STATUS,netStatusHandler);
			
			
			//volume slider
			_volumeSlider = new Slider(this.slider_volume.mc_handle,this.slider_volume.mc_track,true);
			_volumeSlider.value = .5;
			
			//stroke size slider
			_strokeSlider = new Slider(this.slider_stroke.mc_handle,this.slider_stroke.mc_track);
			_strokeSlider.value = .1;
			this.tf_stroke.text = "1";
			
			//colorPicker
			_colorPicker = new ColorPicker(this.mc_colorPicker);
			
			
			//save image
			this.btn_save.buttonMode = true;
			this.btn_save.mouseChildren = false;
			
			//image upload
			this.btn_upload.buttonMode = true;
			this.btn_upload.mouseChildren = false;
			this.btn_upload.visible = false;
		//	this.btn_upload.addEventListener(MouseEvent.CLICK,imageUpload);
			
			//clearImage button
			this.btn_clearImage.buttonMode = true;
			this.btn_clearImage.mouseChildren = false;
			this.btn_clearImage.visible = false;
		//	this.btn_clearImage.addEventListener(MouseEvent.CLICK,clearImage);
		
			//record button, event listner is down in the setupMonitor function
			this.btn_record.buttonMode = true;
			this.btn_record.mouseChildren = false;
			this.btn_record.gotoAndStop(1);
			
			//pencil button
			this.btn_pencil.buttonMode = true;
			this.btn_pencil.gotoAndStop(2);
			
			//eraser button
			this.btn_eraser.buttonMode = true;
			this.btn_eraser.gotoAndStop(1);
			
			//clearMyLayer button
			this.btn_clearMyLayer.buttonMode = true;
			this.btn_clearMyLayer.mouseChildren = false;
			
			//clearMyCanvas
			this.btn_clearMyCanvas.buttonMode = true;
			this.btn_clearMyCanvas.mouseChildren = false;
			
	
		}
		
		//application widgets get added here
		private function setUpApplication():void
		{
			//set up the video selector widget
			_vs = new VideoSelector(_nc,_appURL);
			
			_vs.y = 80;
			
			this.mc_videoSelectorContainer.addChildAt(_vs,1);
			this.mc_videoSelectorContainer.videoSelectorArrows.mouseEnabled = false;
			
			//connect to the server created sharedObject, this one is used for the drawing application
			_drawingSO = SharedObject.getRemote("drawingSO",_appURL,false);
			_drawingSO.addEventListener(SyncEvent.SYNC,drawingOnSync);
			_drawingSO.connect(_nc);
			
			
			_usersSO = SharedObject.getRemote("usersSO",_appURL,false);
			_usersSO.addEventListener(SyncEvent.SYNC,usersOnSync);
			_usersSO.connect(_nc);
			
			/*_imageSO = SharedObject.getRemote("imageSO",_appURL,false);
			_imageSO.addEventListener(SyncEvent.SYNC,usersOnSync);
			_imageSO.connect(_nc);*/
			
			//drawing componant
			_drawingCanvas = new DrawingArea();
			_drawingCanvas.y = 0;
			_drawingCanvas.setStrokeSize(1);
			this.addChild(_drawingCanvas);
			_drawingCanvas.setSharedObject(_drawingSO,_serverUserID.toString());
			
			
			//eventlisteners for ui
			_volumeSlider.addEventListener(Event.CHANGE,changeVol);
			_strokeSlider.addEventListener(Event.CHANGE,changeStroke);
			_colorPicker.addEventListener(ColorPickerEvent.PICKED,changeColor);
			this.btn_save.addEventListener(MouseEvent.CLICK,saveImage);
			this.btn_pencil.addEventListener(MouseEvent.CLICK,pencilClick);
			this.btn_eraser.addEventListener(MouseEvent.CLICK,eraserClick);
			this.btn_clearMyLayer.addEventListener(MouseEvent.CLICK,clearMyLayer);
			this.btn_clearMyCanvas.addEventListener(MouseEvent.CLICK,clearMyCanvas);
			
		}//end setUpApplication
		
		private function setupMonitor():void
		{
			//set up video monitor widget
			_streamName = _usersSO.data[_serverUserID].stream;
			_vm = new VideoMonitor(_appURL,_nc,_streamName);
			
			this.mc_monitorContainer.addChild(_vm);
			this.btn_record.addEventListener(MouseEvent.CLICK,recordClickHandler);
		}//end setupMonitor
		
		
		
		private function updateVideoSelector(userChanged:Number):void
		{
			var tempObj:Object = _usersSO.data[userChanged];
			if(_usersSO.data[userChanged])
			{
				
				_vs.updateStream(tempObj.username,userChanged,tempObj.stream,tempObj.isStreaming);
			}else{
				_vs.updateStream("",userChanged,null,0);
			}
		}
		
		
		//this function gets called by the server in order to tell the client what userID the server has assigned to this client
		//This user id is the slot in the shared object which contains this clients information
		//shared object can be looked at in the debugger, but it is access like: 
		//so.data[_serverUserID.toString()].name,so.data[_serverUserID.toString()].x,so.data[_serverUserID.toString()].y etc
		public function setUserId(value:*):void
		{
			trace("Your user ID is:  "+value);
			_serverUserID = value;
		}

		//the sync event catches different events related to the shared object. 
		private function drawingOnSync(e:SyncEvent):void
		{
			
			for each(var i:Object in e.changeList)
			{
				
				switch(i.code)
				{
					//when another client changes the so
					case "change":
						//test.tf_output.text  = _drawingSO.data[i.name];
						trace("drawing changing: "+i.name);
						_drawingCanvas.userDrawing(i.name);

					break;
					//when this client changes the so
					case "success":
						//test.tf_output.text  = _drawingSO.data[i.name];
						trace("drawing success: "+i.name);
						_drawingCanvas.userDrawing(i.name);
						//_drawingCanvas.userDrawing(i.name);
					break;
					//when so first connects successfully
					case "clear":
						trace("drawing SO is connected")
					break;
					//when something gets deleted from the so
					case "delete":
						trace(i.name +" in drawingSO was deleted!");
					break;
				}
			}
			
		}//drawingOnSync
		
		private function usersOnSync(e:SyncEvent):void
		{
			
			for each(var i:Object in e.changeList)
			{
				
				switch(i.code)
				{
					//when another client changes the so
					case "change":
					//	test.tf_output.text  = _drawingSO.data[i.name];
						trace("users change: "+i.name);
						updateVideoSelector(i.name);
						
							
						if(i.name == "image"){
							trace("trying to draw the image to the canvas.");
							//drawPicture();
						}
					break;
					//when this client changes the so
					case "success":
						//test.tf_output.text  = _drawingSO.data[i.name];
						trace("users success: "+i.name);
						updateVideoSelector(i.name);
					break;
					//when SO first connects successfully
					case "clear":
						trace("users SO is connected")
						setupMonitor();
						
					break;
					//when something gets deleted from the so 
					case "delete":
						trace(i.name +" in usersSO was deleted!");
						updateVideoSelector(i.name);
					break;
				}
			}
			
		}
		
		
		//not working, read below for the explanation of the image upload.
		/*
		private function drawPicture():void
		{
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE,gotBitMapData);
			loader.loadBytes(_imageSO.data["image"].bitMapData);
			trace("LOADINGIMGAGE!")
		}
		
		private function gotBitMapData(e:Event):void
		{
			var decodedBitMapData:BitmapData = new Bitmap(e.target.content).bitmapData;
			
			var bmp:Bitmap = new Bitmap(decodedBitMapData);
			
			_drawingCanvas.addChildAt(bmp,0);
			
		}*/
		
		//*******************************CALLBACKS****************************//
		private function recordClickHandler(e:MouseEvent):void
		{
			var tempParams:Object = _usersSO.data[_serverUserID];
			if(this.btn_record.currentFrame == 1)
			{
				this.btn_record.gotoAndStop(2);
				_vm.record();
				
				
				tempParams.isStreaming = "1";
				_usersSO.setProperty(_serverUserID.toString(),tempParams);
				_usersSO.setDirty(_serverUserID.toString());
				
				trace(_vm.width);
			}else{
				this.btn_record.gotoAndStop(1);
				_vm.stopStream();
				
				
				tempParams.isStreaming = "0";
				_usersSO.setProperty(_serverUserID.toString(),tempParams);
				_usersSO.setDirty(_serverUserID.toString());
			}
		}//end recordClickHandler
		
		//changes volume with value from _volumeSlider
		private function changeVol(e:Event):void
		{
			
			_vs.setVolume(_volumeSlider.value);
		}
		
		
		//changes stroke with value from _strokeSlider
		private function changeStroke(e:Event):void
		{
			var strokeSize:int = Math.ceil(_strokeSlider.value*10 +1);
			
			this.tf_stroke.text = strokeSize.toString();
			_drawingCanvas.setStrokeSize(strokeSize);
			
			trace("setting: "+_serverUserID+" stroke to: "+strokeSize.toString());
			
			var tempParams:Object = _drawingSO.data[_serverUserID];
			tempParams.stroke = strokeSize.toString();
			_drawingSO.setProperty(_serverUserID.toString(),tempParams);
			_drawingSO.setDirty(_serverUserID.toString());
			
		} 
		
		private function changeColor(e:ColorPickerEvent):void
		{
			
			
			_currentColor = e.color;
			trace(_currentColor);
			
			_drawingCanvas.setColor(e.color);
			
			var tempParams:Object = _drawingSO.data[_serverUserID];
			tempParams.color = _currentColor.toString();
			_drawingSO.setProperty(_serverUserID.toString(),tempParams);
			_drawingSO.setDirty(_serverUserID.toString());
		
		
			this.mc_selectedColor.graphics.clear();
			this.mc_selectedColor.graphics.beginFill(e.color);
			this.mc_selectedColor.graphics.drawRect(0,0,this.mc_selectedColor.width,this.mc_selectedColor.height);
			this.mc_selectedColor.graphics.endFill();
			
			
		}
		
		private function saveImage(e:MouseEvent):void
		{
			var img:BitmapSnapshot = new BitmapSnapshot(_drawingCanvas);
			img.saveToDesktop();
		}
		
		private function pencilClick(e:MouseEvent):void
		{
			this.btn_pencil.gotoAndStop(2);
			this.btn_eraser.gotoAndStop(1);
			
			_drawingCanvas.setColor(_currentColor);
			_isErasing = false;
			var tempParams:Object = _drawingSO.data[_serverUserID];
			tempParams.isErasing = "0";
			_drawingSO.setProperty(_serverUserID.toString(),tempParams);
			_drawingSO.setDirty(_serverUserID.toString());
		}
		
		private function eraserClick(e:MouseEvent):void
		{
			this.btn_pencil.gotoAndStop(1);
			this.btn_eraser.gotoAndStop(2);
			
			_drawingCanvas.setColor(0xFFFFFF);
			_isErasing = true;
			var tempParams:Object = _drawingSO.data[_serverUserID];
			tempParams.isErasing = "1";
			_drawingSO.setProperty(_serverUserID.toString(),tempParams);
			_drawingSO.setDirty(_serverUserID.toString());
		}
		
		private function clearMyLayer(e:MouseEvent):void
		{
			var tempParams:Object = _drawingSO.data[_serverUserID];
			tempParams.clearLayer = "1";
			_drawingSO.setProperty(_serverUserID.toString(),tempParams);
			_drawingSO.setDirty(_serverUserID.toString());
		}
		
		private function clearMyCanvas(e:MouseEvent):void
		{
			_drawingCanvas.clearCanvas();
		}
		
		//image upload isnt working, from what I can tell you can't transfer an image acrossed a sharedObject...I tried converting the image to a bytearray
		//and transfering the bytearray and reassembling it.  It didn't appear to work.  The only way I can think of is to upload the picture to the webserver
		//and pass the url of the picture to the other clients through the shared object and than load the image externally.
		//I will give the external image functionality a try if there is time.  But if I get the image to work then the eraser I am currently using will
		//draw white on the picture, the only way to get eraser and drawing to work on top of a picture is to draw using bitmap data.  The eraser is created
		//by using a matrix with a blending mode filter of... its either delete or erase.  The drawing requires a matrix as well with this method.
		/*private function imageUpload(e:MouseEvent):void
		{
			_fileRef = new FileReference();
			var arr:Array = [];
			arr.push(new FileFilter("Images", "*.gif;*.jpeg;*.jpg;*.png"));
			_fileRef.addEventListener(Event.SELECT, fileSelected);
			_fileRef.browse(arr);
		}
		
		private function fileSelected(e:Event):void
		{
			_fileRef..load(); 
			_fileRef.addEventListener(Event.COMPLETE, uploadComplete);
		}
		
		private function uploadComplete(e:Event):void
		{
			var rawBytes:ByteArray = _fileRef.data;
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, getBitmapData)
			_loader.loadBytes(rawBytes);
		}
		
		private function getBitmapData(e:Event):void
		{
			//_drawingCanvas.addChildAt(_loader,0);
			
			var bmd:BitmapData = new BitmapData(_loader.width,_loader.height,true);
			bmd.draw(_loader);
			
			var jpgEncoder:JPGEncoder = new JPGEncoder(100);
			var byteArray:ByteArray = jpgEncoder.encode(bmd);
			
			
			_imageSO.setProperty("image",byteArray);
			_imageSO.setDirty("image");
		}
		
		private function clearImage(e:MouseEvent):void
		{
			
			//_drawingCanvas.graphics.clear();
		}*/
		
		private function monitorRecordHandler(e:VideoPlayerEvent):void
		{
			var tempParams:Object = _usersSO.data[_serverUserID];
			tempParams.isStreaming = "1";
			
			_usersSO.setProperty(_serverUserID.toString(),tempParams);
			
		}
		
		private function monitorStopHandler(e:VideoPlayerEvent):void
		{
			var tempParams:Object = _usersSO.data[_serverUserID];
			tempParams.isStreaming = "0";
			_usersSO.setProperty(_serverUserID.toString(),tempParams);
			_usersSO.setDirty(_serverUserID.toString());
		}
		
		
		//required by the netConnection
		public function onBWDone():void
		{
			
		}
		
		private function netStatusHandler(e:NetStatusEvent):void
		{
			trace(e.info.code);
			if(e.info.code == "NetConnection.Connect.Success")
			{
				setUpApplication();
			}
			
			if(e.info.code == "NetConnection.Connect.Failed")
			{
				var errorText:TextField = new TextField();
				errorText.text = "Connection Failed";
				errorText.x = 20;
				errorText.y = 20;
				this.mc_canvas.addChild(errorText);
			}
		}
		
	}
}