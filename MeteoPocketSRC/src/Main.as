package
{
	import edu.uoc.meteoPocket.MenuScreen;
	import edu.uoc.meteoPocket.PrefEvent;
	import edu.uoc.meteoPocket.PreferencesPlusScreen;
	import edu.uoc.meteoPocket.Screen;
	import edu.uoc.meteoPocket.ScreenA;
	import edu.uoc.meteoPocket.ScreenB;
	import edu.uoc.meteoPocket.ScreenEvent;
	import edu.uoc.meteoPocket.ScreenTypes;
	import edu.uoc.meteoPocket.WeatherDataEvent;
	import edu.uoc.meteoPocket.WeatherRequest;
	
	import flash.desktop.NativeApplication;
	import flash.display.Sprite;
	import flash.display.SimpleButton;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TransformGestureEvent;
	import flash.geom.Rectangle;
	
	public class Main extends Sprite
	{ 
		// Constants
		private const MARGIN:int = 30;
		
		// Timeline instances
		public var appTitle_sp:Sprite;
		public var topBar_sp:Sprite;
		public var btPreferences_sp:Sprite;
		public var btExit_sp:Sprite;
		public var screenContainer_sp:Sprite;
		public var foregroundContainer_sp:Sprite;
		public var background_sp:Sprite;
		public var preloader_sp:Sprite;
		
		// Screens
		private var _actualScreen:int;
		private var _screenIn:Screen = null;
		private var _screenOut:Screen = null;
		private var _screenPreferences:PreferencesPlusScreen = null;
		
		// Monitor
		private var _weatherRequest:WeatherRequest;
		private var _weatherData:Object;
		
		public function Main()
		{
			// Instanciate variables
			_weatherData = new Object();
			_weatherRequest = new WeatherRequest(); // When instanciate weather data is requested
			
			// Important to better control the resizing
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			// We will start code when the instance of Main is on the displayList
			// note: For the document class we can use stage instance directly in the constructor
			// but generally we will reference to stage on init() method
			addEventListener(Event.ADDED_TO_STAGE, init);			
		}
		
		private function init(ev:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			// Initialise buttons
			btExit_sp.buttonMode = true;
			
			// Button exit eventListener (quit application)
			btExit_sp.addEventListener(MouseEvent.CLICK,onExitApp);
			
			// Detect resize (or orientation change)
			stage.addEventListener(Event.RESIZE, adaptLayout);
			
			// WeatherRequest eventlistners
			_weatherRequest.addEventListener(WeatherDataEvent.LOADING, loadingData);
			_weatherRequest.addEventListener(WeatherDataEvent.COMPLETE, dataLoaded);
			
			// Gesture eventListeners
			addEventListener(TransformGestureEvent.GESTURE_SWIPE, onSwipe);
			
		}
		
		public function loadingData(ev:WeatherDataEvent):void {
			
			// During requesting weather data from the server
			
			// Actual screen (Avui - Pronòstic) is not visible
			if(_screenIn) _screenIn.visible = false;
			
			// A preloader inform user of what's happening
			addChild(preloader_sp);
			
			// btPreferences is disable
			btPreferences_sp.alpha = 0.5; 
			btPreferences_sp.buttonMode = false;
			btPreferences_sp.removeEventListener(MouseEvent.CLICK,openPreferences);
		}
		
		private function dataLoaded(ev:WeatherDataEvent):void {	
			// save data
			_weatherData = ev.weatherResponse;
			
			// remove preloader
			if(preloader_sp.stage != null){
				// First time we run the application
				// We choose starting on SCREEN_A (Today weather)
				_actualScreen = ScreenTypes.SCREEN_A;
				refreshScreen();
				// We remove preloader
				removeChild(preloader_sp);
			}
			else {
				refreshScreen();
			}
			
			// Make screen visible
			if(_screenIn) _screenIn.fadeIn();
			
			// Enables btPreferences
			btPreferences_sp.alpha = 1;
			btPreferences_sp.buttonMode = true;
			btPreferences_sp.addEventListener(MouseEvent.CLICK,openPreferences);
		}
		
		// SCREEN MANAGEMENT
		
		private function changeScreen(newScreen):void
		{
			if (newScreen != _actualScreen)
			{
				_actualScreen = newScreen;
				refreshScreen();
			}
		}
		
		private function refreshScreen():void
		{
			// Clear previous screen
			clearPreviousScreen();
			
			// Add new one
			switch (_actualScreen)
			{
				case ScreenTypes.SCREEN_A: 		_screenIn = new ScreenA('Avui',_weatherData); break;
				case ScreenTypes.SCREEN_B: 		_screenIn = new ScreenB('Pronòstic setmanal',_weatherData); break;
			}
			
			// Add eventListeners to the actul screen
			_screenIn.addEventListener(ScreenEvent.CHANGE_SCREEN, onScreenChange);
			_screenIn.screenIn();
			screenContainer_sp.addChild(_screenIn); 
		}
		
		private function clearPreviousScreen():void 
		{
			if (_screenIn != null) 
			{
				// Actual screen go out
				_screenOut = _screenIn;
				
				// We remove eventListeners added by Main.as
				if (_screenOut.hasEventListener(ScreenEvent.CHANGE_SCREEN)) 
				{
					_screenOut.removeEventListener(ScreenEvent.CHANGE_SCREEN, onScreenChange);
				}
				
				// We remove eventListeners added inside the screen instance
				// (See method dispose() on class Screen)
				_screenOut.dispose();
				
				// Tween animation getting out
				_screenOut.screenOut();
				
			}
		}
		
		
		public function removeOut():void {
			// Remove screen from displayList
			screenContainer_sp.removeChild(_screenOut);
			_screenOut = null;
		}
		
		// EVENTLISTENERS
		
		// GESTURES
		private function onSwipe(ev:TransformGestureEvent):void {
			// Look for swipe direction
			if(ev.offsetX == 1){
				// Swipe from left to right)
				if(_actualScreen == ScreenTypes.SCREEN_B){
					changeScreen(ScreenTypes.SCREEN_A);
				}
			}
			else
			{ 
				//Swipe from right to left)
				if(_actualScreen == ScreenTypes.SCREEN_A){
					changeScreen(ScreenTypes.SCREEN_B);
				}
			}
		}
		
		// PREFERENCES BUTTON
		private function openPreferences(ev:MouseEvent):void {
			// Disable swipe detection
			removeEventListener(TransformGestureEvent.GESTURE_SWIPE, onSwipe);
			
			// Disable preferences button
			btPreferences_sp.visible = false;
			
			// Open preferences overlay screen
			_screenPreferences = new PreferencesPlusScreen(_weatherData.city,_weatherData.woeid);
			_screenPreferences.addEventListener(PrefEvent.CLOSE_PREF,closePreferences);
			foregroundContainer_sp.addChild(_screenPreferences);
			
			// Blur background Screen
			_screenIn.blurOn();
		}
		private function closePreferences(ev:PrefEvent){
			// Enable swipe detection
			addEventListener(TransformGestureEvent.GESTURE_SWIPE, onSwipe);
			
			// Enable preferences button
			btPreferences_sp.visible = true;
			
			// Close preferences
			if(ev.woeid != ""){
				_screenIn.visible = false;
				_weatherRequest.updateWoeid(ev.woeid);
			} else{
				trace("NO NEED TO UPDATE DATA");
			}
			
			// Close preferences overlay screens
			_screenPreferences.removeEventListener(PrefEvent.CLOSE_PREF,closePreferences);
			_screenPreferences.dispose();
			foregroundContainer_sp.removeChild(_screenPreferences);
			
			// BlurOff background Screen
			_screenIn.blurOff();
			
		}
		
		private function onScreenChange(ev:ScreenEvent):void 
		{
			// Just two cases here: Avui and Pronòstic Setmanal
			if (ev.screenID != _actualScreen)
			{
				_actualScreen = ev.screenID;
				refreshScreen();
			}
		}
		
		private function onExitApp(ev:MouseEvent):void {
			// Close app
			NativeApplication.nativeApplication.exit();
		}
		
		private function adaptLayout(ev:Event = null):void 
		{
			// Dealing with different DPI screens
			// We base our design on a 480X800 and scale in proportion
			// (scaling is deal for each element)
			var scale = Math.max(stage.stageWidth,stage.stageHeight)/800;
			
			
			// Scaling correction for different DPIs
			topBar_sp.scaleY = scale;
			btPreferences_sp.scaleX = scale;
			btPreferences_sp.scaleY = scale;
			btExit_sp.scaleX = scale;
			btExit_sp.scaleY = scale;
			appTitle_sp.scaleX = scale;
			appTitle_sp.scaleY = scale;
			preloader_sp.scaleX = scale;
			preloader_sp.scaleY = scale;
				
			// topBar_sp
			topBar_sp.width = stage.stageWidth;
			
			// appTitle_sp
			appTitle_sp.x = stage.stageWidth/2 - appTitle_sp.width/2;
			appTitle_sp.y = (topBar_sp.height - appTitle_sp.height)/2;
			
			//Preloader
			preloader_sp.x = stage.stageWidth/2;
			preloader_sp.y = stage.stageHeight/2;
			
			//Exit button
			btExit_sp.x = stage.stageWidth;
			btExit_sp.y = 0;
			
			//Preference button
			btPreferences_sp.x = 0;
			btPreferences_sp.y = 0;
			
			//Background
			background_sp.width = stage.stageWidth;
			background_sp.height = stage.stageHeight;
		}
		
	}
}