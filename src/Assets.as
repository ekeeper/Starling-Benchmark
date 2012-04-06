package
{
    import flash.display.Bitmap;
    import flash.media.Sound;
    import flash.utils.ByteArray;
    import flash.utils.Dictionary;
    
    import starling.display.Image;
    import starling.text.BitmapFont;
    import starling.text.TextField;
    import starling.textures.Texture;
    import starling.textures.TextureAtlas;

    public class Assets
    {
        // TTF-Fonts
        
        // The 'embedAsCFF'-part IS REQUIRED!!!!
        [Embed(source="../media/fonts/Ubuntu-R.ttf", embedAsCFF="false", fontFamily="Ubuntu")]        
        private static const UbuntuRegular:Class;
		
		// Bitmaps
		
		[Embed(source = "../media/textures/splash.png")]
		public static const Startup:Class;
		
		[Embed(source = "../media/textures/background.png")]
		public static const Background:Class;
		
		[Embed(source = "../media/textures/button_normal.png")]
		public static const Button:Class;
		
		[Embed(source = "../media/textures/benchmark_object.png")]
		public static const BenchmarkObject:Class;
		
		[Embed(source = "../media/textures/button_big.png")]
		public static const ButtonBig:Class;
		
		// Texture Atlas
		
		[Embed(source="../media/textures/atlas.xml", mimeType="application/octet-stream")]
		public static const atlasXml:Class;
		
		[Embed(source="../media/textures/atlas.png")]
		public static const atlasTexture:Class;
		
        // Texture cache
        
        private static var sContentScaleFactor:int = 1;
        private static var sTextures:Dictionary = new Dictionary();
		private static var sTextureAtlases:Dictionary = new Dictionary(true);
        private static var sBitmapFontsLoaded:Boolean;
        
        public static function getTexture(name:String):Texture
        {
            if (sTextures[name] == undefined)
            {
                var data:Object = create(name);
                
                if (data is Bitmap)
                    sTextures[name] = Texture.fromBitmap(data as Bitmap, true, false, sContentScaleFactor);
                else if (data is ByteArray)
                    sTextures[name] = Texture.fromAtfData(data as ByteArray, sContentScaleFactor);
            }
            
            return sTextures[name];
        }
        
		public static function getTextureAtlas(name:String):TextureAtlas
		{
			if (sTextureAtlases[name] == undefined)
			{
				var texture:Texture = getTexture(name+"Texture");
				var xml:XML = XML(create(name+"Xml"));
				sTextureAtlases[name] = new TextureAtlas(texture, xml);
			}
			
			return sTextureAtlases[name];
		}
        
        private static function create(name:String):Object
        {
			var _class:Class = Assets[name] as Class;
			
			if (_class) {
				return new _class;
			} else {
				throw new ArgumentError("Asset not found: " + name);
			}
        }
        
		public static function getImage(name:String):Image
		{
			return new Image(getTexture(name));
		}
    }
}