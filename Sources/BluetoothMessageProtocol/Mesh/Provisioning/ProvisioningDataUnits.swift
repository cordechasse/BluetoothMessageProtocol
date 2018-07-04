//
//  ProvisioningDataUnits.swift
//  BluetoothMessageProtocol
//
//  Created by Kevin Hoogheem on 7/4/18.
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

/// Protocol for Provisioning Protocol Data Unit
public protocol ProvisioningDataUnit {

    /// Provisioning Protocol Data Unit Type
    var unitType: ProvisioningDataUnitType { get }

    /// Encodes Provisioning Protocol Data Unit into Data
    ///
    /// - Returns: Encoded Data
    /// - Throws: BluetoothMessageProtocolError
    func encode() throws -> Data
}

/// Provisioning Data Unit Capabilities
///
/// The device sends this PDU to indicate its supported provisioning capabilities to a Provisioner
public struct ProvisioningDataUnitCapabilities: ProvisioningDataUnit {

    /// Provisioning Protocol Data Unit Type
    private(set) public var unitType: ProvisioningDataUnitType

    /// Algorithms
    public struct AlgorithmType: OptionSet {
        public let rawValue: UInt16
        public init(rawValue: UInt16) { self.rawValue = rawValue }

        /// FIPS P-256 Elliptic Curve Supported
        public static let fipsP256  = AlgorithmType(rawValue: 1 << 0)
    }

    /// Public Key Type
    public struct PublicKeyType: OptionSet {
        public let rawValue: UInt8
        public init(rawValue: UInt8) { self.rawValue = rawValue }

        /// Public Key OOB information available
        public static let publicKeyOobAvailable     = PublicKeyType(rawValue: 1 << 0)
    }

    /// Public Key Type
    public struct StaticOobType: OptionSet {
        public let rawValue: UInt8
        public init(rawValue: UInt8) { self.rawValue = rawValue }

        /// Static OOB information available
        public static let staticOobAvailable    = StaticOobType(rawValue: 1 << 0)
    }

    /// Supported Output OOB Actions
    public struct OutputActions: OptionSet {
        public let rawValue: UInt16
        public init(rawValue: UInt16) { self.rawValue = rawValue }

        /// Blink Supported
        public static let blink         = OutputActions(rawValue: 1 << 0)
        /// Beep Supported
        public static let beep          = OutputActions(rawValue: 1 << 1)
        /// Virbrate Supported
        public static let vibrate       = OutputActions(rawValue: 1 << 2)
        /// Output Numeric Supported
        public static let numeric       = OutputActions(rawValue: 1 << 3)
        /// Output Alphanumeric Supported
        public static let alphanumeric  = OutputActions(rawValue: 1 << 4)
    }

    /// Supported Input OOB Actions
    public struct InputActions: OptionSet {
        public let rawValue: UInt16
        public init(rawValue: UInt16) { self.rawValue = rawValue }

        /// Push Supported
        public static let push          = InputActions(rawValue: 1 << 0)
        /// Twist Supported
        public static let twist         = InputActions(rawValue: 1 << 1)
        /// Input Numeric Supported
        public static let numeric       = InputActions(rawValue: 1 << 2)
        /// Output Alphanumeric Supported
        public static let alphanumeric  = InputActions(rawValue: 1 << 3)
    }

    /// Number of Elements
    ///
    /// Number of elements supported by the device
    private(set) public var elements: ProvisioningSize

    /// Algorithms
    ///
    /// Supported algorithms and other capabilities
    private(set) public var algorithm: AlgorithmType

    /// Public Key
    ///
    /// Supported public key types
    private(set) public var publicKey: PublicKeyType

    /// Static OOB Type
    ///
    /// Supported static OOB Types
    private(set) public var staticOobTypes: StaticOobType

    /// Output OOB Size
    ///
    /// Maximum size of Output OOB supported
    private(set) public var outputObbSize: ProvisioningSize

    /// Output OOB Action
    ///
    /// Supported Output OOB Actions
    private(set) public var supportedOutputActions: OutputActions

    /// Input OOB Size
    ///
    /// Maximum size in octets of Input OOB supported
    private(set) public var inputOobSize: ProvisioningSize

    /// Input OOB Action
    ///
    /// Supported Input OOB Actions
    private(set) public var supportedInputActions: InputActions

