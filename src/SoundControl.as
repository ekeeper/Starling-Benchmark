package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	
	public class SoundControl extends Sprite
	{
		private var sndNum:int = 0;
		
		private var sound:Array = new Array();
		private var channel:Array = new Array();
		private var sndTransform:Array = new Array();
		private var sndSwitch:Array = new Array();
		private var loopPlay:Array = new Array();
		public var globalSwitch:Boolean = true;
		
		
		public function SoundControl()
		{
			addEventListener( Event.ENTER_FRAME, onEnterFrame );
		}
		
		public function AddSound(snd:Object):void
		{
			sound[sndNum] = snd;

			channel[sndNum] = new SoundChannel();
			sndTransform[sndNum] = new SoundTransform();
			sndSwitch[sndNum] = true;
			loopPlay[sndNum] = false;
			
			sndNum++;
			
			//if (sndNum == 2)
				//channel[1].soundTransform = new SoundTransform();
		}
		
		public function Play( soundId:int, loop:int, soft:Boolean = false ):void
		{
			sndSwitch[ soundId ] = true;
			
			if ( !loopPlay[ soundId ] )
			{
				if ( loop == 0 )
					loopPlay[ soundId ] = true;
				
				if ( !globalSwitch || soft )
					sndTransform[ soundId ].volume = 0;

				channel[ soundId ] = sound[ soundId ].play( 0, (loop > 0) ? loop : 999999, sndTransform[ soundId ] );				
			}
		}
		
		public function Stop( soundId:int ):void
		{
			sndSwitch[ soundId ] = false;
		}
		
		private function onEnterFrame(event:Event = null):void
		{
			for ( var i:int = 0; i < sndNum; i++ )
			{
				if ( (!globalSwitch || !sndSwitch[i]) && (sndTransform[i].volume > 0.0) )
				{
					sndTransform[i].volume -= 0.05;
					channel[i].soundTransform = sndTransform[i];
					if ( sndTransform[i].volume <= 0.07 )
					{
						sndTransform[i].volume = 0;
						channel[i].soundTransform = sndTransform[i];
					}
				}
				else if ( (globalSwitch && sndSwitch[i]) && (sndTransform[i].volume < 1.0) )
				{
					sndTransform[i].volume += 0.05;
					channel[i].soundTransform = sndTransform[i];
					if ( sndTransform[i].volume >= 0.93 )
					{
						sndTransform[i].volume = 1;
						channel[i].soundTransform = sndTransform[i];
					}
				}
			}
		}
		
		public function TouchSound(force:Boolean = false):void
		{
			if (sndNum == 0) return;

			globalSwitch = !globalSwitch;

			if (force) {
				for ( var i:int = 0; i < sndNum; i++ ) {
					sndTransform[i].volume = globalSwitch ? 1 : 0;
					channel[i].soundTransform = sndTransform[i];
				}
				return;
			}
			
			// sound button click
			if ( globalSwitch )
			{
				sndTransform[0].volume = 1;
				channel[0].soundTransform = sndTransform[0];
			} 
		}
	}
}