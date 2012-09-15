package robots 
{
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.graphics.Spritemap;
	
	/**
	 * ...
	 * @author ...
	 */
	public class Hook extends Entity 
	{
		private var hookSpeed : Number = 10;
		public var originalX : Number;
		public var originalY : Number;
		public var direction : int;
		private var way : int;
		private var vx : Number;
		private var vy : Number;
		private var collidedWall : Boolean = false;
		private var collidedBox : Boolean = false;
		public var hookshot : Hookshot;
		public var animation : Spritemap = new Spritemap (Assets.HOOK, 32, 32);
		
		public function Hook(hookshot : Hookshot) 
		{
			this.hookshot = hookshot;
			way = 1;
			graphic = animation;
			setHitbox(32, 32);
			animation.add("STAND_DOWN", [0]);
			animation.add("STAND_RIGHT", [1]);
			animation.add("STAND_UP", [2]);
			animation.add("STAND_LEFT", [3]);
		}
		
		public function shoot():Boolean
		{
			if (!collidedWall && !collidedBox)
			{
				if (this.collide("breakBlock", x, y) ||
					this.collide("pushBlock", x, y))
				{
					collidedBox = true;
				}
				else if (this.collide("walls", x, y) ||
					this.x <= FP.world.camera.x || this.x >= FP.world.camera.x + 640 ||
					this.y <= FP.world.camera.y || this.y >= FP.world.camera.y + 480)
				{
					collidedWall = true;
				}
				else
				{
					launch(this);
				}
			}
			else if (collidedWall)
			{
				if (retract())
				{
					return true;
				}
			}
			else if (collidedBox)
			{			
				if (latch())
				{
					return true;
				}
			}
			return false;
		}
		
		private function launch(e : Entity):void
		{
			if (direction == 0)
			{
				e.x += way * hookSpeed;
				vx = hookSpeed;
				vy = 0;
			}
			else if (direction == 1)
			{
				e.y += way * hookSpeed;
				vx = 0;
				vy = hookSpeed;
			}
			else if (direction == 2)
			{
				e.x -= way * hookSpeed;
				vx = - hookSpeed;
				vy = 0;
			}
			else
			{
				e.y -= way * hookSpeed;
				vx = 0;
				vy = - hookSpeed;
			}
			
			if (hookshot.direction == 3) animation.play("STAND_UP");
			else if (hookshot.direction == 0) animation.play("STAND_RIGHT");
			else if (hookshot.direction == 1) animation.play("STAND_DOWN");
			else if (hookshot.direction == 2) animation.play("STAND_LEFT");
		}
		
		public function retract():Boolean
		{
			way = -1;
			launch(this);
			if ((direction == 0 && x <= originalX) ||
				(direction == 1 && y <= originalY) ||
				(direction == 2 && x >= originalX) ||
				(direction == 3 && y >= originalY))
			{
				FP.world.remove(this);
				way = 1;
				collidedWall = false;
				return true;
			}
			return false;
		}
		
		public function latch():Boolean
		{
			hookshot.line();
			launch(hookshot);
			if (hookshot.collide("breakBlock", hookshot.x, hookshot.y) ||
				hookshot.collide("pushBlock", hookshot.x, hookshot.y) ||
				hookshot.x <= FP.world.camera.x || hookshot.x >= FP.world.camera.x + 640 ||
				hookshot.y <= FP.world.camera.y || hookshot.y >= FP.world.camera.y + 480)
			{
				if (vx > 0)
				{
					hookshot.x = Math.ceil(hookshot.x / 32) * 32 - hookshot.width;
				}
				else if (vx < 0)
				{
					hookshot.x = Math.ceil(hookshot.x / 32) * 32;
				}
				if (vy > 0)
				{
					hookshot.y = Math.ceil(hookshot.y / 32) * 32 - hookshot.height;
				}
				else if (vy < 0)
				{
					hookshot.y = Math.ceil(hookshot.y / 32) * 32;
				}
				FP.world.remove(this);
				hookshot.bArrived = true;
				collidedWall = false;
				collidedBox = false;
				return true;
			}
			return false;
		}
		
	}

}