package traps 
{
	import collision.CollidableEntity;
	import net.flashpunk.Entity;
	/**
	 * ...
	 * @author 
	 */
	public class SteamHitBox extends CollidableEntity
	{
		public var steamHandle : Steam;
		
		public function SteamHitBox(s : Steam) 
		{
			steamHandle = s;
			type = "steam";
		}
		
	}

}