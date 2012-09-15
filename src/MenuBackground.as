package  
{
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.Image;
	
	/**
	 * ...
	 * @author ...
	 */
	public class MenuBackground extends Entity 
	{
		private var background : Image;
		private var title : Image = new Image(Assets.TITLE);
		private var credits : Image = new Image(Assets.CREDITS);
		
		public function MenuBackground() 
		{
			graphic = title;
		}
		
		public function setTitle():void
		{
			graphic = title;
		}
		
		public function setCredits():void
		{
			graphic = credits;
		}
		
	}

}