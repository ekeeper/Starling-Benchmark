package scenes
{
    import flash.system.Capabilities;
    import flash.system.System;
    
    import starling.core.Starling;
    import starling.display.Button;
    import starling.display.Sprite;
    import starling.events.Event;
    
    public class Scene extends Sprite
    {
        public static const CLOSING:String = "closing";
        
		protected var mStartButton:Button;
		protected var mBackButton:Button;
		
		protected var mContainer:Sprite;
		protected var mScreenWidth:Number;
		protected var mScreenHeight:Number;

		protected var mOptions:Object = {};
        
        public function Scene(options:Object)
        {
			mOptions = options;

			mScreenWidth = Number(Constants.Device.screenWidth); 
			mScreenHeight = Number(Constants.Device.screenHeight);
			
			Starling.current.stop();
			Starling.current.nativeStage.frameRate = options.frameRate;
			Starling.current.start();
			
			// the container will hold all test objects
			mContainer = new Sprite();
			mContainer.touchable = false; // we do not need touch events on the test objects -- 
			// thus, it is more efficient to disable them.
			addChildAt(mContainer, 0);
			
			mStartButton = new Button(Assets.getTexture("ButtonBig"), "Restart");
			mStartButton.fontSize = 24;
			mStartButton.addEventListener(Event.TRIGGERED, startBenchmark);
			mStartButton.x = (mScreenWidth - mStartButton.width) >> 1;
			mStartButton.y = 20;
			mStartButton.visible = false;
			addChild(mStartButton);			
			
            mBackButton = new Button(Assets.getTexture("ButtonBig"), "Back");
			mBackButton.fontSize = 24;
            mBackButton.x = (mScreenWidth - mBackButton.width) >> 1;
            mBackButton.y = mScreenHeight - mBackButton.height - 20;
            mBackButton.addEventListener(Event.TRIGGERED, onBackButtonTriggered);
            addChild(mBackButton);
        }
		
		protected function startBenchmark(event:Event = null):void
		{
			if (mOptions.queued) {
				mBackButton.text = "Please wait";
				mBackButton.enabled = false;
			}	
		}
        
		protected function prepareObject():Object
		{
			return {
				starlingVersion:Starling.VERSION,
				driver:Starling.context.driverInfo,
				fps:Starling.current.nativeStage.frameRate.toString(),
				memory:Number((System.totalMemory * 0.000000954).toFixed(3)).toString(),
				device:Constants.Device
			}	
		}
		
		private function onBackButtonTriggered(event:Event):void
		{
			mBackButton.removeEventListener(Event.TRIGGERED, onBackButtonTriggered);
			dispatchEvent(new Event(CLOSING, true));
		}
    }
}