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
	import UI.ConversationTrigger;
	
	/**
	 * ...
	 * @author 
	 */
	public class Robot extends CollidableEntity 
	{		
		static public const VELOCITY:Number = 160;
		static public const NEAR_RADIUS : int = 30;
		
		static public const MOVING : int = 1;
		static public const ACTION : int = 2;
		static public const FORMATION : int = 4;
		static public const LEFT_BEHIND : int = 8;
		static public const DEAD : int = 16;
		
		static public const LINE : int = 1;
		static public const CLUSTER : int = 2;
		
		public var targetX : Number;
		public var targetY : Number;
		
		static public var keyCount : int;
		public var sacrificeText : Array = [];
		
		protected var _state : int = 0;
		protected var _nextState : int = -1;
		
		protected var bInteractableInRange : Boolean = false;
		private static const arCollideable : Array = ["pushBlock", "breakBlock", "touchingDoor", "door", "key", "lever", "steam", "trigger", "gear", "endingTrigger"];
		
		public var direction : int;
		
		public function Robot(color : int, direction : int) 
		{
			this.direction = direction;
			this.type = "robot";
			_state = MOVING;
		}
		
		public function switchState (nextState : int) : void
		{
			_nextState = nextState;
		}
		
		override public function added():void 
		{
			super.added();
		}
		
		override public function update():void 
		{
			if (_nextState != -1)
			{
				if ((_nextState & MOVING) == MOVING)
				{
					onMove();
				}
				else if ((_nextState & ACTION) == ACTION)
				{
					onAction();
				}
				else if ((_nextState & FORMATION) == FORMATION)
				{
					onFormation();
				}
				else if ((_nextState & LEFT_BEHIND) == LEFT_BEHIND)
				{
					onLeftBehind();
				}
				else if ((_nextState & DEAD) == DEAD)
				{
					onDead();
				}
				_state = _nextState;
				_nextState = -1;
			}
			
			if ((_state & MOVING) == MOVING)
			{
				moveUpdate();
			}
			else if ((_state & ACTION) == ACTION)
			{
				actionUpdate ();
			}
			else if ((_state & FORMATION) == FORMATION)
			{
				formationUpdate ();
			}
			else if ((_state & LEFT_BEHIND) == LEFT_BEHIND)
			{
				leftBehindUpdate ();
			}
			else if ((_state & DEAD) == DEAD)
			{
				deadUpdate ();
			}
		}
		
		protected function onDead():void 
		{
			vx = 0;
			vy = 0;
		}
		
		protected function onLeftBehind():void 
		{
			GameArea.abandonLeader ();
			GameArea.showDialog(sacrificeText);
		}
		
		protected function onFormation():void 
		{
			
		}
		
		protected function onAction():void 
		{
			
		}
		
		protected function onMove():void 
		{
			
		}
		
		protected function moveUpdate():void 
		{
			this.move (VELOCITY);
			this.updateData();
			super.update();			
		}
		
		protected function deadUpdate():void 
		{
			
		}
		
		protected function leftBehindUpdate():void 
		{
			
		}
		
		protected function formationUpdate():void 
		{
			moveTowards(targetX, targetY, VELOCITY * 3);
		}
		
		protected function actionUpdate():void 
		{
			
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
			
			
			else if (lead != null)
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
					if (lead.vx != 0 && lead.vy == 0 && (Math.abs (this.y - lead.y) > + speed * FP.elapsed / 2))
					{
						distY = this.lead.y - this.y;
						this.vy = speed * FP.sign(distY);
					}
					else if (lead.vx == 0 && lead.vy != 0 && (Math.abs (this.x - lead.x) > + speed * FP.elapsed / 2))
					{
						distX = this.lead.x - this.x;
						this.vx = speed * FP.sign(distX);
					}
					else
					{
						this.vx = (lead.x - this.x) * 3;
						this.vy = (lead.y - this.y) * 3;
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
			
			var arEntities : Array = [];
			var result : CollisionResult;
			var entity : CollidableEntity;
			
			bInteractableInRange = false;
			
			//add tilemap to collision array
			var row : Number = Math.floor(centerX / 32);
			var col : Number = Math.floor(centerY / 32);
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
			
			//add Entities to collision array
			for each (var type : String in arCollideable)
			{
				FP.world.getType(type, arEntities);
			}
			
			//process collisions
			for each (entity in arEntities)
			{
				reactCollisionEntities(entity);
			}
			
			
			this.x += this.vx * FP.elapsed;
			this.y += this.vy * FP.elapsed;
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
							switchState (LEFT_BEHIND);
						}
					}
					break;
				case "steam":
					handleSteamCollision(e as SteamHitBox);
					break;
				case "water":
					handleWaterCollision(e);
					break;
				case "trigger":
					if (this.collideWith (e, x, y))
					{
						GameArea.showTriggeredDialog ((e as ConversationTrigger));
					}
					break;
				case "gear":
					if (this.collideWith (e, x, y))
					{
						switchState(DEAD);
					}
					break;
				case "endingTrigger":
					if (this.collideWith (e, x, y))
					{
						GameArea.showEnding();
					}
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
				switchState (DEAD);
			}
		}
		
		protected function handleWaterCollision (e : CollidableEntity) : void
		{
			var result : CollisionResult = collideAABB(e, false);
			if (e.collidePoint(e.x, e.y, this.centerX, this.centerY))
			{
				switchState(DEAD);
			}
			else if (result.willCollide)
			{
				this.vx -= result.minTranslationVector.x / FP.elapsed;
				this.vy -= result.minTranslationVector.y / FP.elapsed;
			}
		}
		
		public function get follower () : Robot
		{
			return GameArea.getMyFollower(this);
		}
		
		public function get lead () : Robot
		{
			return GameArea.getMyLeader(this);
		}
		
		public function get state():int 
		{
			return _state;
		}
	}

}