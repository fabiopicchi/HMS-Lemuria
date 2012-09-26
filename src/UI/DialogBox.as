package UI 
{
	import net.flashpunk.Entity;
	import net.flashpunk.FP;
	import net.flashpunk.graphics.Graphiclist;
	import net.flashpunk.graphics.Image;
	import net.flashpunk.graphics.Text;
	/**
	 * ...
	 * @author 
	 */
	public class DialogBox extends Entity
	{
		private static const hammerImage : Image = new Image (Assets.PORT_HAMMER);
		private static const shieldImage : Image = new Image (Assets.PORT_SHIELD);
		private static const hookShotImage : Image = new Image (Assets.PORT_HOOKSHOT);
		private var avatar : Image;
		private var textBox : Text = new Text ("", 86, 8, {size: 14});
		
		private var textToShow : Array = [];
		private var textIndex : int = 0;
		
		private var bShowingText : Boolean = false;
		private var textInDisplay : String = "";
		private var charIndex : int = 0;
		private var timeShowing : Number = 0;
		private var timer : Number = 0;
		
		
		public function DialogBox() 
		{
			addGraphic(Image.createRect (539, 96, 0x000000, 0.5));
			addGraphic(textBox);
			
			textBox.wordWrap = true;
			textBox.width = 445;
			//textBox.alpha = 0.5;
			
			hammerImage.x = 8;
			hammerImage.y = 8;
			//hammerImage.alpha = 0.5;
			
			shieldImage.x = 8;
			shieldImage.y = 8;
			//shieldImage.alpha = 0.5;
			
			hookShotImage.x = 8;
			hookShotImage.y = 8;
			//hookShotImage.alpha = 0.5;
		}
		
		override public function update():void 
		{
			super.update();
			this.x = FP.camera.x + 47;
			this.y = FP.camera.y + 363;
			
			if (bShowingText)
			{
				if (charIndex < textInDisplay.length)
				{
					textBox.text = textInDisplay.substring (0, ++charIndex);
				}
				else
				{
					timer += FP.elapsed;
					if (timer > timeShowing)
					{
						bShowingText = false;
						textInDisplay = "";
						charIndex = 0;
						timer = 0;
						(graphic as Graphiclist).remove (avatar);
						if (textIndex < textToShow.length)
						{
							showText(textToShow[textIndex++]);
						}
						else
						{
							this.visible = false;
						}
					}
				}
			}
		}
		
		public function showConversation (texts : Array) : void
		{
			textToShow = texts;
			textIndex = 0;
			showText (textToShow[textIndex++]);
		}
		
		private function showText (text : Object):void
		{
			bShowingText = true;
			textInDisplay = text.text;
			charIndex = 0;
			timer = 0;
			this.visible = true;
			this.timeShowing = text.timeShowing;
			switch (text.charId)
			{
				case 1:
					avatar = hammerImage;
					break;
				case 2:
					avatar = shieldImage;
					break;
				case 3:
					avatar = hookShotImage;
					break;
			}
			addGraphic (avatar);
		}
	}

}