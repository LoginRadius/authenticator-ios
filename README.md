# LoginRadius Authenticator for iOS (Open Source Version)

This project is an open source repository of the LoginRadiusAuthenticator iOS app on
the [App Store](https://apps.apple.com/us/app/loginradius-authenticator/id1546040932). 

> LoginRadiusAuthenticator can be used to setup MFA for accounts and then generate OTP code to be used while authentication in those systems just like Google Authenticator app.
>
> 2-Step Verification provides stronger security for your Account by
> requiring a second step of verification when you sign in. In addition to your
> password, you’ll also need a code generated by the LoginRadiusAuthenticator app on
> your phone.
>
> Learn more about 2-Step Verification [here](https://g.co/2step)
>
> Features:
> * Generate verification codes without a data connection
> * Generate Time-Based and Counter-Based codes
> * LoginRadiusAuthenticator works with many providers & accounts
> * Password protected
> * Automatic setup via QR code

## Description

The LoginRadiusAuthenticator project includes implementations of one-time passcode
generators for iOS demonstrating in LoginRadiusAuthenticatorDemo, as well as a LoginRadiusAuthenticator folder as Library claases in it. One-time passcodes are generated using open standards
developed by the [Initiative for Open Authentication (OATH)](https://openauthentication.org/) (which is
unrelated to [OAuth](https://oauth.net/)).

* The iOS implementation supports the HMAC-Based One-time Password (HOTP)
  algorithm specified in [RFC 4226](https://tools.ietf.org/html/rfc4226) and the Time-based One-time Password
  (TOTP) algorithm specified in [RFC 6238](https://tools.ietf.org/html/rfc6238).

## Installation

Installing the app should be as simple as downloading the
app from App store.


### Open Source Version

The easiest way to install the open source flavour of Authenticator is to
download the GitHub repository. To build the demo project from the source code, see the section about
[building from source](#building-from-source).

## Developer Guide

You can also leverage LoginRadiusAuthenticator library classes in your own project and faciliate users with generating 2 factor codes.

Just download the repository from here. And integrate by dragging and dropping LoginRadiusAuthenticator library folder in your own project. Then in any required class, import and use classes as shown in the demo.

The library classes are written in Objective-C which can be directly integrated in an Objective-C project. For integrating in Swift project, create a BridgingHeader file and import library classes there.
For more detail [please refer](https://developer.apple.com/documentation/swift/imported_c_and_objective-c_apis/importing_objective-c_into_swift).

### Building from Source

1. Clone the repository.

```
   git clone https://github.com/LoginRadius/authenticator-ios.git
   cd authenticator-ios
   ```

2. Run the pod command.

  ```
  pod install
  ```

3. Open the created .xcworkspace file in Xcode. Build the demo on simulator or connected device.

## Contributing

```
We'd love to collaborate on this. See CONTRIBUTING.md for details.

```

## Copyright

```
Copyright (c) 2021 LoginRadius
```
## License

```
Released under the MIT license.
```
