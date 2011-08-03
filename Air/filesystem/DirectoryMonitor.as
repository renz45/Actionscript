
/*
Copyright (C) 2011 Adam Rensel

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA. 
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
		
		private var _duration:int = 1000;
		private var _timer:Timer;
		
		public function DirectoryMonitor(duration:int)
		{
			init();
		}
		
		private function init():void
		{
			_timer = new Timer(_duration);
			_timer.addEventListener(TimerEvent.TIMER, onTimer);
			
		}
		
		private function onTimer(e:TimerEvent):void
		{
			var newTotalTime:int;
			
			if(_fileList.length > 0)
			{
				for(var i:int = 0; i < _fileList.length; i++)
				{
					trace("asd");
					newTotalTime = getTotalModTime(_fileContentList[i]);
					
					if(_fileCompareList.length-1 < i)
					{
						_fileCompareList[i] = newTotalTime;
					}
					
					if(_fileCompareList[i] != newTotalTime)
					{
						var evt:DirectoryMonitor_Event = new DirectoryMonitor_Event(DirectoryMonitor_Event.DIRECTORY_CHANGE);
						evt.file = _fileList[i];
						this.dispatchEvent(evt);
						
						_fileCompareList[i] = newTotalTime;
						_fileContentList[i] = traverseDirectoryTree(_fileList[i]);
					}
				}
			}
		}
		
		private function traverseDirectoryTree(dir:File):Vector.<File>
		{
			var dirList:Vector.<File> = new Vector.<File>;
			
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
	}
}