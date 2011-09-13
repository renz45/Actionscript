package com.Fullsail.drawing
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.text.TextFieldAutoSize;
	import flash.utils.Timer;
	
	import libs.canvasBase;
	import libs.myMask;
	import libs.tagBase;
	
	
	public class DrawingArea extends Sprite
	{
		private var _color:uint = 123123;
		private var _sharedObject:Object;
		private var _serverId:String;
		private var _name:String;
		private var _bgImage:Sprite;
		private var _bgWidth:int;
		private var _bgHeight:int;
		//canvas
		private var _myMask:myMask;
		private var _canvas:Sprite;
		private var _canvasBackground:canvasBase;
		private var _drawing:Boolean;
		private var _stroke:int = 1;
		private var _tag:tagBase;
		
		private var _eraser:Boolean;
		private var _marker:Boolean;
		
		//adam added
		private var _drawingLayerList:Array;
		private var _currentDrawingLayer:int;
		private var _drawingRobotStarted:Boolean = false;
		private var _robotTimer:Timer;
		
		public function DrawingArea()
		{
			super();
			_name = "";
			_bgImage = new Sprite();
			
			_eraser = false;
			_marker = true;
			
			_name = new String("tim");
			
			_drawingLayerList = [];
			init();
		}
		
		//-----------------------------------------------public setter functions----------------------------//
		
		public function setColor(c:int):void
		{
			_color = c;
		}
		public function setSharedObject(o:Object,id:String):void
		{
			_sharedObject = o;
			_serverId = id;
			
		}
		public function setName(s:String):void
		{
			_name = s;
		}
		public function setBgImage(bg:Sprite):void
		{
			_bgImage = bg;
		}
		public function clearCanvas():void
		{
			for each(var s:Sprite in _drawingLayerList)
			{
				s.graphics.clear();
			}
		}
		
		public function setStrokeSize(i:int):void
		{
			_stroke = i;
		}
		public function setEraser():void
		{
			_eraser = true;
			_marker = false;
		}
		public function setMarker():void
		{
			_eraser = false;
			_marker = true;
		}
		//-------------------------------------------------for uploaded picture----------------------------//
		
		private function getWidth():int
		{
			return _bgImage.width;
		}
		private function getHeight():int
		{
			return _bgImage.height;
		}
		
		//------------------------------------------------canvas-------------------------------------------//
		
		private function init():void
		{
			//expands the sprite, not sure why I cant just set a width or height.
			this.graphics.beginFill(0xFFFFFF,0);
			this.graphics.drawRect(0,0,676,450);
			this.graphics.endFill();
			
			//using a timer instead of an enterframe to run the drawing robot in an atempt to smooth out the drawing when someone draws fast or framerate drops
			_robotTimer = new Timer(30);
			_robotTimer.addEventListener(TimerEvent.TIMER,drawerRobot);
			
			//_canvasBackground = new canvasBase();
			//this.addChild(_canvasBackground);
			this._canvas = new Sprite();

			this.addChild(_canvas);
			
			_myMask = new myMask();
			this.addChild(_myMask);
			_myMask.x = 6;
			_myMask.y = 6;
			_myMask.graphics.beginFill(0x999999);
			_myMask.graphics.drawRect(0,0,668,437);
			_myMask.graphics.endFill();
			
			_canvas.mask = _myMask;
			
			
			this.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
			this.addEventListener(MouseEvent.MOUSE_MOVE, onMove);
			this.addEventListener(MouseEvent.MOUSE_UP, onUp);
			this.addEventListener(MouseEvent.ROLL_OUT, onUp);
			
			
			//set default color
			_color = 0x000000;
			
		}
		
		//this function loops through the shared object slots and draws on to the layers assigned to each slot
		//I decided to do drawing this way rather than on the change event because the change event exponentially increased drawing "frame rate" so if 2
		//people were drawing at 25FPS, the client was essentially drawing at 50Fps, add a 3rd person and you were up to 75Fps
		//Needless to say it was chugging massively with only 2 people.  This way the drawing FPS stays consistant no matter how many people are drawing.
		private function drawerRobot(e:TimerEvent):void
		{
			//num drawing keeps track of how many lots are drawing at any given time, if there are 0 slots drawing, the timmer which runs this robot is switched off
			var numDrawing:int = 0;
			for(var person:String in _sharedObject.data){
				//if a slot is drawing something
				if(_sharedObject.data[person].isDrawing == "1")
				{
					numDrawing++;
					
					//had to test if the array position existed within the drawingLAyersList to avoid errors occasionally.  When the application starts to
					//get a few people in it, the function which writes to the array when the shared object is changed can be slower than this.
					//so that milli second it loses sync caused an error, now you just losea pixel or 2 in the drawing that is barely noticable.
					if(_drawingLayerList[person])
					{
						//drawingLayerList holds a reference to a sprite in the canvas object
						_drawingLayerList[person].graphics.lineTo(parseFloat(_sharedObject.data[person].x),parseFloat(_sharedObject.data[person].y));
						
						
						
					}
				}//end if drawing
				
				//name tag control
				if(_sharedObject.data[person].isDrawing == "1")
				{
					var nameTag:nameTagBase;
					if(_drawingLayerList[person])
					{
						if(_drawingLayerList[person].numChildren == 0)
						{
							nameTag = _drawingLayerList[person].getChildAt(_drawingLayerList[person].numChildren);
						}else{
							nameTag = _drawingLayerList[person].getChildAt(_drawingLayerList[person].numChildren-1);
						}
					
						nameTag.x = _sharedObject.data[person].x;
						nameTag.y = _sharedObject.data[person].y;
					}
				}
				
			}
			
			//if the number of slots drawing is 0, than the timer(engine for this) is switched off
			if(numDrawing == 0)
			{
				trace("drawing robot is stopping");
				
				_robotTimer.stop();
				_drawingRobotStarted = false;
			}
		}//end drawer robot
		
		//-------------------------------------------------mouseEvents----------------------------------------//
		
		private function onDown(e:MouseEvent):void
		{
		
			_drawing = true;
			
			//_color = Math.random()*0xEEEEEE;

			var drawingLayer:Sprite;
			//create a new drawing layer each time drawing is started
			if(!_drawingLayerList["currentLayer"])
			{
				drawingLayer = new Sprite();
				//place the new drawing into the array to save reference
				_drawingLayerList["currentLayer"] = drawingLayer;
			}else{
				drawingLayer = _drawingLayerList["currentLayer"];
			}
			
			//add new drawing layer to this container
			this._canvas.addChild(drawingLayer);
			
			if(_marker == true)
			{
				drawingLayer.graphics.lineStyle(_stroke,_color);
				drawingLayer.graphics.moveTo(mouseX,mouseY);
			}
			if(_eraser == true)
			{
				drawingLayer.graphics.lineStyle(10,0xffffff);
				drawingLayer.graphics.moveTo(e.stageX,e.stageY);
			}
			
			
			//update the shared object with mouse values and set mouseDown to 1(true)
			var tempObject:Object = _sharedObject.data[_serverId];
			tempObject.mouseDown = "1";
			tempObject.x = mouseX.toString();
			tempObject.y = mouseY.toString();
			tempObject.color = _color.toString();
			
			_sharedObject.setProperty(_serverId,tempObject);
			_sharedObject.setDirty(_serverId);
			
		}
		private function onMove(e:MouseEvent):void
		{
			if(_drawing==true)
			{
				_drawingLayerList["currentLayer"].graphics.lineTo(mouseX,mouseY);

				
				//update the shared object with mouse values and set isDrawing to 1(true)
				var tempObject:Object = _sharedObject.data[_serverId];
				tempObject.x = mouseX.toString();
				tempObject.y = mouseY.toString();
				tempObject.isDrawing = "1";
				_sharedObject.setProperty(_serverId,tempObject);
				_sharedObject.setDirty(_serverId);
			}
		}
		private function onUp(e:MouseEvent):void
		{
			_drawing = false;

			
			var tempObject:Object = _sharedObject.data[_serverId];
				tempObject.mouseDown = "0";
				tempObject.isDrawing = "0";
				tempObject.eraseTag = "1";
				_sharedObject.setProperty(_serverId,tempObject);
				_sharedObject.setDirty(_serverId);
		}
		//----------------------------------------------------canvas getter--------------------------------------//
		
		//------------------------------------------------------shared drawing	--------------------		----//
		
		public function userDrawing(s:String):void
		{
			//test to make sure the id passed in isnt this clients id, we dont need to draw on this client for this clients drawing, we did that by hand
			if(s!=_serverId)
			{
				//when the sharedObject slot has a mousedown or 1(true) than go ahead and moveto the mouse coords provided and prepare for drawing
				if(_sharedObject.data[s].mouseDown == "1")
				{
					//create a new sprite which this sharedObject slot will draw into
					var tempSprite:Sprite
					
					//if the sprite for this slot alread exists, dont make a new but just draw into the exsiting sprite
					if(_drawingLayerList[s])
					{
						tempSprite = _drawingLayerList[s];
					}else{
						tempSprite = new Sprite();
					}
					
					//put the sprite into the drawingLayerList array at the key which equals the userId of the slot to save a reference to the sprite
					_drawingLayerList[s] = tempSprite;
					trace(s+" stroke:" + _sharedObject.data[s].stroke);
					//set colors and stroke of the new sprite we wil draw into
					trace("erasing: "+_sharedObject.data[s].isErasing);
					if(_sharedObject.data[s].isErasing == "1")
					{
						//poor mans eraser
						tempSprite.graphics.lineStyle(parseInt(_sharedObject.data[s].stroke),0xFFFFFF);
					}else{
						tempSprite.graphics.lineStyle(parseInt(_sharedObject.data[s].stroke),_sharedObject.data[s].color);
					}
					this._canvas.addChild(tempSprite);
					
					
					//add name tag to sprite
					var nameTag:nameTagBase = new nameTagBase();
					nameTag.tf_name.text = _sharedObject.data[s].username;
					nameTag.tf_name.autoSize = TextFieldAutoSize.LEFT;
					nameTag.x = -100;
					nameTag.y = -100;
					nameTag.mc_nameTagBg.width = nameTag.tf_name.width+5;
					tempSprite.addChild(nameTag);
					
					
					//move drawing pointer to the spot where the mouseDown occured
					tempSprite.graphics.moveTo(parseFloat(_sharedObject.data[s].x),parseFloat(_sharedObject.data[s].y));
					
					//set mouseDown to 0(false)so when the shared object gets changed again we just get drawing functionality
					var tempObject:Object = _sharedObject.data[s];
					tempObject.mouseDown = "0";
					_sharedObject.setProperty(s,tempObject);
					_sharedObject.setDirty(s);

						//so if the  slot isDrawing = 1(true) than start the drawing robot timer if the timer is not started already.
				}else if(_sharedObject.data[s].isDrawing == "1")
				{
					if(!_drawingRobotStarted)
					{
						trace("drawing robot is starting");
						_robotTimer.start();
						_drawingRobotStarted = true;
					}
				}else if(_drawingLayerList[s] && _sharedObject.data[s].eraseTag=="1"){
				
					if(_drawingLayerList[s].numChildren == 0)
					{
						//_drawingLayerList[s].removeChildAt(_drawingLayerList[s].numChildren);
					}else if(_drawingLayerList[s].numChildren > 0){
						_drawingLayerList[s].removeChildAt(_drawingLayerList[s].numChildren - 1);
					}
					
					var tempObject2:Object = _sharedObject.data[s];
					tempObject2.eraseTag = "0";
					_sharedObject.setProperty(s,tempObject2);
					_sharedObject.setDirty(s);
				}
			}
			
			//clear user layer
			if( _sharedObject.data[s].clearLayer == "1")
			{
			
				if(s!=_serverId)
				{
					_drawingLayerList[s].graphics.clear();
				}else{
					
					_drawingLayerList["currentLayer"].graphics.clear();
				}
				var tempObject3:Object = _sharedObject.data[s];
				tempObject3.clearLayer = "0";
				_sharedObject.setProperty(s,tempObject3);
				_sharedObject.setDirty(s);
			}
			
		}//end userDrawing
		
		
	}
}