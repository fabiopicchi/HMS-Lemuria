package interactables 
{
	import com.greensock.easing.Quad;
	import com.greensock.TweenLite;
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.graphics.Image;
	/**
	 * ...
	 * @author 
	 */
	public class PushBlock extends Entity
	{
		public var bMoving : Boolean = false;
		
		public function PushBlock() 
		{
			this.addGraphic(new Image (Assets.MOVABLE_BLOCK));
			setHitbox (32, 32);
			this.type = "pushBlock";
		}
		
		public function setup (obj : Object) : void
		{
			this.x = obj.x;
			this.y = obj.y;
		}
		
		public function move (dir : int, way : int) : void
		{
			var blockX : Number = this.x;
			var blockY : Number = this.y;
			
			if (dir == 0)
			{
				if (!collide("walls", x + way * 32, y) && !collide("breakBlock", x + way * 32, y) && !collide("pushBlock", x + way * 32, y))
				{
					TweenLite.to(this, 0.5, { x : blockX + way * 32, ease : Quad.easeOut, onComplete : function () : void { bMoving = false; } } );
				}
				else
				{
					bMoving = false;
				}
			}
			else
			{
				if (!collide("walls", x, y + way * 32) && !collide("breakBlock", x, y + way * 32) && !collide("pushBlock", x, y + way * 32))
				{
					TweenLite.to(this, 0.5, { y : blockY + way * 32, ease : Quad.easeOut, onComplete : function () : void { bMoving = false; } } );
				}
				else
				{
					bMoving = false;
				}
			}
		}
		
		override public function added():void 
		{
			super.added();
		}
		
		override public function update():void 
		{
			super.update();
		}
		
		override public function render():void 
		{
			super.render();
		}
		
	}

}