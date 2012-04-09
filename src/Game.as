package 
{
	import com.android.deviceinfo.NativeDeviceInfo;
	import com.android.deviceinfo.NativeDeviceProperties;
	
	import flash.desktop.NativeApplication;
	import flash.net.NetworkInfo;
	import flash.net.NetworkInterface;
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
			Starling.current.stage.stageWidth  = Constants.GameWidth;
			Starling.current.stage.stageHeight = Constants.GameHeight;
			
			addEventListener(Event.ADDED_TO_STAGE, Init);
		}
		
		private function Init( e:Event = null ):void
		{
			removeEventListener( Event.ADDED_TO_STAGE, Init );
			
			sender = new dataSender();
			
			mMainMenu = new Sprite();
			addChild(mMainMenu);
			
			var testRes:String = Constants.GameWidth+"x"+Constants.GameHeight;
			var nativeRes:String = Capabilities.screenResolutionX+"x"+Capabilities.screenResolutionY;
			
			var buttons:Array = [
				["Classic: Images, "+testRes+", 30fps",       "classicBenchmark1"],
				["Classic: MovieClips, "+testRes+", 30fps",   "classicBenchmark2"],
				["Classic: Images, "+testRes+", 60fps",       "classicBenchmark5"],
				["Classic: MovieClips, "+testRes+", 60fps",   "classicBenchmark6"],
			];
			
			if (testRes != nativeRes) {
				buttons = buttons.concat([
					["Classic: Images, "+nativeRes+", 30fps",     "classicBenchmark3"],
					["Classic: MovieClips, "+nativeRes+", 30fps", "classicBenchmark4"],
					["Classic: Images, "+nativeRes+", 60fps",     "classicBenchmark7"],
					["Classic: MovieClips, "+nativeRes+", 60fps", "classicBenchmark8"],
				]);
			}
			
			buttons.push(["Exit", "Exit"]);
			
			
			var count:int = 0;
			
			for each (var buttonToCreate:Array in buttons)
			{
				var button:Button = createButton(buttonToCreate[0], buttonToCreate[1], stage.stageWidth >> 1, 100 + int(count++) * 42, "Button");				
				mMainMenu.addChild(button);
			}			
			
			addEventListener(Scene.CLOSING, onSceneClosing);
			
            // show information about rendering method (hardware/software)
            var deviceInfo:String = "Driver: " + Starling.context.driverInfo + 
				"\nScreen: " + Capabilities.screenResolutionX+"x"+Capabilities.screenResolutionY +
				" ScreenDPI: " + String(Capabilities.screenDPI);
			
			try {
				NativeDeviceInfo.parse();
				
				device = {
					manufacturer:NativeDeviceProperties.PRODUCT_MANUFACTURER.value,
					model:NativeDeviceProperties.PRODUCT_MODEL.value,
					os:NativeDeviceProperties.OS_NAME.value,
					osVersion:NativeDeviceProperties.OS_VERSION.value
				};
				
				deviceInfo += "\nDevice: " + 
					NativeDeviceProperties.PRODUCT_MANUFACTURER.value + ", " + 
					NativeDeviceProperties.PRODUCT_MODEL.value + ", " + 
					NativeDeviceProperties.OS_NAME.value + " " + 
					NativeDeviceProperties.OS_VERSION.value + " ";
			} catch (e:Error) {
				device = {
					manufacturer:"",
					model:"",
					os:"",
					osVersion:""
				};
			}
			
			if (NetworkInfo.isSupported) {
				var interfaces:Vector.<NetworkInterface> = NetworkInfo.networkInfo.findInterfaces();
				var address:String;
				for each (var object:NetworkInterface in interfaces) {
					address = object.hardwareAddress;
					if (address) {
						device.mac = address;
						deviceInfo += "\nMAC: " + address;
						break;
					}
				}			
			} else {
				device.mac = "";
			}

			device.screenWidth = Capabilities.screenResolutionX.toString();
			device.screenHeight = Capabilities.screenResolutionY.toString();
			
			mInfoText = createTF(3, 3, 320, 128, deviceInfo, 0xffffff, 14);			
			mMainMenu.addChild(mInfoText);
        }
		
		private function createButton(title:String, callback:String, x:Number, y:Number, texture:String, blendMode:String = BlendMode.NORMAL):Button
		{
			var buttonTexture:Texture = Assets.getTexture(texture);
			var button:Button = new Button(buttonTexture, title);
			
			if (title != "") {
				button.text = title;
				button.fontName = "Ubuntu";
				button.fontSize = 14;
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
			Starling.current.stage.stageWidth  = Constants.GameWidth;
			Starling.current.stage.stageHeight = Constants.GameHeight;
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
				stageWidth:Constants.GameWidth, 
				stageHeight:Constants.GameHeight, 
				frameRate:30, 
				type:"Images"
			};
			showScene(getQualifiedClassName(ClassicBenchmarkScene), options);
		}
		
		private function classicBenchmark2(event:Event):void {
			var options:Object = {
				stageWidth:Constants.GameWidth, 
				stageHeight:Constants.GameHeight, 
				frameRate:30, 
				type:"MovieClips"
			};
			showScene(getQualifiedClassName(ClassicBenchmarkScene), options);
		}
		
		private function classicBenchmark3(event:Event):void {
			var options:Object = {
				stageWidth:Capabilities.screenResolutionX,
				stageHeight:Capabilities.screenResolutionY, 
				frameRate:30, 
				type:"Images"
			};
			showScene(getQualifiedClassName(ClassicBenchmarkScene), options);
		}
		
		private function classicBenchmark4(event:Event):void {
			var options:Object = {
				stageWidth:Capabilities.screenResolutionX, 
				stageHeight:Capabilities.screenResolutionY, 
				frameRate:30, 
				type:"MovieClips"
			};
			showScene(getQualifiedClassName(ClassicBenchmarkScene), options);
		}
		
		private function classicBenchmark5(event:Event):void {
			var options:Object = {
				stageWidth:Constants.GameWidth, 
				stageHeight:Constants.GameHeight, 
				frameRate:60, 
				type:"Images"
			};
			showScene(getQualifiedClassName(ClassicBenchmarkScene), options);
		}
		
		private function classicBenchmark6(event:Event):void {
			var options:Object = {
				stageWidth:Constants.GameWidth,
				stageHeight:Constants.GameHeight,
				frameRate:60,
				type:"MovieClips"
			};
			showScene(getQualifiedClassName(ClassicBenchmarkScene), options);
		}
		
		private function classicBenchmark7(event:Event):void {
			var options:Object = {
				stageWidth:Capabilities.screenResolutionX, 
				stageHeight:Capabilities.screenResolutionY, 
				frameRate:60, 
				type:"Images"
			};
			showScene(getQualifiedClassName(ClassicBenchmarkScene), options);
		}
		
		private function classicBenchmark8(event:Event):void {
			var options:Object = {
				stageWidth:Capabilities.screenResolutionX, 
				stageHeight:Capabilities.screenResolutionY, 
				frameRate:60, 
				type:"MovieClips"
			};
			showScene(getQualifiedClassName(ClassicBenchmarkScene), options);
		}		
	}
}