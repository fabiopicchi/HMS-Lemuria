package UI 
{
	import net.flashpunk.Entity;
	/**
	 * ...
	 * @author 
	 */
	public class ConversationTrigger extends Entity
	{
		public var bTriggered : Boolean = false;
		public var arConversation : Array = [];
		
		public function ConversationTrigger() 
		{
			this.type = "trigger";
		}
		
		public function setup (obj : Object) : void
		{
			this.x = obj.x;
			this.y = obj.y;
			
		}
	}

}