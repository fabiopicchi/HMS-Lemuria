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
	public class Gear extends Entity 
	{
		
		public var animation:Spritemap = new Spritemap(Assets.GEAR, 32, 32);
		public var period : Number;
		public var direction : int;
		public var way : int;
		private var _trackLength : Number;
		
		public function Gear() 
		{
			animation.add("spin", [0, 1, 2, 3]);
			this.type = "gear";
			graphic = animation;
		}
		
		public function setup (obj : Object) : void
		{
			this.x = obj.x;
			this.y = obj.y;
			_trackLength = obj.size * 32;
			this.period = obj.period;
			this.direction = obj.direction;
		}
		
		override public function update():void 
		{
			var vx : Number;
			var vy : Number;
			var absSpeed : Number = _trackLength / (period / 2);
			
			if (direction == 0)
			{
				vx = 0;
				vy = - absSpeed;
				if (y <= 0)
				{
					way = -1;
				}
				else if (y >= _trackLength)
				{
					way = 1;
				}
			}
			else if (direction == 1)
			{
				vx  = absSpeed;
				vy = 0;
				if (x >= _trackLength)
				{
					way = -1;
				}
				else if (x <= 0)
				{
					way = 1;
				}
			}
			else if (direction == 2)
			{
				vx = 0;
				vy = absSpeed;
				if (y >= _trackLength)
				{
					way = -1;
				}
				else if (y <= 0)
				{
					way = 1;
				}
			}
			else
			{
				vx = - absSpeed;
				vy = 0;
				if (x <= 0)
				{
					way = -1;
				}
				else if (x >= _trackLength)
				{
					way = 1;
				}
			}
			
			if ((x + vx * way) > _trackLength)
			{
				x = _trackLength;
			}
			else if ((x + vx * way) < 0)
			{
				x = 0;
			}
			else
			{
				x += vx * way;
			}
			
			if ((y + vy * way) > _trackLength)
			{
				y = _trackLength;
			}
			else if ((y + vy * way) < 0)
			{
				y = 0;
			}
			else
			{
				y += vy * way;
			}
		}
		
		override public function render():void 
		{
			animation.play("spin");
		}
		
	}

}