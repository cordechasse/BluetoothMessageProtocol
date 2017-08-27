//
//  CharacteristicRowerData.swift
//  BluetoothMessageProtocol
//
//  Created by Kevin Hoogheem on 8/27/17.
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

/// BLE Rower Data Characteristic
///
/// The Rower Data characteristic is used to send training-related data to the Client from a rower (Server).
@available(swift 3.1)
@available(iOS 10.0, tvOS 10.0, watchOS 3.0, OSX 10.12, *)
open class CharacteristicRowerData: Characteristic {

    public static var name: String {
        return "Rower Data"
    }

    public static var uuidString: String {
        return "2AD1"
    }

    /// Flags
    private struct Flags: OptionSet {
        public let rawValue: UInt16
        public init(rawValue: UInt16) { self.rawValue = rawValue }

        public static let moreData: Flags                       = Flags(rawValue: 1 << 0)
        public static let averageStrokePresent: Flags           = Flags(rawValue: 1 << 1)
        public static let totalDistancePresent: Flags           = Flags(rawValue: 1 << 1)
        public static let instantaneousPacePresent: Flags       = Flags(rawValue: 1 << 3)
        public static let averagePacePresent: Flags             = Flags(rawValue: 1 << 4)
        public static let instantaneousPowerPresent: Flags      = Flags(rawValue: 1 << 5)
        public static let averagePowerPresent: Flags            = Flags(rawValue: 1 << 6)
        public static let resistanceLevelPresent: Flags         = Flags(rawValue: 1 << 7)
        public static let expendedEnergyPresent: Flags          = Flags(rawValue: 1 << 8)
        public static let heartRatePresent: Flags               = Flags(rawValue: 1 << 9)
        public static let metabolicEquivalentPresent: Flags     = Flags(rawValue: 1 << 10)
        public static let elapsedTimePresent: Flags             = Flags(rawValue: 1 << 11)
        public static let remainingTimePresent: Flags           = Flags(rawValue: 1 << 12)
    }


    /// Stroke Rate
    private(set) public var strokeRate: Measurement<UnitCadence>?

    /// Stroke Count
    private(set) public var strokeCount: UInt16?

    /// Average Stroke Rate
    private(set) public var averageStrokeRate: Measurement<UnitCadence>?

    /// Total Distance
    private(set) public var totalDistance: Measurement<UnitLength>?

    /// Instantaneous Pace
    private(set) public var instantaneousPace: Measurement<UnitDuration>?

    /// Average Pace
    private(set) public var averagePace: Measurement<UnitDuration>?

    /// Instantaneous Power
    private(set) public var instantaneousPower: Measurement<UnitPower>?

    /// Average Power
    private(set) public var averagePower: Measurement<UnitPower>?

    /// Resistance Level
    private(set) public var resistanceLevel: Double?

    /// Total Energy
    private(set) public var totalEnergy: Measurement<UnitEnergy>?

    /// Energy Per Hour
    private(set) public var energyPerHour: Measurement<UnitEnergy>?

    /// Energy Per Minute
    private(set) public var energyPerMinute: Measurement<UnitEnergy>?

    /// Heart Rate
    private(set) public var heartRate: Measurement<UnitCadence>?

    /// Metabolic Equivalent
    private(set) public var metabolicEquivalent: Double?

    /// Elapsed Time
    private(set) public var elapsedTime: Measurement<UnitDuration>?

    /// Remaining Time
    private(set) public var remainingTime: Measurement<UnitDuration>?


    public init(strokeRate: Measurement<UnitCadence>?, strokeCount: UInt16?, averageStrokeRate: Measurement<UnitCadence>?, totalDistance: Measurement<UnitLength>?, instantaneousPace: Measurement<UnitDuration>?, averagePace: Measurement<UnitDuration>?, instantaneousPower: Measurement<UnitPower>?, averagePower: Measurement<UnitPower>?, resistanceLevel: Double?, totalEnergy: Measurement<UnitEnergy>?, energyPerHour: Measurement<UnitEnergy>?, energyPerMinute: Measurement<UnitEnergy>?, heartRate: UInt8?, metabolicEquivalent: Double?, elapsedTime: Measurement<UnitDuration>?, remainingTime: Measurement<UnitDuration>?) {

        self.strokeRate = strokeRate
        self.strokeCount = strokeCount
        self.averageStrokeRate = averageStrokeRate
        self.totalDistance = totalDistance
        self.instantaneousPace = instantaneousPace
        self.averagePace = averagePace
        self.instantaneousPower = instantaneousPower
        self.averagePower = averagePower
        self.resistanceLevel = resistanceLevel

        self.totalEnergy = totalEnergy
        self.energyPerHour = energyPerHour
        self.energyPerMinute = energyPerMinute

        if let hRate = heartRate {
            self.heartRate = Measurement(value: Double(hRate), unit: UnitCadence.beatsPerMinute)
        } else {
            self.heartRate = nil
        }

        self.metabolicEquivalent = metabolicEquivalent
        self.elapsedTime = elapsedTime
        self.remainingTime = remainingTime

        super.init(name: CharacteristicRowerData.name, uuidString: CharacteristicRowerData.uuidString)
    }

