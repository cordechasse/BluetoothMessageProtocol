//
//  CharacteristicPosition2D.swift
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

/// BLE Position 2D Characteristic
@available(swift 3.1)
@available(iOS 10.0, tvOS 10.0, watchOS 3.0, OSX 10.12, *)
final public class CharacteristicPosition2D: Characteristic {
    
    /// Characteristic Name
    public static var name: String { "Position 2D" }
    
    /// Characteristic UUID
    public static var uuidString: String { "2AAF" }
    
    /// Name of the Characteristic
    public var name: String { Self.name }
    
    /// Characteristic UUID String
    public var uuidString: String { Self.uuidString }
    
    /// Latitude
    ///
    /// WGS84 North coordinate
    private(set) public var latitude: Int32
    
    /// Longitude
    ///
    /// WGS84 East coordinate
    private(set) public var longitude: Int32
    
    /// Creates Position 2D Characteristic
    ///
    /// - Parameters:
    ///   - latitude: WGS84 North coordinate
    ///   - longitude: WGS84 East coordinate
    public init(latitude: Int32, longitude: Int32) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    /// Decodes Characteristic Data into Characteristic
    ///
    /// - Parameter data: Characteristic Data
    /// - Returns: Characteristic Result
    public class func decode(with data: Data) -> Result<CharacteristicPosition2D, BluetoothDecodeError> {
        var decoder = DecodeData()
        
        let lat = decoder.decodeInt32(data)
        let lon = decoder.decodeInt32(data)
        
        let char = CharacteristicPosition2D(latitude: lat,
                                            longitude: lon)
        return.success(char)
    }
    
    /// Encodes the Characteristic into Data
    ///
    /// - Returns: Characteristic Data Result
    public func encode() -> Result<Data, BluetoothEncodeError> {
        var msgData = Data()
        
        msgData.append(Data(from: latitude.littleEndian))
        msgData.append(Data(from: longitude.littleEndian))
        
        return.success(msgData)
    }
}

extension CharacteristicPosition2D: Hashable {
    
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
        hasher.combine(latitude)
        hasher.combine(longitude)
    }
}

extension CharacteristicPosition2D: Equatable {
    
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: CharacteristicPosition2D, rhs: CharacteristicPosition2D) -> Bool {
        return (lhs.uuidString == rhs.uuidString)
            && (lhs.latitude == rhs.latitude)
            && (lhs.longitude == rhs.longitude)
    }
}
