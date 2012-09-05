package  config
{
	import com.adobe.serialization.json.JSON;
	import flash.display.Sprite;
	import flash.events.Event;
	/**
	 * ...
	 * @author Fabio e Helo
	 */
	public class TmxLoader
	{
		private var tmxFile : XML;
		private var outPut : String = '';
		private var i : uint = 0;
		private var j : uint = 0;
		private var layerWidth : uint = 0;
		private var layerHeight : uint = 0;
		private var tileData : XMLList;
		
		public function TmxLoader(xmlObject : String) 
		{
			tmxFile = new XML (xmlObject);
		}
		
		public function get tileWidth () : uint
		{
			return tmxFile.child("tileset").@tilewidth;
		}
		
		public function get tileHeight () :uint
		{
			return tmxFile.child("tileset").@tileheight;
		}
		
		public function getLayerWidth (layer : String) : uint
		{
			for each (var obj : XML in tmxFile.child("layer"))
			{
				if (obj.@name == layer)
					return obj.@width;
			}
			
			return null;
		}
		
		public function getLayerHeight (layer : String) : uint
		{
			for each (var obj : XML in tmxFile.child("layer"))
			{
				if (obj.@name == layer)
					return obj.@height;
			}
			
			return null;
		}
		
		public function getCollisionMap (layer : String) : void
		{
			this.outPut = new String ();
			
			for each (var obj : XML in tmxFile.child("layer"))
			{
				if (obj.@name == layer)
				{
					this.layerWidth = getLayerWidth (layer);
					this.layerHeight = getLayerHeight (layer);
					this.tileData = obj.child ("data");
					this.i = 0;
					
					WriteToFile.getInstance().addEventListener (Event.ENTER_FRAME, readLine);
					break;
				}
			}
		}
		
		private function readLine(e:Event):void 
		{
			if (this.i < this.layerHeight)
			{
				for (var j : uint = 0; j < this.layerWidth; j++)
				{
					outPut += (tileData.child("tile")[(i * this.layerWidth) + j].@gid);
					if (j + 1 != this.layerWidth) outPut += ",";
				}
				if (i + 1 != this.layerHeight)
					outPut += "\n";
				this.i++;
			}
			else
			{
				var evt : MapReadEvent = new MapReadEvent (MapReadEvent.COMPLETE);
				evt.map = this.outPut;
				WriteToFile.getInstance().dispatchEvent(evt);
				WriteToFile.getInstance().removeEventListener (Event.ENTER_FRAME, readLine);
			}
		}
		
		public function getObject (objectGroup : String, objectType : String) : Array
		{
			var arReturn : Array = [];
			var sObject : String;
			
			for each (var obj : XML in tmxFile.child("objectgroup"))
			{
				if (obj.@name == objectGroup)
				{
					for each (var elem : XML in obj.child("object"))
					{
						if (elem.@type == objectType)
						{
							sObject = new String ();
							sObject = "{ \"x\" : \"" + elem.@x + "\" , "+
										"\"y\" : \"" + elem.@y + "\" , "+
										"\"width\" : \"" + elem.@width + "\" , "+
										"\"height\" : \"" + elem.@height + "\"";
										
							for each (var prop : XML in elem.child("properties").child("property"))
							{
								sObject += " , \"" + prop.@name + "\" : \"" + prop.@value + "\"";
							}
							
							sObject += " }";
							arReturn.push(JSON.decode (sObject));
						}
					}
				}
			}
			return arReturn;
		}
	}

}