package interactables 
{
	import collision.CollidableEntity;
	/**
	 * ...
	 * @author 
	 */
	public class EndingTrigger extends CollidableEntity
	{
		
		public function EndingTrigger() 
		{
			this.type = "endingTrigger";
		}
		
		public function setup (obj : Object) : void
		{
			setHitbox (obj.width, obj.height);
			this.x = obj.x;
			this.y = obj.y;
		}
	}

}