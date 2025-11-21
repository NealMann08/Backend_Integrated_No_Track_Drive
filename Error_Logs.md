# Logs for 11/19 - While testing why points are not being recieved while on destop google chrome which also has issues with even clicing the start tracing button.

Sending login request: {email: nov19@gmail.com, password: Winter@1, mode: signin}
js_primitives.dart:28 Auth response received: Login successful
js_primitives.dart:28 Login mode: true, Backend role: driver, Final navigation role: user
m9yn8bsm3k.execute-api.us-west-1.amazonaws.com/analyze-driver?email=nov19@gmail.com:1 
        
        
       Failed to load resource: the server responded with a status of 500 ()
m9yn8bsm3k.execute-api.us-west-1.amazonaws.com/analyze-driver?email=nov19@gmail.com:1 
        
        
       Failed to load resource: the server responded with a status of 500 ()
js_primitives.dart:28 ✅ New trip started: trip_aac094b6-8067-40d1-8c52-2669a48d17ac_1763621338453_621742
js_primitives.dart:28 Base point: Dublin, CA
js_primitives.dart:28 Location permission granted.
errors.dart:274 Uncaught (in promise) Error: Unsupported operation: InternetAddress.lookup
    at Object.throw_ [as throw] (errors.dart:274:3)
    at InternetAddress.lookup (io_patch.dart:440:5)
    at current_trip_page.dart:20:42
    at async_patch.dart:623:19
    at async_patch.dart:648:23
    at Object._asyncStartSync (async_patch.dart:542:3)
    at Object._checkNetworkConnection (current_trip_page.dart:18:14)
    at current_trip_page.dart:211:29
    at async_patch.dart:623:19
    at async_patch.dart:648:23
    at Object._asyncStartSync (async_patch.dart:542:3)
    at current_trip_page.CurrentTripPageState.new.startTrip (current_trip_page.dart:209:16)
    at tear (operations.dart:118:77)
    at dartDevEmbedder.defineLibrary.ink_well._InkResponseState.new.handleTap (ink_well.dart:1204:21)
    at tear (operations.dart:118:77)
    at dartDevEmbedder.defineLibrary.tap.TapGestureRecognizer.new.invokeCallback (recognizer.dart:345:24)
    at dartDevEmbedder.defineLibrary.tap.TapGestureRecognizer.new.handleTapUp (tap.dart:758:11)
    at [_checkUp] (tap.dart:383:5)
    at dartDevEmbedder.defineLibrary.tap.TapGestureRecognizer.new.handlePrimaryPointer (tap.dart:314:7)
    at dartDevEmbedder.defineLibrary.tap.TapGestureRecognizer.new.handleEvent (recognizer.dart:721:9)
    at tear (operations.dart:118:77)
    at [_dispatch] (pointer_router.dart:97:7)
    at pointer_router.dart:142:9
    at dartDevEmbedder.defineLibrary._js_helper.LinkedMap.new.forEach (linked_hash_map.dart:21:7)
    at [_dispatchEventToRoutes] (pointer_router.dart:140:17)
    at dartDevEmbedder.defineLibrary.pointer_router.PointerRouter.new.route (pointer_router.dart:130:7)
    at dartDevEmbedder.defineLibrary.binding.WidgetsFlutterBinding.new.handleEvent (binding.dart:528:5)
    at dartDevEmbedder.defineLibrary.binding.WidgetsFlutterBinding.new.dispatchEvent (binding.dart:498:14)
    at dartDevEmbedder.defineLibrary.binding.WidgetsFlutterBinding.new.dispatchEvent (binding.dart:473:11)
    at [_handlePointerEventImmediately] (binding.dart:437:7)
    at dartDevEmbedder.defineLibrary.binding.WidgetsFlutterBinding.new.handlePointerEvent (binding.dart:394:5)
    at [_flushPointerEventQueue] (binding.dart:341:7)
    at [_handlePointerDataPacket] (binding.dart:308:9)
    at tear (operations.dart:118:77)
    at Object.invoke1 (platform_dispatcher.dart:1537:5)
    at dartDevEmbedder.defineLibrary._engine.EnginePlatformDispatcher.new.invokeOnPointerDataPacket (platform_dispatcher.dart:292:5)
    at [_sendToFramework] (pointer_binding.dart:451:30)
    at dartDevEmbedder.defineLibrary._engine.ClickDebouncer.new.onPointerData (pointer_binding.dart:233:7)
    at dartDevEmbedder.defineLibrary._engine._PointerAdapter.new.tear (operations.dart:118:77)
    at pointer_binding.dart:1070:20
    at pointer_binding.dart:953:7
    at loggedHandler (pointer_binding.dart:576:9)
    at _RootZone.runUnary (zone.dart:1849:54)
    at zone.dart:1804:26
    at Object._callDartFunctionFast1 (js_allow_interop_patch.dart:224:27)
    at ret (js_allow_interop_patch.dart:84:15)


# Successful Loggin it seems to be functioning properly on destop windows chrome, and points are actually accumulating although i am stationary so no actual change in distance.

Sending login request: {email: nov19@gmail.com, password: Winter@1, mode: signin}
js_primitives.dart:28 Auth response received: Login successful
js_primitives.dart:28 Login mode: true, Backend role: driver, Final navigation role: user
m9yn8bsm3k.execute-api.us-west-1.amazonaws.com/analyze-driver?email=nov19@gmail.com:1 
        
        
       Failed to load resource: the server responded with a status of 500 ()
m9yn8bsm3k.execute-api.us-west-1.amazonaws.com/analyze-driver?email=nov19@gmail.com:1 
        
        
       Failed to load resource: the server responded with a status of 500 ()
