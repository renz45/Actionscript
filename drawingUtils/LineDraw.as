package com.rensel.drawingUtils
{
	import flash.display.Sprite;
	import flash.geom.Point;
	
	public class LineDraw
	{
		public function LineDraw()
		{
			
			
			
		}
		
		public static function DrawLine(points:Array,container:Sprite,color:uint,strokeSize:Number):void
		{
			container.graphics.lineStyle(strokeSize,color);
			container.graphics.moveTo(Point(points[0]).x,Point(points[0]).y);
			
			points.shift()
			
			for each(var p:Point in points)
			{
				container.graphics.lineTo(p.x,p.y);
			}
		}

	}
}