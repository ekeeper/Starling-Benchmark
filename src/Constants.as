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
		public static const isLandscape:Boolean = false;

		public static const Device:Object = getDeviceDetails();

		public static const CenterX:int = Number(Device.screenWidth) >> 1;
		public static const CenterY:int = Number(Device.screenHeight) >> 1;

		public static const FPS:int = 60;

		public static function getDeviceDetails():Object {
            var device:Object = {};
            var devStr:String = Capabilities.os;
            var devStrArr:Array = devStr.split(" ");
            var subDevStr:int;
            var osVersion:String;

            devStr = devStrArr.pop();
            osVersion = devStrArr.pop();

            if (devStr.indexOf(",") > -1) {
                devStrArr = devStr.split(",");
                devStr = devStrArr.shift();

                if (devStrArr.length) {
                    subDevStr = int(devStrArr.shift()) || 0;
                }
            }

            // Based on http://theiphonewiki.com/wiki/Models

            device.manufacturer = "Apple";
            device.os = "iOS";
            device.osVersion = osVersion;
            device.cpu = "ARM v7";
            device.cpuHz = "1GHz";

            if ((devStr == "iPhone1") || (devStr == "iPhone2") || (devStr == "iPod3")) {
                // lowdef iphone, 3, 3g, 3gs
                device.screenWidth = 320;
                device.screenHeight = 480;
                device.model = (devStr == "iPod3") ? "iPod 3" : "iPhone 3GS";
                device.cpuHz = "833MHz";
                device.ram = "256MB";
            } else if ((devStr == "iPhone3") || (devStr == "iPhone4") || (devStr == "iPod4")) {
                // highdef iphone 4, 4s
                device.screenWidth = 640;
                device.screenHeight = 960;
                device.model = (devStr == "iPod4") ? "iPod 4" : ("iPhone 4" + ((devStr == "iPhone4") ? "S" : ""));
                device.ram = (devStr == "iPod4") ? "256MB" : "512MB";
            } else if ((devStr == "iPhone5") || (devStr == "iPod5")) {
                // highdef iphone 5
                device.screenWidth = 640;
                device.screenHeight = 1136;
                device.model = (devStr == "iPod5") ? "iPod 5" : "iPhone 5";
                device.ram = (devStr == "iPod5") ? "512MB" : "1GB";
            } else if ((devStr == "iPad1") || (devStr == "iPad2")) {
                device.screenWidth = 768;
                device.screenHeight = 1024;

                // ipad mini
                if (devStr == "iPad2" && subDevStr >= 5 && subDevStr <= 7) {
                    device.model = "iPad mini";
                    device.ram = "512MB";
                } else {
                    // ipad 1,2
                    device.model = (devStr == "iPad1") ? "iPad 1" : "iPad 2";
                    device.ram = (devStr == "iPad1") ? "256MB" : "512MB";
                }

            } else if ((devStr == "iPad3")) {
                // new iPad
                device.screenWidth = 1536;
                device.screenHeight = 2048;

                if (subDevStr >= 4 && subDevStr <= 6) {
                    device.model = "iPad 4";
                    device.cpuHz = "1.4GHz";
                } else {
                    device.model = "iPad 3";
                }

                device.ram = "1GB";
            } else {
				device.screenWidth = Capabilities.screenResolutionX;
				device.screenHeight = Capabilities.screenResolutionY;

				try {
					NativeDeviceInfo.parse();

					device.manufacturer = NativeDeviceProperties.PRODUCT_MANUFACTURER.value;
					device.model = NativeDeviceProperties.PRODUCT_MODEL.value;
					device.os = NativeDeviceProperties.OS_NAME.value;
					device.osVersion = NativeDeviceProperties.OS_VERSION.value;
					device.cpu = NativeDeviceProperties.PRODUCT_CPU.value;
					device.cpuHz = NativeDeviceProperties.PRODUCT_CPU_HZ.value;
					device.ram = NativeDeviceProperties.PRODUCT_RAM.value;
				} catch (e:Error) {
					device.manufacturer = "";
					device.model = "";
					device.os = Capabilities.os;
					device.osVersion = "";
					device.cpu = "";
					device.cpuHz = "";
					device.ram = "";
				}

			}

			// temporary hack
			//device.screenWidth = Capabilities.screenResolutionX;
			//device.screenHeight = Capabilities.screenResolutionY;

			if (isLandscape && device.manufacturer == "Apple") {
				var swap:Number = device.screenWidth;
				device.screenWidth = device.screenHeight;
				device.screenHeight = swap;
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