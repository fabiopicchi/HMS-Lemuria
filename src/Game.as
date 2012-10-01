package 
{
	import com.greensock.easing.Linear;
	import com.greensock.TweenLite;
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
			Input.define ("ACTION", Key.Z, Key.S, Key.G);
			Input.define ("SWAP", Key.X, Key.A, Key.F);
			Input.define ("UP", Key.UP, Key.Q);
			Input.define ("DOWN", Key.DOWN, Key.W);
			Input.define ("LEFT", Key.LEFT, Key.E);
			Input.define ("RIGHT", Key.RIGHT, Key.R);
			Input.define ("SELECTION", Key.ENTER, Key.Z, Key.S, Key.G);
			Input.define ("PAUSE", Key.ESCAPE, Key.DIGIT_1, Key.NUMPAD_1);
		}
		
		override public function init():void 
		{
			// entry point
			FP.screen.scale = 2;
			FP.world = new MainMenu();
		}
		
		private static var bTransition : Boolean = false;
		private static var whiteScreen : Sprite;
		public static function screenTransition (time : Number, color : uint = 0xffffff, callbackFoward : Function = null, callbackBackward : Function = null, bForce : Boolean = false) : void
		{
			if (whiteScreen == null)
			{
				whiteScreen = new Sprite();
				whiteScreen.alpha = 0;
			}
			if (!bTransition || bForce)
			{
				if (bForce)
				{
					TweenLite.killTweensOf(whiteScreen);
				}
				whiteScreen.graphics.clear();
				whiteScreen.graphics.beginFill(color);
				whiteScreen.graphics.drawRect(0, 0, FP.engine.width, FP.engine.height);
				FP.engine.stage.addChild(whiteScreen);
				TweenLite.to (whiteScreen, (time / 2) * (1 - whiteScreen.alpha), { alpha : 1, ease : Linear.easeInOut, onComplete : function () : void {
					if (callbackFoward != null) callbackFoward();
					TweenLite.to (whiteScreen, time / 2, { alpha : 0, ease : Linear.easeInOut, onComplete : function () :void {
						if (callbackBackward != null) callbackBackward();
						FP.engine.stage.removeChild(whiteScreen);
						bTransition = false;
					}});
				}});
			}
			bTransition = true;
		}
	}
	
}