## Quick Start

### Step 1 - Add Dependency

1. SDK is available through [CocoaPods](https://cocoapods.org/pods/deviceintel-ios). To install it, simply add the following line to your Podfile:

```ruby
# Podfile
pod 'deviceintel-ios'

```

2. `import deviceintel_ios` in your UIViewcontroller
3. `Info.plist` -> Add below properties
   - "NSUserTrackingUsageDescription"
   - "NSLocationAlwaysAndWhenInUseUsageDescription"
   - "Privacy - Location When In Use Usage Description"

### Step 2 - Initialise SDK

The SDK is initialized in the client app. Once the submit function is called, the data relating to the user and device is automatically synced in the background.

```swift
// You can initialize BureauAPI from AppDelegate, SceneDelegate, or a ViewController based on your app's architecture.

// 1. Create a config object and initialize the SDK with minimal config values
var config = BureauConfig(
    
    // --- Required ---
    // Replace <CREDENTIAL ID> with the CREDENTIAL ID obtained from your Bureau dashboard when generating API keys.
    credentialID: "<CREDENTIAL ID>",
  
    // --- Required ---
    /*
        Environment in which you want to initialize the SDK.
        Possible values: '.sandbox' (for testing) or '.production' (for live use).
    */
    environment: .sandbox
)

// --- Required ---
/*
    Replace <UNIQUE_USER_ID> with a unique identifier for the user.
    Use the same userId across sessions to associate data with the same user.
    This can be the user's email, phone number, or a custom-generated user ID.
*/
config.userId = "<UNIQUE_USER_ID>"

// --- Optional ---
/*
    Replace <YOUR_FLOW_NAME> with the specify the flow name to track SDK usage context.
    For example: 'login', 'signup', or 'checkout'.
    This can help segment and analyze user behavior by flow.
*/
config.flow = "<YOUR_FLOW_NAME>"

// 2. Initialize the SDK with the config you just created
BureauAPI.shared.configure(config: config)

// 3. (Optional) Set user ID separately if not set in config
BureauAPI.shared.setUserID("<USER_ID>")

// 4. Assign the delegate to receive fingerprinting completion callback (optional)
BureauAPI.shared.fingerprintDelegate = self

```

#### Submit Device Data

```swift
// Submit device data and get insights
BureauAPI.shared.submit { success, eventId, error, insights in
    /* 
        Log the eventId.
        The eventId is always returned — even when submission fails.
        You can use it to fetch device insights or debug issues later.
    */                     
    print("Auto-generated Event ID: \(eventId ?? "")")

    if success {
        if let insights = insights {
            print("Insights received: \(insights)")
        } else {
            print("No insights returned")
        }
    } else {
        print("Submit failed: \(error?.localizedDescription ?? "Unknown error")")
    }
}
```
#### [Optional] Track Fingerprinting Completion with onFinished


If you prefer to track the completion of fingerprinting using `delegate` methods, implement the PrismFingerPrintDelegate method.

```swift
// Example: Inside your ViewController
// Conform to the PrismFingerPrintDelegate
extension YourViewController: PrismFingerPrintDelegate {
    // The onFinished delegate is called in after both success or failure scenarios
    func onFinished(eventID: String?, data: [String: Any]?, insights: Insights?) {
        print("Fingerprinting completed. Event ID: \(eventID ?? "nil")")
    }
}

// `data` may include:
// "eventID" -> String?
// "statusCode" -> Int? (200 or 409 = success)
// "apiResponse" -> NSDictionary?
// "insights" -> Insights? (same as in `submit()`, if enabled)
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
    "sessionId": "<<SessionID/EventID>>"
}'
```

Production:
```ruby
curl --location --request POST 'https://api.bureau.id/v1/suppliers/device-fingerprint' \
--header 'Authorization: Basic MzNiNxxxx2ItZGU2M==' \
--header 'Content-Type: application/json' \
--data-raw '{
    "sessionId": "<<SessionID/EventID>>"
}'
```

---

## Changelog

### v2.2.0 — Storage Volume Feature

**New fields added to the Device Intelligence payload (`memInfo_`):**

| JSON Key | Type | Description |
|---|---|---|
| `totalInternalStorage_` | `Int64` | Total capacity of device internal storage, in bytes |
| `freeInternalStorage_` | `Int64` | Free (available for important usage) internal storage, in bytes. Uses `volumeAvailableCapacityForImportantUsageKey` on iOS 11+. Returns `-1` on failure. |

**iOS Implementation — `StorageVolumeProvider`:**

The SDK collects storage volume data using Apple's `FileManager` / `URLResourceKey` APIs. No new permissions are required.

```swift
// Internal implementation (compiled into XCFramework)
// Uses URL.resourceValues(forKeys:) on the app home directory URL

let url = URL(fileURLWithPath: NSHomeDirectory())

// Total volume
let totalValues = try url.resourceValues(forKeys: [.volumeTotalCapacityKey])
let totalBytes = Int64(totalValues.volumeTotalCapacity ?? 0)

// Free volume (iOS 11+)
if #available(iOS 11.0, *) {
    let freeValues = try url.resourceValues(
        forKeys: [.volumeAvailableCapacityForImportantUsageKey]
    )
    let freeBytes = freeValues.volumeAvailableCapacityForImportantUsage ?? -1
}
```

**Backend payload example (`memInfo_` section):**

```json
{
  "memInfo_": {
    "totalInternalStorage_": 128000000000,
    "freeInternalStorage_": 45200000000,
    "totalRAM_": 6442450944
  }
}
```

**Parity with Android:**
This feature mirrors the Android SDK changes in `DeviceStorageProvider.kt`:
- `getTotalInternalVolume()` → `totalInternalStorage_`
- `getFreeInternalVolume()` → `freeInternalStorage_`
- `getTotalExternalVolume()` → _(iOS has no external storage, field omitted)_
- `getFreeExternalVolume()` → _(iOS has no external storage, field omitted)_
