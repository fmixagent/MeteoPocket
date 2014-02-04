package edu.uoc.meteoPocket
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class BtPreferences extends Sprite
	{
		public var clickStyle_sp:Sprite;
		public var regularStyle_sp:Sprite
		
		public function BtPreferences()
		{
			super();
			
			mouseChildren = false;
			
			clickStyle_sp.visible = false;
			addEventListener(Event.ADDED_TO_STAGE,init);
		}
		
		private function init(ev:Event):void {
			
			// EventListeners
			this.addEventListener(MouseEvent.MOUSE_OVER,onMouseOver);
			this.addEventListener(MouseEvent.MOUSE_OUT,onMouseOut);
			this.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
			this.addEventListener(MouseEvent.MOUSE_UP,onMouseUp);
		}
		
		private function onMouseDown(ev:MouseEvent):void {
			clickStyle_sp.alpha = 1;
			clickStyle_sp.visible = true;
		}
		
		private function onMouseUp(ev:MouseEvent):void {
			clickStyle_sp.visible = false;
			clickStyle_sp.alpha = 1;
		}
		
		private function onMouseOver(ev:MouseEvent):void {
			clickStyle_sp.alpha = 0.5;
			clickStyle_sp.visible = true;
		}
		
		private function onMouseOut(ev:MouseEvent):void {
			clickStyle_sp.visible = false;
			clickStyle_sp.alpha = 1;
		}
	}
}