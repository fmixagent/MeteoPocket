package edu.uoc.meteoPocket
{
	
	import air.net.URLMonitor;
	
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.StatusEvent;
	import flash.net.SharedObject;
	import flash.net.SharedObjectFlushStatus;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.StaticText;
	
	public class WeatherCityToWoeidRequest extends EventDispatcher
	{
		// constants

		private const WOEID_REQ_URL_PRE = "http://where.yahooapis.com/v1/places.q('";
		private const APP_ID:String = "YAHOO_APP_ID"; // To obtain your App ID go to https://developer.apps.yahoo.com/wsregapp/
												      // You will need a Yahoo account
		private const WOEID_REQ_URL_POST = "')?appid=[" + APP_ID +"]";

		// weather variables
		private var _cities:Array;
		private var _city:Object;
		private var _woeid:String;
		
		private var _woeidRequestUrl:String;
		private var dataLoader:URLLoader;
		private var urlMonitor:URLMonitor;
		private var url:URLRequest;
			
		public function WeatherCityToWoeidRequest(city:String)
		{
			_city = new Object();
			_cities = new Array();
			
			_city.name = city;
			
			//init variables
			dataLoader = new URLLoader();
			
			monitoringConnection();
		}    
		
		public function monitoringConnection():void
		{
			urlMonitor = new URLMonitor(new URLRequest("http://www.google.com"));
			urlMonitor.addEventListener(StatusEvent.STATUS, connectionStatus);
			
			if(!urlMonitor.running) urlMonitor.start();
		}
		private function connectionStatus(ev:StatusEvent) { 
			if(urlMonitor.available){
				// Internet available
				cityFromWoeid();
			}
			else{
				// No Internet available
				trace("NO INTERNET CONNECTION");
			}
		} 
		
		private function cityFromWoeid():void{
			
			// Dispatch event WeatherDataEvent.LOADING
			// When weather data start loading we dispatch an event with the data
			var ev:WeatherLookForWoeidEvent;
			ev = new WeatherLookForWoeidEvent(WeatherLookForWoeidEvent.LOADING);
			dispatchEvent(ev);
			
			// Loading eventlistners
			dataLoader.addEventListener(Event.COMPLETE, loaderCompleteHandler);
			dataLoader.addEventListener(IOErrorEvent.IO_ERROR, onFailure);
			
			// loading data
			
			_woeidRequestUrl = WOEID_REQ_URL_PRE + _city.name + WOEID_REQ_URL_POST;
			url = new URLRequest (_woeidRequestUrl);
			dataLoader.load(url);
			
			
			trace("LOADING WOEID FROM CITY");
			
		}
		
		private function onFailure(event:Event):void {
			
			
			trace("LOADING WOEID FROM CITY ----- FAILURE");
			
		}
		
		private function loaderCompleteHandler(event:Event):void {
			
			
			trace("LOADING WOEID FROM CITY ----- COMPLETE");
			
			//serialized string into XML
			var xml:XML;
			xml = new XML(dataLoader.data);
			
			//
			var yahoo:Namespace = new Namespace("http://where.yahooapis.com/v1/schema.rng");
			
			// recover data
			// actual day info
			var numCities:int;
			numCities = xml.children().length();
			trace("NUMBER OF CITIES WITH SAME NAME: "+numCities);
			var i:int;
			for( i = 0; i < numCities; i++){
				_city.provincia = xml.children()[i].yahoo::country;
				_city.woeid = xml.children()[i].yahoo::woeid;
				_cities.push(_city);
			}
			
			trace ("CITIES: " + _cities + " AND FIRST " + _cities[0].woeid);
			// Dispatch event WeatherDataEvent.COMPLETE
			//When weather data has been recovered we dispatch an event with the data
			var ev:WeatherLookForWoeidEvent;
			ev = new WeatherLookForWoeidEvent(WeatherLookForWoeidEvent.COMPLETE,false,false,_cities);
			dispatchEvent(ev);
			trace("DISPATCHED");
			
		}
		
	}
}