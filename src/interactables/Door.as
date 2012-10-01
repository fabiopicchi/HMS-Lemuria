package interactables 
{
	import collision.CollidableEntity;
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.Spritemap;
	/**
	 * ...
	 * @author 
	 */
	public class Door extends CollidableEntity
	{
		public var animation : Spritemap = new Spritemap (Assets.DOOR, 128, 32);
		
		public function Door() 
		{
			this.type = "door";
			this.setHitbox(128, 32);
			animation.add("ON", [0]);
			animation.add("OFF", [1]);
			animation.play ("ON");
			this.graphic = animation;
			this.name = "finalDoor";
		}
		
		public function setup (obj : Object) : void
		{
			this.x = obj.x;
			this.y = obj.y;
		}
		
		public function open():void
		{
			this.type = "";
			animation.play ("OFF");
		}
	}

}