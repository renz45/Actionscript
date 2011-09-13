package com.Fullsail.ui
{
	import libs.ButtonBase;
	
	public class Button extends ButtonBase
	{
		private var _label:String;
		public function Button()
		{
			super();
			this.buttonMode = true;
			this.mouseChildren = false;
			_label = new String();
		}

		public function get label():String
		{
			return _label;
		}

		public function set label(value:String):void
		{
			this.txt_label.text = value;
		}

	}
}