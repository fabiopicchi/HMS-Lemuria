package robots 
{
	import com.greensock.TweenLite;
	import flash.geom.Point;
	import interactables.Door;
	import interactables.Key;
	import interactables.Lever;
	import interactables.PushBlock;
	import interactables.TouchingDoor;
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.utils.Input;
	
	/**
	 * ...
	 * @author 
	 */
	public class Robot extends Entity 
	{		
		private var _lead : Robot;
		public var follower : Robot;
		static protected const VELOCITY:Number = 5;
		static protected const DIAG_VELOCITY:Number = 12.5;
		static public const NEAR_RADIUS : int = 30;
		static public var keyCount : int;
		public var bAction : Boolean = false;
		public var blockHandle : PushBlock;
		public var hasTarget : Boolean = false;
		protected var dead : Boolean = false;
		
		private var timerPushX : Number = 0;
		private var timerPushY : Number = 0;
		
		public var vx : Number = 0;
		public var vy : Number = 0;
		
		public var direction : int;
		
		private var bLeader : Boolean = false;
		
		public function Robot(color : int, direction : int) 
		{
			this.direction = direction;
			this.type = "robot";
		}
		
		override public function added():void 
		{
			super.added();
		}
		
		public function follow (r : Robot) : void
		{
			_lead = r;
			if (r) r.follower = this;
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
			if (_lead == null)
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
			
			
			else if (_lead != null && !hasTarget)
			{
				if (this.distanceFrom(_lead) <= NEAR_RADIUS)
				{
					this.vx = 0;
					this.vy = 0;
				}
				else
				{
					var distX : Number;
					var distY : Number;
					
					if (_lead.vx != 0 && _lead.vy == 0 && this.y != _lead.y)
					{
						distY = this._lead.y - this.y;
						this.vy = (Math.abs(distY) < speed ? distY : speed * Math.abs(distY) / distY);
					}
					else if (_lead.vx == 0 && _lead.vy != 0 && this.x != _lead.x)
					{
						distX = this._lead.x - this.x;
						this.vx = (Math.abs(distX) < speed ? distX : speed * Math.abs(distX) / distX);
					}
					else
					{
						this.vx = (_lead.x - this.x) / 10;
						this.vy = (_lead.y - this.y) / 10;
					}
				}
			}
		}
		
		protected function updateData () : void
		{
			if (!this.hasTarget)
			{
				var e : Entity;
				//position update
				this.x += this.vx;
				e = this.collide ("pushBlock", x, y);
				if (e)
				{
					if (vy == 0 && !(e as PushBlock).bMoving)
					{
						this.timerPushX += FP.elapsed;
						if (timerPushX >= 0.25)
						{
							(e as PushBlock).bMoving = true;
							this.timerPushX = 0;
							(e as PushBlock).move(0, FP.sign (vx));
						}
					}
					else
					{
						this.timerPushX = 0;
					}
					if (FP.sign (this.vx) > 0)
					{
						vx = 0;
						x = e.x - width;
					}
					else
					{
						vx = 0;
						x = e.x + e.width;
					}
				}
				else
				{
					this.timerPushX = 0;
				}
				if (this.collide ("water", x, y) || this.collide ("breakBlock", x, y) || this.collide ("walls", x, y)
					|| this.collide("door", x, y))
				{
					if (vx > 0)
					{
						vx = 0;
						x = Math.ceil(x / 32) * 32 - width;
					}
					else if (vx < 0)
					{
						vx = 0;
						x = Math.ceil(x / 32) * 32;
					}
				}
				
				this.y += this.vy;
				e = this.collide ("pushBlock", x, y);
				if (e)
				{
					if (vx == 0 && !(e as PushBlock).bMoving)
					{
						this.timerPushY += FP.elapsed;
						if (timerPushY >= 0.5)
						{
							(e as PushBlock).bMoving = true;
							this.timerPushY = 0;
							(e as PushBlock).move(1, FP.sign (vy));
						}
					}
					if (FP.sign (this.vy) > 0)
					{
						vy = 0;
						y = e.y - height;
					}
					else
					{
						vy = 0;
						y = e.y + e.height;
					}
				}
				else
				{
					this.timerPushY = 0;
				}
				
				if (this.collide ("water", x, y) || this.collide ("breakBlock", x, y) || this.collide ("walls", x, y)
					|| this.collide("door", x, y))
				{
					if (this.vy > 0)
					{
						vy = 0;
						y = Math.ceil(y / 32) * 32 - height;
					}
					else if (this.vy < 0)
					{
						vy = 0;
						y = Math.ceil(y / 32) * 32;
					}
				}
			}
			
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
			
			if (x == this.x && y == this.y)
			{
				this.hasTarget = false;
			}
			
			super.moveTowards(x, y, amount, solidType, sweep);
		}
		
		public function myBodyIsReady () : void
		{
			var team : Array = (FP.world as GameArea).team;
			
			for each (var r : Robot in team)
			{
				r.x = x;
				r.y = y;
			}
		}
		
		public function freeAll():void
		{
			var team : Array = (FP.world as GameArea).team;
			
			for each (var r : Robot in team)
			{
				r.hasTarget = false;
			}
		}
		
		public function get lead():Robot 
		{
			return _lead;
		}
		
		public function pullLever():void
		{
			var lever : Lever = this.collide("lever", x, y) as Lever;
			var door : Door = FP.world.getInstance("finalDoor");
			if (Input.pressed ("ACTION") && lever && !lever.pulled)
			{
				lever.pull();
				door.open();
				this.dead = true;
				
				var team : Array = (FP.world as GameArea).team;
				
				this.follower._lead = null;
				(FP.world as GameArea).leader = this.follower;
				team.splice(team.indexOf(this), 1);
			}
		}
		
		public function takeKey():void
		{
			var key : Key = this.collide("key", x, y) as Key;
			if (key)
			{
				keyCount++;
				FP.world.remove(key);
			}
		}
		
		public function unlockTouchingDoor():void
		{
			var touchingDoor : TouchingDoor = this.collide("touchingDoor", x, y) as TouchingDoor;
			if (touchingDoor && keyCount > 0)
			{
				keyCount--;
				FP.world.remove(touchingDoor);
			}
			else if (touchingDoor && keyCount <= 0)
			{
				if (this.vy > 0)
				{
					vy = 0;
					y = Math.ceil(y / 32) * 32 - height;
				}
				else if (this.vy < 0)
				{
					vy = 0;
					y = Math.ceil(y / 32) * 32;
				}
			}
		}
	}

}