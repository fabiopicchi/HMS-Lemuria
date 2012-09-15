package  
{
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.utils.Input;
	import net.flashpunk.utils.Key;
	
	/**
	 * ...
	 * @author ...
	 */
	public class MenuCursor extends Entity
	{
		
		private var cursorImage : Image;
		public var play : Boolean = true;
		
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
			super.update();
		}
		
		public function select():Boolean
		{
			if (Input.pressed("SELECTION"))
			{
				return true;
			}
			else
			{
				return false;
			}
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