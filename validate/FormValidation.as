package com.rensel.validate
{
	import flash.text.TextField;
	/**
	 * class with different form validation static functions 
	 * @author adamrensel
	 * 
	 */	
	public class FormValidation
	{
		public function FormValidation()
		{
		}
		/**
		 * This static function will look at the textfields in an array, and will validate if they are blank or not. If they are blank,
		 * the text fields will get a red border. This border will persist as long as the fields are blank. 
		 * @param items
		 * @return 
		 * 
		 */		
		public static function textFieldValidate(items:Array):Boolean
		{
			
			for each(var item:TextField in items)
			{
				if(item.text == "")
				{
					item.border = true;
					item.borderColor = 0xFF0000;
					//trace(1);
					
				}else{
					item.border = false;
					//trace(2);
				}
			}
			for each(var vItem:TextField in items)
				{
					if(vItem.border == true)
					{
						//trace("validation is false");
						return false;
					}
					
				}
				//trace("validation is true");
				return true;
			
				
				
		}

	}
}