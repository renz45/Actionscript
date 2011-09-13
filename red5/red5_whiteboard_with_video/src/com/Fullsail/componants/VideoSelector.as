package com.Fullsail.componants
{
	import com.Fullsail.video.VideoPlayer;
	import com.fs.ui.controllers.LayoutBox;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.NetConnection;
	
	import lib.videoThumbBase;

	public class VideoSelector extends Sprite
	{
		private var _videoList:Array;
		private var _lb:LayoutBox;
		private var _mouseIsOver:Boolean = false;
		private var _scrollValue:Number = 0;
		
		private var _nc:NetConnection;
		private var _appURL:String;
		
		//controls the size of each individual video
		private var _thumbWidth:Number = 200;
		private var _thumbHeight:Number = 150;
		
		//these values control the scrolling function of this videoSelector
		private var _galWidth:Number = 670;
		private var _galHeight:Number = _thumbHeight;//this generally should be the same size as the _thumbHeight, controls the mask size on the layoutBox
		private var _rollOverAreaWidth:Number = 200;
		private var _scrollDirection:Number = -1;
		private var _scrollSpeed:Number = 8;
		
		public function VideoSelector(netConnection:NetConnection,appURL:String)
		{
			super();
			_appURL = appURL;
			_nc = netConnection;
			
			init();
		}
		
		private function init():void
		{
			_videoList = [];
			
			
			
			//layout box holds the videos
			_lb = new LayoutBox(false,0);
			this.addChild(_lb);
			_lb.buttonMode = true;
			
			_lb.addEventListener(MouseEvent.MOUSE_OVER,lbMouseOverHandler);
			_lb.addEventListener(MouseEvent.MOUSE_OUT,lbMouseOutHandler);
			
			//create the mask
			var mask:Sprite = new Sprite();
			mask.graphics.beginFill(0xFFFFFF,.3)
			mask.graphics.drawRect(0,0,_galWidth,_galHeight);
			mask.graphics.endFill();
			this.addChild(mask);
			_lb.mask = mask;
			
			
	
		}
		
		private function lbMouseOverHandler(e:MouseEvent):void
		{
			_mouseIsOver = true;
			this.addEventListener(Event.ENTER_FRAME,engine);
		}//end lbMouseOverHandler
		
		private function lbMouseOutHandler(e:MouseEvent):void
		{
			_mouseIsOver = false;
			_scrollValue = 0;
			this.removeEventListener(Event.ENTER_FRAME,engine);
		}//end lbMouseOverHandler
		
		private function engine(e:Event):void
		{
			//scrolling logics
			//these algorithims look like mud, but the purpose was to be able to scroll without needing additional hit boxes, and so the area could 
			//expand as needed and still work even with the layout box changing sizes constantly when objects were places inside it.
			if(_lb.width > _galWidth && _mouseIsOver)
			{
				//mouse on right side of the layoutbox
				if(_lb.mouseX > (_lb.x*-1)+(_lb.width - _rollOverAreaWidth - (_lb.width-_galWidth)) )
				{
					
					//trace( ((_lb.mouseX - ((_lb.x*-1)+_lb.width - (_lb.width-_galWidth)))+_rollOverAreaWidth) / _rollOverAreaWidth );
					//right side logic             account for changing lb.x   account for changing lb.width so "hitbox" stays on the  right edge of gallery
					_scrollValue = ((_lb.mouseX   - ((_lb.x*-1)+_lb.width -    (_lb.width-_galWidth)))+_rollOverAreaWidth)      / _rollOverAreaWidth;//gives a percent
				
				}else if(_lb.mouseX < (_lb.x*-1) + _rollOverAreaWidth){//mouse on the left side of the Layoutbox
					//trace( ((_lb.mouseX - (_lb.x*-1))-_rollOverAreaWidth) / _rollOverAreaWidth );
					//left side logic                  account for changing lb.x
					_scrollValue = ((_lb.mouseX - (_lb.x*-1))-_rollOverAreaWidth) / _rollOverAreaWidth; //gives a percent
				}
			}//end
			
			
			
			//trace(_lb.x);
			//scrolling
			if(_lb.x <=0 && _lb.x >= -(_lb.width - _galWidth))
			{
				_lb.x +=  _scrollDirection*(_scrollSpeed*_scrollValue);
				
				//these conditionals keep the scrolling from going beyond its limits, defaults the lb.x to the max and min ranges if they exceed them.
				if(_lb.x > 0)
				{
					_lb.x = 0;
				}
				
				if(_lb.x < -(_lb.width - _galWidth))
				{
					_lb.x = -(_lb.width - _galWidth);
				}
				
			}
			
		}//end engine
		
		//*********************public methods ***********************//
		public function updateStream(username:String,serverUserId:Number,streamName:String = null,isPlaying:int = 0):void
		{
			
			
			//if the stream doesnt exist in the videoList and has a stream name, and isPlaying is true(1) than go ahead and create a new videoPlayer
			//and add the videoPlayer to the videoList and layout box.  Saving the videoPlayer to the video list saves a reference so we can remove the player
			//later from the the layout box and videoList if the user logs out or stops their stream
			if(streamName && !_videoList[serverUserId as int] && isPlaying == 1)
			{
				//trace("adding video to the display bar: "+serverUserId);
				var vp:VideoPlayer = new VideoPlayer(_appURL,_nc);
				var vt:videoThumbBase = new videoThumbBase(); 
				vt.addChildAt(vp,0);
				vt.tf_name.text = username;
				vp.play(streamName);
				vp.vidWidth = _thumbWidth;
				vp.vidHeight = _thumbHeight;
				
				_videoList[serverUserId as int] = vt;
				
				_lb.addChild(vt);
				
			//test for if the userId exists in the videoList, if it does than the stream name is tested, if it exsist that means the user didn't log out
			//because the stream name still exists.  We also test if the stream is playing.  Either the stream doesnt exist or it is not playing
			//this results in the video getting pulled out of the videoList and layoutBox
			}else if(_videoList[serverUserId as int]){
				//trace("stage1 remove: "+serverUserId); 
				if(!streamName || isPlaying == 0)
				{
					//trace("stage2 remove: "+serverUserId);
					_lb.removeChild(_videoList[serverUserId]);
					_videoList.splice(serverUserId as int,1);
					
				}//end if
				
			}//else if
	
			
		}//end updateStream
		
		public function setVolume(percent:Number):void
		{
			
			for each(var vid:videoThumbBase in _videoList)
			{
				
				(vid.getChildAt(0) as VideoPlayer).volume = percent;
			}
		}

		
	}//end class
}//end package