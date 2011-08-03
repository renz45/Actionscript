package com.rensel.filesystem
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	public class FileSerializer
	{
		/**
		 * write an object to the application storage directory, the object is serialized along the way 
		 * @param object object to be serialized and saved
		 * @param fname filename of the stored file
		 * 
		 */		
		public static function writeObjectToFile(object:Object, fname:String):void
		{
			var file:File = File.applicationStorageDirectory.resolvePath(fname);
			
			var fileStream:FileStream = new FileStream();
			fileStream.open(file, FileMode.WRITE);
			fileStream.writeObject(object);
			fileStream.close();
		}
		
		/**
		 * read the store file, deserialize and return the reconstructed object 
		 * @param fname filename to load from application storage
		 * @return 
		 * 
		 */		
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