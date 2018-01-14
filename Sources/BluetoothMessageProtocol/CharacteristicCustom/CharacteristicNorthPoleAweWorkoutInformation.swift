//
//  CharacteristicNorthPoleAweWorkoutInformation.swift
//  BluetoothMessageProtocol
//
//  Created by Kevin Hoogheem on 12/21/17.
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


/// BLE AWE Workout Information Characteristic
///
@available(swift 3.1)
@available(iOS 10.0, tvOS 10.0, watchOS 3.0, OSX 10.12, *)
open class CharacteristicNorthPoleAweWorkoutInformation: Characteristic {

    /// Characteristic Name
    public static var name: String {
        return "AWE Workout Information"
    }

    /// Characteristic UUID
    public static var uuidString: String {
        return "4B486402-6E6F-7274-6870-6F6C65656E67"
    }

    private struct Flags {
        /// Are Points Included
        private(set) public var isPointsPresent: Bool
        /// Sensor Contact Status
        private(set) public var isEnergyExpendedPresent: Bool

        /// Rawvalue
        public var rawValue: UInt8 {
            var value: UInt8 = UInt8(isPointsPresent == true ? 1 : 0)

            value |= UInt8(isEnergyExpendedPresent == true ? 1 : 0) << 1

            return UInt8(value)
        }

        /// Creates Flags Struct
        ///
        /// - Parameter value: UInt8 Flag Data
        public init(_ value: UInt8) {
            self.isPointsPresent = (value & 0x01 == 0x01)
            self.isEnergyExpendedPresent = (value & 0x02 == 0x02)
        }

        /// Creates Flags Structs
        ///
        /// - Parameters:
        ///   - isPointsPresent: Points Present
        ///   - isEnergyExpendedPresent: Energy Expended Present
        public init(isPointsPresent: Bool, isEnergyExpendedPresent: Bool) {
            self.isPointsPresent = isPointsPresent
            self.isEnergyExpendedPresent = isEnergyExpendedPresent
        }
    }

    /// Points Earned
    private(set) public var points: UInt16?

    /// Energy Expanded
    private(set) public var energyExpended: Measurement<UnitEnergy>?

    /// Creates Workout Information Characteristic
    ///
    /// - Parameters:
    ///   - points: Points Earned
    ///   - energyExpended: Energy Expended
    public init(points: UInt16?, energyExpended: Measurement<UnitEnergy>?) {

        self.points = points
        self.energyExpended = energyExpended

        super.init(name: CharacteristicNorthPoleAweWorkoutInformation.name,
                   uuidString: CharacteristicNorthPoleAweWorkoutInformation.uuidString)
    }

    /// Deocdes the BLE Data
    ///
    /// - Parameter data: Data from sensor
    /// - Returns: Characteristic Instance
    /// - Throws: BluetoothMessageProtocolError
    open override class func decode(data: Data) throws -> CharacteristicNorthPoleAweWorkoutInformation {
        var decoder = DataDecoder(data)

        let flags = Flags(decoder.decodeUInt8())

        var points: UInt16? = nil

        if flags.isPointsPresent == true {
            points = decoder.decodeUInt16()
        }

        var energy: Measurement<UnitEnergy>? = nil

        if flags.isEnergyExpendedPresent == true {
            let expended = decoder.decodeUInt16()
            energy = Measurement(value: Double(expended), unit: UnitEnergy.kilojoules)
        }

        return CharacteristicNorthPoleAweWorkoutInformation(points: points,
                                                            energyExpended: energy)
    }

    /// Encodes the Characteristic into Data
    ///
    /// - Returns: Data representation of the Characteristic
    /// - Throws: BluetoothMessageProtocolError
    open override func encode() throws -> Data {
        /// This is not a write Characteristic so we don't need to support
        throw BluetoothMessageProtocolError.init(.unsupported)
    }
}
