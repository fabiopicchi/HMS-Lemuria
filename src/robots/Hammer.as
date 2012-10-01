package robots 
{
	import com.greensock.TweenLite;
	import interactables.BreakBlock;
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.graphics.Spritemap;
	import net.flashpunk.Sfx;
	import net.flashpunk.utils.Input;
	import traps.SteamHitBox;
	/**
	 * ...
	 * @author ...
	 */
	public class Hammer extends Robot 
	{
		
		private var hammerStrike : Entity = new Entity (0, 0);
		private var animation : Spritemap = new Spritemap (Assets.HAMMER, 50, 32, ended);
		private var actionSound : Sfx = new Sfx (Assets.HAMMERTIME_SOUND);
		
		public function Hammer(direction : int) 
		{
			hammerStrike.setHitbox (32, 32);
			hammerStrike.type = "hammerStrike";
			this.centerOrigin();
			this.direction = direction;
			super(0x0000FF, direction);
			
			for each (var objGroup : XML in Assets.XML_CONVERSATIONS.child("conversation"))
			{
				if (objGroup.@id == 101)
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
			animation.add("ATTACK_DOWN", [16, 17, 18], 10, false);
			animation.add("ATTACK_RIGHT", [19, 20, 21], 10, false);
			animation.add("ATTACK_UP", [22, 23, 24], 10, false);
			animation.add("ATTACK_LEFT", [25, 26, 27], 10, false);
			animation.add("DIE_DOWN", [28, 29, 30, 31, 32, 33, 34, 35], 10, false);
			animation.add("DIE_RIGHT", [36, 37, 38, 39, 40, 41, 42, 43], 10, false);
			animation.add("DIE_UP", [44, 45, 46, 47, 48, 49, 50, 51], 10, false);
			animation.add("DIE_LEFT", [52, 53, 54, 55, 56, 57, 58, 59], 10, false);
			
			graphic.x = -12;
			graphic.y = -3;
			
			setHitbox (26, 26);
		}
		
		override protected function moveUpdate():void 
		{
			super.moveUpdate();
			hammerStrike.x = this.x;
			hammerStrike.y = this.y;
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
			vx = 0;
			vy = 0;
			actionSound.play();
			hammerTime();
		}
		
		override protected function actionUpdate():void 
		{
			super.actionUpdate();
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
		
		private function ended():void {
			if ((_state & ACTION) == ACTION) 
			{
				switchState (MOVING);
			}
			if ((_state & DEAD) == DEAD)
			{
				if (!GameArea.bReseting)
				{
					TweenLite.delayedCall (2, function () : void { GameArea.resetStage(); } );
					GameArea.bReseting = true;
				}
			}
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