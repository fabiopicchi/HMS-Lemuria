package collision 
{
	/**
	 * ...
	 * @author 
	 */
	public class CollisionResult 
	{
		public var willCollide : Boolean;
		public var collided : Boolean;
		public var minTranslationVector : Vec2;
		
		public function CollisionResult() 
		{
			willCollide = true;
			collided = true;
		}
		
	}

}