package interactables 
{
	import collision.CollidableEntity;
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.Sfx;
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
		private var actionSound : Sfx = new Sfx (Assets.MOVABLE_BLOCK_SOUND);
		
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
				ax = -way * 100;
				vx = way * Math.sqrt (2 * Math.abs(ax) * 32);
				targetX = blockX + way * 32;
			}
			else
			{
				ay = -way * 100;
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
			var row : Number = Math.round (x / 32);
			var col : Number = Math.round (y / 32);
			var i : Number;
			var j : Number;
			var entity : CollidableEntity;
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
			actionSound.play(0.3);
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
				x += vx * FP.elapsed;
				y += vy * FP.elapsed;
				
				if (Math.abs (vx) - Math.abs (ax) * FP.elapsed < 0)
				{
					vx = 0;
					ax = 0;
					bMoving = false;
					x = targetX;
				}
				vx += ax * FP.elapsed;
				if (Math.abs (vy) - Math.abs (ay) * FP.elapsed < 0)
				{
					vy = 0;
					ay = 0;
					bMoving = false;
					y = targetY;
				}
				vy += ay * FP.elapsed;
			}
		}
		
		override public function render():void 
		{
			super.render();
		}
		
	}

}