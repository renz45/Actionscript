package com.Fullsail.ui
{
	import com.Fullsail.events.ColorPickerEvent;
	
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	public class ColorPicker extends Sprite
	{
		private var _bmd:BitmapData;
		public function ColorPicker(img:Sprite)
		{
			super();
			//loadImg(img);
			
			//this.addChild(img);
			_bmd = new BitmapData(img.width,img.height);
			_bmd.draw(img);
			img.addEventListener(MouseEvent.MOUSE_DOWN,getColor);
			
		}
		
		
		
		private function getColor(e:MouseEvent):void
		{
			var s:Sprite = new Sprite();
			var color:uint = _bmd.getPixel(e.localX,e.localY);
			var evt:ColorPickerEvent = new ColorPickerEvent(ColorPickerEvent.PICKED);
			evt.color = color;
			this.dispatchEvent(evt);
		}
		
	}
}