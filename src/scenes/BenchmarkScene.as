package scenes
{
    import flash.system.Capabilities;
    import flash.system.System;
    
    import starling.core.Starling;
    import starling.display.Button;
    import starling.display.Image;
    import starling.display.MovieClip;
    import starling.display.Sprite;
    import starling.events.EnterFrameEvent;
    import starling.events.Event;
    import starling.text.TextField;
    import starling.textures.Texture;
    import starling.utils.formatString;

    public class BenchmarkScene extends Scene
    {
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
		
        public function BenchmarkScene(options:Object)
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
                mContainer.getChildAt(i).rotation += Math.PI / 2 * passedTime;
        }
        
		override protected function startBenchmark(event:Event = null):void
        {
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
			
			im.x = mPadding + Math.random() * (mScreenWidth - 2 * mPadding);
			im.y = mPadding + Math.random() * (mScreenHeight - 2 * mPadding);
			mContainer.addChild(im);
		}
		
		private function addMovieClip():void
		{
			var mc:MovieClip = new MovieClip(mFrames, Math.floor(5+Math.random()*10));
			Starling.juggler.add(mc);
			
			mc.x = mPadding + Math.random() * (mScreenWidth - 2 * mPadding);
			mc.y = mPadding + Math.random() * (mScreenHeight - 2 * mPadding);
			mContainer.addChild(mc);
		}
		
        private function benchmarkComplete():void
        {
            mStarted = false;
            mStartButton.visible = true;
            
            var fps:int = Starling.current.nativeStage.frameRate;
			var memory:Number = Number((System.totalMemory * 0.000000954).toFixed(3));
            
            var resultString:String = formatString("Result:\n{0} objects\nwith {1} fps\nscreen: {2}x{3}\nmemory: {4}mb",
                                                   mContainer.numChildren, fps, mScreenWidth, mScreenHeight, memory);
            mResultText = new TextField(290, 300, resultString);
			mResultText.color = 0xffffff;
            mResultText.fontSize = 30;
            mResultText.x = (mScreenWidth - mResultText.width) >> 1;
            mResultText.y = (mScreenHeight - mResultText.height) >> 1;
            
            addChild(mResultText);
            
            mContainer.removeChildren();
            System.pauseForGCIfCollectionImminent();
        }
        
        
    }
}