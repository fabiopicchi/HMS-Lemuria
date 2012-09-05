package traps 
{
	import net.flashpunk.Entity;
	/**
	 * ...
	 * @author 
	 */
	public class SteamHitBox extends Entity
	{
		public var steamHandle : Steam;
		
		public function SteamHitBox(s : Steam) 
		{
			steamHandle = s;
			type = "steam";
		}
		
	}

}