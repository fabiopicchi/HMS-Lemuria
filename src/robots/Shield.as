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
				if (Input.check ("ACTION") && !this.lead && !this.bInteractableInRange)
				{
					if (!bAction) fixedDirection = direction;
					bAction = true;
					super.move(Robot.VELOCITY / 3);
					GameArea.lookAtFixedDirection (fixedDirection);
					this.cluster();
				}
				else
				{
					super.move(Robot.VELOCITY);
				}
				super.updateData();
				
				if (Input.released ("ACTION") && !this.lead)
				{
					bAction = false;
					GameArea.leaveFormation();
				}
				
				if (!bAction)
				{
					if (vx==0 && vy==0){
						if (direction == 3) animation.play("STAND_UP");
						else if (direction == 0) animation.play("STAND_RIGHT");
						else if (direction == 1) animation.play("STAND_DOWN");
						else if (direction == 2) animation.play("STAND_LEFT");
					}
					else {
						if (direction == 3) animation.play("WALK_UP");
						else if (direction == 0) animation.play("WALK_RIGHT");
						else if (direction == 1) animation.play("WALK_DOWN");
						else if (direction == 2) animation.play("WALK_LEFT");
					}
				}
				else
				{
					if (fixedDirection == 3) animation.play("ATTACK_UP");
					else if (fixedDirection == 0) animation.play("ATTACK_RIGHT");
					else if (fixedDirection == 1) animation.play("ATTACK_DOWN");
					else if (fixedDirection == 2) animation.play("ATTACK_LEFT");
				}
			}
		}
		
		override protected function handleSteamCollision(steam:SteamHitBox):void 
		{
			this.steamHandle = steam.steamHandle;
			if (this.collideWith (steam, x, y) && !this.lead && steamHandle.on)
			{
				if (steam.steamHandle.direction == 0 && this.bAction && this.fixedDirection == 1)
				{
					steam.steamHandle.streamLength = - (this.y + this.height - (steam.steamHandle.y + steam.steamHandle.emitY - 7));
				}
				else if (steam.steamHandle.direction == 1 && this.bAction && this.fixedDirection == 2)
				{
					steam.steamHandle.streamLength = (this.x - (steam.steamHandle.x + steam.steamHandle.emitX - 7));
				}
				else if (steam.steamHandle.direction == 2 && this.bAction && this.fixedDirection == 3)
				{
					steam.steamHandle.streamLength = (this.y - (steam.steamHandle.y + steam.steamHandle.emitY - 7));
				}
				else if (steam.steamHandle.direction == 3 && this.bAction && this.fixedDirection == 0)
				{
					steam.steamHandle.streamLength = - (this.x + this.width - (steam.steamHandle.x + steam.steamHandle.emitX - 7));
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

}