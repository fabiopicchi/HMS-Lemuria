package  
{
	/**
	 * ...
	 * @author Arthur Vieira
	 */
	public final class Assets 
	{
		
		[Embed(source = '../assets/breakable_block.png')] public static const BREAKABLE_BLOCK:Class;
		[Embed(source = '../assets/credits.jpg')] public static const CREDITS:Class;
		[Embed(source = '../assets/door.png')] public static const DOOR:Class;
		[Embed(source = '../assets/ending.jpg')] public static const ENDING:Class;
		[Embed(source = '../assets/gear.png')] public static const GEAR:Class;
		[Embed(source = '../assets/ss_hammer.png')] public static const HAMMER:Class;
		[Embed(source = '../assets/hook.png')] public static const HOOK:Class;
		[Embed(source = '../assets/ss_hookshot.png')] public static const HOOKSHOT:Class;
		[Embed(source = '../assets/key.png')] public static const KEY:Class;	
		[Embed(source = '../assets/lever.png')] public static const LEVER:Class;		
		[Embed(source = '../assets/link_h.png')] public static const LINK_H:Class;		
		[Embed(source = '../assets/link_v.png')] public static const LINK_V:Class;		
		[Embed(source = '../assets/movable_block.png')] public static const MOVABLE_BLOCK:Class;		
		[Embed(source = '../assets/selection.png')] public static const SELECTION:Class;		
		[Embed(source = '../assets/ss_shield.png')] public static const SHIELD:Class;		
		[Embed(source = '../assets/steam.png')] public static const STEAM:Class;
		[Embed(source = '../assets/steamParticle.png')] public static const STEAM_PARTICLE:Class;
		[Embed(source = '../assets/tileset.png')] public static const TILESET:Class;
		[Embed(source = '../assets/title.png')] public static const TITLE:Class;
		[Embed(source = '../assets/touchingDoor.png')] public static const TOUNCHING_DOOR:Class;
		[Embed(source = '../assets/port-hammer.png')] public static const PORT_HAMMER:Class;
		[Embed(source = '../assets/port-shield.png')] public static const PORT_SHIELD:Class;
		[Embed(source = '../assets/port-hookshot.png')] public static const PORT_HOOKSHOT:Class;
		[Embed(source = '../assets/siren.png')] public static const SIREN:Class;
		[Embed(source = '../assets/leak.png')] public static const LEAK:Class;
		[Embed(source = '../assets/pause.png')] public static const PAUSE:Class;
		[Embed(source = '../assets/howtoplay.png')] public static const HOW_TO_PLAY:Class;
		[Embed(source = "../assets/hud-chave_noget.png")] public static const NO_KEY:Class;
		[Embed(source="../assets/hud-chave_yesget.png")] public static const KEY_GET:Class;
		
		
		[Embed(source = '../assets/ending.mp3')] public static const ENDING_SONG:Class;
		[Embed(source = '../assets/hammer.mp3')] public static const HAMMER_SOUND:Class;
		[Embed(source = '../assets/hammerTime.mp3')] public static const HAMMERTIME_SOUND:Class;
		[Embed(source = '../assets/hookshot.mp3')] public static const HOOKSHOT_SOUND:Class;
		[Embed(source = '../assets/hookshotTime.mp3')] public static const HOOKSHOTTIME_SOUND:Class;
		[Embed(source = '../assets/menu.mp3')] public static const MENU_SONG:Class;
		[Embed(source = '../assets/movable_block.mp3')] public static const MOVABLE_BLOCK_SOUND:Class;
		[Embed(source = '../assets/shield.mp3')] public static const SHIELD_SOUND:Class;
		[Embed(source = '../assets/shieldTime.mp3')] public static const SHIELDTIME_SOUND:Class;
		[Embed(source = '../assets/soundtrack.mp3')] public static const MAIN_SONG:Class;
		[Embed(source = '../assets/steam.mp3')] public static const STEAM_SOUND:Class;
		
		[Embed(source = '../maps/1.tmx', mimeType = 'application/octet-stream')]public static const stage1:Class;
		[Embed(source = '../maps/2.tmx', mimeType = 'application/octet-stream')]public static const stage2:Class;
		[Embed(source = '../maps/3.tmx', mimeType = 'application/octet-stream')]public static const stage3:Class;
		[Embed(source = '../maps/walls1.txt', mimeType = 'application/octet-stream')]public static const walls1:Class;
		[Embed(source = '../maps/water1.txt', mimeType = 'application/octet-stream')]public static const water1:Class;
		[Embed(source = '../maps/ground1.txt', mimeType = 'application/octet-stream')]public static const map1:Class;
		[Embed(source = '../maps/walls2.txt', mimeType = 'application/octet-stream')]public static const walls2:Class;
		[Embed(source = '../maps/water2.txt', mimeType = 'application/octet-stream')]public static const water2:Class;
		[Embed(source = '../maps/ground2.txt', mimeType = 'application/octet-stream')]public static const map2:Class;
		[Embed(source = '../maps/walls3.txt', mimeType = 'application/octet-stream')]public static const walls3:Class;
		[Embed(source = '../maps/water3.txt', mimeType = 'application/octet-stream')]public static const water3:Class;
		[Embed(source = '../maps/ground3.txt', mimeType = 'application/octet-stream')]public static const map3:Class;
		
		[Embed(source = '../maps/texts.xml', mimeType = 'application/octet-stream')]private static const TEXTS:Class;
		public static const XML_CONVERSATIONS : XML = new XML (new TEXTS());
		
		public function Assets() 
		{
			
		}
		
	}

}