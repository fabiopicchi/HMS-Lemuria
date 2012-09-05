package traps 
{
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.Spritemap;
	import net.flashpunk.FP;
	import net.flashpunk.graphics.Image;
	import Assets;
	
	/**
	 * ...
	 * @author Arthur Vieira
	 */
	public class Piston extends Entity 
	{
		
		public var sprPiston:Spritemap = new Spritemap(Assets.PISTON, 32, 32);
		public var period : Number = 3;
		public var on : Boolean = false;
		private var tempo : Number = 0;
		
		public function Piston() 
		{
			sprPiston.add("rise", [0, 1, 2], 3, false);
			sprPiston.add("fall", [2, 1, 0], 3, false);
			
			graphic = sprPiston;
		}
		
		override public function update():void 
		{
			tempo = tempo + FP.elapsed;
			if (tempo >= period)
			{
				if (on)
				{
					sprPiston.play("fall");
					on = false;
				}
				else
				{
					sprPiston.play("rise");
					on = true;
				}
				tempo -= period;
			}
			super.update();
		}
		
	}

}