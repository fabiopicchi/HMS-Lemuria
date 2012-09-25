package interactables 
{
	import collision.CollidableEntity;
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.graphics.Spritemap;
	/**
	 * ...
	 * @author 
	 */
	public class BreakBlock extends CollidableEntity
	{
		public var animation : Spritemap = new Spritemap (Assets.BREAKABLE_BLOCK, 32, 32);
		
		public function BreakBlock() 
		{
			graphic = animation;
			animation.add("ON", [0]);
			animation.add("OFF", [1]);
			this.type = "breakBlock";
			setHitbox (32, 32);
		}
		
		public function setup (obj : Object) : void
		{
			this.x = obj.x;
			this.y = obj.y;
		}
		
		public function setBroken () : void
		{
			type = "";
			animation.play("OFF");
		}
		
	}

}