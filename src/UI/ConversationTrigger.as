package UI 
{
	import collision.CollidableEntity;
	import com.adobe.serialization.json.JSON;
	import net.flashpunk.Entity;
	/**
	 * ...
	 * @author 
	 */
	public class ConversationTrigger extends CollidableEntity
	{
		public var bTriggered : Boolean = false;
		private var _arConversation : Array = [];
		private var _bHammer : Boolean = false;
		private var _bHookshot : Boolean = false;
		private var _bShield : Boolean = false;
		
		public function ConversationTrigger() 
		{
			this.type = "trigger";
		}
		
		public function setup (obj : Object) : void
		{
			this.x = obj.x;
			this.y = obj.y;
			this.width = obj.width;
			this.height = obj.height;
			
			for each (var objGroup : XML in Assets.XML_CONVERSATIONS.child("conversation"))
			{
				if (objGroup.@id == obj.id)
				{
					if (objGroup.@hammer == "1") _bHammer = true;
					if (objGroup.@hookshot == "1") _bHookshot = true;
					if (objGroup.@shield == "1") _bShield = true;
					
					for each (var objText : XML in objGroup.child("text"))
					{
						var text : Object = { };
						text["timeShowing"] = int (objText.@timeShowing);
						text["charId"] = int (objText.@charId);
						text["text"] = objText.toString();
						arConversation.push (text);
					}
				}
			}
		}
		
		public function get arConversation():Array 
		{
			return _arConversation;
		}
		
		public function get bHammer():Boolean 
		{
			return _bHammer;
		}
		
		public function get bHookshot():Boolean 
		{
			return _bHookshot;
		}
		
		public function get bShield():Boolean 
		{
			return _bShield;
		}
	}

}