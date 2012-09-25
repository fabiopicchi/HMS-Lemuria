package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import net.flashpunk.Engine;
	import net.flashpunk.FP;
	import net.flashpunk.utils.Input;
	import net.flashpunk.utils.Key;
	import robots.Hammer;
	import robots.Hookshot;
	import robots.Shield;
	
	/**
	 * ...
	 * @author 
	 */
	public class Game extends Engine 
	{
		
		public function Game():void 
		{
			super (640, 480);
			Input.define ("ACTION", Key.Z);
			Input.define ("SWAP", Key.X);
			Input.define ("UP", Key.UP);
			Input.define ("DOWN", Key.DOWN);
			Input.define ("LEFT", Key.LEFT);
			Input.define ("RIGHT", Key.RIGHT);
			Input.define ("SELECTION", Key.ENTER, Key.Z);
		}
		
		override public function init():void 
		{
			// entry point
			//FP.screen.scale = 1;
			FP.world = new MainMenu();
		}
		
	}
	
}