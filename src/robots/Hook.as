package robots 
{
	import collision.CollidableEntity;
	import collision.CollisionResult;
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.graphics.Spritemap;
	
	/**
	 * ...
	 * @author ...
	 */
	public class Hook extends CollidableEntity 
	{
		private var hookSpeed : Number = 10;
		public var originalX : Number;
		public var originalY : Number;
		public var direction : int;
		private var way : int;
		private var collidedWall : Boolean = false;
		private var collidedBox : Boolean = false;
		public var hookshot : Hookshot;
		public var animation : Spritemap = new Spritemap (Assets.HOOK, 32, 32);
		private static const arCollideable : Array = ["pushBlock", "breakBlock", "touchingDoor", "door"];
		
		
		public function Hook(hookshot : Hookshot) 
		{
			this.hookshot = hookshot;
			way = 1;
			graphic = animation;
			setHitbox(26, 26);
			graphic.x = -3;
			graphic.y = -3;
			animation.add("STAND_DOWN", [0]);
			animation.add("STAND_RIGHT", [1]);
			animation.add("STAND_UP", [2]);
			animation.add("STAND_LEFT", [3]);
		}
		
		public function shoot():Boolean
		{
			if (!collidedWall && !collidedBox)
			{
				var arEntities : Array = [];
				var result : CollisionResult;
				var entity : CollidableEntity;
				
				//add Entities to collision array
				for each (var type : String in arCollideable)
				{
					FP.world.getType(type, arEntities);
				}
				
				//add tilemap to collision array
				var row : Number = Math.floor (x / 32);
				var col : Number = Math.floor (y / 32);
				var i : Number;
				var j : Number;
				for (i = row - 1; i < row + 2; i++)
				{
					for (j = col - 1; j < col + 2; j++)
					{
						if (GameArea.wallsMap.getTile(i, j))
						{
							entity = new CollidableEntity ();
							entity.x = i * 32;
							entity.y = j * 32;
							entity.width = 32;
							entity.height = 32;
							arEntities.push (entity);
						}
					}
				}
				
				for each (entity in arEntities)
				{
					reactCollisionEntities(entity);
				}
				
				if (this.x <= FP.world.camera.x || this.x >= FP.world.camera.x + 640 ||
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
		
		private function reactCollisionEntities(e:CollidableEntity):void 
		{
			switch (e.type)
			{
				case "pushBlock":
					if (collideAABB(e).willCollide)
					{
						collidedBox = true;
					}
					break;
				case "breakBlock":
					if (collideAABB(e).willCollide)
					{
						collidedBox = true;
					}
					break;
				default:
					if (collideAABB(e).willCollide)
					{
						collidedWall = true;
					}
					break;
			}
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
				hookshot.collide("pushBlock", hookshot.x, hookshot.y))
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