package edu.uoc.meteoPocket
{
	import flash.events.Event;
	
	public class WeatherDataEvent extends Event 
	{
		public static const COMPLETE:String = 'completed';
		public static const LOADING:String = 'loading';
		
		public var weatherResponse:Object;
		
		public function WeatherDataEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false, weatherResponse:Object = null) 
		{
			super(type, bubbles, cancelable);
			this.weatherResponse = weatherResponse;
		}
		
		override public function clone():Event
		{
			return new WeatherDataEvent(type, bubbles, cancelable, weatherResponse);
		}
		
		override public function toString():String
		{
			return formatToString("WeatherDataEvent", "type", "bubbles", "cancelable", "eventPhase", "weatherResponse"); 
		}
		
	}
	
}