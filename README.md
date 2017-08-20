# BluetoothMessageProtocol

[![CI Status](http://img.shields.io/travis/khoogheem/BluetoothMessageProtocol.svg?style=flat)](https://travis-ci.org/khoogheem/BluetoothMessageProtocol)
[![Version](https://img.shields.io/cocoapods/v/BluetoothMessageProtocol.svg?style=flat)](http://cocoapods.org/pods/BluetoothMessageProtocol)
[![License](https://img.shields.io/cocoapods/l/BluetoothMessageProtocol.svg?style=flat)](http://cocoapods.org/pods/BluetoothMessageProtocol)
[![Platform](https://img.shields.io/cocoapods/p/BluetoothMessageProtocol.svg?style=flat)](http://cocoapods.org/pods/BluetoothMessageProtocol)


## Installation

BluetoothMessageProtocol is available through [CocoaPods](http://cocoapods.org). To install it, simply add the following line to your Podfile:

```ruby
pod "BluetoothMessageProtocol"
```

Swift Package Manager:
```swift
    dependencies: [
        .Package(url: "https://github.com/FitnessKit/BluetoothMessageProtocol", majorVersion: 0)
    ]
```
## How to Use

Example from CoreBluetooth:

```swift
func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {

    if let sensorData = characteristic.value {
        if characteristic.uuid.uuidString == CharacteristicHeartRateMeasurement.uuidString {
            doDecodeHRMess(sensorData: sensorData)
        }

        if characteristic.uuid.uuidString == CharacteristicBodySensorLocation.uuidString {
            doDecodeBody(sensorData: sensorData)
        }
    }
}

func doDecodeHRMess(sensorData: Data) {

    do {
        let hrData = try CharacteristicHeartRateMeasurement.decode(data: sensorData)

        print("HR: \(hrData.heartRate)")

    } catch  {
        print(error)
    }
}

func doDecodeBody(sensorData: Data) {

    do {
        let hrData = try CharacteristicBodySensorLocation.decode(data: sensorData)

        print("Location: \(hrData.sensorLocation.stringValue)")

    } catch  {
        print(error)
    }
}
```

## Author

Kevin A. Hoogheem, kevin@hoogheem.net

## License

BluetoothMessageProtocol is available under the MIT license. See the LICENSE file for more info.