    open override class func decode(data: Data) throws -> CharacteristicRowerData {

        var decoder = DataDecoder(data)

        let flags = Flags(rawValue: decoder.decodeUInt16())

        var strokeRate: Measurement<UnitCadence>?
        var strokeCount: UInt16?
        if flags.contains(.moreData) == true {
            let value = Double(decoder.decodeUInt8()) * 0.5
            strokeRate = Measurement(value: value, unit: UnitCadence.strokesPerMinute)

            strokeCount = decoder.decodeUInt16()
        }

        var averageStrokeRate: Measurement<UnitCadence>?
        if flags.contains(.averageStrokePresent) == true {
            let value = Double(decoder.decodeUInt8()) * 0.5
            averageStrokeRate = Measurement(value: value, unit: UnitCadence.strokesPerMinute)
        }

        var totalDistance: Measurement<UnitLength>?
        if flags.contains(.totalDistancePresent) == true {
            let value = Double(decoder.decodeUInt16())
            totalDistance = Measurement(value: value, unit: UnitLength.meters)
        }

        var instantaneousPace: Measurement<UnitDuration>?
        if flags.contains(.instantaneousPacePresent) == true {
            let value = Double(decoder.decodeUInt16())
            instantaneousPace = Measurement(value: value, unit: UnitDuration.seconds)
        }

        var averagePace: Measurement<UnitDuration>?
        if flags.contains(.averagePacePresent) == true {
            let value = Double(decoder.decodeUInt16())
            averagePace = Measurement(value: value, unit: UnitDuration.seconds)
        }

        var iPower: Measurement<UnitPower>?
        if flags.contains(.instantaneousPowerPresent) == true {
            let value = Double(decoder.decodeInt16())
            iPower = Measurement(value: value, unit: UnitPower.watts)
        }

        var aPower: Measurement<UnitPower>?
        if flags.contains(.averagePowerPresent) == true {
            let value = Double(decoder.decodeInt16())
            aPower = Measurement(value: value, unit: UnitPower.watts)
        }

        var resistanceLevel: Double?
        if flags.contains(.resistanceLevelPresent) == true {
            resistanceLevel = Double(decoder.decodeInt16()) * 0.1
        }

        var totalEnergy: Measurement<UnitEnergy>?
        var energyPerHour: Measurement<UnitEnergy>?
        var energyPerMinute: Measurement<UnitEnergy>?
        if flags.contains(.expendedEnergyPresent) == true {
            let tValue = Double(decoder.decodeUInt16())
            totalEnergy = Measurement(value: tValue, unit: UnitEnergy.kilocalories)

            let perHourValue = Double(decoder.decodeUInt16())
            energyPerHour = Measurement(value: perHourValue, unit: UnitEnergy.kilocalories)

            let perMinValue = Double(decoder.decodeUInt8())
            energyPerMinute = Measurement(value: perMinValue, unit: UnitEnergy.kilocalories)

        }

        var heartRate: UInt8?
        if flags.contains(.heartRatePresent) == true {
            heartRate = decoder.decodeUInt8()
        }

        var mets: Double?
        if flags.contains(.metabolicEquivalentPresent) == true {
            mets = Double(decoder.decodeUInt8()) * 0.1
        }

        var elapsedTime: Measurement<UnitDuration>?
        if flags.contains(.elapsedTimePresent) == true {
            let value = Double(decoder.decodeUInt16())
            elapsedTime = Measurement(value: value, unit: UnitDuration.seconds)
        }

        var remainingTime: Measurement<UnitDuration>?
        if flags.contains(.remainingTimePresent) == true {
            let value = Double(decoder.decodeUInt16())
            remainingTime = Measurement(value: value, unit: UnitDuration.seconds)
        }

        return CharacteristicRowerData(strokeRate: strokeRate,
                                       strokeCount: strokeCount,
                                       averageStrokeRate: averageStrokeRate,
                                       totalDistance: totalDistance,
                                       instantaneousPace: instantaneousPace,
                                       averagePace: averagePace,
                                       instantaneousPower: iPower,
                                       averagePower: aPower,
                                       resistanceLevel: resistanceLevel,
                                       totalEnergy: totalEnergy,
                                       energyPerHour: energyPerHour,
                                       energyPerMinute: energyPerMinute,
                                       heartRate: heartRate,
                                       metabolicEquivalent: mets,
                                       elapsedTime: elapsedTime,
                                       remainingTime: remainingTime)
    }

    open override func encode() throws -> Data {
        //Not Yet Supported
        throw BluetoothMessageProtocolError.init(.unsupported)
    }
}
