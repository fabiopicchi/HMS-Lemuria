package interactables 
{
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.Spritemap;
	/**
	 * ...
	 * @author 
	 */
	public class Door extends Entity
	{
		public var animation : Spritemap = new Spritemap (Assets.TOUNCHING_DOOR, 96, 32);
		
		public function Door() 
		{
			this.type = "door";
			this.setHitbox(96, 32);
			animation.add("ON", [0]);
			animation.add("OFF", [1]);
			animation.play ("ON");
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