package
{
	public class Queue
	{
		private var mCommands:Vector.<Function>;
		private var mIndex:int;
		private var mLength:int;
		
		public function Queue(commands:Vector.<Function>)
		{
			mCommands = commands;
			reset();
		}
		
		public function reset():void {
			mLength = mCommands.length;
			mIndex = 0;
		}
		
		public function nextCommand(param:*):void
		{
			if (!finished) {
				mCommands[mIndex++].call(NaN, param);
			}
		}
		
		public function get finished():Boolean
		{
			return mIndex >= mLength;
		}		
	}
}