package Animated_Scenery 
{
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.Spritemap;
	/**
	 * ...
	 * @author 
	 */
	public class Leak extends Entity
	{
		private var animation : Spritemap = new Spritemap (Assets.LEAK, 32, 32);
		public function Leak() 
		{
			graphic = animation;
			animation.add("RIGHT", [0, 1], 10);
			animation.add("LEFT", [2, 3], 10);
		}
		
		public function setup (obj : Object) : void
		{
			this.x = obj.x;
			this.y = obj.y;
			
			if (obj.direction == 1)
			{
				graphic.x += 20;
				animation.play ("RIGHT");
			}
			else
			{
				graphic.x -= 20;
				animation.play ("LEFT");
			}
		}
	}

}