package
{
	import flash.desktop.NativeApplication;
	import flash.desktop.SystemIdleMode;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	import flash.ui.Keyboard;
	
	import starling.core.Starling;
	
	[SWF(width="320", height="480", frameRate="60", backgroundColor="#000000")]
	public class Startup extends Sprite
	{
		private var mStarling:Starling;
		
		public function Startup()
		{
			if ( stage )
				Init();
			else
				addEventListener( Event.ADDED_TO_STAGE, Init );
		}
		
		public function Init( event:Event = null ):void
		{
			removeEventListener( Event.ADDED_TO_STAGE, Init );
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			// While Stage3D is initializing, the screen will be blank. To avoid any flickering, 
			// we display the background image for now, but will remove it below, when Starling
			// is ready to go.
			
			var startupBitmap:Bitmap = new Assets.Startup();
			addChild(startupBitmap);

			startupBitmap.x = (Number(Constants.Device.screenWidth) - startupBitmap.width) >> 1;
			startupBitmap.y = (Number(Constants.Device.screenHeight) - startupBitmap.height) >> 1;
			
			Starling.multitouchEnabled = false;  // useful on mobile devices
			Starling.handleLostContext = true; // deactivate on mobile devices (to save memory)
			
			mStarling = new Starling(Game, stage);
			mStarling.simulateMultitouch = false;
			mStarling.enableErrorChecking = false;
			mStarling.antiAliasing = 0;
			
			mStarling.stage3D.addEventListener(Event.CONTEXT3D_CREATE, function(e:Event):void 
			{
				// Starling is ready! We remove the startup image and start the game.
				removeChild(startupBitmap);

				Starling.current.stage.stageWidth  = Number(Constants.Device.screenWidth);
				Starling.current.stage.stageHeight = Number(Constants.Device.screenHeight);
				
				mStarling.start();
			});
			
			// When the game becomes inactive, we pause Starling; otherwise, the enter frame event
			// would report a very long 'passedTime' when the app is reactivated. 
			
			NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE, 
				function (e:Event):void {
					mStarling.start();
				});
			
			NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, 
				function (e:Event):void {
					mStarling.stop();
				});
			
			NativeApplication.nativeApplication.addEventListener(KeyboardEvent.KEY_DOWN, 
				function (e:KeyboardEvent):void {
					if(e.keyCode == Keyboard.BACK)  {
						e.preventDefault();
						e.stopImmediatePropagation();						
						NativeApplication.nativeApplication.exit(0);
					}
				});
			
			//  Device will always be awake
			NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.KEEP_AWAKE;
		}
	}
}