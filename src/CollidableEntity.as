package  
{
	import flash.geom.Point;
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	
	/**
	 * ...
	 * @author 
	 */
	public class CollidableEntity extends Entity 
	{
		public var vx : Number = 0;
		public var vy : Number = 0;
		
		public var ax : Number = 0;
		public var ay : Number = 0;
		
		public function CollidableEntity() 
		{
			
		}
		
		public function collideAABB (c1 : CollidableEntity, c2 : CollidableEntity) : Point
		{
			//Axis
			var xSegment : Point = new Point (c1.x, c2.x);
			var ySegment : Point = new Point (c1.y, c2.y);
			
			var xWay : Number = (xSegment.y - xSegment.x) < 0 ? -1 : 1;
			var yWay : Number = (ySegment.y - ySegment.x) < 0 ? -1 : 1;
			
			//Projections
			var c1ProjX : Point = new Point (c1.x, c1.x + xWay * c1.halfWidth + c1.vx);
			var c2ProjX : Point = new Point (c2.x, c2.x - xWay * c2.halfWidth + c2.vx);
			var c1ProjY : Point = new Point (c1.y, c1.y + yWay * c1.halfHeight + c1.vy);
			var c2ProjY : Point = new Point (c2.y, c2.y - yWay * c2.halfHeight + c2.vy);
			
			if (c1ProjX.x < c1ProjX.y) swap (c1ProjX);
			if (c1ProjX.x < c1ProjX.y) swap (c1ProjX);
			if (c1ProjX.x < c1ProjX.y) swap (c1ProjX);
			if (c1ProjX.x < c1ProjX.y) swap (c1ProjX);
			
			//If their projections dont overlap on the X Axis
			if (!((xSegment.y - xSegment.x) < 0 && c1ProjX.y < c2ProjX.y))
			{
				return null;
			}
			else if (!(c1ProjY.x < c2ProjY.y && c1ProjY.y > c2ProjY.x))
			{
				return null;
			}
			else
			{
				return new Point (c1ProjX.x - c2ProjX.x, c1ProjY.y - c2ProjY.y);
			}
			
		}
		
		private function swap (p : Point) : void
		{
			var temp : Number = p.x;
			p.x = p.y;
			p.y = temp;
		}
		
		//private function intersectInterval (p1 : Point, p2 : Point) : Number
		//{
			//
			//retunr 
			//
		//}
		
	}

}