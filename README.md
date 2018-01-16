# ASAppleMusic 🍎🎵

[![Version](https://img.shields.io/cocoapods/v/ASAppleMusic.svg?style=flat)](http://cocoapods.org/pods/ASAppleMusic)
[![License](https://img.shields.io/cocoapods/l/ASAppleMusic.svg?style=flat)](http://cocoapods.org/pods/ASAppleMusic)
[![Platform](https://img.shields.io/cocoapods/p/ASAppleMusic.svg?style=flat)](http://cocoapods.org/pods/ASAppleMusic)

## About
ASAppleMusic allows you as developer to get all the Apple Music data from the catalog including: albums, artists, tracks, etc.
To know more about that API take a look at [the Apple Music API website](https://developer.apple.com/library/content/documentation/NetworkingInternetWeb/Conceptual/AppleMusicWebServicesReference/index.html).

## Docs

[ASAppleMusic API Docs](http://alexsays.github.io/ASAppleMusic)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

- Xcode 9.0+
- iOS 11.0+
- Swift 4.0+

## Installation

ASAppleMusic is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'ASAppleMusic'
```

## Usage

To use this class just call the singleton `shared` and each *getter method* to get the API object desired.
 By default the token used will be the Developer token and there's logging enabled, if you want to change both things just change the value of `source` and `debugLevel` attributes.

 This API is configured as you should know how to generate developer and user tokens, for more info [visit the Apple Music API.](https://developer.apple.com/library/content/documentation/NetworkingInternetWeb/Conceptual/AppleMusicWebServicesReference/SetUpWebServices.html)

 You should create your own web server that receives parameters as `POST` request in the **body** in JSON format like:
 ````
 {
    "kid": "C234234AS",
    "tid": "AS234ASF2"
 }
 ````

 and should return the token in JSON format:
 ````
 {
    "token": "alf9dsahf92fjdsa.fdsaifjds89a4fh"
 }
 ````

## Not Available *(WIP)*

- Recents
- Recommendations
- Reviews

## Author

Alex Silva, alex@alexsays.info

## License

ASAppleMusic is available under the CC BY-SA 4.0 license. See the LICENSE file for more info.
