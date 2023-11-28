package {
	import fairygui.GComponent;
	import fairygui.GRoot;
	import fairygui.UIPackage;

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;

	[SWF(frameRate="25", backgroundColor="#000", width="800", height="480")]
	public class Main extends Sprite {
		[Embed(source="../sys/fonts/MSYHBD.TTF", fontName="WRYH", embedAsCFF="false", mimeType="application/x-font")]
		private static var WRYH:Class;

		//
		public function Main() {
			if (stage) {
				stage.align = StageAlign.TOP_LEFT;
				stage.scaleMode = StageScaleMode.EXACT_FIT;
				initStage(null);
			} else {
				addEventListener(Event.ADDED_TO_STAGE, initStage);

			}
		}
		private var _urlLoader:URLLoader;
		private var _urlRequest:URLRequest;
		private var _view:GComponent;

		private function startGame():void {
			//stage.displayState = StageDisplayState.FULL_SCREEN;
			//
			_urlLoader = new URLLoader();
			_urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
			_urlLoader.addEventListener(Event.COMPLETE, onUrlLoaderHandler);
			_urlRequest = new URLRequest("UI.fui");
			_urlLoader.load(_urlRequest);
			//
			addChild(GRoot.inst.displayObject);
			GRoot.inst.setSize(stage.stageWidth, stage.stageHeight);
		}

		public function onUrlLoaderHandler(evt:Event):void {
			_urlLoader.removeEventListener(Event.COMPLETE, onUrlLoaderHandler);
			//
			UIPackage.addPackage(_urlLoader.data, null);

			// 创建界面
			_view = UIPackage.createObject("UI", "IndexUI").asCom;
			var fgui:uint = setTimeout(function myFunction():void {
				GRoot.inst.addChild(_view);
				clearTimeout(fgui);
			}, 1);
		}

		protected function initStage(event:Event):void {
			startGame();
		}
	}
}