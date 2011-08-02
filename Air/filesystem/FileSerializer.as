package com.rensel.fileUtils
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	public class FileSerializer
	{
		public static function writeObjectToFile(object:Object, fname:String):void
		{
			var file:File = File.applicationStorageDirectory.resolvePath(fname);
			
			var fileStream:FileStream = new FileStream();
			fileStream.open(file, FileMode.WRITE);
			fileStream.writeObject(object);
			fileStream.close();
		}
		
		public static function readObjectFromFile(fname:String):Object
		{
			var file:File = File.applicationStorageDirectory.resolvePath(fname);
			
			if(file.exists) {
				var obj:Object;
				var fileStream:FileStream = new FileStream();
				fileStream.open(file, FileMode.READ);
				obj = fileStream.readObject();
				fileStream.close();
				return obj;
			}
			return null;
		}
	}
}