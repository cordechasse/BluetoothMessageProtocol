//
//  CharacteristicRainfall.swift
//  BluetoothMessageProtocol
//
//  Created by Kevin Hoogheem on 8/20/17.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import Foundation
import DataDecoder
import FitnessUnits

/// BLE Rainfall Characteristic
@available(swift 3.1)
@available(iOS 10.0, tvOS 10.0, watchOS 3.0, OSX 10.12, *)
final public class CharacteristicRainfall: Characteristic {
    
    /// Characteristic Name
    public static var name: String { "Rainfall" }
    
    /// Characteristic UUID
    public static var uuidString: String { "2A78" }
    
    /// Name of the Characteristic
    public var name: String { Self.name }
    
    /// Characteristic UUID String
    public var uuidString: String { Self.uuidString }
    
    /// Rainfall
    private(set) public var rainfall: Measurement<UnitLength>
    
    /// Creates Rainfall Characteristic
    ///
    /// - Parameter rainfall: Rainfall
    public init(rainfall: Measurement<UnitLength>) {
        self.rainfall = rainfall
    }
    
    /// Decodes Characteristic Data into Characteristic
    ///
    /// - Parameter data: Characteristic Data
    /// - Returns: Characteristic Result
    public class func decode(with data: Data) -> Result<CharacteristicRainfall, BluetoothDecodeError> {
        var decoder = DecodeData()
        
        // put into 0.1 PA then into KiloPascals
        let value = Double(decoder.decodeUInt16(data))
        
        let rainfall: Measurement = Measurement(value: value, unit: UnitLength.millimeters)
        
        let char = CharacteristicRainfall(rainfall: rainfall)
        return.success(char)
    }
    
    /// Encodes the Characteristic into Data
    ///
    /// - Returns: Characteristic Data Result
    public func encode() -> Result<Data, BluetoothEncodeError> {
        var msgData = Data()
        
        //Make sure we put this back to back before we create Data
        let value = rainfall.converted(to: UnitLength.millimeters).value
        
        msgData.append(Data(from: UInt32(value).littleEndian))
        
        return.success(msgData)
    }
}

extension CharacteristicRainfall: Hashable {
    
    /// Hashes the essential components of this value by feeding them into the
    /// given hasher.
    ///
    /// Implement this method to conform to the `Hashable` protocol. The
    /// components used for hashing must be the same as the components compared
    /// in your type's `==` operator implementation. Call `hasher.combine(_:)`
    /// with each of these components.
    ///
    /// - Important: Never call `finalize()` on `hasher`. Doing so may become a
    ///   compile-time error in the future.
    ///
    /// - Parameter hasher: The hasher to use when combining the components
    ///   of this instance.
    public func hash(into hasher: inout Hasher) {
        hasher.combine(uuidString)
        hasher.combine(rainfall)
    }
}

extension CharacteristicRainfall: Equatable {
    
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: CharacteristicRainfall, rhs: CharacteristicRainfall) -> Bool {
        return (lhs.uuidString == rhs.uuidString)
            && (lhs.rainfall == rhs.rainfall)
    }
}