js_primitives.dart:28 ✅ New trip started: trip_aac094b6-8067-40d1-8c52-2669a48d17ac_1763622552518_704843
js_primitives.dart:28 Base point: Dublin, CA
js_primitives.dart:28 Location permission granted.
js_primitives.dart:28 🌐 Web platform - assuming network connectivity
js_primitives.dart:28 ✅ Location permission validated for platform
js_primitives.dart:28    Platform: Web
js_primitives.dart:28    Permission level: LocationPermission.whileInUse
js_primitives.dart:28 ✅ Created trip: trip_aac094b6-8067-40d1-8c52-2669a48d17ac_1763622559311
js_primitives.dart:28 🌐 ========== WEB PLATFORM TRACKING STARTING ==========
js_primitives.dart:28 🌐 Web platform detected - using timer-based tracking
js_primitives.dart:28 🌐 Timer will trigger every 2 seconds to collect GPS data
js_primitives.dart:28 🌐 Trip ID: trip_aac094b6-8067-40d1-8c52-2669a48d17ac_1763622559311
js_primitives.dart:28 🌐 User ID: aac094b6-8067-40d1-8c52-2669a48d17ac
js_primitives.dart:28 ✅ ========== WEB TRACKING STARTED SUCCESSFULLY ==========
js_primitives.dart:28 🌐 GPS polling is active - check console for updates
js_primitives.dart:28 🌐 UI will update with speed and point count
js_primitives.dart:28 🌐 ========== WEB GPS POLL #0 ==========
js_primitives.dart:28 🌐 Requesting GPS position...
js_primitives.dart:28 ✅ GPS position obtained - Accuracy: 929.2633619571187m
js_primitives.dart:28 📊 Web: Using GPS speed: 0.0 mph
js_primitives.dart:28 📊 Delta point stored - Buffer size: 1/25
js_primitives.dart:28 ✅ Web tracking - Point #1 collected
js_primitives.dart:28 ✅ Speed: 0.0 mph, Max: 0.0 mph
js_primitives.dart:28 🌐 ========== WEB GPS POLL #1 END ==========
js_primitives.dart:28 🌐 ========== WEB GPS POLL #1 ==========
js_primitives.dart:28 🌐 Requesting GPS position...
js_primitives.dart:28 ✅ GPS position obtained - Accuracy: 929.2633619571187m
js_primitives.dart:28 📊 Web: Using GPS speed: 0.0 mph
js_primitives.dart:28 📊 Delta point stored - Buffer size: 2/25
js_primitives.dart:28 ✅ Web tracking - Point #2 collected
js_primitives.dart:28 ✅ Speed: 0.0 mph, Max: 0.0 mph
js_primitives.dart:28 🌐 ========== WEB GPS POLL #2 END ==========
js_primitives.dart:28 🌐 ========== WEB GPS POLL #2 ==========
js_primitives.dart:28 🌐 Requesting GPS position...
js_primitives.dart:28 ✅ GPS position obtained - Accuracy: 929.2633619571187m
js_primitives.dart:28 📊 Web: Using GPS speed: 0.0 mph
js_primitives.dart:28 📊 Delta point stored - Buffer size: 3/25
js_primitives.dart:28 ✅ Web tracking - Point #3 collected
js_primitives.dart:28 ✅ Speed: 0.0 mph, Max: 0.0 mph
js_primitives.dart:28 🌐 ========== WEB GPS POLL #3 END ==========
js_primitives.dart:28 🌐 ========== WEB GPS POLL #3 ==========
js_primitives.dart:28 🌐 Requesting GPS position...
js_primitives.dart:28 ✅ GPS position obtained - Accuracy: 929.2633619571187m
js_primitives.dart:28 📊 Web: Using GPS speed: 0.0 mph
js_primitives.dart:28 📊 Delta point stored - Buffer size: 4/25
js_primitives.dart:28 ✅ Web tracking - Point #4 collected
js_primitives.dart:28 ✅ Speed: 0.0 mph, Max: 0.0 mph
js_primitives.dart:28 🌐 ========== WEB GPS POLL #4 END ==========
js_primitives.dart:28 🌐 ========== WEB GPS POLL #4 ==========
js_primitives.dart:28 🌐 Requesting GPS position...
js_primitives.dart:28 ✅ GPS position obtained - Accuracy: 929.2633619571187m
js_primitives.dart:28 📊 Web: Using GPS speed: 0.0 mph
js_primitives.dart:28 📊 Delta point stored - Buffer size: 5/25
js_primitives.dart:28 ✅ Web tracking - Point #5 collected
js_primitives.dart:28 ✅ Speed: 0.0 mph, Max: 0.0 mph
js_primitives.dart:28 🌐 ========== WEB GPS POLL #5 END ==========
js_primitives.dart:28 🌐 ========== WEB GPS POLL #5 ==========
js_primitives.dart:28 🌐 Requesting GPS position...
js_primitives.dart:28 ✅ GPS position obtained - Accuracy: 929.2633619571187m
js_primitives.dart:28 📊 Web: Using GPS speed: 0.0 mph
js_primitives.dart:28 📊 Delta point stored - Buffer size: 6/25
js_primitives.dart:28 ✅ Web tracking - Point #6 collected
js_primitives.dart:28 ✅ Speed: 0.0 mph, Max: 0.0 mph
js_primitives.dart:28 🌐 ========== WEB GPS POLL #6 END ==========
js_primitives.dart:28 🌐 ========== WEB GPS POLL #6 ==========
js_primitives.dart:28 🌐 Requesting GPS position...
js_primitives.dart:28 ✅ GPS position obtained - Accuracy: 929.2633619571187m
js_primitives.dart:28 📊 Web: Using GPS speed: 0.0 mph
js_primitives.dart:28 📊 Delta point stored - Buffer size: 7/25
js_primitives.dart:28 ✅ Web tracking - Point #7 collected
js_primitives.dart:28 ✅ Speed: 0.0 mph, Max: 0.0 mph
js_primitives.dart:28 🌐 ========== WEB GPS POLL #7 END ==========
js_primitives.dart:28 🌐 ========== WEB GPS POLL #7 ==========
js_primitives.dart:28 🌐 Requesting GPS position...
js_primitives.dart:28 ✅ GPS position obtained - Accuracy: 929.2633619571187m
js_primitives.dart:28 📊 Web: Using GPS speed: 0.0 mph
js_primitives.dart:28 📊 Delta point stored - Buffer size: 8/25
js_primitives.dart:28 ✅ Web tracking - Point #8 collected
js_primitives.dart:28 ✅ Speed: 0.0 mph, Max: 0.0 mph
js_primitives.dart:28 🌐 ========== WEB GPS POLL #8 END ==========
js_primitives.dart:28 🌐 ========== WEB GPS POLL #8 ==========
js_primitives.dart:28 🌐 Requesting GPS position...
js_primitives.dart:28 ✅ GPS position obtained - Accuracy: 929.2633619571187m
js_primitives.dart:28 📊 Web: Using GPS speed: 0.0 mph
js_primitives.dart:28 📊 Delta point stored - Buffer size: 9/25
js_primitives.dart:28 ✅ Web tracking - Point #9 collected
js_primitives.dart:28 ✅ Speed: 0.0 mph, Max: 0.0 mph
js_primitives.dart:28 🌐 ========== WEB GPS POLL #9 END ==========
js_primitives.dart:28 🌐 ========== WEB GPS POLL #9 ==========
js_primitives.dart:28 🌐 Requesting GPS position...
js_primitives.dart:28 ✅ GPS position obtained - Accuracy: 929.2633619571187m
js_primitives.dart:28 📊 Web: Using GPS speed: 0.0 mph
js_primitives.dart:28 📊 Delta point stored - Buffer size: 10/25
js_primitives.dart:28 ✅ Web tracking - Point #10 collected
js_primitives.dart:28 ✅ Speed: 0.0 mph, Max: 0.0 mph
js_primitives.dart:28 🌐 ========== WEB GPS POLL #10 END ==========
js_primitives.dart:28 🌐 ========== WEB GPS POLL #10 ==========
js_primitives.dart:28 🌐 Requesting GPS position...
js_primitives.dart:28 ✅ GPS position obtained - Accuracy: 929.2633619571187m
js_primitives.dart:28 📊 Web: Using GPS speed: 0.0 mph
js_primitives.dart:28 📊 Delta point stored - Buffer size: 11/25
js_primitives.dart:28 ✅ Web tracking - Point #11 collected
js_primitives.dart:28 ✅ Speed: 0.0 mph, Max: 0.0 mph
js_primitives.dart:28 🌐 ========== WEB GPS POLL #11 END ==========
js_primitives.dart:28 🌐 ========== WEB GPS POLL #11 ==========
js_primitives.dart:28 🌐 Requesting GPS position...
js_primitives.dart:28 ✅ GPS position obtained - Accuracy: 929.2633619571187m
js_primitives.dart:28 📊 Web: Using GPS speed: 0.0 mph
js_primitives.dart:28 📊 Delta point stored - Buffer size: 12/25
js_primitives.dart:28 ✅ Web tracking - Point #12 collected
js_primitives.dart:28 ✅ Speed: 0.0 mph, Max: 0.0 mph
js_primitives.dart:28 🌐 ========== WEB GPS POLL #12 END ==========
js_primitives.dart:28 🌐 ========== WEB GPS POLL #12 ==========
js_primitives.dart:28 🌐 Requesting GPS position...
js_primitives.dart:28 ✅ GPS position obtained - Accuracy: 929.2633619571187m
js_primitives.dart:28 📊 Web: Using GPS speed: 0.0 mph
js_primitives.dart:28 📊 Delta point stored - Buffer size: 13/25
js_primitives.dart:28 ✅ Web tracking - Point #13 collected
js_primitives.dart:28 ✅ Speed: 0.0 mph, Max: 0.0 mph
js_primitives.dart:28 🌐 ========== WEB GPS POLL #13 END ==========
js_primitives.dart:28 🌐 ========== WEB GPS POLL #13 ==========
js_primitives.dart:28 🌐 Requesting GPS position...
js_primitives.dart:28 ✅ GPS position obtained - Accuracy: 929.2633619571187m
js_primitives.dart:28 📊 Web: Using GPS speed: 0.0 mph
js_primitives.dart:28 📊 Delta point stored - Buffer size: 14/25
js_primitives.dart:28 ✅ Web tracking - Point #14 collected
js_primitives.dart:28 ✅ Speed: 0.0 mph, Max: 0.0 mph
js_primitives.dart:28 🌐 ========== WEB GPS POLL #14 END ==========
js_primitives.dart:28 🌐 ========== WEB GPS POLL #14 ==========
js_primitives.dart:28 🌐 Requesting GPS position...
js_primitives.dart:28 ✅ GPS position obtained - Accuracy: 929.2633619571187m
js_primitives.dart:28 📊 Web: Using GPS speed: 0.0 mph
js_primitives.dart:28 📊 Delta point stored - Buffer size: 15/25
js_primitives.dart:28 ✅ Web tracking - Point #15 collected
js_primitives.dart:28 ✅ Speed: 0.0 mph, Max: 0.0 mph
js_primitives.dart:28 🌐 ========== WEB GPS POLL #15 END ==========
js_primitives.dart:28 🌐 ========== WEB GPS POLL #15 ==========
js_primitives.dart:28 🌐 Requesting GPS position...
js_primitives.dart:28 ✅ GPS position obtained - Accuracy: 929.2633619571187m
js_primitives.dart:28 📊 Web: Using GPS speed: 0.0 mph
js_primitives.dart:28 📊 Delta point stored - Buffer size: 16/25
js_primitives.dart:28 ✅ Web tracking - Point #16 collected
js_primitives.dart:28 ✅ Speed: 0.0 mph, Max: 0.0 mph
js_primitives.dart:28 🌐 ========== WEB GPS POLL #16 END ==========
js_primitives.dart:28 🌐 ========== WEB GPS POLL #16 ==========
js_primitives.dart:28 🌐 Requesting GPS position...
js_primitives.dart:28 ✅ GPS position obtained - Accuracy: 929.2633619571187m
js_primitives.dart:28 📊 Web: Using GPS speed: 0.0 mph
js_primitives.dart:28 📊 Delta point stored - Buffer size: 17/25
js_primitives.dart:28 ✅ Web tracking - Point #17 collected
js_primitives.dart:28 ✅ Speed: 0.0 mph, Max: 0.0 mph
js_primitives.dart:28 🌐 ========== WEB GPS POLL #17 END ==========
js_primitives.dart:28 🌐 ========== WEB GPS POLL #17 ==========
js_primitives.dart:28 🌐 Requesting GPS position...
js_primitives.dart:28 ✅ GPS position obtained - Accuracy: 929.2633619571187m
js_primitives.dart:28 📊 Web: Using GPS speed: 0.0 mph
js_primitives.dart:28 📊 Delta point stored - Buffer size: 18/25
js_primitives.dart:28 ✅ Web tracking - Point #18 collected
js_primitives.dart:28 ✅ Speed: 0.0 mph, Max: 0.0 mph
js_primitives.dart:28 🌐 ========== WEB GPS POLL #18 END ==========
js_primitives.dart:28 🌐 ========== WEB GPS POLL #18 ==========
js_primitives.dart:28 🌐 Requesting GPS position...
js_primitives.dart:28 ✅ GPS position obtained - Accuracy: 929.2633619571187m
js_primitives.dart:28 📊 Web: Using GPS speed: 0.0 mph
js_primitives.dart:28 📊 Delta point stored - Buffer size: 19/25
js_primitives.dart:28 ✅ Web tracking - Point #19 collected
js_primitives.dart:28 ✅ Speed: 0.0 mph, Max: 0.0 mph
js_primitives.dart:28 🌐 ========== WEB GPS POLL #19 END ==========
js_primitives.dart:28 🌐 ========== WEB GPS POLL #19 ==========
js_primitives.dart:28 🌐 Requesting GPS position...
js_primitives.dart:28 ✅ GPS position obtained - Accuracy: 929.2633619571187m
js_primitives.dart:28 📊 Web: Using GPS speed: 0.0 mph
js_primitives.dart:28 📊 Delta point stored - Buffer size: 20/25
js_primitives.dart:28 ✅ Web tracking - Point #20 collected
js_primitives.dart:28 ✅ Speed: 0.0 mph, Max: 0.0 mph
js_primitives.dart:28 🌐 ========== WEB GPS POLL #20 END ==========
js_primitives.dart:28 🌐 ========== WEB GPS POLL #20 ==========
js_primitives.dart:28 🌐 Requesting GPS position...
js_primitives.dart:28 ✅ GPS position obtained - Accuracy: 929.2633619571187m
js_primitives.dart:28 📊 Web: Using GPS speed: 0.0 mph
js_primitives.dart:28 📊 Delta point stored - Buffer size: 21/25
js_primitives.dart:28 ✅ Web tracking - Point #21 collected
js_primitives.dart:28 ✅ Speed: 0.0 mph, Max: 0.0 mph
js_primitives.dart:28 🌐 ========== WEB GPS POLL #21 END ==========
js_primitives.dart:28 🌐 ========== WEB GPS POLL #21 ==========
js_primitives.dart:28 🌐 Requesting GPS position...
js_primitives.dart:28 ✅ GPS position obtained - Accuracy: 929.2633619571187m
js_primitives.dart:28 📊 Web: Using GPS speed: 0.0 mph
js_primitives.dart:28 📊 Delta point stored - Buffer size: 22/25
js_primitives.dart:28 ✅ Web tracking - Point #22 collected
js_primitives.dart:28 ✅ Speed: 0.0 mph, Max: 0.0 mph
js_primitives.dart:28 🌐 ========== WEB GPS POLL #22 END ==========
js_primitives.dart:28 🌐 ========== WEB GPS POLL #22 ==========
js_primitives.dart:28 🌐 Requesting GPS position...
js_primitives.dart:28 ✅ GPS position obtained - Accuracy: 929.2633619571187m
js_primitives.dart:28 📊 Web: Using GPS speed: 0.0 mph
js_primitives.dart:28 📊 Delta point stored - Buffer size: 23/25
js_primitives.dart:28 ✅ Web tracking - Point #23 collected
js_primitives.dart:28 ✅ Speed: 0.0 mph, Max: 0.0 mph
js_primitives.dart:28 🌐 ========== WEB GPS POLL #23 END ==========
js_primitives.dart:28 🌐 ========== WEB GPS POLL #23 ==========
js_primitives.dart:28 🌐 Requesting GPS position...
js_primitives.dart:28 ✅ GPS position obtained - Accuracy: 929.2633619571187m
js_primitives.dart:28 📊 Web: Using GPS speed: 0.0 mph
js_primitives.dart:28 📊 Delta point stored - Buffer size: 24/25
js_primitives.dart:28 ✅ Web tracking - Point #24 collected
js_primitives.dart:28 ✅ Speed: 0.0 mph, Max: 0.0 mph
js_primitives.dart:28 🌐 ========== WEB GPS POLL #24 END ==========
js_primitives.dart:28 🌐 ========== WEB GPS POLL #24 ==========
js_primitives.dart:28 🌐 Requesting GPS position...
js_primitives.dart:28 ✅ GPS position obtained - Accuracy: 929.2633619571187m
js_primitives.dart:28 📊 Web: Using GPS speed: 0.0 mph
js_primitives.dart:28 📊 Delta point stored - Buffer size: 25/25
js_primitives.dart:28 📤 ========== WEB BATCH READY ==========
js_primitives.dart:28 🌐 ========== SENDING WEB BATCH TO SERVER ==========
js_primitives.dart:28 👤 User ID: aac094b6-8067-40d1-8c52-2669a48d17ac
js_primitives.dart:28 🚗 Trip ID: trip_aac094b6-8067-40d1-8c52-2669a48d17ac_1763622559311
js_primitives.dart:28 📦 Batch number: 1
js_primitives.dart:28 📊 Delta points: 25
js_primitives.dart:28 📡 Making HTTP POST request to backend...
js_primitives.dart:28 🌐 Endpoint: https://m9yn8bsm3k.execute-api.us-west-1.amazonaws.com/store-trajectory-batch
js_primitives.dart:28 📡 Response received: Status 200
js_primitives.dart:28 ✅ ========== WEB BATCH UPLOADED SUCCESSFULLY ==========
js_primitives.dart:28 ✅ Batch #1 uploaded successfully
js_primitives.dart:28 ✅ Response body: {"message": "Bulletproof trajectory batch stored successfully", "batch_id": "trip_aac094b6-8067-40d1-8c52-2669a48d17ac_1763622559311_batch_1", "deltas_count": 25, "original_deltas_count": 25, "acceptance_rate": "100.0%", "enhancement_level": "high", "quality_score": 0.9, "batch_statistics": {"total_deltas": 25, "enhanced_deltas": 25, "average_speed": 0.0, "average_confidence": 0.9499999999999996, "average_gps_accuracy": 929.2633619571181, "stationary_points": 25, "high_quality_points": 0, "movement_points": 0}, "quality_issues_count": 25, "movement_detected": false, "validation_method": "bulletproof_with_safe_conversion"}
js_primitives.dart:28 📦 Buffer cleared, ready for next batch
js_primitives.dart:28 🌐 ========== WEB BATCH SEND COMPLETE ==========
js_primitives.dart:28 ✅ Web tracking - Point #25 collected
js_primitives.dart:28 ✅ Speed: 0.0 mph, Max: 0.0 mph
js_primitives.dart:28 🌐 ========== WEB GPS POLL #25 END ==========
js_primitives.dart:28 🌐 ========== WEB GPS POLL #25 ==========
js_primitives.dart:28 🌐 Requesting GPS position...
js_primitives.dart:28 ✅ GPS position obtained - Accuracy: 929.2633619571187m
js_primitives.dart:28 📊 Web: Using GPS speed: 0.0 mph
js_primitives.dart:28 📊 Delta point stored - Buffer size: 1/25
js_primitives.dart:28 ✅ Web tracking - Point #26 collected
js_primitives.dart:28 ✅ Speed: 0.0 mph, Max: 0.0 mph
js_primitives.dart:28 🌐 ========== WEB GPS POLL #26 END ==========
js_primitives.dart:28 🌐 ========== WEB GPS POLL #26 ==========
js_primitives.dart:28 🌐 Requesting GPS position...
js_primitives.dart:28 ✅ GPS position obtained - Accuracy: 929.2633619571187m
js_primitives.dart:28 📊 Web: Using GPS speed: 0.0 mph
js_primitives.dart:28 📊 Delta point stored - Buffer size: 2/25
js_primitives.dart:28 ✅ Web tracking - Point #27 collected
js_primitives.dart:28 ✅ Speed: 0.0 mph, Max: 0.0 mph
js_primitives.dart:28 🌐 ========== WEB GPS POLL #27 END ==========
js_primitives.dart:28 🌐 ========== STOPPING WEB TRACKING ==========
js_primitives.dart:28 📤 Sending final batch with 2 remaining points
js_primitives.dart:28 🌐 ========== SENDING WEB BATCH TO SERVER ==========
js_primitives.dart:28 👤 User ID: aac094b6-8067-40d1-8c52-2669a48d17ac
js_primitives.dart:28 🚗 Trip ID: trip_aac094b6-8067-40d1-8c52-2669a48d17ac_1763622559311
js_primitives.dart:28 📦 Batch number: 2
js_primitives.dart:28 📊 Delta points: 2
js_primitives.dart:28 📡 Making HTTP POST request to backend...
js_primitives.dart:28 🌐 Endpoint: https://m9yn8bsm3k.execute-api.us-west-1.amazonaws.com/store-trajectory-batch
js_primitives.dart:28 📡 Response received: Status 200
js_primitives.dart:28 ✅ ========== WEB BATCH UPLOADED SUCCESSFULLY ==========
js_primitives.dart:28 ✅ Batch #2 uploaded successfully
js_primitives.dart:28 ✅ Response body: {"message": "Bulletproof trajectory batch stored successfully", "batch_id": "trip_aac094b6-8067-40d1-8c52-2669a48d17ac_1763622559311_batch_2", "deltas_count": 2, "original_deltas_count": 2, "acceptance_rate": "100.0%", "enhancement_level": "high", "quality_score": 0.9, "batch_statistics": {"total_deltas": 2, "enhanced_deltas": 2, "average_speed": 0.0, "average_confidence": 0.95, "average_gps_accuracy": 929.2633619571187, "stationary_points": 2, "high_quality_points": 0, "movement_points": 0}, "quality_issues_count": 2, "movement_detected": false, "validation_method": "bulletproof_with_safe_conversion"}
js_primitives.dart:28 📦 Buffer cleared, ready for next batch
js_primitives.dart:28 🌐 ========== WEB BATCH SEND COMPLETE ==========
js_primitives.dart:28 🌐 Web tracking stopped
js_primitives.dart:28 🌐 Web platform - assuming network connectivity
js_primitives.dart:28 📊 Finalizing trip: trip_aac094b6-8067-40d1-8c52-2669a48d17ac_1763622559311 with 27 points
js_primitives.dart:28 🌐 Timer cancelled - trip stopped or widget unmounted
js_primitives.dart:28 ✅ Trip finalized successfully