    /// Create Provisioning Data Unit
    ///
    /// - Parameters:
    ///   - elements: Number of elements supported by the device
    ///   - algorithm: Supported algorithms and other capabilities
    ///   - publicKey: Supported public key types
    ///   - staticOobTypes: Supported static OOB Types
    ///   - outputObbSize: Maximum size of Output OOB supported
    ///   - supportedOutputActions: Supported Output OOB Actions
    ///   - inputOobSize: Maximum size in octets of Input OOB supported
    ///   - supportedInputActions: Supported Input OOB Actions
    public init(elements: ProvisioningSize,
                algorithm: AlgorithmType,
                publicKey: PublicKeyType,
                staticOobTypes: StaticOobType,
                outputObbSize: ProvisioningSize,
                supportedOutputActions: OutputActions,
                inputOobSize: ProvisioningSize,
                supportedInputActions: InputActions) {

        self.unitType = .capabilities
        self.elements = elements
        self.algorithm = algorithm
        self.publicKey = publicKey
        self.staticOobTypes = staticOobTypes
        self.outputObbSize = outputObbSize
        self.supportedOutputActions = supportedOutputActions
        self.inputOobSize = inputOobSize
        self.supportedInputActions = supportedInputActions
    }

    /// Encodes Provisioning Protocol Data Unit into Data
    ///
    /// - Returns: Encoded Data
    /// - Throws: BluetoothMessageProtocolError
    public func encode() throws -> Data {
        var msgData = Data()

        msgData.append(unitType.rawValue)
        msgData.append(elements.rawValue)
        msgData.append(Data(from: algorithm.rawValue.littleEndian))
        msgData.append(publicKey.rawValue)
        msgData.append(staticOobTypes.rawValue)
        msgData.append(outputObbSize.rawValue)
        msgData.append(Data(from: supportedOutputActions.rawValue.littleEndian))
        msgData.append(inputOobSize.rawValue)
        msgData.append(Data(from: supportedInputActions.rawValue.littleEndian))

        return msgData
    }
}

/// Provisioning Data Unit Start
///
/// This Provisioner sends this PDU to deliver the public key to be used in the ECDH calculations
public struct ProvisioningDataUnitStart: ProvisioningDataUnit {

    /// Provisioning Protocol Data Unit Type
    private(set) public var unitType: ProvisioningDataUnitType

    /// Provisioning Algorithm
    public enum Algorithm: UInt8 {
        /// FIPS P-256 Elliptic Curve
        case fipsP256   = 0x00
    }

    /// Public Key Type
    public enum PublicKeyType: UInt8 {
        /// No OOB Public Key is used
        case none       = 0
        /// OOB Public Key is used
        case oobPublic  = 1
    }

    /// Algorithm
    ///
    /// The algorithm used for provisioning
    private(set) public var algorithm: Algorithm

    /// Public Key
    ///
    /// Public Key used
    private(set) public var publicKey: PublicKeyType

    /// Authentication
    private(set) public var authentiction: ProvisioningAuthentication

    /// Create Provisioning Data Unit
    ///
    /// - Parameter algorithm: Algorithm
    /// - Parameter publicKey: Public Key
    /// - Parameter authentiction: ProvisioningAuthentication
    public init(algorithm: Algorithm, publicKey: PublicKeyType, authentiction: ProvisioningAuthentication) {
        self.unitType = .start
        self.algorithm = algorithm
        self.publicKey = publicKey
        self.authentiction = authentiction
    }

    /// Encodes Provisioning Protocol Data Unit into Data
    ///
    /// - Returns: Encoded Data
    /// - Throws: BluetoothMessageProtocolError
    public func encode() throws -> Data {
        var msgData = Data()

        msgData.append(unitType.rawValue)
        msgData.append(algorithm.rawValue)
        msgData.append(publicKey.rawValue)
        msgData.append(try authentiction.encode())

        return msgData
    }
}

/// Provisioning Data Unit Public Key
///
/// This Provisioner sends this PDU to deliver the public key to be used in the ECDH calculations
public struct ProvisioningDataUnitPublicKey: ProvisioningDataUnit {

    /// Provisioning Protocol Data Unit Type
    private(set) public var unitType: ProvisioningDataUnitType

    /// Public Key X
    ///
    /// The X component of public key for the FIPS P-256 algorithm
    private(set) public var publicKeyX: Data

    /// Public Key Y
    ///
    /// The Y component of public key for the FIPS P-256 algorithm
    private(set) public var publicKeyY: Data

