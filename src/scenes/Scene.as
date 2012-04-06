package scenes
{
    import flash.system.Capabilities;
    
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

			mScreenWidth = options.stageWidth; 
			mScreenHeight = options.stageHeight;
			
			Starling.current.stop();
			Starling.current.stage.stageWidth  = mScreenWidth;
			Starling.current.stage.stageHeight = mScreenHeight;
			Starling.current.nativeStage.frameRate = options.frameRate;
			Starling.current.start();
			
			// the container will hold all test objects
			mContainer = new Sprite();
			mContainer.touchable = false; // we do not need touch events on the test objects -- 
			// thus, it is more efficient to disable them.
			addChildAt(mContainer, 0);
			
			mStartButton = new Button(Assets.getTexture("ButtonBig"), "Restart");
			mStartButton.fontSize = 16;
			mStartButton.addEventListener(Event.TRIGGERED, startBenchmark);
			mStartButton.x = (options.stageWidth - mStartButton.width) >> 1;
			mStartButton.y = 20;
			mStartButton.visible = false;
			addChild(mStartButton);			
			
            mBackButton = new Button(Assets.getTexture("ButtonBig"), "Back");
			mBackButton.fontSize = 16;
            mBackButton.x = (mScreenWidth - mBackButton.width) >> 1;
            mBackButton.y = mScreenHeight - mBackButton.height - 20;
            mBackButton.addEventListener(Event.TRIGGERED, onBackButtonTriggered);
            addChild(mBackButton);
        }
		
		protected function startBenchmark(event:Event = null):void
		{
		}
        
        private function onBackButtonTriggered(event:Event):void
        {
            mBackButton.removeEventListener(Event.TRIGGERED, onBackButtonTriggered);
            dispatchEvent(new Event(CLOSING, true));
        }
    }
}