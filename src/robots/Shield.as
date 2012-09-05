package robots 
{
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.graphics.Spritemap;
	import net.flashpunk.utils.Input;
	import traps.Steam;
	import traps.SteamHitBox;
	/**
	 * ...
	 * @author ...
	 */
	public class Shield extends Robot 
	{
		
		public var shieldStance : Boolean = false;
		public var fixedDirection : int;
		public var second : Robot;
		public var third : Robot;
		public var fourth : Robot;
		private var steamHandle : Steam;
		public var animation : Spritemap = new Spritemap (Assets.SHIELD, 32, 32);
		
		public function Shield(direction : int) 
		{
			this.centerOrigin();
			this.direction = direction;
			super(0xFF0000, direction);
			
			graphic = animation;
			animation.add("STAND_DOWN", [0]);
			animation.add("STAND_RIGHT", [4]);
			animation.add("STAND_UP", [8]);
			animation.add("STAND_LEFT", [12]);
			animation.add("WALK_DOWN", [0, 1, 2, 3], 10, true);
			animation.add("WALK_RIGHT", [4, 5, 6, 7], 10, true);
			animation.add("WALK_UP", [8, 9, 10, 11], 10, true);
			animation.add("WALK_LEFT", [12, 13, 14, 15], 10, true);
			animation.add("ATTACK_DOWN", [16,17,18,19], 10, false);
			animation.add("ATTACK_RIGHT", [20,21,22,23], 10, false);
			animation.add("ATTACK_UP", [24,25,26,27], 10, false);
			animation.add("ATTACK_LEFT", [28, 29, 30, 31], 10, false);
			
			graphic.x = -3;
			graphic.y = -3;
			
			setHitbox (26, 26);
		}
		
		override public function update():void 
		{
			if (!this.dead)
			{
				if (Input.pressed ("ACTION") && !this.lead)
				{
					fixedDirection = direction;
					
					if (direction == 3) animation.play("ATTACK_UP");
					else if (direction == 0) animation.play("ATTACK_RIGHT");
					else if (direction == 1) animation.play("ATTACK_DOWN");
					else if (direction == 2) animation.play("ATTACK_LEFT");
				}
				if (Input.check ("ACTION") && !this.lead)
				{
					shieldStance = true;
					bAction = true;
					super.move(Robot.VELOCITY / 3);
					updateData();
					fixDirection (fixedDirection);
					this.cluster();
				}
				else
				{
					shieldStance = false;
					bAction = false;
					super.move(Robot.VELOCITY);
					super.updateData();
				}
				if (Input.released ("ACTION") && !this.lead)
				{
					this.myBodyIsReady ();
					this.freeAll();
				}
				
				this.pullLever();
				this.takeKey();
				this.unlockTouchingDoor();
				
				if(vx==0 && vy==0 && bAction==false){
					if (direction == 3) animation.play("STAND_UP");
					else if (direction == 0) animation.play("STAND_RIGHT");
					else if (direction == 1) animation.play("STAND_DOWN");
					else if (direction == 2) animation.play("STAND_LEFT");
				}else if(bAction==false) {
					if (direction == 3) animation.play("WALK_UP");
					else if (direction == 0) animation.play("WALK_RIGHT");
					else if (direction == 1) animation.play("WALK_DOWN");
					else if (direction == 2) animation.play("WALK_LEFT");
				}
				
				var steam : SteamHitBox = collide ("steam", x, y) as SteamHitBox;
				if (steam && !this.lead)
				{
					this.steamHandle = steam.steamHandle;
					if (steam.steamHandle.direction == 0 && this.direction == 1 && this.shieldStance)
					{
						steam.steamHandle.streamLength = - (this.y + this.height - (steam.steamHandle.y + steam.steamHandle.emitY - 7));
					}
					else if (steam.steamHandle.direction == 1 && this.direction == 2 && this.shieldStance)
					{
						steam.steamHandle.streamLength = - (this.x - (steam.steamHandle.x + steam.steamHandle.emitX - 7));
					}
					else if (steam.steamHandle.direction == 2 && this.direction == 3 && this.shieldStance)
					{
						steam.steamHandle.streamLength = (this.y - (steam.steamHandle.y + steam.steamHandle.emitY - 7));
					}
					else if (steam.steamHandle.direction == 3 && this.direction == 0 && this.shieldStance)
					{
						steam.steamHandle.streamLength = (this.x + this.width - (steam.steamHandle.x + steam.steamHandle.emitX - 7));
					}
					else
					{
						this.steamHandle.streamLength = this.steamHandle.maxLength;
						this.steamHandle = null;
						FP.world = new GameArea (GameArea.stage, GameArea.map, GameArea.water, GameArea.walls, GameArea.song, GameArea.arRobots);
					}
				}
				else if (this.steamHandle)
				{
					this.steamHandle.streamLength = this.steamHandle.maxLength;
					this.steamHandle = null;
				}
			}
		}
		
		public function fixDirection (dir : int) : void
		{
			var team : Array = (FP.world as GameArea).team;
			
			for each (var r : Robot in team)
			{
				r.direction = dir;
			}
		}
	}

}