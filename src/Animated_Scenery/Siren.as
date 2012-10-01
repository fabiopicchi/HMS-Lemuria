package Animated_Scenery
{
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.Spritemap;
	/**
	 * ...
	 * @author 
	 */
	public class Siren extends Entity
	{
		private var animation : Spritemap = new Spritemap (Assets.SIREN, 32, 32);
		public function Siren() 
		{
			graphic = animation;
			animation.add("LEFT", [0, 1, 2, 3], 10);
			animation.add("RIGHT", [4, 5, 6, 7], 10);
		}
		
		public function setup (obj : Object) : void
		{
			this.x = obj.x;
			this.y = obj.y;
			
			if (obj.direction == 1)
			{
				animation.play ("RIGHT");
			}
			else
			{
				animation.play ("LEFT");
			}
		}
	}

}