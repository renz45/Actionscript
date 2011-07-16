package com.rensel.utils
{
	public class Format
	{
		public function Format()
		{
		}
		
		public static function money(value:Number):String
		{
			var formatedText:String;
			
			if(Math.floor(value) == value)
			{
				formatedText = "$" + String(value) + ".00";
			}else{
				value *= 100;
				value = Math.round(value);
				
				if(value % 10 == 0)
				{
					value /= 100;
					formatedText = "$" + String(value) + "0";
				}else{
					value /= 100;
					formatedText = "$" + String(value);
				}
			}
			
			return formatedText;
		}
		
		public static function convertToTime(time:Number,inMilliSeconds:Boolean = true,hours:Boolean = false):String
		{
			//1 hour = 3 600 000 milliseconds
			//1 minute = 60 000 milliseconds
			//1 second = 1000 milliseconds
			//3 hours 45 minutes 37 seconds = 13 537 000 milliseconds
			//trace(int(13537000 / 3600000));
			//trace( int((13537000 % 3600000)/60000));
			//trace(((13537000 % 3600000)%60000)/1000);
			var hour:int;
			var min:int;
			var sec:int;
			if(inMilliSeconds)
			{
				hour = int(time / 3600000);
				min = int((time % 3600000)/60000);
				sec = ((time % 3600000)%60000)/1000;
			}else{
				hour = int(time / 3600);
				min = int((time % 3600)/60);
				sec = ((time % 3600)%60);
			}
			var output:String = "";
			
			if(hours)
			{
				if(hour > 0)
				{
					if(hour < 10)
					{
						output += "0" + hour + ":";
					}else{
						output += hour + ":";
					}
				}else{
					output += "00" + ":";
				}
			}
			
			if(min > 0)
				{
					if(min < 10)
					{
						output += "0" + min + ":";
					}else{
						output += min + ":";
					}
				}else{
					output += "00" + ":";
				}
				
				if(sec > 0)
				{
					if(sec < 10)
					{
						output += "0" + sec;
					}else{
						output += sec;
					}
				}else{
					output += "00";
				}
			return output;
		}

	}
}