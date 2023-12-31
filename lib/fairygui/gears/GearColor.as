package fairygui.gears
{
    import fairygui.GObject;
    import fairygui.ObjectPropID;
    import fairygui.UIPackage;
    import fairygui.tween.GTween;
    import fairygui.tween.GTweener;
    import fairygui.utils.ToolSet;

    public class GearColor extends GearBase
	{
		private var _storage:Object;
		private var _default:GearColorValue;
		
		public function GearColor(owner:GObject)
		{
			super(owner);
		}
		
		override protected function init():void
		{
			_default = new GearColorValue(_owner.getProp(ObjectPropID.Color), 
				_owner.getProp(ObjectPropID.OutlineColor));
			_storage = {};
		}
		
		override protected function addStatus(pageId:String, value:String):void
		{
			if(value=="-" || value.length==0)
				return;
			
			var pos:int = value.indexOf(",");
			var col1:uint;
			var col2:uint;
			if(pos==-1)
			{
				col1 = ToolSet.convertFromHtmlColor(value);
				col2 = 0xFF000000; //为兼容旧版本，用这个值表示不设置
			}
			else
			{
				col1 = ToolSet.convertFromHtmlColor(value.substr(0,pos));
				col2 = ToolSet.convertFromHtmlColor(value.substr(pos+1));
			}
			if(pageId==null)
			{
				_default.color = col1;
				_default.strokeColor = col2;
			}
			else
				_storage[pageId] = new GearColorValue(col1, col2);
		}
		
		override public function apply():void
		{
			var gv:GearColorValue = _storage[_controller.selectedPageId];
			if(!gv)
				gv = _default;
			
			if(_tweenConfig != null && _tweenConfig.tween && !UIPackage._constructing && !disableAllTweenEffect)
			{
				if(gv.strokeColor!=0xFF000000)
				{
					_owner._gearLocked = true;
					_owner.setProp(ObjectPropID.OutlineColor, gv.strokeColor);
					_owner._gearLocked = false;
				}
				
				if (_tweenConfig._tweener != null)
				{
					if (_tweenConfig._tweener.endValue.color != gv.color)
					{
						_tweenConfig._tweener.kill(true);
						_tweenConfig._tweener = null;
					}
					else
						return;
				}
				
				var curColor:uint = _owner.getProp(ObjectPropID.Color);
				if (curColor != gv.color)
				{
					if (_owner.checkGearController(0, _controller))
						_tweenConfig._displayLockToken = _owner.addDisplayLock();
					
					_tweenConfig._tweener = GTween.toColor(curColor, gv.color, _tweenConfig.duration)
						.setDelay(_tweenConfig.delay)
						.setEase(_tweenConfig.easeType)
						.setTarget(this)
						.onUpdate(__tweenUpdate)
						.onComplete(__tweenComplete);
				}
			}
			else
			{
				_owner._gearLocked = true;
				_owner.setProp(ObjectPropID.Color, gv.color);
				if(gv.strokeColor!=0xFF000000)
					_owner.setProp(ObjectPropID.OutlineColor, gv.strokeColor);
				_owner._gearLocked = false;
			}
		}
		
		private function __tweenUpdate(tweener:GTweener):void
		{
			_owner._gearLocked = true;
			_owner.setProp(ObjectPropID.Color, tweener.value.color);
			_owner._gearLocked = false;
		}
		
		private function __tweenComplete():void
		{
			if(_tweenConfig._displayLockToken!=0)
			{
				_owner.releaseDisplayLock(_tweenConfig._displayLockToken);
				_tweenConfig._displayLockToken = 0;
			}
			_tweenConfig._tweener = null;
		}
		
		override public function updateState():void
		{
			var gv:GearColorValue = _storage[_controller.selectedPageId];
			if(!gv)
			{
				gv = new GearColorValue();
				_storage[_controller.selectedPageId] = gv;
			}
			
			gv.color = _owner.getProp(ObjectPropID.Color);
			gv.strokeColor = _owner.getProp(ObjectPropID.OutlineColor);
		}
	}
}

class GearColorValue
{
	public var color:uint;
	public var strokeColor:uint;
	
	public function GearColorValue(color:uint=0, strokeColor:uint=0)
	{
		this.color = color;
		this.strokeColor = strokeColor;
	}
}