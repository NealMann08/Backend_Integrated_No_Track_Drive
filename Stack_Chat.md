flutter_background_geolocation 4.18.2 copy "flutter_background_geolocation: ^4.18.2" to clipboard
Published 3 days ago • verified publishertransistorsoft.com• Latest: 4.18.2 / Prerelease: 5.0.0-beta.3
SDKFlutterPlatformAndroidiOS
823
Readme
Changelog
Example
Installing
Versions
Scores
flutter_background_geolocation 


The most sophisticated background location-tracking & geofencing module with battery-conscious motion-detection intelligence for iOS and Android.

The plugin's Philosophy of Operation is to use motion-detection APIs (using accelerometer, gyroscope and magnetometer) to detect when the device is moving and stationary.

When the device is detected to be moving, the plugin will automatically start recording a location according to the configured distanceFilter (meters).

When the device is detected be stationary, the plugin will automatically turn off location-services to conserve energy.

Also available for Cordova, React Native, NativeScript and pure native apps.

Note

The Android module requires purchasing a license. However, it will work for DEBUG builds. It will not work with RELEASE builds without purchasing a license. This plugin is supported full-time and field-tested daily since 2013.

Google Play

Home Settings

Contents 
📚 API Documentation 
Installing the Plugin 
Setup Guides 
Using the plugin 
Example 
Debugging 
Demo Application 
Testing Server 
🔷 Installing the Plugin 
📂 pubspec.yaml:

Note: See Versions for latest available version.

dependencies:
  flutter_background_geolocation: '^4.12.0'
Or latest from Git: 
dependencies:
  flutter_background_geolocation:
    git:
      url: https://github.com/transistorsoft/flutter_background_geolocation.git
🔷 Setup Guides 
iOS
Android
🔷 Using the plugin 
import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;
Warning

Note as bg in the import. This is important to namespace the plugin's classes, which often use common class-names such as Location, Config, State. You will access every flutter_background_geolocation class with the prefix bg (ie: "background geolocation").

🔷 Example 
Full Example

There are three main steps to using BackgroundGeolocation:

Wire up event-listeners.
Configure the plugin with #ready.
#start the plugin.
Warning

Do not execute any API method which will require accessing location-services until the .ready(config) method resolves (Read its API docs), For example:

.getCurrentPosition
.start

import 'package:flutter_background_geolocation/flutter_background_geolocation.dart' as bg;

class _MyHomePageState extends State<MyHomePage> {

  @override
  void initState() {
    super.initState();

    ////
    // 1.  Listen to events (See docs for all 12 available events).
    //

    // Fired whenever a location is recorded
    bg.BackgroundGeolocation.onLocation((bg.Location location) {
      print('[location] - $location');
    });

    // Fired whenever the plugin changes motion-state (stationary->moving and vice-versa)
    bg.BackgroundGeolocation.onMotionChange((bg.Location location) {
      print('[motionchange] - $location');
    });

    // Fired whenever the state of location-services changes.  Always fired at boot
    bg.BackgroundGeolocation.onProviderChange((bg.ProviderChangeEvent event) {
      print('[providerchange] - $event');
    });

    ////
    // 2.  Configure the plugin
    //
    bg.BackgroundGeolocation.ready(bg.Config(
        desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
        distanceFilter: 10.0,
        stopOnTerminate: false,
        startOnBoot: true,
        debug: true,
        logLevel: bg.Config.LOG_LEVEL_VERBOSE
    )).then((bg.State state) {
      if (!state.enabled) {
        ////
        // 3.  Start the plugin.
        //
        bg.BackgroundGeolocation.start();
      }
    });
  }
}

🔷 Demo Application 
A fully-featured Demo App is available in the repo in the /example folder.

Google Play

Home Settings

🔷 Simple Testing Server 
A simple Node-based web-application with SQLite database is available for field-testing and performance analysis. If you're familiar with Node, you can have this server up-and-running in about one minute.





License 
The MIT License (MIT)

Copyright (c) 2018 Chris Scott, Transistor Software

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.