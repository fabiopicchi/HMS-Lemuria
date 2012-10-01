package traps 
{
	import com.greensock.TweenLite;
	import flash.display.BitmapData;
	import flash.filters.ConvolutionFilter;
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.graphics.Emitter;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.graphics.Spritemap;
	import net.flashpunk.Sfx;
	import net.flashpunk.utils.Ease;
	/**
	 * ...
	 * @author 
	 */
	public class Steam extends Entity
	{
		private var emitter : Emitter;
		private var animation : Spritemap;
		private var timer : Number;
		private var _streamLength : Number = 300;
		
		public var period : Number = 5;
		public var direction : Number = 5;
		public var maxLength : Number = 5;
		public var emitX : int = 0;
		public var emitY : int = 0;
		public var on : Boolean = false;
		private var actionSound : Sfx = new Sfx (Assets.STEAM_SOUND);
		
		private var e: SteamHitBox;
		
		public function Steam() 
		{
			timer = 0;
			
			animation = new Spritemap (Assets.STEAM, 32, 32);
			animation.add ("right", [0]);
			animation.add ("down", [1]);
			animation.add ("left", [2]);
			animation.add ("up", [3]);
			
			addGraphic(animation);
			
			emitter = new Emitter (Assets.STEAM_PARTICLE, 15, 14);
			emitter.newType("steam", [0]);
			emitter.newType("leak", [0]);
			emitter.relative = false;
			
			addGraphic(emitter);
			
			e = new SteamHitBox (this);
		}
		
		public function setup (obj : Object) : void
		{
			this.x = obj.x;
			this.y = obj.y;
			_streamLength = obj.size * 32;
			maxLength = obj.size * 32;
			period = obj.period;
			direction = obj.direction;
			
			if (obj.direction == 0)
			{	
				animation.play("up");
				
				emitter.setMotion ("steam", 87, _streamLength, 0, 6, 0, 2, Ease.backOut);
				emitter.setAlpha("steam", 1, 0);
				
				emitter.setMotion("leak", 60, 30, 0, 60, 0, 2, Ease.backOut);
				emitter.setAlpha("leak", 1, 0);
				
				emitX = 16;
				emitY = 32;
				
				e.setHitbox(26, obj.size * 32);
				e.x = this.x + 3;
				e.y = this.y - obj.size * 32 + 32;
			}
			else if (obj.direction == 1)
			{
				animation.play("right");
				
				emitter.setMotion ("steam", -3, _streamLength, 0, 6, 0, 2, Ease.backOut);
				emitter.setAlpha("steam", 1, 0);
				
				emitter.setMotion("leak", -30, 30, 0, 60, 0, 2, Ease.backOut);
				emitter.setAlpha("leak", 1, 0);
				
				emitX = 0;
				emitY = 16;
				
				e.setHitbox(obj.size * 32, 26);
				e.x = this.x;
				e.y = this.y + 3;
			}
			else if (obj.direction == 2)
			{
				animation.play("down");
				
				_streamLength -= 16;
				maxLength -= 16;
				
				emitter.setMotion ("steam", 267, _streamLength, 0, 6, 0, 2, Ease.backOut);
				emitter.setAlpha("steam", 1, 0);
				
				emitter.setMotion("leak", 240, 30, 0, 60, 0, 2, Ease.backOut);
				emitter.setAlpha("leak", 1, 0);
				
				emitX = 16;
				emitY = 16;
				
				e.setHitbox(26, obj.size * 32);
				e.x = this.x - 3;
				e.y = this.y + 16;
			}
			else if (obj.direction == 3)
			{
				animation.play("left");
				
				emitter.setMotion ("steam", 177, _streamLength, 0, 6, 0, 2, Ease.backOut);
				emitter.setAlpha("steam", 1, 0);
				
				emitter.setMotion("leak", 150, 30, 0, 60, 0, 2, Ease.backOut);
				emitter.setAlpha("leak", 1, 0);
				
				emitX = 32;
				emitY = 16;
				
				e.setHitbox(obj.size * 32, 26);
				e.x = this.x - obj.size * 32 + 32;
				e.y = this.y - 3;
			}
			TweenLite.delayedCall (1, function () : void { FP.world.add (e); e.visible = false; } );
		}
		
		public function get streamLength () : Number
		{
			return _streamLength;
		}
		
		public function set streamLength (len : Number) : void
		{
			_streamLength = len;
			if (direction == 0)
			{
				emitter.setMotion ("steam", 87, _streamLength, 0, 6, 0, 2, Ease.backOut);
			}
			else if (direction == 1)
			{
				emitter.setMotion ("steam", -3, _streamLength, 0, 6, 0, 2, Ease.backOut);
			}
			
			else if (direction == 2)
			{
				emitter.setMotion ("steam", 267, _streamLength, 0, 6, 0, 2, Ease.backOut);
			}
			
			else if (direction == 3)
			{
				emitter.setMotion ("steam", 177, _streamLength, 0, 6, 0, 2, Ease.backOut);
			}
		}
		
		override public function update():void 
		{
			timer += FP.elapsed;
			var i : int = 0;
			if (this.x < FP.world.camera.x + 640 &&
					this.x + this.width > FP.world.camera.x &&
					this.y < FP.world.camera.y + 480 &&
					this.y + this.height > FP.world.camera.y)
			{
				if (period != 0)
				{
					if (timer <= period / 4)
					{
						on = false;
					}
					else if (timer <= period / 2)
					{
						emitter.emit("leak", this.x + emitX - 7, this.y + emitY - 7);
					}
					else if (timer <= period)
					{
						for (i = 0; i < 5; i++)
						{
							emitter.emit("steam", this.x + emitX - 7, this.y + emitY - 7);
						}
						if (timer >= 0.55 * period)
						{
							on = true;
						}
					}
					else
					{
						timer = 0;
						on = false;
					}
				}
				else
				{
					on = true;
					for (i = 0; i < 5; i++)
					{
						emitter.emit("steam", this.x + emitX - 7, this.y + emitY - 7);
					}
				}
			}
			super.update();
		}
		
		override public function render():void 
		{
			e.render();
			super.render();
		}
		
	}

}