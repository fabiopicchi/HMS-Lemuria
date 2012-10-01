package robots 
{
	import collision.CollidableEntity;
	import com.greensock.TweenLite;
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
	public class Hookshot extends Robot 
	{
		
		private var hook : Hook;
		public var bArrived : Boolean = false;
		private var animation : Spritemap = new Spritemap (Assets.HOOKSHOT, 32, 32, ended);
		private var actionSound : Sfx = new Sfx (Assets.HOOKSHOTTIME_SOUND);
		
		public function Hookshot(direction : int) 
		{
			this.centerOrigin();
			this.direction = direction;
			hook = new Hook(this);
			super(0x00FF00, direction);
			
			for each (var objGroup : XML in Assets.XML_CONVERSATIONS.child("conversation"))
			{
				if (objGroup.@id == 102)
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
			animation.add("ATTACK_DOWN", [16], 10, false);
			animation.add("ATTACK_RIGHT", [18], 10, false);
			animation.add("ATTACK_UP", [20], 10, false);
			animation.add("ATTACK_LEFT", [22], 10, false);
			animation.add("DIE_DOWN", [24, 25, 26, 27, 28, 29, 30, 31], 10, false);
			animation.add("DIE_RIGHT", [32, 33, 34, 35, 36, 37, 38, 39], 10, false);
			animation.add("DIE_UP", [40, 41, 42, 43, 44, 45, 46, 47], 10, false);
			animation.add("DIE_LEFT", [48, 49, 50, 51, 52, 53, 54, 55], 10, false);
			
			graphic.x = -3;
			graphic.y = -3;
			
			setHitbox (26, 26);
		}
		
		override protected function moveUpdate():void 
		{
			super.moveUpdate();
			if (Input.pressed ("ACTION") && !this.lead && !bInteractableInRange)
			{
				switchState (ACTION);
			}
			if (vx == 0 && vy == 0)
			{
				if (direction == 3) animation.play("STAND_UP");
				else if (direction == 0) animation.play("STAND_RIGHT");
				else if (direction == 1) animation.play("STAND_DOWN");
				else if (direction == 2) animation.play("STAND_LEFT");
			}
			else 
			{
				if (direction == 3) animation.play("WALK_UP");
				else if (direction == 0) animation.play("WALK_RIGHT");
				else if (direction == 1) animation.play("WALK_DOWN");
				else if (direction == 2) animation.play("WALK_LEFT");
			}
		}
		
		override protected function onAction():void 
		{
			super.onAction();
			vx = 0;
			vy = 0;
			if (direction == 3)
			{
				hook.x = this.x + 3;
				hook.y = this.y - hook.height;
				hook.originalX = this.x + 3;
				hook.originalY = this.y - hook.height;
			}
			else if (direction == 0)
			{
				hook.x = this.x + width;
				hook.y = this.y + 3;
				hook.originalX = this.x + width;
				hook.originalY = this.y + 3;
			}
			else if (direction == 1)
			{
				hook.x = this.x + 3;
				hook.y = this.y + height;
				hook.originalX = this.x + 3;
				hook.originalY = this.y + height;
			}
			else if (direction == 2)
			{
				hook.x = this.x - hook.width;
				hook.y = this.y + 3;
				hook.originalX = this.x - hook.width;
				hook.originalY = this.y + 3;
			}
			hook.vx = 0;
			hook.vy = 0;
			hook.direction = this.direction;
			FP.world.add(hook);
			if (hook.shoot())
			{
				switchState(MOVING);
			}
			else
			{
				actionSound.play();
			}
			
			if (direction == 3) animation.play("ATTACK_UP");
			else if (direction == 0) animation.play("ATTACK_RIGHT");
			else if (direction == 1) animation.play("ATTACK_DOWN");
			else if (direction == 2) animation.play("ATTACK_LEFT");
		}
		
		override protected function actionUpdate():void 
		{
			super.actionUpdate();
			if (hook.shoot())
			{
				switchState(MOVING);
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
		
		override protected function handleWaterCollision(e:CollidableEntity):void 
		{
			if (_state & ACTION == ACTION)
			{
				super.handleWaterCollision(e);
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