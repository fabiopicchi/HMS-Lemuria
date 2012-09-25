package robots 
{
	import collision.CollidableEntity;
	import collision.CollisionResult;
	import com.greensock.TweenLite;
	import flash.geom.Point;
	import flash.utils.getQualifiedClassName;
	import interactables.Door;
	import interactables.Key;
	import interactables.Lever;
	import interactables.PushBlock;
	import interactables.TouchingDoor;
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.masks.Grid;
	import net.flashpunk.utils.Input;
	import traps.SteamHitBox;
	
	/**
	 * ...
	 * @author 
	 */
	public class Robot extends CollidableEntity 
	{		
		static protected const VELOCITY:Number = 5;
		static protected const DIAG_VELOCITY:Number = 12.5;
		static public const NEAR_RADIUS : int = 30;
		static public var keyCount : int;
		public var bAction : Boolean = false;
		public var blockHandle : PushBlock;
		public var hasTarget : Boolean = false;
		protected var dead : Boolean = false;
		protected var bInteractableInRange : Boolean = false;
		private static const arCollideable : Array = ["pushBlock", "breakBlock", "touchingDoor", "door", "key", "lever", "steam"];
		
		public var direction : int;
		
		public function Robot(color : int, direction : int) 
		{
			this.direction = direction;
			this.type = "robot";
		}
		
		override public function added():void 
		{
			super.added();
		}
		
		override public function update():void 
		{
			this.move (VELOCITY);
			this.updateData();
			super.update();
		}
		
		public function move(speed : Number):void
		{
			//input update
			if (lead == null)
			{
				this.vx = 0;
				this.vy = 0;
				if (Input.check ("UP"))
				{
					this.vy = -speed;
					direction = 3;
				} 
				else if (Input.check ("DOWN"))
				{
					this.vy = speed;
					direction = 1;
				}
				
				if (Input.check ("RIGHT"))
				{
					this.vx = speed;
					direction = 0;
				}
				else if (Input.check ("LEFT"))
				{
					this.vx = -speed;
					direction = 2;
				}
				
				if (this.vx != 0 && this.vy != 0)
				{
					this.vx = (this.vx < 0 ? -1 : 1) * Math.sqrt (speed * speed / 2);
					this.vy = (this.vy < 0 ? -1 : 1) * Math.sqrt (speed * speed / 2);
				}
			}
			
			
			else if (lead != null && !hasTarget)
			{
				if (this.distanceFrom(lead) <= NEAR_RADIUS)
				{
					this.vx = 0;
					this.vy = 0;
				}
				else
				{
					var distX : Number;
					var distY : Number;
					
					if (lead.vx != 0 && lead.vy == 0 && this.y != lead.y)
					{
						distY = this.lead.y - this.y;
						this.vy = (Math.abs(distY) < speed ? distY : speed * Math.abs(distY) / distY);
					}
					else if (lead.vx == 0 && lead.vy != 0 && this.x != lead.x)
					{
						distX = this.lead.x - this.x;
						this.vx = (Math.abs(distX) < speed ? distX : speed * Math.abs(distX) / distX);
					}
					else
					{
						this.vx = (lead.x - this.x) / 10;
						this.vy = (lead.y - this.y) / 10;
					}
				}
			}
		}
		
		protected function updateData () : void
		{
			//direction update
			if (vy == 0)
			{
				if (vx > 0)
				{
					direction = 0;
				}
				else if (vx < 0)
				{
					direction = 2;
				}
			}
			else if (vx == 0)
			{
				if (vy > 0)
				{
					direction = 1;
				}
				else if (vy < 0)
				{
					direction = 3;
				}
			}
			else if (direction != 0 && direction != 1 && vx > 0 && vy > 0)
			{
				direction = 1;
			}
			else if (direction != 1 && direction != 2 && vx < 0 && vy > 0)
			{
				direction = 2;
			}
			else if (direction != 2 && direction != 3 && vx < 0 && vy < 0)
			{
				direction = 3;
			}
			else if (direction != 3 && direction != 0 && vx > 0 && vy < 0)
			{
				direction = 0;
			}
			
			if (!this.hasTarget)
			{
				var arEntities : Array = [];
				var result : CollisionResult;
				var entity : CollidableEntity;
				
				bInteractableInRange = false;
				
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
						if (GameArea.wallsMap.getTile(i, j) || GameArea.waterMap.getTile(i, j))
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
				
				//process collisions
				for each (entity in arEntities)
				{
					reactCollisionEntities(entity);
				}
				
				
				this.x += this.vx;
				this.y += this.vy;
			}
		}
		
		protected function reactCollisionEntities(e : CollidableEntity) : void
		{
			switch (e.type)
			{
				case "pushBlock":
					var result : CollisionResult = collideAABB(e);
					if (result.willCollide)
					{
						if (!(e as PushBlock).bMoving)
						{
							if (result.minTranslationVector.x != 0)
							{
								(e as PushBlock).timerPushX += FP.elapsed;
								if ((e as PushBlock).timerPushX >= 0.25)
								{
									(e as PushBlock).bMoving = true;
									(e as PushBlock).timerPushX = 0;
									(e as PushBlock).move(0, FP.sign (result.minTranslationVector.x));
								}
							}
							else
							{
								(e as PushBlock).timerPushX = 0;
							}
							if (result.minTranslationVector.y != 0)
							{
								(e as PushBlock).timerPushY += FP.elapsed;
								if ((e as PushBlock).timerPushY >= 0.25)
								{
									(e as PushBlock).bMoving = true;
									(e as PushBlock).timerPushY = 0;
									(e as PushBlock).move(1, FP.sign (result.minTranslationVector.y));
								}
							}
							else
							{
								(e as PushBlock).timerPushY = 0;
							}
						}
					}
					else if (!this.lead)
					{
						(e as PushBlock).timerPushX = 0;
						(e as PushBlock).timerPushY = 0;
					}
					break;
				case "touchingDoor":
					if (collideAABB(e).willCollide && keyCount > 0)
					{
						keyCount--;
						FP.world.remove(e);
					}
					break;
				case "key":
					if (this.collideWith (e, x, y))
					{
						keyCount++;
						FP.world.remove(e);
					}
					break;
				case "lever":
					//If lever is not pulled and this is the leader, let him die
					if (this.collideWith (e, x, y) && !(e as Lever).pulled && !this.lead)
					{
						bInteractableInRange = true;
						if (Input.pressed ("ACTION"))
						{
							var door : Door = FP.world.getInstance("finalDoor");
							(e as Lever).pull();
							door.open();
							this.dead = true;
							GameArea.abandonLeader ();
						}
					}
					break;
				case "steam":
					handleSteamCollision(e as SteamHitBox);
					break;
				default:
					collideAABB(e);
					break;
			}
		}
		
		protected function handleSteamCollision (e : SteamHitBox) : void
		{
			if (this.collideWith (e, x, y) && (e as SteamHitBox).steamHandle.on)
			{
				FP.world = new GameArea (GameArea.stage, GameArea.map, GameArea.water, GameArea.walls, GameArea.song, GameArea.arRobots);
			}
		}
		
		public function cluster():void
		{
			var clusterSpeed : Number = VELOCITY * 3;
			
			var second : Robot;
			var third : Robot;
			var teamSize : int = 1;
			
			if (this.follower)
			{
				teamSize++;
				second = this.follower;
				if (second.follower)
				{
					teamSize++;
					third = second.follower;
				}
			}
			
			if (teamSize == 3)
			{
				second.vx = 0;
				second.vy = 0;
				
				third.vx = 0;
				third.vy = 0;
				if (this.direction == 0)
				{
					second.moveTowards(this.x - this.halfWidth, this.y - this.halfHeight, clusterSpeed);
					third.moveTowards(this.x - this.halfWidth, this.y + this.halfHeight, clusterSpeed);
				}
				else if (this.direction == 1)
				{
					second.moveTowards(this.x + this.halfWidth, this.y - this.halfHeight, clusterSpeed);
					third.moveTowards(this.x - this.halfWidth, this.y - this.halfHeight, clusterSpeed);
				}
				else if (this.direction == 2)
				{
					second.moveTowards(this.x + this.halfWidth, this.y + this.halfHeight, clusterSpeed);
					third.moveTowards(this.x + this.halfWidth, this.y - this.halfHeight, clusterSpeed);
				}
				else
				{
					second.moveTowards(this.x - this.halfWidth, this.y + this.halfHeight, clusterSpeed);
					third.moveTowards(this.x + this.halfWidth, this.y + this.halfHeight, clusterSpeed);
				}
			}
			else if (teamSize == 2)
			{
				second.vx = 0;
				second.vy = 0;
				
				if (this.direction == 0)
				{
					second.moveTowards(this.x - this.halfWidth, this.y, clusterSpeed);
				}
				else if (this.direction == 1)
				{
					second.moveTowards(this.x, this.y - this.halfHeight, clusterSpeed);
				}
				else if (this.direction == 2)
				{
					second.moveTowards(this.x + this.halfWidth, this.y, clusterSpeed);
				}
				else
				{
					second.moveTowards(this.x, this.y + this.halfHeight, clusterSpeed);
				}
			}
		}
		
		public function line():void
		{
			var lineSpeed : Number = VELOCITY * 3;
			
			var second : Robot;
			var third : Robot;
			var teamSize : int = 1;
			
			var moveX : int;
			var moveY : int;
			var moveLength : Number = this.width / 2;
			
			if (this.direction == 0)
			{
				moveX = 1;
				moveY = 0;
			}
			else if (this.direction == 1)
			{
				moveX = 0;
				moveY = 1;
			}
			else if (this.direction == 2)
			{
				moveX = -1;
				moveY = 0;
			}
			else
			{
				moveX = 0;
				moveY = -1;
			}
			
			if (this.follower)
			{
				second = this.follower;
				second.moveTowards(this.x - moveX * moveLength, this.y - moveY * moveLength, lineSpeed);
				if (second.follower)
				{
					third = second.follower;
					third.moveTowards(this.x - moveX * moveLength * 2, this.y - moveY * moveLength * 2, lineSpeed);
				}
			}
		}
		
		override public function render():void 
		{
			super.render();
		}
		
		override public function moveTowards(x:Number, y:Number, amount:Number, solidType:Object = null, sweep:Boolean = false):void 
		{
			this.hasTarget = true;
			
			super.moveTowards(x, y, amount, solidType, sweep);
		}
		
		public function get follower () : Robot
		{
			return GameArea.getMyFollower(this);
		}
		
		public function get lead () : Robot
		{
			return GameArea.getMyLeader(this);
		}
	}

}