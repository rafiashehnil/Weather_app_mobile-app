import 'package:flutter/material.dart';
import 'package:weather_today_completed/utils/constants.dart';
import '../utils/custom_paint.dart';
import 'city_screen.dart';
import '../services/network.dart';
import 'loading_screen.dart';

class LocationScreen extends StatefulWidget {
  LocationScreen({this.locationWeather});

  final locationWeather;

  @override
  LocationScreenState createState() => LocationScreenState();
}

class LocationScreenState extends State<LocationScreen> {
  int temperature = 0;
  double minTemperature = 0.0;
  double maxTemperature = 0.0;
  double windSpeed = 0.0;
  int humidity = 50;
  String cityName = "Dhaka";

  @override
  void initState() {
    super.initState();
    updateUI(widget.locationWeather);
  }

  void updateUI(dynamic weatherData) {
    setState(() {
      if (weatherData != null) {
        double temp = weatherData['main']['temp'];
        temperature = temp.toInt();
        minTemperature = weatherData['main']['temp_min'].toDouble();
        maxTemperature = weatherData['main']['temp_max'].toDouble();
        windSpeed = weatherData['wind']['speed'].toDouble();
        humidity = weatherData['main']['humidity'];
        cityName = weatherData['name'];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/location_background.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.09),
              BlendMode.darken,
            ),
          ),
        ),
        constraints: BoxConstraints.expand(),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(height: 16.0),
              Padding(
                padding: EdgeInsets.only(
                  top: 24,
                  left: 16.0,
                  right: 16.0,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        '$temperature°',
                        style: kTempTextStyle,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return LoadingScreen();
                            },
                          ),
                        );
                      },
                      child: Image.asset(
                        'images/ic_current_location.png',
                        width: 32.0,
                      ),
                    ),
                    SizedBox(width: 24.0),
                    GestureDetector(
                      onTap: () async {
                        final searchedCity = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return CityScreen();
                            },
                          ),
                        );

                        if (searchedCity != null && searchedCity is String) {
                          getWeatherData(searchedCity);
                        }
                      },
                      child: Image.asset(
                        'images/ic_search.png',
                        width: 32.0,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(width: 16.0),
                    Image.asset(
                      'images/ic_location_pin.png',
                      width: 24.0,
                      height: 24.0,
                    ),
                    SizedBox(width: 10),
                    Padding(
                      padding: EdgeInsets.only(right: 15.0),
                      child: Text(
                        cityName,
                        textAlign: TextAlign.center,
                        style: kSmallTextStyle.copyWith(
                          fontSize: 16.0,
                          color: Colors.black45,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 190,
                child: CustomPaint(
                  painter: MyCustomPaint(),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 24.0,
                          bottom: 24.0,
                        ),
                        child: Text(
                          'Weather Today',
                          style: kConditionTextStyle.copyWith(fontSize: 16.0),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ConditionRow(
                            icon: 'images/ic_temp.png',
                            title: 'Min Temp',
                            value: '$minTemperature°',
                          ),
                          ConditionRow(
                            icon: 'images/ic_wind_speed.png',
                            title: 'Wind Speed',
                            value: '${windSpeed.toStringAsFixed(1)} Km/h',
                          ),
                          ConditionRow(
                            icon: 'images/ic_temp.png',
                            title: 'Max Temp',
                            value: '$maxTemperature°',
                          ),
                          ConditionRow(
                            icon: 'images/ic_humidity.png',
                            title: 'Humidity',
                            value: '$humidity%',
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void getWeatherData(String cityName) async {
    var weatherData = await getCityWeather(cityName);

    updateUI(weatherData);
  }

  Future<dynamic> getCityWeather(String cityName) async {
    final String weatherUrl =
        "https://api.openweathermap.org/data/2.5/weather?q=$cityName&appid=49cc426143bee1ee3b4653262a27330d&units=metric";
    NetworkHelper networkHelper = NetworkHelper('$weatherUrl');
    var weatherData = await networkHelper.getData();
    return weatherData;
  }
}

class ConditionRow extends StatelessWidget {
  final String icon;
  final String title;
  final String value;

  const ConditionRow({
    Key? key,
    required this.icon,
    required this.title,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          icon,
          width: 24.0,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 8.0,
          ),
          child: Text(
            title,
            style: kConditionTextStyleSmall,
          ),
        ),
        Text(
          value,
          style: kConditionTextStyle,
        ),
      ],
    );
  }
}

