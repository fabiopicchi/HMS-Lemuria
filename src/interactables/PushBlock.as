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
		private var arCollideable : Array = ["breakBlock", "pushBlock"];
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
				ax = -way * 0.01;
				vx = way * Math.sqrt (2 * Math.abs(ax) * 32);
				targetX = blockX + way * 32;
			}
			else
			{
				ay = -way * 0.01;
				vy = way * Math.sqrt (2 * Math.abs(ay) * 32);
				targetY = blockY + way * 32;
			}
			
			
			//Collision
			var arEntities : Array = [];
			
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
			var entity : CollidableEntity;
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
						entity.type = "walls";
						arEntities.push (entity);
					}
					else if (GameArea.waterMap.getTile(i, j))
					{
						entity = new CollidableEntity ();
						entity.x = i * 32;
						entity.y = j * 32;
						entity.width = 32;
						entity.height = 32;
						entity.type = "water";
						arEntities.push (entity);
					}
				}
			}
			
			//process collisions
			for each (entity in arEntities)
			{
				if (entity != this)
				{
					if (this.collideAABB(entity).willCollide)
					{
						vx = 0;
						ax = 0;
						vy = 0;
						ay = 0;
						bMoving = false;
						return;
					}
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