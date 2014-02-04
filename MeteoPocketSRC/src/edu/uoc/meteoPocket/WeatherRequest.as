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
	
	public class WeatherRequest extends EventDispatcher
	{
		// constants
		private const WEATHER_URL_PRE = 'http://weather.yahooapis.com/forecastrss?w=';
		private const WEATHER_URL_POST = '&u=c&d=7';
		private const BARCELONA_WOEID = '753692';
		
		
		// weather variables
		private var _weatherUrl:String;
		private var _woeid:String;
		private var _weatherData:Object;
		private var _city:String;
		private var _cityLong:int;
		private var _cityLat:int;
		private var _todayTemp:int;
		private var _todayCond:String;
		
		private var dataLoader:URLLoader;
		private var urlMonitor:URLMonitor;
		private var url:URLRequest;
		
		private var weatherSO:SharedObject;
			
		public function WeatherRequest()
		{
			
			//init variables
			dataLoader = new URLLoader();
			
			//We will keep the weather data in the object _weatherData
			_weatherData = new Object();
			
			//Init sharedObject of the application
			weatherSO = SharedObject.getLocal("weatherData");
			
			// Just use for debugging: erase sharedObject
			//resetLocalData()
			
			refreshData();
		}    
		
		public function updateWoeid(newWoeid:String):void {
			trace("UPDATING DATA");
			updateData(newWoeid);
		}
		
		private function updateData(newWoeid:String):void {
			
			_weatherData.woeid = newWoeid;
			trace("_weatherData.woeid: "+_weatherData.woeid);
				
			// Save info on sharedObject
			weatherSO.data.weatherData = _weatherData;
			
			//We update the sharedObject (save the new info)
			var flushResult = weatherSO.flush();
			
			//Always verify that the action has been successful
			if(flushResult == SharedObjectFlushStatus.FLUSHED){
				//Success
				trace("SAVE DATA SUCCEED");
				refreshData();
			} else {
				//Fail
				trace("SAVE DATA FAILED");
			}
			
		}
		private function refreshData():void {
			
			if(weatherSO.data.weatherData){
				// recover woeid from smartObject
				_weatherData.woeid = weatherSO.data.weatherData.woeid;
				
			}else{
				//Default Barcelona
				_weatherData.woeid = BARCELONA_WOEID;
			}
			
			_weatherUrl = WEATHER_URL_PRE + _weatherData.woeid + WEATHER_URL_POST;
			url = new URLRequest (_weatherUrl);
			trace("NEW URL : "+ _weatherUrl);
			
			//init application
			//resetLocalData()
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
				trace("READING WEATHER ONLINE");
				recoverOnlineData();
			}
			else{
				// No Internet available
				trace("READING LOCAL INFO");
				recoverLocalData();
			}
		} 
		
		private function recoverOnlineData():void{
			
			// Dispatch event WeatherDataEvent.LOADING
			// When weather data start loading we dispatch an event with the data
			var ev:WeatherDataEvent;
			ev = new WeatherDataEvent(WeatherDataEvent.LOADING);
			dispatchEvent(ev);
			
			// Loading eventlistners
			dataLoader.addEventListener(Event.COMPLETE, loaderCompleteHandler);
			dataLoader.addEventListener(IOErrorEvent.IO_ERROR, onFailure);
			
			// loading data
			dataLoader.load(url);
			
		}
		
		private function onFailure(event:Event):void {
			
		}
		
		private function loaderCompleteHandler(event:Event):void {
			
			//serialized string into XML
			var xml:XML;
			xml = new XML(dataLoader.data);
			
			//Example using forecastrss.xml
			var yweather:Namespace = new Namespace("http://xml.weather.yahoo.com/ns/rss/1.0");
			var geo:Namespace = new Namespace("http://www.w3.org/2003/01/geo/wgs84_pos#");
			
			// recover data
			// actual day info
			_weatherData.city = new String(xml.channel.yweather::location.@city);
			trace("CITY : "+ _weatherData.city);
			_weatherData.cityLong = new Number(xml.channel.item.geo::long);
			_weatherData.cityLat = new Number(xml.channel.item.geo::lat);
			_weatherData.todayTemp = new Number(xml.channel.item.yweather::condition.@temp);
			_weatherData.todayCondition = new String (xml.channel.item.yweather::condition.@text);
			_weatherData.todayCode = new Number (xml.channel.item.yweather::condition.@code);
				
			//forecast
			_weatherData.forecastCode = new Array( 
				Number(xml.channel.item.yweather::forecast[0].@code),
				Number(xml.channel.item.yweather::forecast[1].@code),
				Number(xml.channel.item.yweather::forecast[2].@code),
				Number(xml.channel.item.yweather::forecast[3].@code),
				Number(xml.channel.item.yweather::forecast[4].@code),
				Number(xml.channel.item.yweather::forecast[5].@code),
				Number(xml.channel.item.yweather::forecast[6].@code)
			);
			// Recover condition from code
			_weatherData.forecastCondition = new Array();
			_weatherData.forecastCondition = codeToConditionCat(_weatherData.forecastCode);
			trace("Weather condition : " + _weatherData.forecastCondition);
			
			
			// DAY
			_weatherData.forecastDay = new Array( 
				xml.channel.item.yweather::forecast[0].@day,
				xml.channel.item.yweather::forecast[1].@day,
				xml.channel.item.yweather::forecast[2].@day,
				xml.channel.item.yweather::forecast[3].@day,
				xml.channel.item.yweather::forecast[4].@day,
				xml.channel.item.yweather::forecast[5].@day,
				xml.channel.item.yweather::forecast[6].@day
			);
			// Translate to cat
			_weatherData.forecastDay = dayEnToCat(_weatherData.forecastDay);
				
			// DATE
			_weatherData.forecastDate = new Array( 
				String(xml.channel.item.yweather::forecast[0].@date),
				String(xml.channel.item.yweather::forecast[1].@date),
				String(xml.channel.item.yweather::forecast[2].@date),
				String(xml.channel.item.yweather::forecast[3].@date),
				String(xml.channel.item.yweather::forecast[4].@date),
				String(xml.channel.item.yweather::forecast[5].@date),
				String(xml.channel.item.yweather::forecast[6].@date)
			);
			
			// LOWEST
			_weatherData.forecastLow = new Array( 
				Number(xml.channel.item.yweather::forecast[0].@low),
				Number(xml.channel.item.yweather::forecast[1].@low),
				Number(xml.channel.item.yweather::forecast[2].@low),
				Number(xml.channel.item.yweather::forecast[3].@low),
				Number(xml.channel.item.yweather::forecast[4].@low),
				Number(xml.channel.item.yweather::forecast[5].@low),
				Number(xml.channel.item.yweather::forecast[6].@low)
				);
			
			//HIGHEST
			_weatherData.forecastHigh = new Array( 
				Number(xml.channel.item.yweather::forecast[0].@high),
				Number(xml.channel.item.yweather::forecast[1].@high),
				Number(xml.channel.item.yweather::forecast[2].@high),
				Number(xml.channel.item.yweather::forecast[3].@high),
				Number(xml.channel.item.yweather::forecast[4].@high),
				Number(xml.channel.item.yweather::forecast[5].@high),
				Number(xml.channel.item.yweather::forecast[6].@high)
			);
			
			// Dispatch event WeatherDataEvent.COMPLETE
			//When weather data has been recovered we dispatch an event with the data
			var ev:WeatherDataEvent;
			ev = new WeatherDataEvent(WeatherDataEvent.COMPLETE,false,false,_weatherData);
			dispatchEvent(ev);
			
			// Save on sharedObject 
			saveLocalData();
		}
		
		private function saveLocalData():void {
			// Save info on sharedObject
			weatherSO.data.weatherData = _weatherData;
			
			//We update the sharedObject (save the new info)
			var flushResult = weatherSO.flush();
			
			//Always verify that the action has been successful
			if(flushResult == SharedObjectFlushStatus.FLUSHED){
				//Success
				trace("SAVE DATA SUCCEED");
			} else {
				//Fail
				trace("SAVE DATA FAILED");
			}
		}
		
		private function recoverLocalData():void{
			//Initial message
			if(weatherSO.data.weatherData){
				trace("RECOVERED WEATHER FROM LOCAL SHARED OBJECT");
				_weatherData = weatherSO.data.weatherData;
				
				// Dispatch event
				//When weather data has been recovered we dispatch an event with the data
				var ev:WeatherDataEvent;
				ev = new WeatherDataEvent(WeatherDataEvent.COMPLETE,false,false,_weatherData);
				dispatchEvent(ev);
				
			} else {
				//shared object has no data
				trace("NO LOCAL DATA");
			}
		}
		
		private function resetLocalData():void{
			//note: used just for testing process
			//Clear shared object
			weatherSO.clear();
		}
		
		private function dayEnToCat(dayArray:Array):Array{
			for(var i = 0; i< dayArray.length; i++){
				var day:String = dayArray[i];
				switch(day){
					case "Mon": day = "Dilluns"; break;
					case "Tue": day = "Dimarts"; break;
					case "Wed": day = "Dimecres"; break;
					case "Thu": day = "Dijous"; break;
					case "Fri": day = "Divendres"; break;
					case "Sat": day = "Dissabte"; break;
					case "Sun": day = "Diumenge"; break;
					default: day = "--";break;
				}
				dayArray[i] = day;
			}
			return dayArray;
		}
		
		private function codeToConditionCat(codeArray:Array):Array{
			var conditionArray:Array = new Array();
			for(var i = 0; i< codeArray.length; i++){
				var code:String = codeArray[i];
				var condition:String;
				switch(code){
					case "0": condition = "tornado"; break;
					case "1": condition = "tropical storm"; break;
					case "2": condition = "hurricane"; break;
					case "3": condition = "severe thunderstorms"; break;
					case "4": condition = "thunderstorms"; break;
					case "5": condition = "mixed rain and snow"; break;
					case "6": condition = "mixed rain and sleet"; break;
					case "7": condition = "mixed snow and sleet"; break;
					case "8": condition = "freezing drizzle"; break;
					case "9": condition = "drizzle"; break;
					case "10": condition = "freezing rain"; break;
					case "11": condition = "showers"; break;
					case "12": condition = "showers"; break;
					case "13": condition = "snow flurries"; break;
					case "14": condition = "light snow showers"; break;
					case "15": condition = "blowing snow"; break;
					case "16": condition = "snow"; break;
					case "17": condition = "hail"; break;
					case "18": condition = "sleet"; break;
					case "19": condition = "dust"; break;
					case "20": condition = "foggy"; break;
					case "21": condition = "haze"; break;
					case "22": condition = "smoky"; break;
					case "23": condition = "blustery"; break;
					case "24": condition = "windy"; break;
					case "25": condition = "cold"; break;
					case "26": condition = "cloudy"; break;
					case "27": condition = "mostly cloudy (night)"; break;
					case "28": condition = "mostly cloudy (day)"; break;
					case "29": condition = "partly cloudy (night)"; break;
					case "30": condition = "partly cloudy (day)"; break;
					case "31": condition = "clear (night)"; break;
					case "32": condition = "sunny"; break;
					case "33": condition = "fair (night)"; break;
					case "34": condition = "fair (day)"; break;
					case "35": condition = "mixed rain and hail"; break;
					case "36": condition = "hot"; break;
					case "37": condition = "isolated thunderstorms"; break;
					case "38": condition = "scattered thunderstorms"; break;
					case "39": condition = "scattered thunderstorms"; break;
					case "40": condition = "scattered showers"; break;
					case "41": condition = "heavy snow"; break;
					case "42": condition = "scattered snow showers"; break;
					case "43": condition = "heavy snow"; break;
					case "44": condition = "partly cloudy"; break;
					case "45": condition = "thundershowers"; break;
					case "46": condition = "snow showers"; break;
					case "47": condition = "isolated thundershowers"; break;
					default: condition = "Not available";break;
				}
				conditionArray[i] = condition;
			}
			return conditionArray;
		}
	}
}