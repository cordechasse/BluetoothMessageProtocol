//
//  CharacteristicIndoorBikeData.swift
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

/// BLE Indoor Bike Data Characteristic
///
/// The Indoor Bike Data characteristic is used to send training-related data to
/// the Client from an indoor bike (Server).
@available(swift 3.1)
@available(iOS 10.0, tvOS 10.0, watchOS 3.0, OSX 10.12, *)
final public class CharacteristicIndoorBikeData: Characteristic {
    
    /// Characteristic Name
    public static var name: String { "Indoor Bike Data" }
    
    /// Characteristic UUID
    public static var uuidString: String { "2AD2" }
    
    /// Name of the Characteristic
    public var name: String { Self.name }
    
    /// Characteristic UUID String
    public var uuidString: String { Self.uuidString }
    
    /// Instantaneous Speed
    private(set) public var instantaneousSpeed: FitnessMachineSpeedType?
    
    /// Average Speed
    private(set) public var averageSpeed: FitnessMachineSpeedType?
    
    /// Instantaneous Cadence
    private(set) public var instantaneousCadence: Measurement<UnitCadence>?
    
    /// Average Cadence
    private(set) public var averageCadence: Measurement<UnitCadence>?
    
    /// Total Distance
    private(set) public var totalDistance: Measurement<UnitLength>?
    
    /// Resistance Level
    private(set) public var resistanceLevel: Int16?
    
    /// Instantaneous Power
    private(set) public var instantaneousPower: FitnessMachinePowerType?
    
    /// Average Power
    private(set) public var averagePower: FitnessMachinePowerType?
    
    /// Energy Information
    private(set) public var energy: FitnessMachineEnergy
    
    /// Heart Rate
    private(set) public var heartRate: Measurement<UnitCadence>?
    
    /// Metabolic Equivalent
    private(set) public var metabolicEquivalent: Double?
    
    /// Time Information
    private(set) public var time: FitnessMachineTime
    
    /// Creates Indoor Bike Data Characteristic
    ///
    /// - Parameters:
    ///   - instantaneousSpeed: Instantaneous Speed
    ///   - averageSpeed: Average Speed
    ///   - instantaneousCadence: Instantaneous Cadence
    ///   - averageCadence: Average Cadence
    ///   - totalDistance: Total Distance
    ///   - resistanceLevel: Instantaneous Power
    ///   - instantaneousPower: Instantaneous Power
    ///   - averagePower: Average Power
    ///   - energy: Energy Information
    ///   - heartRate: Heart Rate
    ///   - metabolicEquivalent: Metabolic Equivalent
    ///   - time: Time Information
    public init(instantaneousSpeed: FitnessMachineSpeedType?,
                averageSpeed: FitnessMachineSpeedType?,
                instantaneousCadence: Measurement<UnitCadence>?,
                averageCadence: Measurement<UnitCadence>?,
                totalDistance: Measurement<UnitLength>?,
                resistanceLevel: Int16?,
                instantaneousPower: FitnessMachinePowerType?,
                averagePower: FitnessMachinePowerType?,
                energy: FitnessMachineEnergy,
                heartRate: UInt8?,
                metabolicEquivalent: Double?,
                time: FitnessMachineTime) {
        
        self.instantaneousSpeed = instantaneousSpeed
        self.averageSpeed = averageSpeed
        self.instantaneousCadence = instantaneousCadence
        self.averageCadence = averageCadence
        self.totalDistance = totalDistance
        self.resistanceLevel = resistanceLevel
        self.instantaneousPower = instantaneousPower
        self.averagePower = averagePower
        self.energy = energy
        
        if let hRate = heartRate {
            self.heartRate = Measurement(value: Double(hRate), unit: UnitCadence.beatsPerMinute)
        } else {
            self.heartRate = nil
        }
        
        self.metabolicEquivalent = metabolicEquivalent
        self.time = time
    }
    
    /// Decodes Characteristic Data into Characteristic
    ///
    /// - Parameter data: Characteristic Data
    /// - Returns: Characteristic Result
    public class func decode<C: Characteristic>(with data: Data) -> Result<C, BluetoothDecodeError> {
        var decoder = DecodeData()
        
        let flags = Flags(rawValue: decoder.decodeUInt16(data))
        
