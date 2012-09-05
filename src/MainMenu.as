package  
{
	
	import net.flashpunk.graphics.Image;
	import net.flashpunk.Sfx;
	import net.flashpunk.World;
	
	/**
	 * ...
	 * @author ...
	 */
	public class MainMenu extends World 
	{
		private var title : Image = new Image(Assets.TITLE);
		private var cursor : MenuCursor;
		private var menuSong : Sfx;
		
		public function MainMenu() 
		{
			addGraphic(title);
			cursor = new MenuCursor();
			add(cursor);
			menuSong = new Sfx(Assets.MENU_SONG);
			menuSong.loop();
		}
		
		override public function update():void 
		{
			super.update();
		}
		
	}

}