    /// Create Provisioning Data Unit
    ///
    /// - Parameter publicKeyX: Public Key X
    /// - Parameter publicKeyY: Public Key Y
    public init(publicKeyX: Data, publicKeyY: Data) {
        self.unitType = .publicKey
        self.publicKeyX = publicKeyX
        self.publicKeyY = publicKeyY
    }

    /// Encodes Provisioning Protocol Data Unit into Data
    ///
    /// - Returns: Encoded Data
    /// - Throws: BluetoothMessageProtocolError
    public func encode() throws -> Data {
        var msgData = Data()

        guard publicKeyX.count == 32 else {
            throw BluetoothMessageProtocolError(.encodeError(msg: "The publicKeyX must be 32 bytes"))
        }
        guard publicKeyY.count == 32 else {
            throw BluetoothMessageProtocolError(.encodeError(msg: "The publicKeyY must be 32 bytes"))
        }

        msgData.append(unitType.rawValue)
        msgData.append(publicKeyX)
        msgData.append(publicKeyY)

        return msgData
    }
}

/// Provisioning Data Unit Input Complete
///
/// The device sends this PDU when the user completes the input operation
public struct ProvisioningDataUnitInputComplete: ProvisioningDataUnit {

    /// Provisioning Protocol Data Unit Type
    private(set) public var unitType: ProvisioningDataUnitType

    /// Create Provisioning Data Unit
    public init() {
        self.unitType = .inputComplete
    }

    /// Encodes Provisioning Protocol Data Unit into Data
    ///
    /// - Returns: Encoded Data
    /// - Throws: BluetoothMessageProtocolError
    public func encode() throws -> Data {
        var msgData = Data()

        msgData.append(unitType.rawValue)

        return msgData
    }
}

/// Provisioning Data Unit Confirmation
///
/// The Provisioner or the device sends this PDU to the peer to confirm the values exchanged so far including the OOB Authentication value and the random number that has yet to be exchanged
public struct ProvisioningDataUnitConfirmation: ProvisioningDataUnit {

    /// Provisioning Protocol Data Unit Type
    private(set) public var unitType: ProvisioningDataUnitType

    /// Confirmation
    ///
    /// The values exchanged so far including the OOB Authentication value
    private(set) public var confirmation: Data

    /// Create Provisioning Data Unit
    ///
    /// - Parameter confirmation: Confirmation Data
    public init(confirmation: Data) {
        self.unitType = .confirmation
        self.confirmation = confirmation
    }

    /// Encodes Provisioning Protocol Data Unit into Data
    ///
    /// - Returns: Encoded Data
    /// - Throws: BluetoothMessageProtocolError
    public func encode() throws -> Data {
        var msgData = Data()

        guard confirmation.count == 16 else {
            throw BluetoothMessageProtocolError(.encodeError(msg: "The confirmation must be 16 bytes"))
        }

        msgData.append(unitType.rawValue)
        msgData.append(confirmation)

        return msgData
    }
}

/// Provisioning Data Unit Random
///
/// A Provisioner or device sends this PDU to enable the peer device to validate the confirmation
public struct ProvisioningDataUnitRandom: ProvisioningDataUnit {

    /// Provisioning Protocol Data Unit Type
    private(set) public var unitType: ProvisioningDataUnitType

    /// Confirmation
    ///
    /// The final input to the confirmation
    private(set) public var confirmation: Data

    /// Create Provisioning Data Unit
    ///
    /// - Parameter confirmation: Confirmation Data
    public init(confirmation: Data) {
        self.unitType = .random
        self.confirmation = confirmation
    }

    /// Encodes Provisioning Protocol Data Unit into Data
    ///
    /// - Returns: Encoded Data
    /// - Throws: BluetoothMessageProtocolError
    public func encode() throws -> Data {
        var msgData = Data()

        guard confirmation.count == 16 else {
            throw BluetoothMessageProtocolError(.encodeError(msg: "The final input to the confirmation must be 16 bytes"))
        }

        msgData.append(unitType.rawValue)
        msgData.append(confirmation)

        return msgData
    }
}

/// Provisioning Data Unit Data
///
/// A Provisioner sends this PDU to deliver provisioning data to the device
public struct ProvisioningDataUnitData: ProvisioningDataUnit {

    /// Provisioning Protocol Data Unit Type
    private(set) public var unitType: ProvisioningDataUnitType