        var heartRate: UInt8?
        var mets: Double?
        
        var iSpeed: FitnessMachineSpeedType?
        /// Available only when More data is NOT present
        if flags.contains(.moreData) == false {
            iSpeed = FitnessMachineSpeedType.create(decoder.decodeUInt16(data))
        }
        
        var avgSpeed: FitnessMachineSpeedType?
        if flags.contains(.averageSpeedPresent) {
            avgSpeed = FitnessMachineSpeedType.create(decoder.decodeUInt16(data))
        }
        
        let instantaneousCadence = decodeCadence(supported: flags,
                                                 flag: .instantaneousCadencePresent,
                                                 unit: UnitCadence.revolutionsPerMinute,
                                                 data: data, decoder: &decoder)
        
        let averageCadence = decodeCadence(supported: flags,
                                           flag: .averageCadencePresent,
                                           unit: UnitCadence.revolutionsPerMinute,
                                           data: data, decoder: &decoder)
        
        var totalDistance: Measurement<UnitLength>?
        if flags.contains(.totalDistancePresent) {
            let value = Double(decoder.decodeUInt24(data))
            totalDistance = Measurement(value: value, unit: UnitLength.meters)
        }
        
        var resistanceLevel: Int16?
        if flags.contains(.resistanceLevelPresent) {
            resistanceLevel = decoder.decodeInt16(data)
        }
        
        var iPower: FitnessMachinePowerType?
        if flags.contains(.instantaneousPowerPresent) {
            iPower = FitnessMachinePowerType.create(decoder.decodeInt16(data))
        }
        
        var aPower: FitnessMachinePowerType?
        if flags.contains(.averagePowerPresent) {
            aPower = FitnessMachinePowerType.create(decoder.decodeInt16(data))
        }
        
        var fitEnergy: FitnessMachineEnergy
        if flags.contains(.expendedEnergyPresent) {
            fitEnergy = FitnessMachineEnergy.decode(data, decoder: &decoder)
        } else {
            fitEnergy = FitnessMachineEnergy(total: nil, perHour: nil, perMinute: nil)
        }
        
        if flags.contains(.heartRatePresent) {
            heartRate = decoder.decodeUInt8(data)
        }
        
        if flags.contains(.metabolicEquivalentPresent) {
            mets = decoder.decodeUInt8(data).resolution(.removing, resolution: .oneTenth)
        }
        
        let elapsedTime = decodeDuration(supported: flags,
                                         flag: .elapsedTimePresent,
                                         unit: UnitDuration.seconds,
                                         data: data, decoder: &decoder)
        
        let remainingTime = decodeDuration(supported: flags,
                                           flag: .remainingTimePresent,
                                           unit: UnitDuration.seconds,
                                           data: data, decoder: &decoder)
        
        let time = FitnessMachineTime(elapsed: elapsedTime, remaining: remainingTime)
        
        let char = CharacteristicIndoorBikeData(instantaneousSpeed: iSpeed,
                                                averageSpeed: avgSpeed,
                                                instantaneousCadence: instantaneousCadence,
                                                averageCadence: averageCadence,
                                                totalDistance: totalDistance,
                                                resistanceLevel: resistanceLevel,
                                                instantaneousPower: iPower,
                                                averagePower: aPower,
                                                energy: fitEnergy,
                                                heartRate: heartRate,
                                                metabolicEquivalent: mets,
                                                time: time)
        return.success(char as! C)
    }
    
    /// Encodes the Characteristic into Data
    ///
    /// - Returns: Characteristic Data Result
    public func encode() -> Result<Data, BluetoothEncodeError> {
        /// Not Yet Supported
        return.failure(BluetoothEncodeError.notSupported)
    }
}

extension CharacteristicIndoorBikeData: Hashable {
    
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
        hasher.combine(instantaneousSpeed)
        hasher.combine(averageSpeed)
        hasher.combine(instantaneousCadence)
        hasher.combine(averageCadence)
        hasher.combine(totalDistance)
        hasher.combine(resistanceLevel)
        hasher.combine(instantaneousPower)
        hasher.combine(averagePower)
        hasher.combine(energy)
        hasher.combine(heartRate)
        hasher.combine(metabolicEquivalent)
        hasher.combine(time)
    }
}

