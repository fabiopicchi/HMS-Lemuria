package  
{
	import flash.events.Event;
	/**
	 * ...
	 * @author 
	 */
	public class MapReadEvent extends Event
	{
		public var map : String;
		public static const COMPLETE : String = "complete";
		public function MapReadEvent (type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super (type, bubbles, cancelable);
		}
		
	}

}