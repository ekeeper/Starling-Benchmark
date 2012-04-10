package 
{
	import flash.desktop.NativeApplication;
	import flash.system.Capabilities;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	import scenes.ClassicBenchmarkScene;
	import scenes.Scene;
	
	import starling.core.Starling;
	import starling.display.BlendMode;
	import starling.display.Button;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.text.TextField;
	import starling.textures.Texture;
	import starling.utils.HAlign;
	import starling.utils.VAlign;

    public class Game extends Sprite
    {
		public static var sender:dataSender;
		public static var device:Object = new Object();
		
		private var mInfoText:TextField;
		private var mMainMenu:Sprite;
		private var mCurrentScene:Scene;
		
        public function Game()
        {
//			Starling.current.stage.stageWidth  = Number(Constants.Device.screenWidth);
//			Starling.current.stage.stageHeight = Number(Constants.Device.screenHeight);
			
			addEventListener(Event.ADDED_TO_STAGE, Init);
		}
		
		private function Init( e:Event = null ):void
		{
			removeEventListener( Event.ADDED_TO_STAGE, Init );
			
			sender = new dataSender();
			
			mMainMenu = new Sprite();
			addChild(mMainMenu);
			
			var nativeRes:String = Constants.Device.screenWidth+"x"+Constants.Device.screenHeight;
			
			var buttons:Array = [
				["Classic: Images, "+nativeRes+", 30fps",     "classicBenchmark1"],
				["Classic: MovieClips, "+nativeRes+", 30fps", "classicBenchmark2"],
				["Classic: Images, "+nativeRes+", 60fps",     "classicBenchmark3"],
				["Classic: MovieClips, "+nativeRes+", 60fps", "classicBenchmark4"],
				["Exit", "Exit"]
			];
			
			var count:int = 0;
			var button:Button;
			var buttonsContainer:Sprite = new Sprite();
			
			for each (var buttonToCreate:Array in buttons)
			{
				button = createButton(buttonToCreate[0], buttonToCreate[1], 0, 42 * count++, "Button");				
				buttonsContainer.addChild(button);

				button.x += button.pivotX;
				button.y += button.pivotY;				
			}
			
			mMainMenu.addChild(buttonsContainer);
			buttonsContainer.pivotX = buttonsContainer.width >> 1;
			buttonsContainer.pivotY = buttonsContainer.height >> 1;
			buttonsContainer.x = Constants.CenterX;
			buttonsContainer.y = Constants.CenterY;
			
			addEventListener(Scene.CLOSING, onSceneClosing);
			
            // show information about rendering method (hardware/software)
            var deviceInfo:String = "Driver: " + Starling.context.driverInfo + 
				"\nScreen: " + Constants.Device.screenWidth+"x"+Constants.Device.screenHeight +
				" ScreenDPI: " + Constants.Device.dpi +
				"\nDevice: " +
					Constants.Device.manufacturer + ", " +
					Constants.Device.model + ", " +
					Constants.Device.os + ", " +
					Constants.Device.osVersion + ", " +
				"\nMAC: " + Constants.Device.mac;

			mInfoText = createTF(3, 3, Constants.Device.screenWidth, 128, deviceInfo, 0xffffff, 16);			
			mMainMenu.addChild(mInfoText);
        }
		
		private function createButton(title:String, callback:String, x:Number, y:Number, texture:String, blendMode:String = BlendMode.NORMAL):Button
		{
			var buttonTexture:Texture = Assets.getTexture(texture);
			var button:Button = new Button(buttonTexture, title);
			
			if (title != "") {
				button.text = title;
				button.fontName = "Ubuntu";
				button.fontSize = 16;
			}
			
			button.pivotX = button.width >> 1;
			button.pivotY = button.height >> 1;
			button.x = x;
			button.y = y;
			button.name = callback;
			button.addEventListener(Event.TRIGGERED, onButtonTriggered);
			button.blendMode = blendMode;
			
			return button;
		}
		
		private function createTF(x:Number, y:Number, width:Number, height:Number, text:String = "", color:int = 0xfaf3e0, size:int = 14):TextField
		{
			var TF:TextField = new TextField(width, height, text, "Ubuntu", size);
			TF.color = color;
			TF.x = x;
			TF.y = y;
			TF.vAlign = VAlign.TOP;
			TF.hAlign = HAlign.LEFT;
			TF.touchable = false;
			
			return TF;
		}

		private function onButtonTriggered(event:Event):void
		{
			var button:Button = event.target as Button;
			this[button.name].call(this, event);
		}
		
		private function Exit(event:Event):void {
			NativeApplication.nativeApplication.exit(0);			
		}
		
		private function onSceneClosing(event:Event):void
		{
			mCurrentScene.removeFromParent(true);
			mCurrentScene = null;
			
			Starling.current.stop();
			Starling.current.nativeStage.frameRate = Constants.FPS;
			Starling.current.start();
			
			mMainMenu.visible = true;
		}
		
		private function showScene(name:String, options:Object):void
		{
			if (mCurrentScene) return;
			
			var sceneClass:Class = getDefinitionByName(name) as Class;
			mCurrentScene = new sceneClass(options) as Scene;
			mMainMenu.visible = false;
			addChild(mCurrentScene);
		}
		
		// BENCHMARKS
		
		private function classicBenchmark1(event:Event):void {
			var options:Object = {
				frameRate:30, 
				type:"Images"
			};
			showScene(getQualifiedClassName(ClassicBenchmarkScene), options);
		}
		
		private function classicBenchmark2(event:Event):void {
			var options:Object = {
				frameRate:30, 
				type:"MovieClips"
			};
			showScene(getQualifiedClassName(ClassicBenchmarkScene), options);
		}
		
		private function classicBenchmark3(event:Event):void {
			var options:Object = {
				frameRate:60, 
				type:"Images"
			};
			showScene(getQualifiedClassName(ClassicBenchmarkScene), options);
		}
		
		private function classicBenchmark4(event:Event):void {
			var options:Object = {
				frameRate:60, 
				type:"MovieClips"
			};
			showScene(getQualifiedClassName(ClassicBenchmarkScene), options);
		}		
	}
}