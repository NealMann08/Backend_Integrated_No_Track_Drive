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