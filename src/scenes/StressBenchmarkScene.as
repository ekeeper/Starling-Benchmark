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
	import starling.utils.deg2rad;
	import starling.utils.formatString;
	
	public class StressBenchmarkScene extends Scene
	{
		public static const VERSION:String = "1.0";
		public static const NAME:String = "Stress";
		
		private var mResultText:TextField;
		
		private var mFrameCount:int;
		private var mStarted:Boolean;
		private var mFrames:Vector.<Texture>;
		private var mTexture:Texture;
		private var mCallback:Function;
		
		private var mPadding:int = 15;
		private var mObjectsCount:int = 0;
		private var mTime:Number;
		private var mGoalTime:Number;
		
		public function StressBenchmarkScene(options:Object)
		{
			super(options);
			
			mStarted = false;
			
			mFrames = Assets.getTextureAtlas("atlas").getTextures("flight");
			mTexture = Assets.getTexture("BenchmarkObject");
			mGoalTime = options.time;
			mObjectsCount = options.count;
			
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
			
			if (getTimer() - mTime >= mGoalTime) benchmarkComplete();

			mFrameCount++;

			var numObjects:int = mContainer.numChildren;
			var passedTime:Number = event.passedTime;
			var dObj:DisplayObject;
			
			for (var i:int=0; i<numObjects; ++i) {
				dObj = mContainer.getChildAt(i);
				
				dObj.rotation += passedTime * (Math.PI >> 1);
				dObj.x += passedTime * dObj.scaleX * mPadding * 4;
				dObj.y += passedTime * dObj.scaleY * mPadding * 4;
				
				if (dObj.x > (mScreenWidth - 2 * mPadding) || dObj.y > (mScreenHeight - 2 * mPadding)) reInitCoords(dObj);
			}
		}
		
		override protected function startBenchmark(event:Event = null):void
		{
			super.startBenchmark();
			
			mStartButton.visible = false;
			mStarted = true;
			mFrameCount = 0;
			
			if (mResultText) 
			{
				mResultText.removeFromParent(true);
				mResultText = null;
			}
			
			mTime = getTimer();
			
			addTestObjects(mObjectsCount);
		}
		
		private function addTestObjects(count:int = 10):void
		{
			var numObjects:int = count;
			
			for (var i:int = 0; i<numObjects; ++i) mCallback.call();
		}
		
		private function addImage():void
		{
			var im:Image = new Image(mTexture); 
			
			initDisplayObject(im);
			mContainer.addChild(im);
		}
		
		private function addMovieClip():void
		{
			var mc:MovieClip = new MovieClip(mFrames, Math.floor(5+Math.random()*10));
			Starling.juggler.add(mc);
			
			initDisplayObject(mc);
			mContainer.addChild(mc);
		}
		
		private function initDisplayObject(dObj:DisplayObject):void
		{
			dObj.rotation = deg2rad(Math.random() * 360);
			
			dObj.pivotX = dObj.width >> 1;
			dObj.pivotY = dObj.height >> 1;

			dObj.scaleX = dObj.scaleY = 0.5 + Math.random();

			dObj.x = mPadding + Math.random() * (mScreenWidth - 2 * mPadding);
			dObj.y = mPadding + Math.random() * (mScreenHeight - 2 * mPadding);
		}		
		
		private function reInitCoords(dObj:DisplayObject):void
		{
			if (Math.random() > 0.5) {
				dObj.x = mPadding;
				dObj.y = mPadding + Math.random() * (mScreenHeight - 2 * mPadding);
			} else {
				dObj.x = mPadding + Math.random() * (mScreenWidth - 2 * mPadding);
				dObj.y = mPadding;
			}
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
			resultObject.fps = Number((mFrameCount * 1000 / time).toFixed(2)).toString();
			resultObject.objects = mContainer.numChildren.toString();
			
			Game.sender.Send(resultObject);
			
			if (mOptions.queued) {
				mBackButton.text = Game.currentQueue.finished ? "Back" : "Next";
				mBackButton.enabled = true;
			}			
			
			var resultString:String = formatString("Result:\n{0} {6}\nwith {1}/{7} fps\nscreen: {2}x{3}\nmemory: {4}mb\ntime: {5}sec",
				mContainer.numChildren, resultObject.fps, mScreenWidth, mScreenHeight, resultObject.memory, formatedTime, mOptions.type, Starling.current.nativeStage.frameRate);
			
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