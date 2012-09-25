package interactables 
{
	import collision.CollidableEntity;
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.Image;
	/**
	 * ...
	 * @author 
	 */
	public class TouchingDoor extends CollidableEntity
	{
		
		public function TouchingDoor() 
		{
			this.addGraphic(new Image (Assets.TOUNCHING_DOOR));
			setHitbox (64, 32);
			this.type = "touchingDoor";
		}
		
		public function setup (obj : Object) : void
		{
			this.x = obj.x;
			this.y = obj.y;
		}
	}

}