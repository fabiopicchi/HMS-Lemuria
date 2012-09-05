package  
{
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.utils.Input;
	import net.flashpunk.utils.Key;
	import robots.Hammer;
	import robots.Hookshot;
	import robots.Shield;
	
	/**
	 * ...
	 * @author ...
	 */
	public class MenuCursor extends Entity 
	{
		
		private var cursorImage : Image;
		private var play : Boolean = true;
		
		public function MenuCursor() 
		{
			cursorImage = new Image(Assets.SELECTION);
			addGraphic(cursorImage);
		}
		
		override public function update():void 
		{
			if (Input.pressed("UP") || Input.pressed("DOWN"))
			{
				play = !play;
			}
			if (Input.pressed("SELECTION"))
			{
				if (play)
				{
					FP.world = new GameArea (Assets.stage1, Assets.map1, Assets.water1, Assets.walls1, Assets.MAIN_SONG, [Hammer, Hookshot, Shield]);
				}
				else
				{
					//Credits
				}
			}
			super.update();
		}
		
		override public function render():void 
		{
			if (play)
			{
				this.x = 55;
				this.y = 240;
			}
			else
			{
				this.x = 55;
				this.y = 300;
			}
			super.render();
		}
	}

}