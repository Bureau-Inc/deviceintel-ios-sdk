## Quick Start

### Step 1 - Add Dependency

1. SDK is available through [CocoaPods](https://cocoapods.org/pods/deviceintel-ios). To install it, simply add the following line to your Podfile:

```ruby
# Podfile
pod 'deviceintel-ios'

#Add below lines to end of your pod file
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      if target.name == "Sentry" then
        config.build_settings["BUILD_LIBRARY_FOR_DISTRIBUTION"] = 'YES'
      end
    end
  end
end

```

2. "import deviceintel_ios" in your UIViewcontroller
3. Info.plist -> Add below properties
   - “NSUserTrackingUsageDescription”
   - “NSLocationAlwaysAndWhenInUseUsageDescription”
   - “Privacy - Location When In Use Usage Description”

### Step 2 - Initialise SDK

The SDK is initialized in the client app. Once the submit function is called, the data relating to the user and device is automatically synced in the background.

```swift
// Initialize BureauAPI Where ever you want AppDelegate or ViewController
BureauAPI.shared.configure(clientID: "***CLIENT ID**", environment: .production, sessionID: "*** SESSION ID ***", enableBehavioralBiometrics: true)
// clientID  -> Bureau Merchant Id
// environment -> .stage, .production, .sandbox
// sessionID -> unique String value
// enableBehavioralBiometrics -> true/false

BureauAPI.shared.setUserID("***USER ID***")

//call this to start collecting behavior biometrics signals
BureauAPI.shared.startSubSession(NSUUID().uuidString)

BureauAPI.shared.stopSubSession() //Optional -> suppose if we are not call this function. it will call automatically when BureauAPI.shared.submit() 

//assign the delegate where you want to get a callback response from SDK
BureauAPI.shared.fingerprintDelegate = self

BureauAPI.shared.submit() //submit device and behavior(if enabled) data to Bureau's backend using the submit function
```
Note: Client ID and Session ID should be mandatory. Session ID should be unique for every request.

#### Response returned from the SDK

The DataCallback added in the Submit function returns whether the device data has been registered or not.

```swift
// Should need to extent the PrismDelegate for your View controller
extension YourViewController : PrismFingerPrintDelegate{ }

// onFinished Delegate will trigger after success or failure Fingerprint SDK completion 
func onFinished(data: [String : Any]?) { }
// “data” returning blow key values
// "statusCode"  -> Int? ( if statusCode == 200 or 409 “success” else “failure” ) 
// “apiResponse” -> NSDictionary?
```
***
### Step 3 - Invoke API for Insights

To access insights from users and devices, including OTL, device fingerprint, and risk signals, integrating with Bureau's backend API is a must for both OTL and Device Intelligence. 

[Device Intelligence API Document](https://docs.bureau.id/reference/device_intelligence).
[Behavioural Biometrics API Documentation](https://docs.bureau.id/reference/behavioural_biometrics).

#### API Requests

The URL to Bureau's API service is either:

- Sandbox - <https://api.sandbox.bureau.id/v1/suppliers/device-fingerprint>
- Production - <https://api.bureau.id/v1/suppliers/device-fingerprint>

##### Authentication
API's are authenticated via an clientID and secret, they have to be base64 encoded and sent in the header with the parameter name as Authorisation.
Authorisation : Base64(clientID:secret)

Sandbox:
```ruby
curl --location --request POST 'https://api.sandbox.bureau.id/v1/suppliers/device-fingerprint' \
--header 'Authorization: Basic MzNiNxxxx2ItZGU2M==' \
--header 'Content-Type: application/json' \
--data-raw '{
    "sessionId": "697bb2d6-1111-1111-1111-548d6a809360"
}'
```

Production:
```ruby
curl --location --request POST 'https://api.bureau.id/v1/suppliers/device-fingerprint' \
--header 'Authorization: Basic MzNiNxxxx2ItZGU2M==' \
--header 'Content-Type: application/json' \
--data-raw '{
    "sessionId": "697bb2d6-1111-1111-1111-548d6a809360"
}'
```