# November 20th  - Essentially the app seems to be receiving data when testing on computer device the points counter does increase however coordinates change remains zero since computer is not moving, however same app when run on iphone does not even accumulate teh number of points, even upon moving, not sure what issue is but below are the logs

flutter: Sending login request: {email: nm08@gmail.com, password: Winter@1, mode: signin}
flutter: Auth response received: Login successful
flutter: Login mode: true, Backend role: driver, Final navigation role: user
flutter: ✅ New trip started: trip_a6d2d070-7a66-45b0-a899-63d733467955_1763691708912_326265
flutter: Base point: Dublin, CA
flutter: Location permission granted.
flutter: ✅ Location permission validated for platform
flutter:    Platform: Mobile
flutter:    Permission level: LocationPermission.always
flutter: ✅ Created trip: trip_a6d2d070-7a66-45b0-a899-63d733467955_1763691714421
flutter: 📱 Mobile platform detected - using foreground service
flutter: 🚀 ========== STARTING FOREGROUND SERVICE ==========
flutter: 📱 Platform: Mobile (Android/iOS)
flutter: 🚗 Trip ID: trip_a6d2d070-7a66-45b0-a899-63d733467955_1763691714421
Please register the registerPlugins function using the SwiftFlutterForegroundTaskPlugin.setPluginRegistrantCallback.
flutter: 📊 Service start result: Instance of 'ServiceRequestSuccess'
flutter: 🔍 Checking if service is running: true
flutter: 📊 Service successfully started: true
flutter: ✅ ========== FOREGROUND SERVICE STARTED SUCCESSFULLY ==========
flutter: ✅ Background location tracking is ACTIVE
flutter: ✅ GPS polling will occur every 2 seconds
flutter: ✅ Check console for location events
flutter: ✅ Look for messages like "REPEAT EVENT TRIGGERED"
flutter: 📱 UI Update Check - Points: 0, Speed: 0.0 mph, Max: 0.0 mph
flutter: 📱 UI Update Check - Points: 0, Speed: 0.0 mph, Max: 0.0 mph
flutter: 📱 UI Update Check - Points: 0, Speed: 0.0 mph, Max: 0.0 mph
flutter: 📱 UI Update Check - Points: 0, Speed: 0.0 mph, Max: 0.0 mph
flutter: 📱 UI Update Check - Points: 0, Speed: 0.0 mph, Max: 0.0 mph
flutter: 📱 UI Update Check - Points: 0, Speed: 0.0 mph, Max: 0.0 mph
flutter: 📱 UI Update Check - Points: 0, Speed: 0.0 mph, Max: 0.0 mph
flutter: 📱 UI Update Check - Points: 0, Speed: 0.0 mph, Max: 0.0 mph
flutter: 📱 UI Update Check - Points: 0, Speed: 0.0 mph, Max: 0.0 mph
flutter: 📱 UI Update Check - Points: 0, Speed: 0.0 mph, Max: 0.0 mph
flutter: 📱 UI Update Check - Points: 0, Speed: 0.0 mph, Max: 0.0 mph
flutter: 📱 UI Update Check - Points: 0, Speed: 0.0 mph, Max: 0.0 mph
flutter: 📱 UI Update Check - Points: 0, Speed: 0.0 mph, Max: 0.0 mph
flutter: 📱 UI Update Check - Points: 0, Speed: 0.0 mph, Max: 0.0 mph
flutter: 📱 UI Update Check - Points: 0, Speed: 0.0 mph, Max: 0.0 mph
flutter: 📱 UI Update Check - Points: 0, Speed: 0.0 mph, Max: 0.0 mph
flutter: 📱 UI Update Check - Points: 0, Speed: 0.0 mph, Max: 0.0 mph
flutter: 📱 UI Update Check - Points: 0, Speed: 0.0 mph, Max: 0.0 mph
flutter: 📱 UI Update Check - Points: 0, Speed: 0.0 mph, Max: 0.0 mph
flutter: 📱 UI Update Check - Points: 0, Speed: 0.0 mph, Max: 0.0 mph
flutter: 📱 UI Update Check - Points: 0, Speed: 0.0 mph, Max: 0.0 mph
flutter: 📱 UI Update Check - Points: 0, Speed: 0.0 mph, Max: 0.0 mph
flutter: 📱 UI Update Check - Points: 0, Speed: 0.0 mph, Max: 0.0 mph
flutter: 📱 UI Update Check - Points: 0, Speed: 0.0 mph, Max: 0.0 mph
flutter: 📱 UI Update Check - Points: 0, Speed: 0.0 mph, Max: 0.0 mph
flutter: 📱 UI Update Check - Points: 0, Speed: 0.0 mph, Max: 0.0 mph
flutter: 📱 UI Update Check - Points: 0, Speed: 0.0 mph, Max: 0.0 mph
flutter: 📱 UI Update Check - Points: 0, Speed: 0.0 mph, Max: 0.0 mph
flutter: 📱 UI Update Check - Points: 0, Speed: 0.0 mph, Max: 0.0 mph
flutter: 📱 UI Update Check - Points: 0, Speed: 0.0 mph, Max: 0.0 mph
flutter: 📱 UI Update Check - Points: 0, Speed: 0.0 mph, Max: 0.0 mph
flutter: 📱 UI Update Check - Points: 0, Speed: 0.0 mph, Max: 0.0 mph
flutter: 📱 UI Update Check - Points: 0, Speed: 0.0 mph, Max: 0.0 mph
flutter: 📱 UI Update Check - Points: 0, Speed: 0.0 mph, Max: 0.0 mph
flutter: 📱 UI Update Check - Points: 0, Speed: 0.0 mph, Max: 0.0 mph
flutter: 📱 UI Update Check - Points: 0, Speed: 0.0 mph, Max: 0.0 mph
flutter: 📱 UI Update Check - Points: 0, Speed: 0.0 mph, Max: 0.0 mph
flutter: 📱 UI Update Check - Points: 0, Speed: 0.0 mph, Max: 0.0 mph
flutter: 📱 UI Update Check - Points: 0, Speed: 0.0 mph, Max: 0.0 mph
flutter: 📱 UI Update Check - Points: 0, Speed: 0.0 mph, Max: 0.0 mph
flutter: 📱 UI Update Check - Points: 0, Speed: 0.0 mph, Max: 0.0 mph
flutter: 📱 UI Update Check - Points: 0, Speed: 0.0 mph, Max: 0.0 mph
flutter: 📱 UI Update Check - Points: 0, Speed: 0.0 mph, Max: 0.0 mph
flutter: 📱 UI Update Check - Points: 0, Speed: 0.0 mph, Max: 0.0 mph
flutter: 📱 Stopping mobile foreground service
flutter: 📊 Finalizing trip: trip_a6d2d070-7a66-45b0-a899-63d733467955_1763691714421 with 0 points
flutter: ✅ Trip finalized successfully

