package robots 
{
	import com.greensock.TweenLite;
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.graphics.Spritemap;
	import net.flashpunk.Sfx;
	import net.flashpunk.utils.Input;
	import traps.Steam;
	import traps.SteamHitBox;
	/**
	 * ...
	 * @author ...
	 */
	public class Shield extends Robot 
	{
		private var fixedDirection : int;
		private var steamHandle : Steam;
		private var animation : Spritemap = new Spritemap (Assets.SHIELD, 32, 32, ended);
		private var actionSound : Sfx = new Sfx (Assets.SHIELDTIME_SOUND);
		
		public function Shield(direction : int) 
		{
			this.centerOrigin();
			this.direction = direction;
			super(0xFF0000, direction);
			
			for each (var objGroup : XML in Assets.XML_CONVERSATIONS.child("conversation"))
			{
				if (objGroup.@id == 100)
				{
					for each (var objText : XML in objGroup.child("text"))
					{
						var text : Object = { };
						text["timeShowing"] = int (objText.@timeShowing);
						text["charId"] = int (objText.@charId);
						text["text"] = objText.toString();
						sacrificeText.push (text);
					}
				}
			}
			
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
			animation.add("DIE_DOWN", [32, 33, 34, 35, 36, 37, 38, 39], 10, false);
			animation.add("DIE_RIGHT", [40, 41, 42, 43, 44, 45, 46, 47], 10, false);
			animation.add("DIE_UP", [48, 49, 50, 51, 52, 53, 54, 55], 10, false);
			animation.add("DIE_LEFT", [56, 57, 58, 59, 60, 61, 62, 63], 10, false);
			
			graphic.x = -3;
			graphic.y = -3;
			
			setHitbox (26, 26);
		}
		
		override protected function moveUpdate():void 
		{
			super.moveUpdate();
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
			if (Input.pressed ("ACTION") && !this.lead && !bInteractableInRange)
			{
				switchState (ACTION);
			}
		}
		
		override protected function onDead():void 
		{
			super.onDead();
			if (direction == 3) animation.play("DIE_UP");
			else if (direction == 0) animation.play("DIE_RIGHT");
			else if (direction == 1) animation.play("DIE_DOWN");
			else if (direction == 2) animation.play("DIE_LEFT");
		}
		
		override protected function onAction():void 
		{
			super.onAction();
			fixedDirection = direction;
			actionSound.play();
			
			GameArea.enterFormation();
		}
		
		override protected function actionUpdate():void 
		{
			super.actionUpdate();
			
			super.move(Robot.VELOCITY / 3);
			super.updateData();
			
			GameArea.lookAtFixedDirection (fixedDirection);
			GameArea.cluster();
			if (fixedDirection == 3) animation.play("ATTACK_UP");
			else if (fixedDirection == 0) animation.play("ATTACK_RIGHT");
			else if (fixedDirection == 1) animation.play("ATTACK_DOWN");
			else if (fixedDirection == 2) animation.play("ATTACK_LEFT");
			if (Input.released ("ACTION") && !this.lead)
			{
				GameArea.leaveFormation();
				switchState (MOVING);
			}
		}
		
		override protected function handleSteamCollision(steam:SteamHitBox):void 
		{
			this.steamHandle = steam.steamHandle;
			if (this.collideWith (steam, x, y) && !this.lead && steamHandle.on)
			{
				if ((_state & ACTION) == ACTION)
				{
					if (steam.steamHandle.direction == 0 && this.fixedDirection == 1)
					{
						steam.steamHandle.streamLength = - (this.y + this.height - (steam.steamHandle.y + steam.steamHandle.emitY - 7));
					}
					else if (steam.steamHandle.direction == 1  && this.fixedDirection == 2)
					{
						steam.steamHandle.streamLength = (this.x - (steam.steamHandle.x + steam.steamHandle.emitX - 7));
					}
					else if (steam.steamHandle.direction == 2 && this.fixedDirection == 3)
					{
						steam.steamHandle.streamLength = (this.y - (steam.steamHandle.y + steam.steamHandle.emitY - 7));
					}
					else if (steam.steamHandle.direction == 3 && this.fixedDirection == 0)
					{
						steam.steamHandle.streamLength = - (this.x + this.width - (steam.steamHandle.x + steam.steamHandle.emitX - 7));
					}
					else
					{
						this.steamHandle.streamLength = this.steamHandle.maxLength;
						this.steamHandle = null;
						switchState(DEAD);
					}
				}
				else
				{
					this.steamHandle.streamLength = this.steamHandle.maxLength;
					this.steamHandle = null;
					switchState(DEAD);
				}
			}
			else if (this.steamHandle)
			{
				this.steamHandle.streamLength = this.steamHandle.maxLength;
				this.steamHandle = null;
			}
		}
		
		private function ended():void {
			if ((_state & DEAD) == DEAD)
			{
				if (!GameArea.bReseting)
				{
					TweenLite.delayedCall (2, function () : void { GameArea.resetStage(); } );
					GameArea.bReseting = true;
				}
			}
		}
	}

}