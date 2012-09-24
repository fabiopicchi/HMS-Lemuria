package robots 
{
	import net.flashpunk.FP;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.graphics.Spritemap;
	import net.flashpunk.utils.Input;
	import traps.SteamHitBox;
	/**
	 * ...
	 * @author ...
	 */
	public class Hookshot extends Robot 
	{
		
		private var hook : Hook;
		public var bArrived : Boolean = false;
		public var animation : Spritemap = new Spritemap (Assets.HOOKSHOT, 32, 32);
		
		public function Hookshot(direction : int) 
		{
			this.centerOrigin();
			this.direction = direction;
			hook = new Hook(this);
			super(0x00FF00, direction);
			
			graphic = animation;
			animation.add("STAND_DOWN", [0]);
			animation.add("STAND_RIGHT", [4]);
			animation.add("STAND_UP", [8]);
			animation.add("STAND_LEFT", [12]);
			animation.add("WALK_DOWN", [0, 1, 2, 3], 10, true);
			animation.add("WALK_RIGHT", [4, 5, 6, 7], 10, true);
			animation.add("WALK_UP", [8, 9, 10, 11], 10, true);
			animation.add("WALK_LEFT", [12, 13, 14, 15], 10, true);
			animation.add("ATTACK_DOWN", [16], 10, false);
			animation.add("ATTACK_RIGHT", [17], 10, false);
			animation.add("ATTACK_UP", [18], 10, false);
			animation.add("ATTACK_LEFT", [19], 10, false);
			
			graphic.x = -3;
			graphic.y = -3;
			
			setHitbox (26, 26);
		}
		
		override public function update():void 
		{
			if (!this.dead)
			{
				if (Input.pressed ("ACTION") && !this.lead && !bAction)
				{
					bAction = true;
					hook.x = this.x;
					hook.y = this.y;
					hook.originalX = this.x;
					hook.originalY = this.y;
					hook.direction = this.direction;
					FP.world.add(hook);
					
					if (direction == 3) animation.play("ATTACK_UP");
					else if (direction == 0) animation.play("ATTACK_RIGHT");
					else if (direction == 1) animation.play("ATTACK_DOWN");
					else if (direction == 2) animation.play("ATTACK_LEFT");
				}
				if (bArrived && !this.lead && !bAction)
				{
					bArrived = false;
					GameArea.leaveFormation();
				}
				if (bAction)
				{
					if (hook.shoot())
					{
						bAction = false;
					}
				}
				else
				{
					super.move(Robot.VELOCITY);
					super.updateData();
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
				if (!this.lead && steam && steam.steamHandle.on)
				{
					FP.world = new GameArea (GameArea.stage, GameArea.map, GameArea.water, GameArea.walls, GameArea.song, GameArea.arRobots);
				}
			}
		}
		
	}

}