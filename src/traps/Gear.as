package traps 
{
	import collision.CollidableEntity;
	import net.flashpunk.Entity;
	import net.flashpunk.graphics.Spritemap;
	import net.flashpunk.FP;
	import net.flashpunk.graphics.Image;
	import Assets;
	
	/**
	 * ...
	 * @author Arthur Vieira
	 */
	public class Gear extends CollidableEntity 
	{
		
		public var animation : Spritemap = new Spritemap(Assets.GEAR, 32, 32);
		public var period : Number;
		public var direction : int;
		public var way : int;
		public var _trackLength : Number;
		private var x0 : Number;
		private var y0 : Number;
		
		public function Gear() 
		{
			animation.add("spin", [0, 1, 2, 3], 10, true);
			this.type = "gear";
			addGraphic(animation);
		}
		
		public function setup (obj : Object) : void
		{
			this.x = obj.x;
			this.y = obj.y;
			x0 = x;
			y0 = y;
			way = 1;
			_trackLength = (obj.size - 1) * 32;
			this.period = obj.period;
			this.direction = obj.direction;
		}
		
		override public function update():void 
		{
			var absSpeed : Number = _trackLength / (period / 2);
			
			if (direction == 0)
			{
				if ((y - absSpeed * way * FP.elapsed) < y0 - _trackLength)
				{
					y = y0 - _trackLength;
					way *= -1;
				}
				else if ((y - absSpeed * way * FP.elapsed) > y0)
				{
					y = y0;
					way *= -1;
				}
				else
				{
					y -= absSpeed * way * FP.elapsed;
				}
			}
			else if (direction == 1)
			{
				if ((x + absSpeed * way * FP.elapsed) > x0 + _trackLength)
				{
					x = x0 + _trackLength;
					way *= -1;
				}
				else if ((x + absSpeed * way * FP.elapsed) < x0)
				{
					x = x0;
					way *= -1;
				}
				else
				{
					x += absSpeed * way * FP.elapsed;
				}
			}
			else if (direction == 2)
			{
				if ((y + absSpeed * way * FP.elapsed) > y0 + _trackLength)
				{
					y = y0 + _trackLength;
					way *= -1;
				}
				else if ((y + absSpeed * way * FP.elapsed) < y0)
				{
					y = y0;
					way *= -1;
				}
				else
				{
					y += absSpeed * way * FP.elapsed;
				}
			}
			else if (direction == 3)
			{
				if ((x - absSpeed * way * FP.elapsed) < x0 - _trackLength)
				{
					x = x0 - _trackLength;
					way *= -1;
				}
				else if ((x - absSpeed * way * FP.elapsed) > x0)
				{
					x = x0;
					way *= -1;
				}
				else
				{
					x -= absSpeed * way * FP.elapsed;
				}
			}
			
			animation.play("spin");
			
		}
		
		override public function render():void 
		{
			super.render();
		}
		
	}

}