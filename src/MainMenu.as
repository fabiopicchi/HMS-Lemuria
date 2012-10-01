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
				Game.screenTransition (2, 0x000000, function () : void
				{
					FP.world = new GameArea (Assets.stage1, Assets.map1, Assets.water1, Assets.walls1, 
										 Assets.MAIN_SONG, [Hammer, Hookshot, Shield], true);
				}, null, true);
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