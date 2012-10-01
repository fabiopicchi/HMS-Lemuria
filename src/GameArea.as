package  
{
	import Animated_Scenery.Leak;
	import Animated_Scenery.Siren;
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	import config.TmxLoader;
	import flash.geom.Point;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import interactables.BreakBlock;
	import interactables.Door;
	import interactables.EndingTrigger;
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
	import UI.ConversationTrigger;
	import UI.DialogBox;
	
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
		private static var room : Entity = new Entity (0, 0);
		private static var dialogBox : DialogBox;
		private static var tmxMap : TmxLoader;
		
		static public var stage : Class;
		static public var map : Class;
		static public var water : Class;
		static public var walls : Class;
		static public var song : Class;
		static public var arRobots : Array;
		
		static public var bReseting : Boolean = false;
		private static var bGameOver : Boolean = false;
		private static var paused : Boolean = false;
		private static var bHowToPlay : Boolean = false;
		private static var bIntro : Boolean = false;
		
		private static var music : Sfx;
		private static var pauseScreen : Entity = new Entity (0, 0, new Image (Assets.PAUSE));
		private var noKey : Entity = new Entity (0, 0, new Image (Assets.NO_KEY));
		private var keyGet : Entity = new Entity (0, 0, new Image (Assets.KEY_GET));
		private static var pauseCursor : Entity = new Entity (0, 0, new Image (Assets.SELECTION));
		private static var pauseOption : int = 0;
		private static var howToPlayScreen : Entity = new Entity (0, 0, new Image (Assets.HOW_TO_PLAY));
		private static var introScreen : Entity = new Entity (0, 0, Image.createRect (FP.width, FP.height, 0x000000));
		private static var introText : Text = new Text ("");
		private static var arTextsIntro : Array = ["-Mayday! The HMS Lemuria is sinking! Abandon ship, all passengers and crew to the escape pods!",
													"-Sir! What about the worker robots?",
													"-Leave them, the passengers have top priority! We can make more later!"];
		private static var textInDisplay : String = "";
		private static var charIndex : int = 0;
		private static var timeShowing : int = 3;
		
		private const OBJECT_LAYER : String = "objects";
		private var arObjects : Array = [ { type : BreakBlock, id : "breakable_block", layer : OBJECT_LAYER },
										{type : PushBlock, id : "movable_block", layer : OBJECT_LAYER },
										{type : Lever, id : "lever", layer : OBJECT_LAYER },
										{type : Key, id : "key", layer : OBJECT_LAYER },
										{type : Gear, id : "gear", layer : OBJECT_LAYER },
										{type : Steam, id : "steam", layer : OBJECT_LAYER },
										{type : TouchingDoor, id : "door", layer : OBJECT_LAYER },
										{type : Door, id : "finaldoor", layer : OBJECT_LAYER },
										{type : ConversationTrigger, id : "trigger", layer : OBJECT_LAYER },
										{type : EndingTrigger, id : "end", layer : OBJECT_LAYER },
										{type : Leak, id : "leak", layer : OBJECT_LAYER },
										{type : Siren, id : "siren", layer : OBJECT_LAYER }];
		
		public function GameArea(stage : Class, map : Class, water : Class, walls : Class, song : Class, arRobots : Array, bFromMenu : Boolean = false) 
		{
			Robot.keyCount = 0;
			music = new Sfx (song);
			
			bReseting = false;
			bGameOver = false;
			paused = false;
			bHowToPlay = false;
			charIndex = 0;
			
			introScreen.addGraphic (introText);
			introText.x = 90;
			introText.y = 400;
			introText.wordWrap = true;
			introText.width = 460;
			
			GameArea.arRobots = arRobots;
			GameArea.stage = stage;
			GameArea.map = map;
			GameArea.water = water;
			GameArea.walls = walls;
			GameArea.song = song;
			
			tmxMap = new TmxLoader (new stage ());
			room = new Entity (0, 0);
			
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
			
			add (keyGet);
			add (noKey);
			
			dialogBox = new DialogBox ();
			add (dialogBox);
			dialogBox.visible = false;
			if (bFromMenu)
			{
				add(howToPlayScreen);
				bHowToPlay = true;
			}
			else
			{
				music.loop();
			}
		}
		
		override public function update():void 
		{
			if (!bGameOver && !bReseting && !paused && !bHowToPlay && !bIntro)
			{
				if (Input.pressed("PAUSE"))
				{
					paused = true;
					add (pauseScreen);
					add (pauseCursor);
					pauseScreen.x = FP.camera.x;
					pauseScreen.y = FP.camera.y;
					pauseCursor.x = FP.camera.x + 232;
					pauseCursor.y = FP.camera.y + 255;
					pauseOption = 0;
					return;
				}
				
				if (Input.pressed("SWAP") && !((leader.state & Robot.ACTION) == Robot.ACTION))
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
						Game.screenTransition (2, 0x000000, function () : void
						{
							FP.world = new GameArea (Assets.stage2, Assets.map2, Assets.water2, Assets.walls2, Assets.MAIN_SONG, ar);
						}, null, true);
					}
					else
					{
						music.stop();
						Game.screenTransition (2, 0x000000, function () : void
						{
							FP.world = new GameArea (Assets.stage3, Assets.map3, Assets.water3, Assets.walls3, Assets.ENDING_SONG, ar);
						}, null, true);
					}
				}
				
				FP.camera.x = leader.x + leader.halfWidth - FP.halfWidth;
				FP.camera.y = leader.y + leader.halfHeight - FP.halfHeight;
				
				FP.camera.x = FP.clamp(FP.camera.x, 0, tmxMap.getLayerWidth("ground") * 32 - FP.width);
				FP.camera.y = FP.clamp(FP.camera.y, 0, tmxMap.getLayerHeight("ground") * 32 - FP.height);
				
				keyGet.x = FP.camera.x + 8;
				keyGet.y = FP.camera.y + 8;
				
				noKey.x = FP.camera.x + 8;
				noKey.y = FP.camera.y + 8;
				
				if (Robot.keyCount)
				{
					keyGet.visible = true;
					noKey.visible = false;
				}
				else
				{
					keyGet.visible = false;
					noKey.visible = true;
				}
				
				super.update();
			}
			else if (paused)
			{
				if (Input.pressed("PAUSE"))
				{
					paused = false;
					remove (pauseScreen);
					remove (pauseCursor);
					return;
				}
				
				if (Input.pressed("UP"))
				{
					if (pauseOption == 0) 
					{
						pauseCursor.y = FP.camera.y + 305;
						pauseOption = 2;
					}
					else if (pauseOption == 1)
					{
						pauseCursor.y = FP.camera.y + 247;
						pauseOption = 0;
					}
					else if (pauseOption == 2)
					{
						pauseCursor.y = FP.camera.y + 275;
						pauseOption = 1;
					}
				}
				if (Input.pressed("DOWN"))
				{
					if (pauseOption == 0) 
					{
						pauseCursor.y = FP.camera.y + 275;
						pauseOption = 1;
					}
					else if (pauseOption == 1)
					{
						pauseCursor.y = FP.camera.y + 305;
						pauseOption = 2;
					}
					else if (pauseOption == 2)
					{
						pauseCursor.y = FP.camera.y + 247;
						pauseOption = 0;
					}
				}
				
				if (Input.pressed ("SELECTION"))
				{
					switch (pauseOption)
					{
						case 0:
							paused = false;
							remove (pauseScreen);
							remove (pauseCursor);
							return;
							break;
						case 1:
							remove (pauseScreen);
							remove (pauseCursor);
							paused = false;
							bGameOver = true;
							Game.screenTransition (2, 0x000000, function () : void
							{
								GameArea.resetStage ();
							}, null, true);
							break;
						case 2:
							remove (pauseScreen);
							remove (pauseCursor);
							music.stop();
							paused = false;
							bGameOver = true;
							Game.screenTransition (2, 0x000000, function () : void
							{
								FP.world = new MainMenu ();
							}, null, true);
							break;
					}
				}	
			}
			else if (bHowToPlay)
			{
				if (Input.pressed("SELECTION") || Input.pressed("PAUSE") || Input.pressed("ACTION"))
				{
					Game.screenTransition (2, 0x000000, function () : void
					{
						bHowToPlay = false;
						remove (howToPlayScreen);
						bIntro = true;
						music.loop();
						add (introScreen);
						textInDisplay = arTextsIntro[0];
					}, null, true);
				}
			}
			else if (bIntro)
			{
				if (charIndex < textInDisplay.length)
				{
					introText.text = textInDisplay.substring (0, ++charIndex);
				}
				else
				{
					timer += FP.elapsed;
					if (timer > timeShowing)
					{
						timer = 0;
						if (arTextsIntro.indexOf(textInDisplay) < arTextsIntro.length - 1)
						{
							textInDisplay = arTextsIntro[arTextsIntro.indexOf(textInDisplay) + 1];
							charIndex = 0;
						}
						else
						{
							Game.screenTransition (2, 0x000000, function () : void
							{
								bIntro = false;
								remove (introScreen);
							}, null, true);
						}
					}
				}
			}
		}
		
		override public function render():void 
		{
			super.render();
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
		
		public static function line () : void
		{
			var lineSpeed : Number = Robot.VELOCITY * 3;
			
			var second : Robot;
			var third : Robot;
			var teamSize : int = 1;
			
			var moveX : int;
			var moveY : int;
			var moveLength : Number = leader.width / 2;
			
			if (leader.direction == 0)
			{
				moveX = 1;
				moveY = 0;
			}
			else if (leader.direction == 1)
			{
				moveX = 0;
				moveY = 1;
			}
			else if (leader.direction == 2)
			{
				moveX = -1;
				moveY = 0;
			}
			else
			{
				moveX = 0;
				moveY = -1;
			}
			
			if (leader.follower)
			{
				second = leader.follower;
				second.targetX = leader.x - moveX * moveLength;
				second.targetY = leader.y - moveY * moveLength;
				if (second.follower)
				{
					third = second.follower;
					third.targetX = leader.x - moveX * moveLength * 2;
					third.targetY = leader.y - moveY * moveLength * 2;
				}
			}
		}
		
		public static function enterFormation () : void
		{
			for each (var r : Robot in _team)
			{
				if (leader != r)
				{
					r.switchState (Robot.FORMATION);
				}
			}
		}
		
		public static function cluster () : void
		{
			var clusterSpeed : Number = Robot.VELOCITY * 3;
			
			var second : Robot;
			var third : Robot;
			var teamSize : int = 1;
			
			if (leader.follower)
			{
				teamSize++;
				second = leader.follower;
				if (second.follower)
				{
					teamSize++;
					third = second.follower;
				}
			}
			
			if (teamSize == 3)
			{
				second.vx = 0;
				second.vy = 0;
				
				third.vx = 0;
				third.vy = 0;
				if (leader.direction == 0)
				{
					second.targetX = leader.x - leader.halfWidth;
					second.targetY = leader.y - leader.halfHeight;
					third.targetX = leader.x - leader.halfWidth;
					third.targetY = leader.y + leader.halfHeight;
				}
				else if (leader.direction == 1)
				{
					second.targetX = leader.x + leader.halfWidth;
					second.targetY = leader.y - leader.halfHeight;
					third.targetX = leader.x - leader.halfWidth;
					third.targetY = leader.y - leader.halfHeight;
				}
				else if (leader.direction == 2)
				{
					second.targetX = leader.x + leader.halfWidth;
					second.targetY = leader.y + leader.halfHeight;
					third.targetX = leader.x + leader.halfWidth;
					third.targetY = leader.y - leader.halfHeight;
				}
				else
				{
					second.targetX = leader.x - leader.halfWidth;
					second.targetY = leader.y + leader.halfHeight;
					third.targetX = leader.x + leader.halfWidth;
					third.targetY = leader.y + leader.halfHeight;
				}
				
			}
			else if (teamSize == 2)
			{
				second.vx = 0;
				second.vy = 0;
				
				if (leader.direction == 0)
				{
					second.targetX = leader.x - leader.halfWidth;
					second.targetY = leader.y;
				}
				else if (leader.direction == 1)
				{
					second.targetX = leader.x;
					second.targetY = leader.y - leader.halfHeight;
				}
				else if (leader.direction == 2)
				{
					second.targetX = leader.x + leader.halfWidth;
					second.targetY = leader.y;
				}
				else
				{
					second.targetX = leader.x;
					second.targetY = leader.y + leader.halfHeight;
				}
			}
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
				r.vx = 0;
				r.vy = 0;
			}
		}
		
		public static function isAlive (c : Class) : Boolean
		{
			for each (var r : Robot in _team)
			{
				if (r is c)
					return true;
			}
			return false;
		}
		
		public static function leaveFormation () : void
		{
			for each (var r : Robot in _team)
			{
				if (leader != r)
				{
					r.switchState (Robot.MOVING);
				}
			}
		}
		
		public static function abandonLeader () : void
		{
			_team.shift();
		}
		
		public static function showTriggeredDialog (t : ConversationTrigger) : void
		{
			if (!t.bTriggered && ((!t.bHammer && !isAlive(Hammer)) || (t.bHammer && isAlive(Hammer))) &&
				((!t.bHookshot && !isAlive(Hookshot)) || (t.bHookshot && isAlive(Hookshot))) && 
				((!t.bShield && !isAlive(Shield))|| (t.bShield && isAlive(Shield))))
			{
				dialogBox.showConversation (t.arConversation);
				t.bTriggered = true;
			}
		}
		
		public static function showDialog (t : Array) : void
		{
			dialogBox.showConversation (t);
		}
		
		public static function resetStage () : void
		{
			music.stop();
			Game.screenTransition (2, 0x000000, function () : void
			{
				FP.world = new GameArea (GameArea.stage, GameArea.map, GameArea.water, GameArea.walls, GameArea.song, GameArea.arRobots);
			}, null, true);
		}
		
		public static function showEnding () : void
		{
			music.stop();
			Game.screenTransition (2, 0xffffff, function () : void
			{
				FP.world.addGraphic (new Image (Assets.ENDING), 0, 0, 0);
				bGameOver = true;
				TweenLite.delayedCall (5, function () : void {
					Game.screenTransition (2, 0x000000, function () : void
					{
						music.stop();
						FP.world = new MainMenu ();
					}, null, true);
				});
			}, null, true);
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