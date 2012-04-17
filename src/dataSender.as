package{
	import flash.display.*;
	import flash.events.*;
	import flash.external.ExternalInterface;
	import flash.net.*;
	import flash.system.Capabilities;
	import flash.utils.Dictionary;
	import flash.xml.XMLDocument;
	import flash.xml.XMLNode;
	
	public class dataSender extends MovieClip{
		private var dataObj:Object = new Object();
		private var respondXML:XML = <respond />;
		private var loader:URLLoader;
		private var url:String = "http://makegames.ru/starling/benchmark/stats.php";

		public function dataSender():void{}

		public function getDataObj():Object{ return dataObj; }

		public function Send(object:Object, format:String = "xml", name:String = "data"):void
		{
			if (!object || object == {}) {
				return;
			}
				
			var request:URLRequest = new URLRequest(url);
			var variables:URLVariables = new URLVariables();
			
			if (format == "xml") {
				var data:XML = new XML(objectToXMLString(object));
				variables[name] = data.toXMLString();
			} else {
				variables[name] = object.toString();
			}
			
			request.data = variables;
			request.method = URLRequestMethod.POST;			

			loader = new URLLoader();
			configureListeners(loader);
			
			try {
				loader.load(request);
			} catch (error:Error) {
				//trace("Unable to load requested script.");
			}			
		}
		
        private function configureListeners(dispatcher:IEventDispatcher):void {
            dispatcher.addEventListener(Event.COMPLETE, completeHandler);
            dispatcher.addEventListener(Event.OPEN, openHandler);
            dispatcher.addEventListener(ProgressEvent.PROGRESS, progressHandler);
            dispatcher.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
            dispatcher.addEventListener(HTTPStatusEvent.HTTP_STATUS, httpStatusHandler);
            dispatcher.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
        }

        private function completeHandler(event:Event):void {
            var loader:URLLoader = URLLoader(event.target);
            trace("completeHandler: " + loader.data);
			//dispatchEvent(new Event("DATALOADED"));
			//trace("data loaded\n\n");
        }

        private function openHandler(event:Event):void {
            //trace("openHandler: " + event);
        }

        private function progressHandler(event:ProgressEvent):void {
            //trace("progressHandler loaded:" + event.bytesLoaded + " total: " + event.bytesTotal);
        }

        private function securityErrorHandler(event:SecurityErrorEvent):void {
			var loader:URLLoader = URLLoader(event.target);
			trace("securityErrorHandler: " + loader.data);
			//dispatchEvent(new Event("DATALOADED"));
			//trace("data loaded\n\n");
        }

        private function httpStatusHandler(event:HTTPStatusEvent):void {
            //trace("httpStatusHandler: " + event);
        }

        private function ioErrorHandler(event:IOErrorEvent):void {
			var loader:URLLoader = URLLoader(event.target);
			trace("ioErrorHandler: " + loader.data);
			//dispatchEvent(new Event("DATALOADED"));
			//trace("data loaded\n\n");
        }
		
		private function objectToXMLString(obj:Object, root:String = "data", level:int = 1):String {
			var string:String = "<"+root+">\n";
			var ls:String = "";

			for (var j:int = 0; j < level; j++) {
				ls += "\t";
			}
			
			var value:*;
			for (var i:String in obj) {
				value = obj[i];
				if (value is String) {
					string += ls+"<"+i+">"+value+"</"+i+">\n";
				} else {
					string += ls+objectToXMLString(value, i, level+1);
				}
			}
			string += "</"+root+">\n";
			
			return string;
		}		
	}
}