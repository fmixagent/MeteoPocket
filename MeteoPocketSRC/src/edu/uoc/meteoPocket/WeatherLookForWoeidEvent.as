package edu.uoc.meteoPocket
{
	import flash.events.Event;
	
	public class WeatherLookForWoeidEvent extends Event 
	{
		public static const COMPLETE:String = 'completed';
		public static const LOADING:String = 'loading';
		
		public var cities:Array;
		
		public function WeatherLookForWoeidEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, cities:Array = null) 
		{
			super(type, bubbles, cancelable);
			this.cities = cities;
		}
		
		override public function clone():Event
		{
			return new WeatherLookForWoeidEvent(type, bubbles, cancelable, cities);
		}
		
		override public function toString():String
		{
			return formatToString("WeatherLookForWoeidEvent", "type", "bubbles", "cancelable", "eventPhase", "cities"); 
		}
		
	}
	
}