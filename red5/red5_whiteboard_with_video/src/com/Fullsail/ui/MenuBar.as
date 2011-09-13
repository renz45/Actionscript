package com.Fullsail.ui
{
	import com.Fullsail.events.ColorPickerEvent;
	import com.Fullsail.events.SliderEvent;
	import com.Fullsail.events.UploadedImageEvent;
	
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	
	import libs.Eraser;
	import libs.VolumeBase;
	
	[Event(name="uploaded", type="com.fullsail.events.UploadedImageEvent")]
	[Event(name="save", type="com.fullsail.events.UploadedImageEvent")]
	public class MenuBar extends Sprite
	{
		private var _picker:ColorPicker;
		private var _color:uint;
		private var _uploadImg:Button;
		private var _saveImg:Button;
		private var _eraser:Eraser;
		private var _fileRef:FileReference;
		private var _loader:Loader;
		private var _slider:SliderControl;
		private var _volBar:VolumeBase;
		
		private var _img:Bitmap;
			
		public function MenuBar()
		{
			super();
			
			_picker = new ColorPicker(new Sprite());
			this.addChild(_picker);
			_picker.x = 5;
			_picker.y = 5;
			_picker.addEventListener(ColorPickerEvent.PICKED, colorPicked);
			
			_uploadImg = new Button;
			_uploadImg.x = 40;
			_uploadImg.y = 5;
			_uploadImg.label = "Upload";
			this.addChild(_uploadImg);
			_uploadImg.addEventListener(MouseEvent.CLICK, browseImg);
			
			_saveImg = new Button;
			_saveImg.x = 40;
			_saveImg.y = 35;
			_saveImg.label = "Save";
			this.addChild(_saveImg);
			_saveImg.addEventListener(MouseEvent.CLICK, saveImg);
			
			_eraser = new Eraser();
			_eraser.buttonMode = true;
			_eraser.x = 60;
			_eraser.y = 200;
			this.addChild(_eraser);
			_eraser.addEventListener(MouseEvent.CLICK, erase);
			
			_volBar = new VolumeBase();
			_volBar.x = 40;
			_volBar.y = 80;
			this.addChild(_volBar);
			_slider = new SliderControl(true);
			_slider.makeAssets(_volBar.mc_handle,_volBar.mc_track);
			_slider.addEventListener(SliderEvent.CHANGE,changeVol);
		}
		
		private function changeVol(e:SliderEvent):void
		{
			trace("volume changed");
		}
		
		private function erase(e:MouseEvent):void
		{
			_color = 0xffffff;
			trace(_color);
		}
		
		private function colorPicked(e:ColorPickerEvent):void
		{
			_color = e.color;
			trace(_color);
		}
		
		private function saveImg(e:MouseEvent):void
		{
			trace("save");
			var evt:UploadedImageEvent = new UploadedImageEvent(UploadedImageEvent.SAVE);
			this.dispatchEvent(evt);
		}
		
		private function browseImg(e:MouseEvent):void
		{
			_fileRef = new FileReference();
			var arr:Array = [];
			arr.push(new FileFilter("Images", "*.gif;*.jpeg;*.jpg;*.png"));
			_fileRef.addEventListener(Event.SELECT, fileSelected);
			_fileRef.browse(arr);
		}
		
		private function fileSelected(e:Event):void
		{
			trace(_fileRef.name);
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
			var evt:UploadedImageEvent = new UploadedImageEvent(UploadedImageEvent.UPLOADED);
			evt.image = _loader;
			this.dispatchEvent(evt);
		}
		
	}
}