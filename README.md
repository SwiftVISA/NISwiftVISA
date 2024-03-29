<img src="https://github.com/SwiftVISA/CoreSwiftVISA/blob/master/SwiftVISA%20Logo.png" width="512" height="512">

# NISwiftVISA

NISwiftVISA allows for communicating over the VISA protocol for USB instruments. NISwiftVISA uses the NI-VISA C backend and requires that the use have [NI-VISA 20.0](https://www.ni.com/en-us/support/downloads/drivers/download.ni-visa.html#351229) or later installed. 

## Requirements

- Swift 5.3+
- macOS 11.0+ (Big Sur)
- 64-bit Intel processor (Apple Silicon not supported)
- [NI-VISA 20.0+](https://www.ni.com/en-us/support/downloads/drivers/download.ni-visa.html#351229)
- [NISwiftVISAService 0.1.0+](https://github.com/SwiftVISA/NISwiftVISAService)

## Installation

Before using, make sure to install [NI-VISA](https://www.ni.com/en-us/support/downloads/drivers/download.ni-visa.html#351229) and [NISwiftVISAService](https://github.com/SwiftVISA/NISwiftVISAService). You may need to restart your computer in this process.

Installation can be done through the [Swift Package Manager](https://swift.org/package-manager/). To use SwiftVISASwift in your project, include the following dependency in your `Package.swift` file.
```swift
dependencies: [
    .package(url: "https://github.com/SwiftVISA/NISwiftVISA.git", .upToNextMinor(from: "0.1.0"))
]
```

NISwiftVISA automatically exports [CoreSwiftVISA](https://github.com/SwiftVISA/CoreSwiftVISA), so `import NISwiftVISA` is sufficient for importing CoreSwiftVISA.

## Usage

To create a connection to an instrument, pass the VISA reesource name to `InstrumentManager.shared.niInstrument(withIdentifier:)`;
```swift
do {
  // Pass the IPv4 or IPv6 address of the instrument to "address" and the insturment's port to "port".
  let instrument = try InstrumentManager.shared.niInstrument(withIdentifier: "USB0::0x2A8D::0x1602::MY59001317::INSTR")
} catch {
  // Could not connect to insturment
}
```

To write to the instrument, call `write(_:)` on the instrument:
```swift
do {
  // Pass the command as a string.
  try instrument.write("OUTPUT ON")
} catch {
  // Could not write to insturment
}
```

To read from the instrument, call `read()` on the instrument:
```swift
do {
  try instrument.write("VOLTAGE?")
  let voltage = try instrument.read() // read() will return a String
} catch {
  // Could not read from (or write to) insturment
}
```

To query the instrument, call `query(_:)` on the instrument. Query will first write the message provided to the instrument, then read from the instrument and return the given string. To decode the message from the instrument into another type, call `query(_:as:)`:
```swift
do {
  let voltage = try instrument.query("VOLTAGE?" as: Double.self) // query(_:as:) will return a Double because Double.self was passed to "as".
} catch {
  // Could not query or decode from insturment
}
```

## Customization

NISwiftVISA supports a great deal of customization for communicating to/from instruments. To customize how NISwiftVISA sends messages, call `write(_:appending:encoding:)`. Pass the termination character/string to "appending", and pass the string encoding you would like to use to "encoding". Both of these parameters have defualt values, so you may ommit parameters that you don't need to customize. By default, the terminating character is "/n" and the encoding is UTF8:
```swift
do {
  let voltage = try instrument.write("OUTPUT OFF", appending: "\0", encoding: .ascii)
} catch {
  // Could not write to insturment
}
```

To customize how NISwiftVISA reads messages, call `read(until:strippingTerminator:encoding:chunkSize:)`. Pass a custom termination character/string to `until`. Pass `false` to `strippingTerminator` if you would like NISwiftVISA to keep the terminator on the end of the sting (by default this is removed). Pass the string encoding you would like to use to `encoding`. `chunkSize` can be set to limit the number of bytes that is requested from the instrument at a time; for long messages, NISwiftVISA breaks up the reading into multiple smaller reads. These three parameters all have default values, so you may ommit parameters that you don't need to customize. By default, the terminating character/string is "\n" and is stripped, the encoding is UTF8, and the chunk size is 1024 bytes:
```swift
do {
  try instrument.write("VOLTAGE?")
  let voltage = try instrument.read(until: "\0", strippingTerminator: false, encoding: .ascii, chunkSize: 256)
} catch {
  // Could not read from (or write to) instrument
 }
 ```
 
 To customize the defaults used for an instrument, you can set the properties on the `attributes` property of the insturment. The following values can be customized: `chunkSize`, `encoding`, `operationDelay`, `readTerminator`, and `writeTerminator`. These attributes correspond to the additional arguments above for `read()` and `write(_:)`. The attribute `operationDelay` is used to customize how much time the computer shoud wait between calls to `read()` and `write(_:)`. Some instruments will stop working correctly if messages are sent too quickly so a a small amount of time is waited before sending each message. By deault, this value is 1 ms. Each instrument can have its own custom attributes. Setting the attributes on one instrument will not change the attributes of other insturments:
```swift
// Sets the attributes to SwiftVISASwift's default values
instrument.chunkSize = 1024 // Set the default chunk size for reading long messages
insturment.encoding = .utf8 // Set the encoding to use for reading and writing messages
insturment.operationDelay = 1e-3 // Set the number of seconds to wait before sending each message
instrument.readTerminator = "\n" // Set the character/string that indicates an end of a message from the insturment
instrument.writeTermiantor = "\n" // Set the character/string that indicates an end of the message to the insturment
```

To customize how NISwiftVISA decodes types, you can create your own custom decoders. To create a custom decoder, create a struct that conforms to the `MessageDecoder` protocol. You will need to declare the type you wish to decode to as `DeccodingType`, and you will need to implement `decode(_:)`:
```swift
// The following decoder returns an Int rounded to the nearest interger:
struct RoundingDecoder: MessageDecoder {
  typealias DecodingType = Int
  
  // Define an Error enum if you would like to throw custom errors
  enum Error: Swift.Error {
    case notANumber
     case magnitudeTooLarge
  }
  
  func decode(_ message: String) throws -> DecodingType {
    guard let number = Double(message) else {
      // If the message can't be converted into a Double, then it's not a number
      throw Error.notANumber
    }
    guard !number.isNaN else {
      // If the number is NAN, then it's not a number
      throw Error.notANumber
    }
    
    let rounded = round(number)
    
    guard let integer = Int(exactly: rounded) else {
      // If the number can't be expressed exaclty as an integer after rounding, it's magnitude is too large
      throw Error.magnitudeTooLarge
    }

    return integer
  }
}
```

Included with NISwiftVISA (actually in CoreSwiftVISA) are four default decoders: `DefaultStringDecoder`, `DefaultIntDecoder`, `DefaultDoubleDecoder`, and `DefaultBoolDecoder`. When decoding when calling query, if no decoder is passed in, one of the decoders aboved will be automatically used (depending on which type is used). To change which decoder will be used automatically, you can set the `customDecode` property to be a custom decoding function on `DefaultStringDecoder`, `DefaultIntDecoder`, `DefaultDoubleDecoder`, or `DefaultBoolDecoder`:
```swift
// Set default decoder
DefaultIntDecoder.customDecode = RoundingDecoder().decode(_:)
do {
  let voltage = instrument.query("VOLTAGE?", as: Int.self)
  // Can also use a custom decoder without changing the default decoder
  let sameVoltage = instrument.query("VOLTAGE?", as: Int.self, using RoundingDecoder())
} catch {
  // Could not query or decode
}
```

## Contributions and Comments
This project is a slow-moving "labor-of-love" for our group and intended additional features are worked on sporadically based upon need, time, and our ability to deal with Apple's poor documentation.  Currently, the bulk of our efforts are put into SwiftVISASwift (https://github.com/SwiftVISA/SwiftVISASwift).  We would love help and please e-mail me (or to reply to the relevant issue or open a new one).

When contributing to this repository, please first discuss the change you wish to make via issue, email, or any other method with the owner of this repository before making a change.

### All Code Changes Happen Through Pull Requests

1. Fork the repo and create your branch from `master`.
2. Make sure the syle of your code is consistent with that of the current one (indentation, etc.).
3. If you've changed any relevant functionalities, update the documentation.
4. Ensure the application is working correctly.
5. Issue that pull request.

### Code of Conduct

Use common sense (source: https://github.com/gasparl/possa/blob/master/CONTRIBUTING.md)

Examples:

* Be respectful of differing viewpoints and experiences
* Gracefully accept constructive criticism
* Focus on what is best for the community
* Have empathy towards other community members

Examples of unacceptable behavior by participants include:

* Trolling, insulting/derogatory comments, and personal or political attacks
* Public or private harassment
* Publishing others' private information without explicit permission
* Other conduct which could reasonably be considered inappropriate in a
  professional setting
  
 
### Reporting Issues or Problems
* Please submit an Issue if you have any problems with any SwiftVISA frameworks/packages
* Please submit an Issue if you need any help installing or working with any of the SwiftVISA Frameworks/Packages
