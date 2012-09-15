package  
{
	import com.greensock.TweenMax;
	import config.TmxLoader;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import interactables.BreakBlock;
	import interactables.Door;
	import interactables.Key;
	import interactables.Lever;
	import interactables.PushBlock;
	import interactables.TouchingDoor;
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.graphics.Text;
	import net.flashpunk.graphics.Tilemap;
	import net.flashpunk.masks.Grid;
	import net.flashpunk.Sfx;
	import net.flashpunk.utils.Input;
	import net.flashpunk.World;
	import robots.Hammer;
	import robots.Hookshot;
	import robots.Robot;
	import robots.Shield;
	import traps.Gear;
	import traps.Steam;
	
	/**
	 * ...
	 * @author 
	 */
	public class GameArea extends World
	{
		private var timer : Number = 0;
		public var team : Array = [];
		
		public var waterMap : Grid;
		public var wallsMap : Grid;
		private var room : Entity = new Entity (0, 0);
		private var dialogBox : Entity = new Entity (180, 380);
		private var tmxMap : TmxLoader;
		public var leader : Robot;
		
		static public var stage : Class;
		static public var map : Class;
		static public var water : Class;
		static public var walls : Class;
		static public var song : Class;
		static public var arRobots : Array;
		
		private var music : Sfx;
		
		private const OBJECT_LAYER : String = "objects";
		private var arObjects : Array = [ { type : BreakBlock, id : "breakable_block", layer : OBJECT_LAYER },
										{type : PushBlock, id : "movable_block", layer : OBJECT_LAYER },
										{type : Lever, id : "lever", layer : OBJECT_LAYER },
										{type : Key, id : "key", layer : OBJECT_LAYER },
										{type : Gear, id : "gear", layer : OBJECT_LAYER },
										{type : Steam, id : "steam", layer : OBJECT_LAYER },
										{type : TouchingDoor, id : "door", layer : OBJECT_LAYER },
										{type : Door, id : "finaldoor", layer : OBJECT_LAYER }];
		
		public function GameArea(stage : Class, map : Class, water : Class, walls : Class, song : Class, arRobots : Array) 
		{
			music = new Sfx (song);
			music.loop();
			
			GameArea.arRobots = arRobots;
			GameArea.stage = stage;
			GameArea.map = map;
			GameArea.water = water;
			GameArea.walls = walls;
			GameArea.song = song;
			
			tmxMap = new TmxLoader (new stage ());
			
			var tileMap : Tilemap = new Tilemap (Assets.TILESET, tmxMap.getLayerWidth("ground") * 32, tmxMap.getLayerHeight("ground") * 32, 32, 32);
			parseTileMap (new map (), tileMap);
			room.addGraphic(tileMap);
			tileMap = new Tilemap (Assets.TILESET, tmxMap.getLayerWidth("water") * 32, tmxMap.getLayerHeight("water") * 32, 32, 32);
			parseTileMap (new water (), tileMap);
			room.addGraphic(tileMap);
			tileMap = new Tilemap (Assets.TILESET, tmxMap.getLayerWidth("walls") * 32, tmxMap.getLayerHeight("walls") * 32, 32, 32);
			parseTileMap (new walls (), tileMap);
			room.addGraphic(tileMap);
			add(room);
			
			
			//dialogBox.graphic = new Text ("One of them will be left behind...");
			//add(dialogBox);
			
			var e : Entity = new Entity (0, 0);
			e.graphic = Image.createRect (tmxMap.getLayerWidth("water") * 32, tmxMap.getLayerHeight("water") * 32);
			e.visible = false;
			
			waterMap = new Grid (tmxMap.getLayerWidth("water") * 32, tmxMap.getLayerHeight("water") * 32, 32, 32);
			parseCollisionMap (new water (), waterMap);
			e.mask = waterMap;
			e.type = "water";
			add(e);
			
			e = new Entity (0, 0);
			e.graphic = Image.createRect (tmxMap.getLayerWidth("walls") * 32, tmxMap.getLayerHeight("walls") * 32);
			e.visible = false;
			
			wallsMap = new Grid (tmxMap.getLayerWidth("walls") * 32, tmxMap.getLayerHeight("walls") * 32, 32, 32);
			parseCollisionMap (new walls (), wallsMap);
			e.mask = wallsMap;
			e.type = "walls";
			add(e);
			
			for (var i : int = 0; i < arRobots.length; i++)
			{
				var cl : Class = arRobots[i];
				team.push (new cl (0));
				if (i > 0)
				{
					team[i - 1].follow(team[i]);
				}
			}
			leader = team[i - 1];
			
			var spawnPoint : Object = tmxMap.getObject("objects", "spawn")[0];
			for (i = 0; i < team.length; i++)
			{
				team[i].x = parseInt(spawnPoint.x) + 30 * (team.length - i);
				team[i].y = parseInt(spawnPoint.y);
				add (team[i]);
			}
			loadMap(tmxMap);
		}
		override public function update():void 
		{
			if (Input.pressed("SWAP"))
			{
				swap();
			}
			
			if (leader.y <= 0)
			{
				var ar : Array = [];
				for each (var r : Robot in team)
				{
					ar.push (getDefinitionByName(getQualifiedClassName(r)));
				}
				if (GameArea.arRobots.length == 3)
				{
					music.stop();
					FP.world = new GameArea (Assets.stage2, Assets.map2, Assets.water2, Assets.walls2, Assets.MAIN_SONG, ar);
				}
				else
				{
					music.stop();
					FP.world = new GameArea (Assets.stage3, Assets.map3, Assets.water3, Assets.walls3, Assets.ENDING_SONG, ar);
				}
			}
			
			FP.camera.x = leader.x + leader.halfWidth - FP.halfWidth;
			FP.camera.y = leader.y + leader.halfHeight - FP.halfHeight;
			
			FP.camera.x = FP.clamp(FP.camera.x, 0, tmxMap.getLayerWidth("ground") * 32 - FP.width);
			FP.camera.y = FP.clamp(FP.camera.y, 0, tmxMap.getLayerHeight("ground") * 32 - FP.height);
			
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
			for (var i : int = 0; i < team.length; i++)
			{
				if (team [i].lead == null)
				{
					first = team [i];
				}
				
				if (team [i].follower == null)
				{
					last = team [i];
				}
			}
			first.follow(last);
			
			if (first.follower)
			{
				var firstX : int = first.x;
				var firstY : int = first.y;
				
				first.x = first.lead.x;
				first.y = first.lead.y;
				
				last.x = last.lead.x;
				last.y = last.lead.y;
				
				first.follower.x = firstX;
				first.follower.y = firstY;
				
				first.follower.follow (null);
				leader = first.follower;
				if (leader is Shield)
				{
					new Sfx (Assets.SHIELD_SOUND).play(0.2);
				}
				else if (leader is Hookshot)
				{
					new Sfx (Assets.HOOKSHOT_SOUND).play(0.2);
				}
				else if (leader is Hammer)
				{
					new Sfx (Assets.HAMMER_SOUND).play(0.2);
				}
				
				
				first.follower = null;
			}
		}
		
		public function parseCollisionMap (tileMap : String, grid : Grid) : void
		{
			var ar : Array = [];
			var row : int = 0;
			var column : int = 0;
			var i : int = 0;
			
			while (i < tileMap.length)
			{
				if (tileMap.charAt(i) == ",")
				{
					column++;
					i++;
					continue;
				}
				else if (tileMap.charAt(i) == "\n")
				{
					row++;
					i++;
					column = 0;
					continue;
				}
				var tile : String = new String ();
				tile = tileMap.charAt (i);
				i++;
				while (tileMap.charAt (i) == "0" ||
						tileMap.charAt (i) == "1" ||
						tileMap.charAt (i) == "2" ||
						tileMap.charAt (i) == "3" ||
						tileMap.charAt (i) == "4" ||
						tileMap.charAt (i) == "5" ||
						tileMap.charAt (i) == "6" ||
						tileMap.charAt (i) == "7" ||
						tileMap.charAt (i) == "8" ||
						tileMap.charAt (i) == "9")
				{
					tile += tileMap.charAt (i);
					i++;
				}
				if (tile != "0")
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
			var i : int = 0;
			
			while (i < tileMap.length)
			{
				if (tileMap.charAt(i) == ",")
				{
					column++;
					i++;
					continue;
				}
				else if (tileMap.charAt(i) == "\n")
				{
					row++;
					i++;
					column = 0;
					continue;
				}
				var tile : String = new String ();
				tile = tileMap.charAt (i);
				i++;
				while (tileMap.charAt (i) == "0" ||
						tileMap.charAt (i) == "1" ||
						tileMap.charAt (i) == "2" ||
						tileMap.charAt (i) == "3" ||
						tileMap.charAt (i) == "4" ||
						tileMap.charAt (i) == "5" ||
						tileMap.charAt (i) == "6" ||
						tileMap.charAt (i) == "7" ||
						tileMap.charAt (i) == "8" ||
						tileMap.charAt (i) == "9")
				{
					tile += tileMap.charAt (i);
					i++;
				}
				if (tile != "0")
				{
					tm.setTile(column, row, parseInt(tile) - 1);
				}
			}
		}
		
		private function loadMap (map : TmxLoader) : void
		{
			for each (var obj : Object in arObjects)
			{
				loadObjects (obj.type, obj.id, map, obj.layer);
			}
		}
		
		private function loadObjects (cl : Class, id : String, map : TmxLoader, layer : String) : void
		{
			var object : Entity;
			for each (var objData : Object in map.getObject ("objects", id))
			{
				object = new cl ();
				(object as cl).setup (objData);
				add (object);
			}
		}
	}
}