# NOVEMBER 20th 10pm

# Exact error that occurs when I try to do step three of your build process with flutter build ios --release, is this a big problem that needs to be fixed or no? Can i skip this step It might just have something to do with my xcode setup? 

sandeepmann@macbookpro Backend_Integrated_No_Track_Drive % flutter build ios --release

Building com.neal.driveGuard for device (ios-release)...
Automatically signing iOS for device deployment using specified development team in Xcode project: 32L9HYCPDN
Running pod install...                                           2,718ms
Running Xcode build...                                                  
Xcode build done.                                           50.4s
Failed to build iOS app
Error output from Xcode build:
↳
    AssertMacros: amdErr = AMDeviceConnect(tmpDevice) == 0 ,  file:
    /AppleInternal/Library/BuildRoots/4~B5lnugAmzyNZn31SSjPArj8QPAbWVEgb-FGD05Y/Library/Caches/com.apple.xbs/Source
    s/MobileDevice/Source/AMDevicePowerAssertion.c, line: 224, value: -402653083
    ** BUILD FAILED **


Xcode's output:
↳
    Writing result bundle at path:
        /var/folders/pl/kb1_lmkj7_zgjvt_78tprkyh0000gn/T/flutter_tools.XUuiO8/flutter_ios_build_temp_direk9OJ8/tempora
        ry_xcresult_bundle

    /Users/sandeepmann/.pub-cache/hosted/pub.dev/flutter_foreground_task-8.17.0/ios/Classes/service/BackgroundServi
    ce.swift:132:27: warning: 'alert' was deprecated in iOS 14.0
          completionHandler([.alert, .sound])
                              ^
    /Users/sandeepmann/.pub-cache/hosted/pub.dev/flutter_foreground_task-8.17.0/ios/Classes/service/BackgroundServi
    ce.swift:134:27: warning: 'alert' was deprecated in iOS 14.0
          completionHandler([.alert])
                              ^
    /Users/sandeepmann/.pub-cache/hosted/pub.dev/flutter_foreground_task-8.17.0/ios/Classes/SwiftFlutterForegroundT
    askPlugin.swift:180:7: warning: class 'AppRefreshOperation' must restate inherited '@unchecked Sendable'
    conformance
    class AppRefreshOperation: Operation {
          ^
    /Users/sandeepmann/.pub-cache/hosted/pub.dev/flutter_foreground_task-8.17.0/ios/Classes/SwiftFlutterForegroundT
    askPlugin.swift:88:26: warning: 'setMinimumBackgroundFetchInterval' was deprecated in iOS 13.0: Use a
    BGAppRefreshTask in the BackgroundTasks framework instead
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplication.backgroundFetchIntervalMinimum)
                             ^
    /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang -cc1
    -Wundef-prefix\=TARGET_OS_ -fdiagnostics-show-note-include-stack -fmacro-backtrace-limit\=0 -ferror-limit 19
    -serialize-diagnostic-file
    /Users/sandeepmann/Library/Developer/Xcode/DerivedData/Runner-cdzkurfjewjsrcdhcadlpcmqmpqp/Build/Intermediates.
    noindex/Pods.build/Release-iphoneos/geolocator_apple.build/Objects-normal/arm64/PermissionHandler.dia
    -Wdeprecated-objc-isa-usage -Werror\=deprecated-objc-isa-usage -Werror\=implicit-function-declaration
    -Wnon-modular-include-in-framework-module -Werror\=non-modular-include-in-framework-module -Wno-trigraphs
    -Wno-missing-field-initializers -Wno-missing-prototypes -Werror\=return-type -Wdocumentation -Wunreachable-code
    -Wno-implicit-atomic-properties -Werror\=deprecated-objc-isa-usage -Wno-objc-interface-ivars
    -Werror\=objc-root-class -Wno-arc-repeated-use-of-weak -Wimplicit-retain-self -Wduplicate-method-match
    -Wno-missing-braces -Wparentheses -Wswitch -Wunused-function -Wno-unused-label -Wno-unused-parameter
    -Wunused-variable -Wunused-value -Wempty-body -Wuninitialized -Wconditional-uninitialized -Wno-unknown-pragmas
    -Wno-shadow -Wno-four-char-constants -Wno-conversion -Wconstant-conversion -Wint-conversion -Wbool-conversion
    -Wenum-conversion -Wno-float-conversion -Wnon-literal-null-conversion -Wobjc-literal-conversion
    -Wshorten-64-to-32 -Wpointer-sign -Wno-newline-eof -Wno-selector -Wno-strict-selector-match
    -Wundeclared-selector -Wdeprecated-implementations -Wno-implicit-fallthrough -Wprotocol
    -Wdeprecated-declarations -Wno-sign-conversion -Winfinite-recursion -Wcomma -Wblock-capture-autoreleasing
    -Wstrict-prototypes -Wno-semicolon-before-method-body -Wunguarded-availability -Wno-reorder-init-list
    -Wno-implicit-int-float-conversion -Wno-c99-designator -Wno-final-dtor-non-final-class -Wno-extra-semi-stmt
    -Wno-misleading-indentation -Wno-quoted-include-in-framework-header -Wno-implicit-fallthrough
    -Wno-enum-enum-conversion -Wno-enum-float-conversion -Wno-elaborated-enum-base -Wno-reserved-identifier
    -Wno-gnu-folding-constant
    -fmodule-map-file\=/Users/sandeepmann/Documents/Neal/No_Track_Drive_Neal/Backend_Integrated_No_Track_Drive/buil
    d/ios/Release-iphoneos/geolocator_apple/geolocator_apple.framework/Modules/module.modulemap
    -fmodule-map-file\=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhone
    OS.sdk/System/Library/Frameworks/UIKit.framework/Modules/module.modulemap
    -fmodule-map-file\=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhone
    OS.sdk/System/Library/Frameworks/Foundation.framework/Modules/module.modulemap
    -fmodule-map-file\=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhone
    OS.sdk/System/Library/Frameworks/CoreLocation.framework/Modules/module.modulemap -o
    /Users/sandeepmann/Library/Developer/Xcode/DerivedData/Runner-cdzkurfjewjsrcdhcadlpcmqmpqp/Build/Intermediates.
    noindex/Pods.build/Release-iphoneos/geolocator_apple.build/Objects-normal/arm64/PermissionHandler.o
    -disable-free -emit-obj -x objective-c
    /Users/sandeepmann/.pub-cache/hosted/pub.dev/geolocator_apple-2.3.13/darwin/geolocator_apple/Sources/geolocator
    _apple/Handlers/PermissionHandler.m -target-abi darwinpcs -target-cpu apple-a7 -target-feature +v8a
    -target-feature +aes -target-feature +fp-armv8 -target-feature +sha2 -target-feature +neon -target-feature +zcm
    -target-feature +zcz -triple arm64-apple-ios14.0.0 -target-linker-version 1115.7.3 -target-sdk-version\=18.1
    -fmodules-validate-system-headers -fno-modulemap-allow-subdirectory-search -isysroot
    /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS18.1.sdk
    -resource-dir /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/clang/16
    -fmodule-format\=obj
    -fmodule-file\=CoreLocation\=/Users/sandeepmann/Library/Developer/Xcode/DerivedData/Runner-cdzkurfjewjsrcdhcadl
    pcmqmpqp/Build/Intermediates.noindex/ExplicitPrecompiledModules/CoreLocation-193CSLPFPUJI5TASCUNDQLONQ.pcm
    -fmodule-file\=Foundation\=/Users/sandeepmann/Library/Developer/Xcode/DerivedData/Runner-cdzkurfjewjsrcdhcadlpc
    mqmpqp/Build/Intermediates.noindex/ExplicitPrecompiledModules/Foundation-B8ER1U5KDKZY53BN81L7A92KB.pcm
    -fmodule-file\=UIKit\=/Users/sandeepmann/Library/Developer/Xcode/DerivedData/Runner-cdzkurfjewjsrcdhcadlpcmqmpq
    p/Build/Intermediates.noindex/ExplicitPrecompiledModules/UIKit-ETTT3NA9RMWP7PDHVR8B239UT.pcm -I
    /Users/sandeepmann/Library/Developer/Xcode/DerivedData/Runner-cdzkurfjewjsrcdhcadlpcmqmpqp/Build/Intermediates.
    noindex/Pods.build/Release-iphoneos/geolocator_apple.build/geolocator_apple-own-target-headers.hmap -I
    /Users/sandeepmann/Library/Developer/Xcode/DerivedData/Runner-cdzkurfjewjsrcdhcadlpcmqmpqp/Build/Intermediates.
    noindex/Pods.build/Release-iphoneos/geolocator_apple.build/geolocator_apple-all-non-framework-target-headers.hm
    ap -I
    /Users/sandeepmann/Documents/Neal/No_Track_Drive_Neal/Backend_Integrated_No_Track_Drive/build/ios/Release-iphon
    eos/geolocator_apple/include -I
    /Users/sandeepmann/Library/Developer/Xcode/DerivedData/Runner-cdzkurfjewjsrcdhcadlpcmqmpqp/Build/Intermediates.
    noindex/Pods.build/Release-iphoneos/geolocator_apple.build/DerivedSources-normal/arm64 -I
    /Users/sandeepmann/Library/Developer/Xcode/DerivedData/Runner-cdzkurfjewjsrcdhcadlpcmqmpqp/Build/Intermediates.
    noindex/Pods.build/Release-iphoneos/geolocator_apple.build/DerivedSources/arm64 -I
    /Users/sandeepmann/Library/Developer/Xcode/DerivedData/Runner-cdzkurfjewjsrcdhcadlpcmqmpqp/Build/Intermediates.
    noindex/Pods.build/Release-iphoneos/geolocator_apple.build/DerivedSources -F
    /Users/sandeepmann/Documents/Neal/No_Track_Drive_Neal/Backend_Integrated_No_Track_Drive/build/ios/Release-iphon
    eos/geolocator_apple -F
    /Users/sandeepmann/Documents/Sandeep/code/flutter/flutter/bin/cache/artifacts/engine/ios-release/Flutter.xcfram
    ework/ios-arm64 -iquote
    /Users/sandeepmann/Library/Developer/Xcode/DerivedData/Runner-cdzkurfjewjsrcdhcadlpcmqmpqp/Build/Intermediates.
    noindex/Pods.build/Release-iphoneos/geolocator_apple.build/geolocator_apple-generated-files.hmap -iquote
    /Users/sandeepmann/Library/Developer/Xcode/DerivedData/Runner-cdzkurfjewjsrcdhcadlpcmqmpqp/Build/Intermediates.
    noindex/Pods.build/Release-iphoneos/geolocator_apple.build/geolocator_apple-project-headers.hmap -isystem
    /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS18.1.sdk/usr/loca
    l/include -isystem
    /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/clang/16/include
    -internal-externc-isystem
    /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS18.1.sdk/usr/incl
    ude -internal-externc-isystem
    /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/include -ivfsstatcache
    /Users/sandeepmann/Library/Developer/Xcode/DerivedData/SDKStatCaches.noindex/iphoneos18.1-22B74-456b5073a84ca8a
    40bffd5133c40ea2b.sdkstatcache -ivfsoverlay
    /Users/sandeepmann/Library/Developer/Xcode/DerivedData/Runner-cdzkurfjewjsrcdhcadlpcmqmpqp/Build/Intermediates.
    noindex/Pods.build/Release-iphoneos/Pods-8699adb1dd336b26511df848a716bd42-VFS-iphoneos/all-product-headers.yaml
    -std\=gnu11 -fexceptions -fmodules -fmodule-name\=geolocator_apple -fno-implicit-modules -fobjc-exceptions
    -fmax-type-align\=16 -fpascal-strings -fstack-check -fvisibility-inlines-hidden-static-local-var
    -mdarwin-stkchk-strong-link -fno-odr-hash-protocols -pic-level 2 -fencode-extended-block-signature
    -stack-protector 1 -fobjc-runtime\=ios-14.0.0 -fobjc-arc -fobjc-runtime-has-weak -fobjc-weak
    -fgnuc-version\=4.2.1 -fblocks -ffp-contract\=on -fclang-abi-compat\=4.0
    -fno-experimental-relative-c++-abi-vtables -fno-file-reproducible
    -clang-vendor-feature\=+disableNonDependentMemberExprInCurrentInstantiation
    -clang-vendor-feature\=+enableAggressiveVLAFolding -clang-vendor-feature\=+revert09abecef7bbf
    -clang-vendor-feature\=+thisNoAlignAttr -clang-vendor-feature\=+thisNoNullAttr
    -clang-vendor-feature\=+disableAtImportPrivateFrameworkInImplementationError -O2
    -fdebug-compilation-dir\=/Users/sandeepmann/Documents/Neal/No_Track_Drive_Neal/Backend_Integrated_No_Track_Driv
    e/ios/Pods
    -fcoverage-compilation-dir\=/Users/sandeepmann/Documents/Neal/No_Track_Drive_Neal/Backend_Integrated_No_Track_D
    rive/ios/Pods -fobjc-msgsend-selector-stubs -fregister-global-dtors-with-atexit -fno-strict-return
    -dwarf-version\=4 -debugger-tuning\=lldb -disable-llvm-verifier -dwarf-ext-refs -mframe-pointer\=non-leaf
    -funwind-tables\=1 -vectorize-loops -vectorize-slp -clear-ast-before-backend -discard-value-names
    -main-file-name PermissionHandler.m -finline-functions -debug-info-kind\=standalone -Os
    -fdiagnostics-hotness-threshold\=0 -fdiagnostics-misexpect-tolerance\=0 -D COCOAPODS\=1 -D
    NS_BLOCK_ASSERTIONS\=1 -D OBJC_OLD_DISPATCH_PROTOTYPES\=0 -D POD_CONFIGURATION_RELEASE\=1 -D
    __GCC_HAVE_DWARF2_CFI_ASM\=1 -include
    /Users/sandeepmann/Documents/Neal/No_Track_Drive_Neal/Backend_Integrated_No_Track_Drive/ios/Pods/Target\
    Support\ Files/geolocator_apple/geolocator_apple-prefix.pch -MT dependencies -dependency-file
    /Users/sandeepmann/Library/Developer/Xcode/DerivedData/Runner-cdzkurfjewjsrcdhcadlpcmqmpqp/Build/Intermediates.
    noindex/Pods.build/Release-iphoneos/geolocator_apple.build/Objects-normal/arm64/PermissionHandler.d
    -skip-unused-modulemap-deps
    /Users/sandeepmann/.pub-cache/hosted/pub.dev/geolocator_apple-2.3.13/darwin/geolocator_apple/Sources/geolocator
    _apple/Handlers/PermissionHandler.m:40:31: warning: 'authorizationStatus' is deprecated: first deprecated in
    iOS 14.0 [-Wdeprecated-declarations]
       40 |     return [CLLocationManager authorizationStatus];
          |                               ^~~~~~~~~~~~~~~~~~~
          |                               authorizationStatus
    In module 'CoreLocation' imported from
    /Users/sandeepmann/.pub-cache/hosted/pub.dev/geolocator_apple-2.3.13/darwin/geolocator_apple/Sources/geolocator
    _apple/Handlers/../include/geolocator_apple/Handlers/PermissionHandler.h:11:
    /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS18.1.sdk/System/L
    ibrary/Frameworks/CoreLocation.framework/Headers/CLLocationManager.h:231:1: note: 'authorizationStatus' has
    been explicitly marked deprecated here
      231 | + (CLAuthorizationStatus)authorizationStatus API_DEPRECATED_WITH_REPLACEMENT("-authorizationStatus",
      ios(4.2, 14.0), macos(10.7, 11.0), watchos(1.0, 7.0), tvos(9.0, 14.0));
          | ^
    /Users/sandeepmann/.pub-cache/hosted/pub.dev/geolocator_apple-2.3.13/darwin/geolocator_apple/Sources/geolocator
    _apple/Handlers/PermissionHandler.m:47:65: warning: 'authorizationStatus' is deprecated: first deprecated in
    iOS 14.0 [-Wdeprecated-declarations]
       47 |   CLAuthorizationStatus authorizationStatus = CLLocationManager.authorizationStatus;
          |                                                                 ^~~~~~~~~~~~~~~~~~~
          |                                                                 authorizationStatus
    In module 'CoreLocation' imported from
    /Users/sandeepmann/.pub-cache/hosted/pub.dev/geolocator_apple-2.3.13/darwin/geolocator_apple/Sources/geolocator
    _apple/Handlers/../include/geolocator_apple/Handlers/PermissionHandler.h:11:
    /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS18.1.sdk/System/L
    ibrary/Frameworks/CoreLocation.framework/Headers/CLLocationManager.h:231:1: note: 'authorizationStatus' has
    been explicitly marked deprecated here
      231 | + (CLAuthorizationStatus)authorizationStatus API_DEPRECATED_WITH_REPLACEMENT("-authorizationStatus",
      ios(4.2, 14.0), macos(10.7, 11.0), watchos(1.0, 7.0), tvos(9.0, 14.0));
          | ^
    /Users/sandeepmann/.pub-cache/hosted/pub.dev/geolocator_apple-2.3.13/darwin/geolocator_apple/Sources/geolocator
    _apple/Handlers/PermissionHandler.m:47:65: warning: 'authorizationStatus' is deprecated: first deprecated in
    iOS 14.0 [-Wdeprecated-declarations]
       47 |   CLAuthorizationStatus authorizationStatus = CLLocationManager.authorizationStatus;
          |                                                                 ^~~~~~~~~~~~~~~~~~~
          |                                                                 authorizationStatus
    In module 'CoreLocation' imported from
    /Users/sandeepmann/.pub-cache/hosted/pub.dev/geolocator_apple-2.3.13/darwin/geolocator_apple/Sources/geolocator
    _apple/Handlers/../include/geolocator_apple/Handlers/PermissionHandler.h:11:
    /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS18.1.sdk/System/L
    ibrary/Frameworks/CoreLocation.framework/Headers/CLLocationManager.h:231:1: note: 'authorizationStatus' has
    been explicitly marked deprecated here
      231 | + (CLAuthorizationStatus)authorizationStatus API_DEPRECATED_WITH_REPLACEMENT("-authorizationStatus",
      ios(4.2, 14.0), macos(10.7, 11.0), watchos(1.0, 7.0), tvos(9.0, 14.0));
          | ^
    /Users/sandeepmann/.pub-cache/hosted/pub.dev/geolocator_apple-2.3.13/darwin/geolocator_apple/Sources/geolocator
    _apple/Handlers/PermissionHandler.m:107:1: warning: implementing deprecated method
    [-Wdeprecated-implementations]
      107 | - (void) locationManager:(CLLocationManager *)manager
      didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
          | ^
    In module 'CoreLocation' imported from
    /Users/sandeepmann/.pub-cache/hosted/pub.dev/geolocator_apple-2.3.13/darwin/geolocator_apple/Sources/geolocator
    _apple/Handlers/../include/geolocator_apple/Handlers/PermissionHandler.h:11:
    /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS18.1.sdk/System/L
    ibrary/Frameworks/CoreLocation.framework/Headers/CLLocationManagerDelegate.h:208:1: note: method
    'locationManager:didChangeAuthorizationStatus:' declared here
      208 | - (void)locationManager:(CLLocationManager *)manager
      didChangeAuthorizationStatus:(CLAuthorizationStatus)status
      API_DEPRECATED_WITH_REPLACEMENT("-locationManagerDidChangeAuthorization:", ios(4.2, 14.0), macos(10.7, 11.0),
      watchos(1.0, 7.0), tvos(9.0, 14.0));
          | ^
    4 warnings generated.
    /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/clang -cc1
    -Wundef-prefix\=TARGET_OS_ -fdiagnostics-show-note-include-stack -fmacro-backtrace-limit\=0 -ferror-limit 19
    -serialize-diagnostic-file
    /Users/sandeepmann/Library/Developer/Xcode/DerivedData/Runner-cdzkurfjewjsrcdhcadlpcmqmpqp/Build/Intermediates.
    noindex/Pods.build/Release-iphoneos/geolocator_apple.build/Objects-normal/arm64/LocationServiceStreamHandler.di
    a -Wdeprecated-objc-isa-usage -Werror\=deprecated-objc-isa-usage -Werror\=implicit-function-declaration
    -Wnon-modular-include-in-framework-module -Werror\=non-modular-include-in-framework-module -Wno-trigraphs
    -Wno-missing-field-initializers -Wno-missing-prototypes -Werror\=return-type -Wdocumentation -Wunreachable-code
    -Wno-implicit-atomic-properties -Werror\=deprecated-objc-isa-usage -Wno-objc-interface-ivars
    -Werror\=objc-root-class -Wno-arc-repeated-use-of-weak -Wimplicit-retain-self -Wduplicate-method-match
    -Wno-missing-braces -Wparentheses -Wswitch -Wunused-function -Wno-unused-label -Wno-unused-parameter
    -Wunused-variable -Wunused-value -Wempty-body -Wuninitialized -Wconditional-uninitialized -Wno-unknown-pragmas
    -Wno-shadow -Wno-four-char-constants -Wno-conversion -Wconstant-conversion -Wint-conversion -Wbool-conversion
    -Wenum-conversion -Wno-float-conversion -Wnon-literal-null-conversion -Wobjc-literal-conversion
    -Wshorten-64-to-32 -Wpointer-sign -Wno-newline-eof -Wno-selector -Wno-strict-selector-match
    -Wundeclared-selector -Wdeprecated-implementations -Wno-implicit-fallthrough -Wprotocol
    -Wdeprecated-declarations -Wno-sign-conversion -Winfinite-recursion -Wcomma -Wblock-capture-autoreleasing
    -Wstrict-prototypes -Wno-semicolon-before-method-body -Wunguarded-availability -Wno-reorder-init-list
    -Wno-implicit-int-float-conversion -Wno-c99-designator -Wno-final-dtor-non-final-class -Wno-extra-semi-stmt
    -Wno-misleading-indentation -Wno-quoted-include-in-framework-header -Wno-implicit-fallthrough
    -Wno-enum-enum-conversion -Wno-enum-float-conversion -Wno-elaborated-enum-base -Wno-reserved-identifier
    -Wno-gnu-folding-constant
    -fmodule-map-file\=/Users/sandeepmann/Documents/Neal/No_Track_Drive_Neal/Backend_Integrated_No_Track_Drive/buil
    d/ios/Release-iphoneos/geolocator_apple/geolocator_apple.framework/Modules/module.modulemap
    -fmodule-map-file\=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhone
    OS.sdk/System/Library/Frameworks/UIKit.framework/Modules/module.modulemap
    -fmodule-map-file\=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhone
    OS.sdk/System/Library/Frameworks/Foundation.framework/Modules/module.modulemap
    -fmodule-map-file\=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhone
    OS.sdk/System/Library/Frameworks/CoreLocation.framework/Modules/module.modulemap
    -fmodule-map-file\=/Users/sandeepmann/Documents/Sandeep/code/flutter/flutter/bin/cache/artifacts/engine/ios-rel
    ease/Flutter.xcframework/ios-arm64/Flutter.framework/Modules/module.modulemap -o
    /Users/sandeepmann/Library/Developer/Xcode/DerivedData/Runner-cdzkurfjewjsrcdhcadlpcmqmpqp/Build/Intermediates.
    noindex/Pods.build/Release-iphoneos/geolocator_apple.build/Objects-normal/arm64/LocationServiceStreamHandler.o
    -disable-free -emit-obj -x objective-c
    /Users/sandeepmann/.pub-cache/hosted/pub.dev/geolocator_apple-2.3.13/darwin/geolocator_apple/Sources/geolocator
    _apple/Handlers/LocationServiceStreamHandler.m -target-abi darwinpcs -target-cpu apple-a7 -target-feature +v8a
    -target-feature +aes -target-feature +fp-armv8 -target-feature +sha2 -target-feature +neon -target-feature +zcm
    -target-feature +zcz -triple arm64-apple-ios14.0.0 -target-linker-version 1115.7.3 -target-sdk-version\=18.1
    -fmodules-validate-system-headers -fno-modulemap-allow-subdirectory-search -isysroot
    /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS18.1.sdk
    -resource-dir /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/clang/16
    -fmodule-format\=obj
    -fmodule-file\=CoreLocation\=/Users/sandeepmann/Library/Developer/Xcode/DerivedData/Runner-cdzkurfjewjsrcdhcadl
    pcmqmpqp/Build/Intermediates.noindex/ExplicitPrecompiledModules/CoreLocation-193CSLPFPUJI5TASCUNDQLONQ.pcm
    -fmodule-file\=Flutter\=/Users/sandeepmann/Library/Developer/Xcode/DerivedData/Runner-cdzkurfjewjsrcdhcadlpcmqm
    pqp/Build/Intermediates.noindex/ExplicitPrecompiledModules/Flutter-9O8P7TKHTHSJ0W7S1E9PJ7JJC.pcm
    -fmodule-file\=Foundation\=/Users/sandeepmann/Library/Developer/Xcode/DerivedData/Runner-cdzkurfjewjsrcdhcadlpc
    mqmpqp/Build/Intermediates.noindex/ExplicitPrecompiledModules/Foundation-B8ER1U5KDKZY53BN81L7A92KB.pcm
    -fmodule-file\=UIKit\=/Users/sandeepmann/Library/Developer/Xcode/DerivedData/Runner-cdzkurfjewjsrcdhcadlpcmqmpq
    p/Build/Intermediates.noindex/ExplicitPrecompiledModules/UIKit-ETTT3NA9RMWP7PDHVR8B239UT.pcm -I
    /Users/sandeepmann/Library/Developer/Xcode/DerivedData/Runner-cdzkurfjewjsrcdhcadlpcmqmpqp/Build/Intermediates.
    noindex/Pods.build/Release-iphoneos/geolocator_apple.build/geolocator_apple-own-target-headers.hmap -I
    /Users/sandeepmann/Library/Developer/Xcode/DerivedData/Runner-cdzkurfjewjsrcdhcadlpcmqmpqp/Build/Intermediates.
    noindex/Pods.build/Release-iphoneos/geolocator_apple.build/geolocator_apple-all-non-framework-target-headers.hm
    ap -I
    /Users/sandeepmann/Documents/Neal/No_Track_Drive_Neal/Backend_Integrated_No_Track_Drive/build/ios/Release-iphon
    eos/geolocator_apple/include -I
    /Users/sandeepmann/Library/Developer/Xcode/DerivedData/Runner-cdzkurfjewjsrcdhcadlpcmqmpqp/Build/Intermediates.
    noindex/Pods.build/Release-iphoneos/geolocator_apple.build/DerivedSources-normal/arm64 -I
    /Users/sandeepmann/Library/Developer/Xcode/DerivedData/Runner-cdzkurfjewjsrcdhcadlpcmqmpqp/Build/Intermediates.
    noindex/Pods.build/Release-iphoneos/geolocator_apple.build/DerivedSources/arm64 -I
    /Users/sandeepmann/Library/Developer/Xcode/DerivedData/Runner-cdzkurfjewjsrcdhcadlpcmqmpqp/Build/Intermediates.
    noindex/Pods.build/Release-iphoneos/geolocator_apple.build/DerivedSources -F
    /Users/sandeepmann/Documents/Neal/No_Track_Drive_Neal/Backend_Integrated_No_Track_Drive/build/ios/Release-iphon
    eos/geolocator_apple -F
    /Users/sandeepmann/Documents/Sandeep/code/flutter/flutter/bin/cache/artifacts/engine/ios-release/Flutter.xcfram
    ework/ios-arm64 -iquote
    /Users/sandeepmann/Library/Developer/Xcode/DerivedData/Runner-cdzkurfjewjsrcdhcadlpcmqmpqp/Build/Intermediates.
    noindex/Pods.build/Release-iphoneos/geolocator_apple.build/geolocator_apple-generated-files.hmap -iquote
    /Users/sandeepmann/Library/Developer/Xcode/DerivedData/Runner-cdzkurfjewjsrcdhcadlpcmqmpqp/Build/Intermediates.
    noindex/Pods.build/Release-iphoneos/geolocator_apple.build/geolocator_apple-project-headers.hmap -isystem
    /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS18.1.sdk/usr/loca
    l/include -isystem
    /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/clang/16/include
    -internal-externc-isystem
    /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS18.1.sdk/usr/incl
    ude -internal-externc-isystem
    /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/include -ivfsstatcache
    /Users/sandeepmann/Library/Developer/Xcode/DerivedData/SDKStatCaches.noindex/iphoneos18.1-22B74-456b5073a84ca8a
    40bffd5133c40ea2b.sdkstatcache -ivfsoverlay
    /Users/sandeepmann/Library/Developer/Xcode/DerivedData/Runner-cdzkurfjewjsrcdhcadlpcmqmpqp/Build/Intermediates.
    noindex/Pods.build/Release-iphoneos/Pods-8699adb1dd336b26511df848a716bd42-VFS-iphoneos/all-product-headers.yaml
    -std\=gnu11 -fexceptions -fmodules -fmodule-name\=geolocator_apple -fno-implicit-modules -fobjc-exceptions
    -fmax-type-align\=16 -fpascal-strings -fstack-check -fvisibility-inlines-hidden-static-local-var
    -mdarwin-stkchk-strong-link -fno-odr-hash-protocols -pic-level 2 -fencode-extended-block-signature
    -stack-protector 1 -fobjc-runtime\=ios-14.0.0 -fobjc-arc -fobjc-runtime-has-weak -fobjc-weak
    -fgnuc-version\=4.2.1 -fblocks -ffp-contract\=on -fclang-abi-compat\=4.0
    -fno-experimental-relative-c++-abi-vtables -fno-file-reproducible
    -clang-vendor-feature\=+disableNonDependentMemberExprInCurrentInstantiation
    -clang-vendor-feature\=+enableAggressiveVLAFolding -clang-vendor-feature\=+revert09abecef7bbf
    -clang-vendor-feature\=+thisNoAlignAttr -clang-vendor-feature\=+thisNoNullAttr
    -clang-vendor-feature\=+disableAtImportPrivateFrameworkInImplementationError -O2
    -fdebug-compilation-dir\=/Users/sandeepmann/Documents/Neal/No_Track_Drive_Neal/Backend_Integrated_No_Track_Driv
    e/ios/Pods
    -fcoverage-compilation-dir\=/Users/sandeepmann/Documents/Neal/No_Track_Drive_Neal/Backend_Integrated_No_Track_D
    rive/ios/Pods -fobjc-msgsend-selector-stubs -fregister-global-dtors-with-atexit -fno-strict-return
    -dwarf-version\=4 -debugger-tuning\=lldb -disable-llvm-verifier -dwarf-ext-refs -mframe-pointer\=non-leaf
    -funwind-tables\=1 -vectorize-loops -vectorize-slp -clear-ast-before-backend -discard-value-names
    -main-file-name LocationServiceStreamHandler.m -finline-functions -debug-info-kind\=standalone -Os
    -fdiagnostics-hotness-threshold\=0 -fdiagnostics-misexpect-tolerance\=0 -D COCOAPODS\=1 -D
    NS_BLOCK_ASSERTIONS\=1 -D OBJC_OLD_DISPATCH_PROTOTYPES\=0 -D POD_CONFIGURATION_RELEASE\=1 -D
    __GCC_HAVE_DWARF2_CFI_ASM\=1 -include
    /Users/sandeepmann/Documents/Neal/No_Track_Drive_Neal/Backend_Integrated_No_Track_Drive/ios/Pods/Target\
    Support\ Files/geolocator_apple/geolocator_apple-prefix.pch -MT dependencies -dependency-file
    /Users/sandeepmann/Library/Developer/Xcode/DerivedData/Runner-cdzkurfjewjsrcdhcadlpcmqmpqp/Build/Intermediates.
    noindex/Pods.build/Release-iphoneos/geolocator_apple.build/Objects-normal/arm64/LocationServiceStreamHandler.d
    -skip-unused-modulemap-deps
    /Users/sandeepmann/.pub-cache/hosted/pub.dev/geolocator_apple-2.3.13/darwin/geolocator_apple/Sources/geolocator
    _apple/Handlers/LocationServiceStreamHandler.m:36:1: warning: implementing deprecated method
    [-Wdeprecated-implementations]
       36 | - (void)locationManager:(CLLocationManager *)manager
       didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
          | ^
    In module 'CoreLocation' imported from
    /Users/sandeepmann/.pub-cache/hosted/pub.dev/geolocator_apple-2.3.13/darwin/geolocator_apple/Sources/geolocator
    _apple/Handlers/LocationServiceStreamHandler.m:9:
    /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS18.1.sdk/System/L
    ibrary/Frameworks/CoreLocation.framework/Headers/CLLocationManagerDelegate.h:208:1: note: method
    'locationManager:didChangeAuthorizationStatus:' declared here
      208 | - (void)locationManager:(CLLocationManager *)manager
      didChangeAuthorizationStatus:(CLAuthorizationStatus)status
      API_DEPRECATED_WITH_REPLACEMENT("-locationManagerDidChangeAuthorization:", ios(4.2, 14.0), macos(10.7, 11.0),
      watchos(1.0, 7.0), tvos(9.0, 14.0));
          | ^
    1 warning generated.
    Target release_unpack_ios failed: Exception: Failed to codesign
    /Users/sandeepmann/Documents/Neal/No_Track_Drive_Neal/Backend_Integrated_No_Track_Drive/build/ios/Release-iphon
    eos/Flutter.framework/Flutter with identity 483C2F9E3B529CD446097800BAD69A45B61F63D7.
    /Users/sandeepmann/Documents/Neal/No_Track_Drive_Neal/Backend_Integrated_No_Track_Drive/build/ios/Release-iphon
    eos/Flutter.framework/Flutter: replacing existing signature
    /Users/sandeepmann/Documents/Neal/No_Track_Drive_Neal/Backend_Integrated_No_Track_Drive/build/ios/Release-iphon
    eos/Flutter.framework/Flutter: resource fork, Finder information, or similar detritus not allowed
    Failed to package /Users/sandeepmann/Documents/Neal/No_Track_Drive_Neal/Backend_Integrated_No_Track_Drive.
    Command PhaseScriptExecution failed with a nonzero exit code
    note: Disabling previews because SWIFT_VERSION is set and SWIFT_OPTIMIZATION_LEVEL=-O, expected -Onone (in
    target 'GoogleMaps' from project 'Pods')
    note: Disabling previews because SWIFT_VERSION is set and SWIFT_OPTIMIZATION_LEVEL=-O, expected -Onone (in
    target 'path_provider_foundation-path_provider_foundation_privacy' from project 'Pods')
    note: Disabling previews because SWIFT_VERSION is set and SWIFT_OPTIMIZATION_LEVEL=-O, expected -Onone (in
    target 'shared_preferences_foundation-shared_preferences_foundation_privacy' from project 'Pods')
    note: Disabling previews because SWIFT_VERSION is set and SWIFT_OPTIMIZATION_LEVEL=-O, expected -Onone (in
    target 'shared_preferences_foundation' from project 'Pods')
    note: Disabling previews because SWIFT_VERSION is set and SWIFT_OPTIMIZATION_LEVEL=-O, expected -Onone (in
    target 'path_provider_foundation' from project 'Pods')
    note: Disabling previews because SWIFT_VERSION is set and SWIFT_OPTIMIZATION_LEVEL=-O, expected -Onone (in
    target 'image_picker_ios-image_picker_ios_privacy' from project 'Pods')
    note: Disabling previews because SWIFT_VERSION is set and SWIFT_OPTIMIZATION_LEVEL=-O, expected -Onone (in
    target 'image_picker_ios' from project 'Pods')
    note: Disabling previews because SWIFT_VERSION is set and SWIFT_OPTIMIZATION_LEVEL=-O, expected -Onone (in
    target 'google_maps_flutter_ios-google_maps_flutter_ios_privacy' from project 'Pods')
    note: Disabling previews because SWIFT_VERSION is set and SWIFT_OPTIMIZATION_LEVEL=-O, expected -Onone (in
    target 'google_maps_flutter_ios' from project 'Pods')
    /Users/sandeepmann/Documents/Neal/No_Track_Drive_Neal/Backend_Integrated_No_Track_Drive/ios/Pods/Pods.xcodeproj
    : warning: The iOS deployment target 'IPHONEOS_DEPLOYMENT_TARGET' is set to 11.0, but the range of supported
    deployment target versions is 12.0 to 18.1.99. (in target 'geolocator_apple-geolocator_apple_privacy' from
    project 'Pods')
    note: Disabling previews because SWIFT_VERSION is set and SWIFT_OPTIMIZATION_LEVEL=-O, expected -Onone (in
    target 'geolocator_apple-geolocator_apple_privacy' from project 'Pods')
    note: Disabling previews because SWIFT_VERSION is set and SWIFT_OPTIMIZATION_LEVEL=-O, expected -Onone (in
    target 'geolocator_apple' from project 'Pods')
    note: Disabling previews because SWIFT_VERSION is set and SWIFT_OPTIMIZATION_LEVEL=-O, expected -Onone (in
    target 'flutter_keyboard_visibility' from project 'Pods')
    note: Disabling previews because SWIFT_VERSION is set and SWIFT_OPTIMIZATION_LEVEL=-O, expected -Onone (in
    target 'flutter_foreground_task' from project 'Pods')
    note: Disabling previews because SWIFT_VERSION is set and SWIFT_OPTIMIZATION_LEVEL=-O, expected -Onone (in
    target 'Runner' from project 'Runner')
    note: Run script build phase 'Run Script' will be run during every build because the option to run the script
    phase "Based on dependency analysis" is unchecked. (in target 'Runner' from project 'Runner')
    note: Run script build phase 'Thin Binary' will be run during every build because the option to run the script
    phase "Based on dependency analysis" is unchecked. (in target 'Runner' from project 'Runner')
    note: Disabling previews because SWIFT_VERSION is set and SWIFT_OPTIMIZATION_LEVEL=-O, expected -Onone (in
    target 'Pods-Runner' from project 'Pods')
    note: Disabling previews because SWIFT_VERSION is set and SWIFT_OPTIMIZATION_LEVEL=-O, expected -Onone (in
    target 'GoogleMaps-GoogleMapsResources' from project 'Pods')
    note: Disabling previews because SWIFT_VERSION is set and SWIFT_OPTIMIZATION_LEVEL=-O, expected -Onone (in
    target 'Google-Maps-iOS-Utils' from project 'Pods')
    note: Disabling previews because SWIFT_VERSION is set and SWIFT_OPTIMIZATION_LEVEL=-O, expected -Onone (in
    target 'Flutter' from project 'Pods')

Encountered error while building for device.

