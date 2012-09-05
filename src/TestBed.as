package  
{
	import com.greensock.easing.Linear;
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import config.TmxLoader;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import interactables.BreakBlock;
	import interactables.PushBlock;
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.graphics.Text;
	import net.flashpunk.graphics.Tilemap;
	import net.flashpunk.masks.Grid;
	import net.flashpunk.utils.Ease;
	import net.flashpunk.utils.Input;
	import net.flashpunk.World;
	import robots.Hammer;
	import robots.Hookshot;
	import robots.Robot;
	import robots.Shield;
	import traps.Piston;
	import traps.Steam;
	/**
	 * ...
	 * @author 
	 */
	public class TestBed extends World
	{	
		private var timer : Number = 0;
		public var team : Array = [];
		
		private var r1 : Robot = new Hammer (0);
		private var r2 : Robot = new Hookshot (0);
		private var r3 : Robot = new Shield (0);
		private var r4 : Robot = new Robot (0xFF0000, 0);
		
		private var steam : Steam = new Steam();
		
		public var collisionMap : Grid = new Grid (640, 480, 32, 32);
		private var room : Entity = new Entity (0, 0);
		private var dialogBox : Entity = new Entity (180, 380);
		private var tileMap : Tilemap = new Tilemap (Assets.TILESET, 640, 480, 32, 32);
		private var tmxMap : TmxLoader;
		
		public function TestBed() 
		{
			
			tmxMap = new TmxLoader (new Assets["fase1_3_2"] ());
			
			var spawnPoint : Object = tmxMap.getObject("objects", "spawn")[0];
			if (spawnPoint)
			{
				r1.x = parseInt(spawnPoint.x) + 5;
				r1.y = spawnPoint.y;
				
				r2.x = parseInt(spawnPoint.x) - 5;
				r2.y = spawnPoint.y;
				
				r3.x = spawnPoint.x;
				r3.y = parseInt(spawnPoint.y) + 5;
				
				r4.x = spawnPoint.x;
				r4.y = parseInt(spawnPoint.y) - 5;
			} 
			else
			{
				r1.x = 70;
				r1.y = 400;
				r2.x = 70;
				r2.y = 400;
				r3.x = 70;
				r3.y = 400;
				r4.x = 70;
				r4.y = 400;
			}
			
			parseTileMap (new Assets.fase1_3_2T (), tileMap);
			room.graphic = tileMap;
			room.type = "map";
			add(room);
			
			var arObjects : Array = [];
			arObjects = tmxMap.getObject("objects", "movable_block");
			for each (var obj : Object in arObjects)
			{
				var push : PushBlock = new PushBlock ();
				push.x = obj.x;
				push.y = obj.y;
				push.type = "pushBlock";
				add(push);
			}
			
			arObjects = tmxMap.getObject("objects", "breakable_block");
			for each (var obj : Object in arObjects)
			{
				var breakable : BreakBlock = new BreakBlock ();
				breakable.x = obj.x;
				breakable.y = obj.y;
				breakable.type = "breakBlock";
				add(breakable);
			}
			
			this.add (r1);
			this.add (r2);
			this.add (r3);
			this.add (r4);
			
			dialogBox.graphic = new Text ("One of them will be left behind...");
			add(dialogBox);
			
			parseCollisionMap (new Assets.fase1_3_2T (), collisionMap);
			room.mask = collisionMap;
			
			team.push (r1);
			team.push (r2);
			team.push (r3);
			team.push (r4);
			
			r4.follow(r3);
			r3.follow(r2);
			r2.follow(r1);
			
			add(steam);
		}
		
		override public function update():void 
		{
			if (Input.pressed("SWAP"))
			{
				swap();
			}
			
			super.update();
		}
		
		override public function render():void 
		{
			super.render();
		}
		
		public function animateLeftBehind () : void
		{
			dialogBox.visible = true;
			dialogBox.graphic.y = 0;
			TweenMax.to (dialogBox.graphic, 5, { y : -50, alpha : 0, onComplete : function () : void { 
					(dialogBox.graphic as Text).alpha = 1;
					dialogBox.visible = false;
			} } );
		}
		
		public function swap() : void
		{
			var first : Robot;
			var last : Robot;
			for each (var r : Robot in team)
			{
				if (r.lead == null)
				{
					first = r;
				}
				
				if (r.follower == null)
				{
					last = r;
				}
			}
			first.follow(last);
			
			var firstX : int = first.x;
			var firstY : int = first.y;
			
			first.x = first.lead.x;
			first.y = first.lead.y;
			
			last.x = last.lead.x;
			last.y = last.lead.y;
			
			last.lead.x = first.follower.x;
			last.lead.y = first.follower.y;
			
			first.follower.x = firstX;
			first.follower.y = firstY;
			
			first.follower.follow (null);
			first.follower = null;
		}
		
		public function parseCollisionMap (tileMap : String, grid : Grid) : void
		{
			var ar : Array = [];
			var row : int = 0;
			var column : int = 0;
			for (var i : int = 0; i < tileMap.length; i++)
			{
				if (tileMap.charAt(i) == ",")
				{
					column++;
					continue;
				}
				else if (tileMap.charAt(i) == "\n")
				{
					row++;
					column = 0;
					continue;
				}
				
				if (tileMap.charAt(i) != '1')
				{
					grid.setTile(column, row);
				}
				else
				{
					grid.setTile(column, row, false);
				}
			}
		}
		
		public function parseTileMap (tileMap : String, tm : Tilemap) : void
		{
			var ar : Array = [];
			var row : int = 0;
			var column : int = 0;
			for (var i : int = 0; i < tileMap.length; i++)
			{
				if (tileMap.charAt(i) == ",")
				{
					column++;
					continue;
				}
				else if (tileMap.charAt(i) == "\n")
				{
					row++;
					column = 0;
					continue;
				}
				tm.setTile(column, row, parseInt(tileMap.charAt(i)) - 1);
			}
		}
	}

}