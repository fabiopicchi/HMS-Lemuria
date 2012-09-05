package robots 
{
	import interactables.BreakBlock;
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.graphics.Spritemap;
	import net.flashpunk.utils.Input;
	import traps.SteamHitBox;
	/**
	 * ...
	 * @author ...
	 */
	public class Hammer extends Robot 
	{
		
		public var hammerStrike : Entity = new Entity (0, 0);
		public var animation : Spritemap = new Spritemap (Assets.HAMMER, 50, 32, ended);
		
		public function Hammer(direction : int) 
		{
			hammerStrike.setHitbox (32, 32);
			hammerStrike.type = "hammerStrike";
			this.centerOrigin();
			this.direction = direction;
			super(0x0000FF, direction);
			
			graphic = animation;
			animation.add("STAND_DOWN", [0]);
			animation.add("STAND_RIGHT", [4]);
			animation.add("STAND_UP", [8]);
			animation.add("STAND_LEFT", [12]);
			animation.add("WALK_DOWN", [0, 1, 2, 3], 10, true);
			animation.add("WALK_RIGHT", [4, 5, 6, 7], 10, true);
			animation.add("WALK_UP", [8, 9, 10, 11], 10, true);
			animation.add("WALK_LEFT", [12, 13, 14, 15], 10, true);
			animation.add("ATTACK_DOWN", [16, 17, 18], 10, false);
			animation.add("ATTACK_RIGHT", [19, 20, 21], 10, false);
			animation.add("ATTACK_UP", [22, 23, 24], 10, false);
			animation.add("ATTACK_LEFT", [25, 26, 27], 10, false);
			
			graphic.x = -12;
			graphic.y = -3;
			
			setHitbox (26, 26);
		}
		
		override public function update():void 
		{
			if (!this.dead)
			{
				if (bAction)
				{
					var blocks : Array = [];
					
					if (direction == 3) animation.play("ATTACK_UP");
					else if (direction == 0) animation.play("ATTACK_RIGHT");
					else if (direction == 1) animation.play("ATTACK_DOWN");
					else if (direction == 2) animation.play("ATTACK_LEFT");
					
					hammerStrike.collideInto("breakBlock", hammerStrike.x, hammerStrike.y, blocks);
					for each (var block : BreakBlock in blocks)
					{
						block.setBroken();
					}
				}
				if (Input.pressed ("ACTION") && vx == 0 && vy == 0 && !this.lead)
				{
					hammerTime();
					bAction = true;
				}
				else
				{
					super.move(Robot.VELOCITY);
					super.updateData();
					hammerStrike.x = this.x;
					hammerStrike.y = this.y;
					FP.world.remove (hammerStrike);
				}
				
				this.pullLever();
				this.takeKey();
				this.unlockTouchingDoor();
				if (vx == 0 && vy == 0 && bAction==false){
					if (direction == 3) animation.play("STAND_UP");
					else if (direction == 0) animation.play("STAND_RIGHT");
					else if (direction == 1) animation.play("STAND_DOWN");
					else if (direction == 2) animation.play("STAND_LEFT");
				}else if(bAction==false  && bAction==false) {
					if (direction == 3) animation.play("WALK_UP");
					else if (direction == 0) animation.play("WALK_RIGHT");
					else if (direction == 1) animation.play("WALK_DOWN");
					else if (direction == 2) animation.play("WALK_LEFT");
				}
				var steam : SteamHitBox = collide ("steam", x, y) as SteamHitBox;
				if (!this.lead && steam && steam.steamHandle.on)
				{
					FP.world = new GameArea (GameArea.stage, GameArea.map, GameArea.water, GameArea.walls, GameArea.song, GameArea.arRobots);
				}
				
			}
		}
		
		private function ended():void {
			if (bAction) bAction = false;
		}
		
		private function hammerTime():void
		{
			hammerStrike.x = x;
			hammerStrike.y = y;
			
			if (direction == 0)
			{
				hammerStrike.x += width;
			}
			else if (direction == 1)
			{
				hammerStrike.y += height;
			}
			else if (direction == 2)
			{
				hammerStrike.x -= hammerStrike.width;
			}
			else
			{
				hammerStrike.y -= hammerStrike.height;
			}
			FP.world.add(hammerStrike);
		}
		
	}

}