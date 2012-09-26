package  
{
	
	import net.flashpunk.FP;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.Sfx;
	import net.flashpunk.World;
	import robots.Hammer;
	import robots.Hookshot;
	import robots.Shield;
	
	/**
	 * ...
	 * @author ...
	 */
	public class MainMenu extends World
	{
		private var background : MenuBackground;
		private var cursor : MenuCursor;
		private var menuSong : Sfx;
		private var creditsScreen : Boolean = false;
		
		public function MainMenu() 
		{
			background = new MenuBackground();
			add(background);
			cursor = new MenuCursor();
			add(cursor);
			menuSong = new Sfx(Assets.MENU_SONG);
			menuSong.loop();
		}
		
		override public function update():void 
		{
			super.update();
			if (!creditsScreen && cursor.play && cursor.select())
			{
				menuSong.stop();
				FP.world = new GameArea (Assets.stage2, Assets.map2, Assets.water2, Assets.walls2, 
										 Assets.MAIN_SONG, [Hookshot, Shield]);
			}
			else if (!creditsScreen && !cursor.play && cursor.select())
			{
				background.setCredits();
				creditsScreen = true;
				remove(cursor);
			}
			else if (creditsScreen && cursor.select())
			{
				background.setTitle();
				creditsScreen = false;
				add(cursor);
			}
		}
		
	}

}