    /// Encrypted Provisioning Data
    ///
    /// An encrypted and authenticated network key, NetKey Index, Key Refresh Flag, IV Update Flag, current value of the IV Index, and unicast address of the primary element
    private(set) public var provisioningData: ProvisioningData

    /// Provisioning Data Message Integrity Check (MIC)
    ///
    /// Provisioning Data MIC
    private(set) public var messageIntegrity: Data

    /// Create Provisioning Data Unit
    ///
    /// - Parameter provisioningData: Provisioning Data
    /// - Parameter messageIntegrity: Provisioning Data MIC
    public init(provisioningData: ProvisioningData, messageIntegrity: Data) {
        self.unitType = .data
        self.provisioningData = provisioningData
        self.messageIntegrity = messageIntegrity
    }

    /// Encodes Provisioning Protocol Data Unit into Data
    ///
    /// - Returns: Encoded Data
    /// - Throws: BluetoothMessageProtocolError
    public func encode() throws -> Data {
        var msgData = Data()

        guard messageIntegrity.count == 8 else {
            throw BluetoothMessageProtocolError(.encodeError(msg: "The messageIntegrity must be 8 bytes"))
        }

        msgData.append(unitType.rawValue)
        /// Get the Provisioning Data and try to encode it
        msgData.append(try provisioningData.encode())
        msgData.append(messageIntegrity)

        return msgData
    }
}

/// Provisioning Data Unit Complete
///
/// The device sends this PDU to indicate that it has successfully received and processed the provisioning data
public struct ProvisioningDataUnitComplete: ProvisioningDataUnit {

    /// Provisioning Protocol Data Unit Type
    private(set) public var unitType: ProvisioningDataUnitType

    /// Create Provisioning Data Unit
    public init() {
        self.unitType = .complete
    }

    /// Encodes Provisioning Protocol Data Unit into Data
    ///
    /// - Returns: Encoded Data
    /// - Throws: BluetoothMessageProtocolError
    public func encode() throws -> Data {
        var msgData = Data()

        msgData.append(unitType.rawValue)

        return msgData
    }
}

/// Provisioning Data Unit Failed
///
/// The device sends this PDU if it fails to process a received provisioning protocol PDU
public struct ProvisioningDataUnitFailed: ProvisioningDataUnit {

    /// Provisioning Protocol Data Unit Type
    private(set) public var unitType: ProvisioningDataUnitType

    /// Provisioning Protocol Data Unit Types
    public enum ErrorType: UInt8 {
        /// Prohibited
        case prohibited             = 0x00
        /// The provisioning protocol PDU is not recognized by the device
        case invalidDataUnit        = 0x01
        /// The arguments of the protocol PDUs are outside expected values or the length of the PDU is different than expected
        case invalidFormat          = 0x02
        /// The PDU received was not expected at this moment of the procedure
        case unexpectedUnit         = 0x03
        /// The PDU received was not expected at this moment of the procedure
        case confirmationFailed     = 0x04
        /// The provisioning protocol cannot be continued due to insufficient resources in the device
        case outOfResources         = 0x05
        /// The Data block was not successfully decrypted
        case decryptionFailed       = 0x06
        /// An unexpected error occurred that may not be recoverable
        case unexpectedError        = 0x07
        /// The device cannot assign consecutive unicast addresses to all elements
        case cannotAssignAddresses  = 0x08
    }

    /// Error for Failure Reason
    private(set) public var errorReason: ErrorType

    /// Create Provisioning Data Unit
    ///
    /// - Parameter errorReason: Error Rason
    public init(errorReason: ErrorType) {
        self.unitType = .failed
        self.errorReason = errorReason
    }

    /// Encodes Provisioning Protocol Data Unit into Data
    ///
    /// - Returns: Encoded Data
    /// - Throws: BluetoothMessageProtocolError
    public func encode() throws -> Data {
        var msgData = Data()

        msgData.append(unitType.rawValue)
        msgData.append(unitType.rawValue)

        return msgData
    }
}

extension ProvisioningDataUnitFailed.ErrorType {

    public var description: String {
        return String(describing: self)
    }
}

@available(swift 4.0)
extension ProvisioningDataUnitFailed.ErrorType: Encodable {

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: TypeValueCodingKeys.self)

        /// KAH - Prefer the name of the type over a raw value
        try container.encode(self.rawValue, forKey: .value)
        try container.encode(self.description, forKey: .type)
    }
}
