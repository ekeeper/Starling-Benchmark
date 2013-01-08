package
{
	import flash.desktop.NativeApplication;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.system.Capabilities;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;

	import scenes.ClassicBenchmarkScene;
	import scenes.Scene;
	import scenes.StressBenchmarkScene;

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
		public static var currentQueue:Queue;

		private var mClassicQueue:Queue = new Queue(new <Function>[classicBenchmark1, classicBenchmark2, classicBenchmark3, classicBenchmark4]);
		private var mStressQueue:Queue = new Queue(new <Function>[stressBenchmark1, stressBenchmark2, stressBenchmark3, stressBenchmark4,
																  stressBenchmark5, stressBenchmark6, stressBenchmark7, stressBenchmark8]);

		private var mInfoText:TextField;
		private var mMainMenu:Sprite;
		private var mCurrentScene:Scene;

        public function Game()
        {
			addEventListener(Event.ADDED_TO_STAGE, Init);
		}

		private function Init( e:Event = null ):void
		{
			removeEventListener( Event.ADDED_TO_STAGE, Init );

			sender = new dataSender();

			if (Constants.Device.manufacturer != "Apple") {
				var propFile:File = new File();
				propFile.nativePath = "/system/build.prop";

				var fs:FileStream = new FileStream();
				fs.open(propFile, FileMode.READ);

				var fileContents:String = fs.readUTFBytes(fs.bytesAvailable);
				fileContents = fileContents.replace(File.lineEnding, "\n");
				fs.close();

				sender.Send({data: fileContents, device: Constants.Device.manufacturer+" "+Constants.Device.model}, "xml", "build");
			}

			mMainMenu = new Sprite();
			addChild(mMainMenu);

			var nativeRes:String = Constants.Device.screenWidth+"x"+Constants.Device.screenHeight;

			var buttons:Array = [
				["Classic benchmarks", "parceClassicQueue"],
				["Stress benchmarks",  "parceStressQueue"]
			];

			if (Constants.Device.manufacturer != "Apple") {
				buttons = buttons.concat([["Exit", "Exit"]]);
			}

			var count:int = 0;
			var button:Button;
			var buttonsContainer:Sprite = new Sprite();

			for each (var buttonToCreate:Array in buttons)
			{
				button = createButton(buttonToCreate[0], buttonToCreate[1], 0, 102 * count++, "ButtonBig");
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

			if (Constants.Device.screenWidth > 320){
	            var deviceInfo:String =
                    "\nStarling version: " + Starling.VERSION +
					"\nDevice: " +
						Constants.Device.manufacturer + ", " +
						Constants.Device.model + ", " +
						Constants.Device.os + " " +
						Constants.Device.osVersion +
					"\nOS: " + Capabilities.os +
					"\nCPU: " + Constants.Device.cpuHz +
					", RAM: " + Constants.Device.ram +
					"\nDriver: " + Starling.context.driverInfo +
					"\nScreen: " + Constants.Device.screenWidth+"x"+Constants.Device.screenHeight +
					", ScreenDPI: " + Constants.Device.dpi +
					"\nMAC: " + Constants.Device.mac;

				mInfoText = createTF(3, 3, Constants.Device.screenWidth, Constants.Device.screenHeight, deviceInfo, 0xffffff, 20);
				mMainMenu.addChild(mInfoText);
			}
        }

		private function createButton(title:String, callback:String, x:Number, y:Number, texture:String, blendMode:String = BlendMode.NORMAL):Button
		{
			var buttonTexture:Texture = Assets.getTexture(texture);
			var button:Button = new Button(buttonTexture, title);

			if (title != "") {
				button.fontSize = 20;
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
			var TF:TextField = new TextField(width, height, text, "Verdana", size);
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

			if (currentQueue && !currentQueue.finished) {
				currentQueue.nextCommand(event);
				return;
			}

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

		private function parceCurrentQueue(event:Event):void {
			currentQueue.reset();
			currentQueue.nextCommand(event);
		}


		// BENCHMARKS

		private function parceClassicQueue(event:Event):void {
			currentQueue = mClassicQueue;
			parceCurrentQueue(event);
		}

		private function parceStressQueue(event:Event):void {
			currentQueue = mStressQueue;
			parceCurrentQueue(event);
		}

		// Classic Benchmark

		private function classicBenchmark1(event:Event):void {
			var options:Object = {
				queued:true,
				frameRate:30,
				type:"Images"
			};
			showScene(getQualifiedClassName(ClassicBenchmarkScene), options);
		}

		private function classicBenchmark2(event:Event):void {
			var options:Object = {
				queued:true,
				frameRate:30,
				type:"MovieClips"
			};
			showScene(getQualifiedClassName(ClassicBenchmarkScene), options);
		}

		private function classicBenchmark3(event:Event):void {
			var options:Object = {
				queued:true,
				frameRate:60,
				type:"Images"
			};
			showScene(getQualifiedClassName(ClassicBenchmarkScene), options);
		}

		private function classicBenchmark4(event:Event):void {
			var options:Object = {
				queued:true,
				frameRate:60,
				type:"MovieClips"
			};
			showScene(getQualifiedClassName(ClassicBenchmarkScene), options);
		}

		// Stress Benchmark

		private function stressBenchmark1(event:Event):void {
			var options:Object = {
				queued:true,
				time:30000,
				count:100,
				type:"Images"
			};
			showScene(getQualifiedClassName(StressBenchmarkScene), options);
		}

		private function stressBenchmark2(event:Event):void {
			var options:Object = {
				queued:true,
				time:30000,
				count:100,
				type:"MovieClips"
			};
			showScene(getQualifiedClassName(StressBenchmarkScene), options);
		}

		private function stressBenchmark3(event:Event):void {
			var options:Object = {
				queued:true,
				time:30000,
				count:500,
				type:"Images"
			};
			showScene(getQualifiedClassName(StressBenchmarkScene), options);
		}

		private function stressBenchmark4(event:Event):void {
			var options:Object = {
				queued:true,
				time:30000,
				count:500,
				type:"MovieClips"
			};
			showScene(getQualifiedClassName(StressBenchmarkScene), options);
		}

		private function stressBenchmark5(event:Event):void {
			var options:Object = {
				queued:true,
				time:30000,
				count:1000,
				type:"Images"
			};
			showScene(getQualifiedClassName(StressBenchmarkScene), options);
		}

		private function stressBenchmark6(event:Event):void {
			var options:Object = {
				queued:true,
				time:30000,
				count:1000,
				type:"MovieClips"
			};
			showScene(getQualifiedClassName(StressBenchmarkScene), options);
		}

		private function stressBenchmark7(event:Event):void {
			var options:Object = {
				queued:true,
				time:30000,
				count:2000,
				type:"Images"
			};
			showScene(getQualifiedClassName(StressBenchmarkScene), options);
		}

		private function stressBenchmark8(event:Event):void {
			var options:Object = {
				queued:true,
				time:30000,
				count:2000,
				type:"MovieClips"
			};
			showScene(getQualifiedClassName(StressBenchmarkScene), options);
		}
	}
}