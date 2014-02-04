package edu.uoc.meteoPocket
{
	import com.greensock.TweenMax;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.BlurFilter;
	import flash.geom.ColorTransform;
	
	public class Screen extends Sprite
	{
		private const DURATION_TRANSITION:Number = 1;
		
		private var myBlur:BlurFilter;
		private var brightTransform:ColorTransform;
		
		public function Screen() 
		{
			// constructor code
			super();
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		protected function init(ev:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			//Afegim l'escoltador de l'event Event.RESIZE
			stage.addEventListener(Event.RESIZE, adaptLayout);
			
			//Adaptem la pantalla una vegafa iniciats
			adaptLayout();
		}
		
		protected function adaptLayout(ev:Event = null):void 
		{
			//Cada pantalla te elements visuals diferents
			//caldrà doncs modificar com s'adapta cada pantalla per separat
			//A partir de cada pantalla (heredera de Screen) reescribirem aquesta funció
			//Si no reescribim aquest mètode (oblit) rebrem un error (recordatori)
			throw new Error('This method must be implemented by subclasses of Screen');
		}
		
		public function screenIn():void 
		{
			throw new Error('This method must be implemented by subclasses of Screen');
		}
		
		public function screenOut():void 
		{
			throw new Error('This method must be implemented by subclasses of Screen');
		}
		
		public function dispose ():void 
		{
			//Ens permet treure l'eventListener de l'event Event.RESIZE quan treiem una pantalla
			if (stage.hasEventListener(Event.RESIZE)) {
				stage.removeEventListener(Event.RESIZE, adaptLayout);
			}
			
		}
		
		public function blurOn():void {
			myBlur = new BlurFilter();	
			myBlur.quality = 3;
			myBlur.blurX = 20;
			myBlur.blurY = 20;
			this.filters = [myBlur];
			brightTransform = new ColorTransform(0,0,0);
			this.transform.colorTransform = brightTransform;
			
		}
		
		public function blurOff():void {
			this.filters = [];
			brightTransform = new ColorTransform(1,1,1);
			this.transform.colorTransform = brightTransform;
		}
		
		public function fadeIn():void {
			this.alpha = 0;
			this.visible = true;
			var tween:TweenMax = new TweenMax(this,DURATION_TRANSITION, {alpha:1});
		}
		
		public function fadeOut():void {
			this.alpha = 0;
			this.visible = true;
			var tween:TweenMax = new TweenMax(this,DURATION_TRANSITION, {alpha:0,onComplete:function(){this.visible = false;}});
		}
		
	}
	
}
