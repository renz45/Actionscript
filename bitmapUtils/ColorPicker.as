package com.rensel.bitmapUtils
{
	import com.rensel.bitmapUtils.bitmapEvents.BitmapEvent;
	
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;

	[Event(type="colorChange",type="com.rensel.bitmapUtils.bitmapEvents.BitmapEvent")]

	public class ColorPicker extends Sprite
	{
		private var _bmp:Bitmap;
		private var _color:int
		
		public function ColorPicker(path:String)
		{
			super();
			
			var ld:Loader = new Loader();
			ld.load(new URLRequest(path));
			ld.contentLoaderInfo.addEventListener(Event.COMPLETE,imgLoad_CompleteHandler);
		}
		
		private function imgLoad_CompleteHandler(evt:Event):void
		{
			_bmp = Bitmap(evt.target.content);
			
			this.addChild(_bmp);
			this.addEventListener(MouseEvent.MOUSE_DOWN,getColor);
		}
		
		private function getColor(evt:MouseEvent):void
		{
			_color = _bmp.bitmapData.getPixel(evt.localX,evt.localY);
			
			var e:BitmapEvent = new BitmapEvent(BitmapEvent.COLOR_CHANGE);
			e.color = _color;
			this.dispatchEvent(e);
		}
		
		public function get color():int
		{
			return _color;
		}
	
	}
}