extension CharacteristicIndoorBikeData: Equatable {
    
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: CharacteristicIndoorBikeData, rhs: CharacteristicIndoorBikeData) -> Bool {
        return (lhs.uuidString == rhs.uuidString)
            && (lhs.instantaneousSpeed == rhs.instantaneousSpeed)
            && (lhs.averageSpeed == rhs.averageSpeed)
            && (lhs.instantaneousCadence == rhs.instantaneousCadence)
            && (lhs.averageCadence == rhs.averageCadence)
            && (lhs.totalDistance == rhs.totalDistance)
            && (lhs.resistanceLevel == rhs.resistanceLevel)
            && (lhs.instantaneousPower == rhs.instantaneousPower)
            && (lhs.averagePower == rhs.averagePower)
            && (lhs.energy == rhs.energy)
            && (lhs.heartRate == rhs.heartRate)
            && (lhs.metabolicEquivalent == rhs.metabolicEquivalent)
            && (lhs.time == rhs.time)
    }
}

private extension CharacteristicIndoorBikeData {
    
    /// Flags
    struct Flags: OptionSet {
        public let rawValue: UInt16
        public init(rawValue: UInt16) { self.rawValue = rawValue }
        
        /// More Data not present (is defined opposite of the norm)
        public static let moreData                      = Flags(rawValue: 1 << 0)
        /// Average Speed present
        public static let averageSpeedPresent           = Flags(rawValue: 1 << 1)
        /// Instantaneous Cadence present
        public static let instantaneousCadencePresent   = Flags(rawValue: 1 << 2)
        /// Average Candence present
        public static let averageCadencePresent         = Flags(rawValue: 1 << 3)
        /// Total Distance Present
        public static let totalDistancePresent          = Flags(rawValue: 1 << 4)
        /// Resistance Level present
        public static let resistanceLevelPresent        = Flags(rawValue: 1 << 5)
        /// Instantaneous Power present
        public static let instantaneousPowerPresent     = Flags(rawValue: 1 << 6)
        /// Average Power present
        public static let averagePowerPresent           = Flags(rawValue: 1 << 7)
        /// Expended Energy present
        public static let expendedEnergyPresent         = Flags(rawValue: 1 << 8)
        /// Heart Rate present
        public static let heartRatePresent              = Flags(rawValue: 1 << 9)
        /// Metabolic Equivalent present
        public static let metabolicEquivalentPresent    = Flags(rawValue: 1 << 10)
        /// Elapsed Time present
        public static let elapsedTimePresent            = Flags(rawValue: 1 << 11)
        /// Remaining Time present
        public static let remainingTimePresent          = Flags(rawValue: 1 << 12)
    }
    
    /// Decode Cadence Data
    ///
    /// - Parameters:
    ///   - flag: Flags
    ///   - unit: Cadence Unit
    ///   - data: Sensor Data
    ///   - decoder: Decoder
    /// - Returns: Measurement<UnitCadence>?
    /// - Throws: BluetoothDecodeError
    private class func decodeCadence(supported: Flags,
                                     flag: Flags,
                                     unit: UnitCadence,
                                     data: Data,
                                     decoder: inout DecodeData) -> Measurement<UnitCadence>? {
        
        var cadenceValue: Measurement<UnitCadence>?
        if supported.contains(flag) {
            let value = Double(decoder.decodeUInt16(data)).resolution(.removing, resolution: .two)
            cadenceValue = Measurement(value: value, unit: unit)
        }
        return cadenceValue
    }
    
    /// Decode Duration Data
    ///
    /// - Parameters:
    ///   - flag: Flags
    ///   - unit: Duration Unit
    ///   - data: Sensor Data
    ///   - decoder: Decoder
    /// - Returns: Measurement<UnitDuration>?
    /// - Throws: BluetoothDecodeError
    private class func decodeDuration(supported: Flags,
                                      flag: Flags,
                                      unit: UnitDuration,
                                      data: Data,
                                      decoder: inout DecodeData) -> Measurement<UnitDuration>? {
        
        var durationData: Measurement<UnitDuration>?
        if supported.contains(flag) {
            let value = Double(decoder.decodeUInt16(data))
            durationData = Measurement(value: value, unit: unit)
        }
        return durationData
    }
}
