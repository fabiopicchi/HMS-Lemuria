package  
{
	import com.greensock.TweenMax;
	import config.TmxLoader;
	import flash.geom.Point;
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
		private static var _team : Array = [];
		
		public static var waterMap : Grid;
		public static var wallsMap : Grid;
		private var room : Entity = new Entity (0, 0);
		private var dialogBox : Entity = new Entity (180, 380);
		private var tmxMap : TmxLoader;
		
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
			//music.loop();
			
			GameArea.arRobots = arRobots;
			GameArea.stage = stage;
			GameArea.map = map;
			GameArea.water = water;
			GameArea.walls = walls;
			GameArea.song = song;
			
			tmxMap = new TmxLoader (new stage ());
			
			//ground, water and walls separated for layering purposes
			
			//add ground
			var tileMap : Tilemap = new Tilemap (Assets.TILESET, tmxMap.getLayerWidth("ground") * 32, tmxMap.getLayerHeight("ground") * 32, 32, 32);
			parseTileMap (new map (), tileMap);
			room.addGraphic(tileMap);
			
			//add water
			tileMap = new Tilemap (Assets.TILESET, tmxMap.getLayerWidth("water") * 32, tmxMap.getLayerHeight("water") * 32, 32, 32);
			parseTileMap (new water (), tileMap);
			room.addGraphic(tileMap);
			
			//add walls
			tileMap = new Tilemap (Assets.TILESET, tmxMap.getLayerWidth("walls") * 32, tmxMap.getLayerHeight("walls") * 32, 32, 32);
			parseTileMap (new walls (), tileMap);
			room.addGraphic(tileMap);
			add(room);
			
			//creates water collision mask
			waterMap = new Grid (tmxMap.getLayerWidth("water") * 32, tmxMap.getLayerHeight("water") * 32, 32, 32);
			parseCollisionMap (new water (), waterMap);
			
			//creates walls collision mask
			wallsMap = new Grid (tmxMap.getLayerWidth("walls") * 32, tmxMap.getLayerHeight("walls") * 32, 32, 32);
			parseCollisionMap (new walls (), wallsMap);
			
			//add robots
			_team = [];
			for (var i : int = 0; i < arRobots.length; i++)
			{
				var cl : Class = arRobots[i];
				_team.unshift (new cl (0));
			}
			
			//place the robots according to the spawnpoint
			var spawnPoint : Object = tmxMap.getObject("objects", "spawn")[0];
			for (i = 0; i < _team.length; i++)
			{
				_team[i].x = parseInt(spawnPoint.x) + 30 * i;
				_team[i].y = parseInt(spawnPoint.y);
				_team[i].direction = 2;
				add (_team[i]);
			}
			sortDepth();
			
			//loads and adds objects from tmx map
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
				for each (var r : Robot in _team)
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
			var next : Point = new Point (_team [_team.length - 1].x, _team [_team.length - 1].y);
			var current : Point = null;
			
			for (var i : int = 0; i < _team.length; i++)
			{
				current = new Point (_team[i].x, _team[i].y);
				
				_team[i].x = next.x;
				_team[i].y = next.y;
				
				next = current;
			}
			
			_team.push(_team.shift());
			
			sortDepth();
			
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
		}
		
		private function sortDepth () : void
		{
			for (var i : int = _team.length - 1; i >= 0; i--)
			{
				remove(_team[i]);
				add(_team[i]);
			}
		}
		
		public static function get leader () : Robot
		{
			return _team[0];
		}
		
		public static function get last () : Robot
		{
			return _team[_team.length - 1];
		}
		
		public static function getMyLeader (me : Robot) : Robot
		{
			var index : int = _team.indexOf(me);
			if (index > 0)
			{
				return _team [index - 1];
			}
			else
			{
				return null;
			}
		}
		
		public static function getMyFollower (me : Robot) : Robot
		{
			var index : int = _team.indexOf(me);
			if (index < (_team.length - 1))
			{
				return _team [index + 1];
			}
			else
			{
				return null;
			}
		}
		
		//Robot formations
		public static function collapse () : void
		{
			for each (var r : Robot in _team)
			{
				r.x = leader.x;
				r.y = leader.y;
			}
		}
		
		public static function lookAtFixedDirection (dir : int) : void
		{
			for each (var r : Robot in _team)
			{
				r.direction = dir;
			}
		}
		
		public static function leaveFormation () : void
		{
			for each (var r : Robot in _team)
			{
				r.hasTarget = false;
			}
		}
		
		public static function abandonLeader () : void
		{
			_team.shift();
		}
		
		private function parseCollisionMap (tileMap : String, grid : Grid) : void
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
		
		private function parseTileMap (tileMap : String, tm : Tilemap) : void
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