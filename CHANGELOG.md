Version 2.0.1
=============
Other
------------
- Add a convenient initializer with only on parameter: Vibes App ID
- Move archive.sh to the right folder bin
- Remove unused class VibesConfiguration

Version 2.0.0
=============
New Features
------------
- Objective-C compatibility
- Change Vibes methods callback by Delegate
- Added a Queue mechanism for HTTP requests
- Handle timeout http error code (408, 429, 500, 502, 503, 504) and retry 4 times with a random delay between 2 requests (max 15s)
- Update the device location (Vibes new method and Backend enpoint)
- Added a method to retrieve Karl messages (for now, the backend url and person_uid is hardcoded as Karl
is not integrated with PublicAPI, Core ...)
- Added badge number handling

Version 1.0.3
=============

Other
---------
- Move key 'wallet' under 'client_app_data' in the push notification

Version 1.0.2
=============

Other
---------
- Add PassKit as dependency in order to present a PKPass view.

Version 1.0.1
=============

Bug Fixes
---------
- Fix the script which generate the VibesPush.framework


Version 1.0.0
=============

New Features
------------
- register/unregister Device
- registerPush/unregisterPush
- events upload
- Simple push notification
- Set default vibes endpoint to https://public-api.vibescm.com/mobile_app
- Add the possibility to set Device.advertisingID (AdKit)
- Change the parsing of the metadata (key name changed from metadata to client_app_data)

Bug Fixes
---------
- Fix too many launch event sent