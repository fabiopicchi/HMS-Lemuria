package interactables 
{
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.graphics.Spritemap;
	
	/**
	 * ...
	 * @author ...
	 */
	public class Lever extends Entity 
	{
		
		public var pulled : Boolean = false;
		public var animation : Spritemap = new Spritemap (Assets.LEVER, 32, 32);
		
		public function Lever() 
		{
			graphic = animation;
			animation.add("ON", [0]);
			animation.add("OFF", [1]);
			type = "lever";
			animation.play ("ON");
			setHitbox(32, 32);
		}
		
		public function setup (obj : Object) : void
		{
			this.x = obj.x;
			this.y = obj.y;
		}
		
		public function pull():void
		{
			animation.play ("OFF");
			pulled = true;
		}
	}

}