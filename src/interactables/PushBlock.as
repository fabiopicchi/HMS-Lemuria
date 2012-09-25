package interactables 
{
	import collision.CollidableEntity;
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.graphics.Image;
	/**
	 * ...
	 * @author 
	 */
	public class PushBlock extends CollidableEntity
	{
		public var bMoving : Boolean = false;
		
		private var targetX : Number = 0;
		private var targetY : Number = 0;
		public var timerPushX : Number = 0;
		public var timerPushY : Number = 0;
		
		public function PushBlock() 
		{
			this.addGraphic(new Image (Assets.MOVABLE_BLOCK));
			setHitbox (32, 32);
			this.type = "pushBlock";
		}
		
		public function setup (obj : Object) : void
		{
			this.x = obj.x;
			this.y = obj.y;
		}
		
		public function move (dir : int, way : int) : void
		{
			var blockX : Number = this.x;
			var blockY : Number = this.y;
			
			if (dir == 0)
			{
				if (!collide("walls", x + way * 32, y) && !collide("breakBlock", x + way * 32, y) && !collide("pushBlock", x + way * 32, y))
				{
					ax = -way * 0.01;
					vx = way * Math.sqrt (2 * Math.abs(ax) * 32);
					targetX = blockX + way * 32;
				}
				else
				{
					bMoving = false;
				}
			}
			else
			{
				if (!collide("walls", x, y + way * 32) && !collide("breakBlock", x, y + way * 32) && !collide("pushBlock", x, y + way * 32))
				{
					ay = -way * 0.01;
					vy = way * Math.sqrt (2 * Math.abs(ay) * 32);
					targetY = blockY + way * 32;
				}
				else
				{
					bMoving = false;
				}
			}
		}
		
		override public function added():void 
		{
			super.added();
		}
		
		override public function update():void 
		{
			super.update();
			if (bMoving)
			{
				x += vx;
				y += vy;
				
				if (Math.abs (vx) - Math.abs (ax) < 0)
				{
					vx = 0;
					ax = 0;
					bMoving = false;
					x = targetX;
				}
				vx += ax;
				if (Math.abs (vy) - Math.abs (ay) < 0)
				{
					vy = 0;
					ay = 0;
					bMoving = false;
					y = targetY;
				}
				vy += ay;
			}
		}
		
		override public function render():void 
		{
			super.render();
		}
		
	}

}