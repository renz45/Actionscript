/*
DO WHAT THE FUCK YOU WANT TO + BEER/PIZZA PUBLIC LICENSE
Version 1, May 2011

Copyright (C) 2011 Adam Rensel


DO WHAT THE FUCK YOU WANT TO + BEER/PIZZA PUBLIC LICENSE
TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION

0. You just DO WHAT THE FUCK YOU WANT TO.
1. If you make a substantial amount of money by exercising clause 0,
   you should consider buying the author a beer or a pizza.
*/
package com.rensel.fileUtils
{
	import com.rensel.fileUtils.Events.DirectoryMonitor_Event;
	
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.filesystem.File;
	import flash.utils.Timer;
	
	
	[Event(type="com.rensel.fileUtils.Events.DirectoryMonitor_Event",name="directoryChange")]
	/**
	 * Directory monitor class, monitors a directory for changes and dispatches an event with the file object representing the directory 
	 * @author adamrensel - www.adamrensel.com
	 * 
	 */	
	public class DirectoryMonitor extends EventDispatcher
	{
		private var _fileList:Vector.<File> = new Vector.<File>;
		private var _fileContentList:Vector.<Vector.<File>> =  new Vector.<Vector.<File>>;
		private var _fileCompareList:Vector.<int> = new Vector.<int>;
		
		private var _duration:int;
		private var _timer:Timer;
		
		public function DirectoryMonitor(duration:int = 1000)
		{
			_duration = duration;
			init();
		}
		
		private function init():void
		{
			//create timer add event listeners
			createTimer();
		}
		
		private function createTimer():void
		{
			var isRunning:Boolean = false;
			if(_timer)
			{
				_timer.stop();
				isRunning = true;
				
				_timer.removeEventListener(TimerEvent.TIMER, onTimer);
				_timer = null;
			}
			
			
			_timer = new Timer(_duration);
			_timer.addEventListener(TimerEvent.TIMER, onTimer);
			
			if(isRunning)
			{
				_timer.start();
			}
		}
		
		//when the timer starts, compare date modified times to cached values and dispatch a custom event with the File if a difference is detected
		private function onTimer(e:TimerEvent):void
		{
			var newTotalTime:int;
			
			//if the list of directories has something in it
			if(_fileList.length > 0)
			{
				//loop through the list of directories
				for(var i:int = 0; i < _fileList.length; i++)
				{
					// find a new total time based on the last of cached directories
					newTotalTime = getTotalModTime(_fileContentList[i]);
					
					//if there isnt anything in the compare list, give it a default value
					if(_fileCompareList.length-1 < i)
					{
						_fileCompareList[i] = newTotalTime;
					}
					
					//if the cached comparelist time isnt equal to the new time
					if(_fileCompareList[i] != newTotalTime)
					{
						//dispatch a custom event with File that contains the change
						var evt:DirectoryMonitor_Event = new DirectoryMonitor_Event(DirectoryMonitor_Event.DIRECTORY_CHANGE);
						evt.file = _fileList[i];
						this.dispatchEvent(evt);
						
						//give the compareList the new time, cache the new value
						_fileCompareList[i] = newTotalTime;
						//rebuild the stored list of directories in case a new folder was added someplace
						//this can be cpu intensive if the directory is large, but it only runs when a change is detected
						_fileContentList[i] = traverseDirectoryTree(_fileList[i]);
					}
				}
			}
		}
		
		//loop through all folders and make a list of all directories, store those directories in dirList and return it.
		//recursive function that can be cpu intensive, but it only runs when a change is detected to update cached values
		private function traverseDirectoryTree(dir:File):Vector.<File>
		{
			var dirList:Vector.<File> = new Vector.<File>;
			dirList.push(dir);
			for each (var file:File in dir.getDirectoryListing())
			{
				if(!file.isHidden && file.isDirectory)
				{
					dirList.push(file);
					dirList = dirList.concat(traverseDirectoryTree(file));
				}
			}
			
			return dirList;
		}
		
		//add the date modified times up of the list of directories, return the total
		private function getTotalModTime(dirList:Vector.<File>):int
		{
			var total:int = 0;
			
			for each(var file:File in dirList)
			{
				if(file.exists)
				{
					total += file.modificationDate.time;
				}
			}
			
			return total;
		}		
		
		/**
		 * add a directory to the directory monitor class, mutiple directories can be watched by calling this method multiple times
		 * @param directory directory to add
		 * 
		 */		
		public function addDirectory(directory:File):void
		{
			if(directory.isDirectory)
			{
				var vectorList:Vector.<File> = traverseDirectoryTree(directory);
				
				_fileList.push(directory);
				_fileContentList.push(vectorList);
				_fileCompareList.push(getTotalModTime(vectorList));
			}else{
				throw Error('File passed in must be a directory');
			}
		}
		
		/**
		 * removes a directory from the monitor 
		 * @param directory directory to remove
		 * 
		 */		
		public function removeDirectory(directory:File):void
		{
			var index:int = -1;
			
			for(var i:int = 0; i < _fileList.length; i++)
			{
				if(_fileList[i].nativePath == directory.nativePath)
				{
					index = i
				}
			}
			
			if(index != -1)
			{
				_fileList.splice(index,1);
				_fileContentList.splice(index,1);
				_fileCompareList.splice(index,1);
			}
		}
		
		/**
		 * starts the directory monitor watching the directories for changes 
		 * 
		 */		
		public function watch():void
		{
			_timer.start();
		}
		
		/**
		 * stops the directory monitor from watching for changes 
		 * 
		 */		
		public function unWatch():void
		{
			_timer.stop();
		}
		
		public function get duration():int
		{
			return _duration;
		}
		
		public function set duration(duration:int):void
		{
			_duration = duration;
			createTimer();
		}
	}
}