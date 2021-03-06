package
{
	import flash.desktop.NativeApplication;
	import flash.desktop.SystemIdleMode;
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageOrientation;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.StageOrientationEvent;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	import flash.ui.Keyboard;
	import flash.utils.setTimeout;
	
	import starling.core.Starling;
	
	[SWF(frameRate="60", backgroundColor="#000000")]
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
			//stage.quality = StageQuality.LOW; // Don't use it please! TextFields and Buttons will not work correctly!
			
			// While Stage3D is initializing, the screen will be blank. To avoid any flickering, 
			// we display the background image for now, but will remove it below, when Starling
			// is ready to go.
			
			var startupBitmap:Bitmap = new Assets.Startup();
			addChild(startupBitmap);

			startupBitmap.x = (Number(Constants.Device.screenWidth) - startupBitmap.width) >> 1;
			startupBitmap.y = (Number(Constants.Device.screenHeight) - startupBitmap.height) >> 1;
			
			Starling.multitouchEnabled = false;  // useful on mobile devices
			Starling.handleLostContext = (Constants.Device.manufacturer != "Apple");
			
			var viewPort:Rectangle = new Rectangle(0, 0, Number(Constants.Device.screenWidth), Number(Constants.Device.screenHeight));
			
			mStarling = new Starling(Game, stage, viewPort);
			mStarling.simulateMultitouch = false;
			mStarling.enableErrorChecking = false;
			mStarling.antiAliasing = 0;
			
			stage.addEventListener(flash.events.Event.RESIZE, checkResolution, false, 0, true);
			
			if (Constants.isLandscape) {
				stage.addEventListener(StageOrientationEvent.ORIENTATION_CHANGING, onOrientationChanging, false, 0, true);
			}
			
			mStarling.stage3D.addEventListener(Event.CONTEXT3D_CREATE, function(e:Event):void 
			{
				// Starling is ready! We remove the startup image and start the game.
				removeChild(startupBitmap);
				checkResolution();
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
		
		public function checkResolution(event:flash.events.Event = null):void {
			Starling.current.stage.stageWidth  = Number(Constants.Device.screenWidth);
			Starling.current.stage.stageHeight = Number(Constants.Device.screenHeight);
		}
		
		private function onOrientationChanging(event:StageOrientationEvent):void {
			//Determine whether DEFAULT and UPSIDE_DOWN == landscape, this varies from device to device.
			var isDefaultLandscape:Boolean = true;
			var isLandscapeNow:Boolean = (stage.stageWidth > stage.stageHeight);
			if(isLandscapeNow && (stage.orientation == StageOrientation.ROTATED_LEFT || stage.orientation == StageOrientation.ROTATED_RIGHT)){
				isDefaultLandscape = false;
			}
			//Are we switching to a landscape mode? If we are, use preventDefault to stop it.
			var goingToDefault:Boolean = (event.afterOrientation == StageOrientation.DEFAULT || event.afterOrientation == StageOrientation.UPSIDE_DOWN);
			if((goingToDefault && !isDefaultLandscape) || (!goingToDefault && isDefaultLandscape)){
				event.preventDefault();
			}
		}		
	}
}