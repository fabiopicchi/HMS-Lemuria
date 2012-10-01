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
		private var hookSpeed : Number = 500;
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
			setHitbox(20, 20);
			graphic.x = -6;
			graphic.y = -6;
			animation.add("STAND_DOWN", [0]);
			animation.add("STAND_RIGHT", [1]);
			animation.add("STAND_UP", [2]);
			animation.add("STAND_LEFT", [3]);
		}
		
		public function shoot():Boolean
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
			var row : Number = Math.round (x / 32);
			var col : Number = Math.round (y / 32);
			var i : Number;
			var j : Number;
			for (i = row - 1; i < row + 2; i++)
			{
				for (j = col - 1; j < col + 2; j++)
				{
					if (i == row || j == col)
					{
						if (GameArea.wallsMap.getTile(i, j))
						{
							entity = new CollidableEntity ();
							entity.x = i * 32;
							entity.y = j * 32;
							entity.width = 32;
							entity.height = 32;
							entity.type = "walls";
							arEntities.push (entity);
						}
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
			
			if (!collidedWall && !collidedBox)
			{
				launch(this);
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
						GameArea.enterFormation();
						collidedBox = true;
					}
					break;
				case "breakBlock":
					if (collideAABB(e).willCollide)
					{
						GameArea.enterFormation();
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
				vx = way * hookSpeed;
				vy = 0;
				
			}
			else if (direction == 1)
			{
				vx = 0;
				vy = way * hookSpeed;
			}
			else if (direction == 2)
			{
				vx = - way * hookSpeed;
				vy = 0;
			}
			else
			{
				vx = 0;
				vy = - way * hookSpeed;
			}
			
			e.x += vx * FP.elapsed;
			e.y += vy * FP.elapsed;
			
			if (hookshot.direction == 3) animation.play("STAND_UP");
			else if (hookshot.direction == 0) animation.play("STAND_RIGHT");
			else if (hookshot.direction == 1) animation.play("STAND_DOWN");
			else if (hookshot.direction == 2) animation.play("STAND_LEFT");
		}
		
		public function retract():Boolean
		{
			way = -1;
			launch(this);
			if (collideWith (hookshot, x, y))
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
			GameArea.line();
			launch(hookshot);
			if (hookshot.collide ("pushBlock", hookshot.x, hookshot.y) || 
				hookshot.collide ("breakBlock", hookshot.x, hookshot.y))
			{
				hookshot.vx = 0;
				hookshot.vy = 0;
				FP.world.remove(this);
				GameArea.leaveFormation();
				collidedWall = false;
				collidedBox = false;
				return true;
			}
			return false;
		}
		
	}

}