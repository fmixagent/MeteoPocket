===============================================

MeteoPocket: weather forecast application (AIR)
by Daniel de Fuenmayor (www.fmixlab.com)

This is the final project I asked my students this year on Aplicacions Rich Media (Rich Media Applications) course at the Universitat Oberta de Catalynya (UOC: Open University of Catalonia http://www.uoc.edu/).
This application (completely operational) is a non-commercial non-profit application with the sole purpose of showing the creation of a multi-platform/multi-devices AIR Application and the use, in this case, of some very useful Yahoo APIs.
 
===============================================


-----------

DESCRIPTION

-----------

An Actionscript3 (AIR) application to get the weekly weather forecast of your city. You can change your city by the preference screen of the application.

You can export MeteoPocket to be installed as:
- a desktop application: PC or MAC
- a mobile native application: iOS or Android
(note: AIR let you export to other platforms as Blackberry, TV, etc… but I haven’t have the time and devices to test it)

The application also adapts to multiple devices sizes (smartphones, tablet, monitor,...) and DPI (Dots Per Inch).


-----------

INFORMATION

-----------

MeteoPocket gets the weather forecast from two really complete and useful Yahoo APIs.


1) Obtain forecast information using Yahoo Weather RSS Feed
http://developer.yahoo.com/weather/

I will use the request:
http://weather.yahooapis.com/forecastrss?w=[WOEID]&u=c&d=[NUMBER_OF_DAYS]

Where:
- WOEID (Where On Earth ID) indicates the place where I want to obtain the weather forecast from.
- NUMBER_OF_DAYS:  how many days in advance I want the weather  forecast to be.


2)  Change the city of your weather forecast 
For this matter I will be using the GeoPlanet API from Yahoo. http://developer.yahoo.com/geo/geoplanet/

This API let us search the WOEID corresponding to a significant landmark, a set of coordinates, etc. In my case I will be using it to do a search by the name of the city and obtain the possible/s WOEID/s.
(note: In this version I grab just the most possible WOEID of my search)


VERY IMPORTANT: You will have to obtain your Yahoo AppID and add it to the MeteoPocket code to test completely MeteoPocket.
Note:  If no AppID is introduce, the city by default is Barcelona (SPAIN). MeteoPocket will still be operational but you won’t be able to change the city. However  you could also change the WOEID directly on the code (WeatherRequest) or add a user functionality to do so.


Getting forecasts from Yahoo is free and has no important restrictions, however the use of this second API you will need to have a Yahoo AppID. 

Obtaining this AppID is very simple (and FREE, with some use restrictions):
1) You will need to have a Yahoo Account (if you don’t have one already)
2) You will have to create your AppId. Just follow the steps on:
https://developer.apps.yahoo.com/wsregapp/

(note: you can find more about the terms and conditions of this API on their site)

Once obtained your AppID add it to MeteoPocket code:

To add your App Id to MeteoPocket just open WeatherCityToWoeidRequest.as and add your AppID on the constant APP_ID declared on the top of the classe.



Voilà!
The rest of the code is already operational and ready for you to test.

As often on any application there’s parts which could be optimised and other functionalities to be add, but I wish it can be useful to whoever is interested on AIR projects and the use of Yahoo Weather APIs.

Keep on truckin'
Dani