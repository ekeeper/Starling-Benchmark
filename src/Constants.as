package
{
	import com.android.deviceinfo.NativeDeviceInfo;
	import com.android.deviceinfo.NativeDeviceProperties;
	
	import flash.net.NetworkInfo;
	import flash.net.NetworkInterface;
	import flash.system.Capabilities;
	
	import starling.core.Starling;

    public class Constants
    {
		public static const Device:Object = getDeviceDetails();
		
		public static const CenterX:int = Number(Device.screenWidth) >> 1;
		public static const CenterY:int = Number(Device.screenHeight) >> 1;
		
		public static const FPS:int = 60;
		
		public static function getDeviceDetails():Object {
			var device:Object = {};
			var devStr:String = Capabilities.os;
			var devStrArr:Array = devStr.split(" ");
			devStr = devStrArr.pop();
			devStr = (devStr.indexOf(",") > -1)?devStr.split(",").shift():devStr;
			
			device.manufacturer = "Apple";
			device.model = devStr;
			device.os = "iOS";
			device.osVersion = devStrArr.pop();			
			
			if ((devStr == "iPhone1") || (devStr == "iPhone2") || (devStr == "iPod3")){
				// lowdef iphone, 3, 3g, 3gs
				device.screenWidth = 320;
				device.screenHeight = 480;
			} else if ((devStr == "iPhone3") || (devStr == "iPhone4") || (devStr == "iPod4")){
				// highdef iphone 4, 4s
				device.screenWidth = 640;
				device.screenHeight = 960;
			} else if ((devStr == "iPad1") || (devStr == "iPad2")){
				// ipad 1,2
				device.screenWidth = 768;
				device.screenHeight = 1024;
			} else if ((devStr == "iPad3")){
				// new iPad
				device.screenWidth = 1536;
				device.screenHeight = 2048;
			} else {
				device.screenWidth = Capabilities.screenResolutionX;
				device.screenHeight = Capabilities.screenResolutionY;
				
				try {
					NativeDeviceInfo.parse();

					device.manufacturer = NativeDeviceProperties.PRODUCT_MANUFACTURER.value;
					device.model = NativeDeviceProperties.PRODUCT_MODEL.value;
					device.os = NativeDeviceProperties.OS_NAME.value;
					device.osVersion = NativeDeviceProperties.OS_VERSION.value;
				} catch (e:Error) {
					device.manufacturer = "";
					device.model = "";
					device.os = Capabilities.os;
					device.osVersion = "";
				}
				
			}
			
			device.dpi = String(Capabilities.screenDPI);
			device.screenWidth = device.screenWidth.toString();
			device.screenHeight = device.screenHeight.toString();
			device.mac = "";
			
			if (NetworkInfo.isSupported) {
				var interfaces:Vector.<NetworkInterface> = NetworkInfo.networkInfo.findInterfaces();
				var address:String;
				for each (var object:NetworkInterface in interfaces) {
					address = object.hardwareAddress;
					if (address) {
						device.mac = address;
						break;
					}
				}			
			}
			
			return device;
		}
	}
}