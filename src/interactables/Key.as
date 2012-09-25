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
	public class Key extends CollidableEntity 
	{
		
		public function Key() 
		{
			graphic = new Spritemap (Assets.KEY, 32, 32);
			this.type = "key";
		}
		
		public function setup (obj : Object) : void
		{
			this.x = obj.x;
			this.y = obj.y;
		}
	}

}