package scenes
{
    import flash.system.Capabilities;
    import flash.system.System;
    import flash.utils.getTimer;
    
    import starling.core.Starling;
    import starling.display.Button;
    import starling.display.DisplayObject;
    import starling.display.Image;
    import starling.display.MovieClip;
    import starling.display.Sprite;
    import starling.events.EnterFrameEvent;
    import starling.events.Event;
    import starling.text.TextField;
    import starling.textures.Texture;
    import starling.utils.formatString;

    public class ClassicBenchmarkScene extends Scene
    {
		public static const VERSION:String = "1.0";
		public static const NAME:String = "Classic";
		
        private var mResultText:TextField;
        
        private var mFrameCount:int;
        private var mElapsed:Number;
        private var mStarted:Boolean;
        private var mFailCount:int;
        private var mWaitFrames:int;
        private var mFrames:Vector.<Texture>;
		private var mTexture:Texture;
		private var mCallback:Function;
		
		private var mPadding:int = 15;
		private var mTime:Number;
		
        public function ClassicBenchmarkScene(options:Object)
        {
            super(options);
			
            mStarted = false;
            mElapsed = 0.0;
			
			mFrames = Assets.getTextureAtlas("atlas").getTextures("flight");
			mTexture = Assets.getTexture("BenchmarkObject");

			switch (options.type) {
				case "Images":
					mCallback = addImage;
					break;
				case "MovieClips":
					mCallback = addMovieClip;
					break;
				default:
					mCallback = addImage;
					break;
			}
			
            addEventListener(Event.ENTER_FRAME, onEnterFrame);
			startBenchmark();
        }
        
        public override function dispose():void
        {
            removeEventListener(Event.ENTER_FRAME, onEnterFrame);
            mStartButton.removeEventListener(Event.TRIGGERED, startBenchmark);
            super.dispose();
        }
        
        private function onEnterFrame(event:EnterFrameEvent):void
        {
            if (!mStarted) return;
            
            mElapsed += event.passedTime;
            mFrameCount++;
            
            if (mFrameCount % mWaitFrames == 0)
            {
                var fps:Number = mWaitFrames / mElapsed;
                var targetFps:int = Starling.current.nativeStage.frameRate;
                
                if (Math.ceil(fps) >= targetFps)
                {
                    mFailCount = 0;
                    addTestObjects();
                }
                else
                {
                    mFailCount++;
                    
                    if (mFailCount > 20)
                        mWaitFrames = 5; // slow down creation process to be more exact
                    if (mFailCount > 30)
                        mWaitFrames = 10;
                    if (mFailCount == 40)
                        benchmarkComplete(); // target fps not reached for a while
                }
                
                mElapsed = mFrameCount = 0;
            }
            
            var numObjects:int = mContainer.numChildren;
            var passedTime:Number = event.passedTime;
            
            for (var i:int=0; i<numObjects; ++i)
                mContainer.getChildAt(i).rotation += passedTime * (Math.PI >> 1);
        }
        
		override protected function startBenchmark(event:Event = null):void
        {
			super.startBenchmark();
			
            System.gc();
			
			mStartButton.visible = false;
            mStarted = true;
            mFailCount = 0;
            mWaitFrames = 2;
            mFrameCount = 0;
            
            if (mResultText) 
            {
                mResultText.removeFromParent(true);
                mResultText = null;
            }
			
			mTime = getTimer();
            
            addTestObjects();
        }
        
        private function addTestObjects(count:int = 10):void
        {
            var numObjects:int = mFailCount > 20 ? count * 0.2 : count;

            for (var i:int = 0; i<numObjects; ++i) mCallback.call();
        }
        
		private function addImage():void
		{
			var im:Image = new Image(mTexture); 
			
			initCoords(im);
			mContainer.addChild(im);
		}
		
		private function addMovieClip():void
		{
			var mc:MovieClip = new MovieClip(mFrames, Math.floor(5+Math.random()*10));
			Starling.juggler.add(mc);
			
			initCoords(mc);
			mContainer.addChild(mc);
		}
		
		private function initCoords(dObj:DisplayObject):void
		{
			dObj.x = mPadding + Math.random() * (mScreenWidth - 2 * mPadding);
			dObj.y = mPadding + Math.random() * (mScreenHeight - 2 * mPadding);
		}
		
        private function benchmarkComplete():void
        {
            mStarted = false;
            mStartButton.visible = true;
            
            var time:Number = getTimer() - mTime;
			var formatedTime:Number = Number((time/1000).toFixed(3));
			
			var resultObject:Object = prepareObject();
			
			resultObject.benchmarkName = NAME;
			resultObject.benchmarkVersion = VERSION;
			resultObject.screenWidth = mScreenWidth.toString(),
			resultObject.screenHeight = mScreenHeight.toString(),
			resultObject.time = time.toString();
			resultObject.type = mOptions.type;
			resultObject.objects = mContainer.numChildren.toString();
				
			Game.sender.Send(resultObject);
			
			if (mOptions.queued) {
				mBackButton.text = Game.currentQueue.finished ? "Back" : "Next";
				mBackButton.enabled = true;
			}			
			
            var resultString:String = formatString("Result:\n{0} {6}\nwith {1} fps\nscreen: {2}x{3}\nmemory: {4}mb\ntime: {5}sec",
                                                   mContainer.numChildren, resultObject.fps, mScreenWidth, mScreenHeight, resultObject.memory, formatedTime, mOptions.type);
            
			mResultText = new TextField(320, 480, resultString);
			mResultText.color = 0xffffff;
            mResultText.fontSize = 30;
            mResultText.x = (mScreenWidth - mResultText.width) >> 1;
            mResultText.y = (mScreenHeight - mResultText.height) >> 1;
			mResultText.touchable = false;
            
            addChild(mResultText);
            
            mContainer.removeChildren();
            System.pauseForGCIfCollectionImminent();
        }
    }
}