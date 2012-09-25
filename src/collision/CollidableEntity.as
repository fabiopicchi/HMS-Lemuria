package collision
{
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
		
		public function collideAABB (c : CollidableEntity) : CollisionResult
		{
			//Polygon vertices
			var arVerticesMe : Array = getAABBVertices();
			var arVerticesC : Array = c.getAABBVertices();
			//Polygon sides
			var arSidesMe : Array = getAABBSides();
			var arSidesC : Array = c.getAABBSides();
			
			//Result of the collision
			var result : CollisionResult = new CollisionResult ();
			
			//AABB specific case
			var nSidesMe : int = 4;
			var nSidesC : int = 4;
			
			//Varibles used in the collision algorithm
			var intervalIntersection : Number;
			var minIntervalIntersection : Number = Infinity;
			
			var translationAxis : Vec2;
			var side : Vec2;
			var axis : Vec2;
			var d : Vec2;
			var velocity : Vec2 = new Vec2 (vx, vy);
			
			var sideIndex : int = 0;
			
			var projectionMe : Interval;
			var projectionC : Interval;
			var projectionVelocity : Number;
			
			for (sideIndex = 0; sideIndex < nSidesMe + nSidesC; sideIndex++)
			{
				if (sideIndex < nSidesMe)
				{
					side = arSidesMe[sideIndex];
				}
				else
				{
					side = arSidesC[sideIndex - nSidesMe];
				}
				
				axis = new Vec2 ( -side.y, side.x);
				axis.normalize();
				
				projectionMe = projectPolygonOverAxis(axis, arVerticesMe, arSidesMe);
				projectionC = c.projectPolygonOverAxis(axis, arVerticesC, arSidesC);
				
				if (Interval.intervalIntersection(projectionMe, projectionC) >= 0)
				{
					result.collided = false;
				}
				
				projectionVelocity = axis.dot(velocity);
				
				if (projectionVelocity < 0)
				{
					projectionMe.beggining += projectionVelocity;
				}
				else
				{
					projectionMe.end += projectionVelocity;
				}
				
				intervalIntersection = Interval.intervalIntersection(projectionMe, projectionC);
				
				if (intervalIntersection >= 0)
				{
					result.willCollide = false;
				}
				
				if (!result.collided && !result.willCollide)
				{
					break;
				}
				
				intervalIntersection = Math.abs (intervalIntersection);
				
				if (intervalIntersection < minIntervalIntersection)
				{
					minIntervalIntersection = intervalIntersection;
					translationAxis = axis;
					
					d = new Vec2 ((c.x + c.width / 2) - (x + width / 2), (c.y + c.height / 2) - (y + height / 2));
					
					if (d.dot(translationAxis) < 0)
					{
						translationAxis.x = - translationAxis.x;
						translationAxis.y = - translationAxis.y;
					}
				}
			}
			
			if (result.willCollide)
			{
				result.minTranslationVector = new Vec2 (translationAxis.x * minIntervalIntersection, translationAxis.y * minIntervalIntersection);
				//apply collision result
				this.vx -= result.minTranslationVector.x;
				this.vy -= result.minTranslationVector.y;
			}
			
			return result;
		}
		
		public function getAABBVertices () : Array
		{
			return [
				new Vec2 (x, y),
				new Vec2 (x + width, y),
				new Vec2 (x + width, y + height),
				new Vec2 (x, y + height)
			];
		}
		
		public function getAABBSides () : Array
		{
			return [
				new Vec2 (width, 0),
				new Vec2 (0, height),
				new Vec2 (-width, 0),
				new Vec2 (0, -height)
			];
		}
		
		internal function projectPolygonOverAxis (axis:Vec2, arVertices : Array, arSides : Array) : Interval
		{
			var projection : Number;
			
			projection = axis.dot (arVertices[0]);
			
			var interval : Interval = new Interval (projection, projection);
			var length : Number = arVertices.length;
			
			for (var i : int = 1; i < length; i++)
			{
				projection = arVertices[i].dot(axis);
				
				if (projection < interval.beggining)
				{
					interval.beggining = projection;
				}
				else if (projection > interval.end)
				{
					interval.end = projection;
				}
			}
			
			return interval;
		}
	}

}