import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as error_code;
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_ios/local_auth_ios.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  LocalAuthentication? auth;
  bool isDeviceSupport = false;
  List<BiometricType>? availableBiometrics;

  @override
  void initState() {
    auth = LocalAuthentication();
    deviceCapability();
    _getAvailableBiometrics();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fingerprint Auth'),
      ),
      body: const Center(child: Text('Home Page')),
    );
  }

  void deviceCapability() async {
    final bool isCapable = await auth!.canCheckBiometrics;
    isDeviceSupport = isCapable || await auth!.isDeviceSupported();
  }

  Future<void> _getAvailableBiometrics() async {
    try{
      availableBiometrics = await auth!.getAvailableBiometrics();
      print("Biometric: $availableBiometrics");

      if(availableBiometrics!.contains(BiometricType.strong) || availableBiometrics!.contains(BiometricType.fingerprint)){
        final bool didAuthenticate = await auth!.authenticate(
          localizedReason: 'Unlock your screen with PIN, pattern, password, face, or fingerprint',
          options: const AuthenticationOptions(biometricOnly: true, stickyAuth: true),
          authMessages: <AuthMessages>[
            const AndroidAuthMessages(
              signInTitle: 'Unlock Ideal Group',
              cancelButton: 'No thanks'
            ),
            const IOSAuthMessages(
              cancelButton: 'No thanks',
            ),
          ]);
        if(!didAuthenticate){
          exit(0);
        }
      }else if(availableBiometrics!.contains(BiometricType.weak) || availableBiometrics!.contains(BiometricType.face)){
        final bool didAuthenticate = await auth!.authenticate(
          localizedReason: 'Unlock your screen with PIN, pattern, password, face, or fingerprint',
          options: const AuthenticationOptions(stickyAuth: true),
          authMessages: <AuthMessages>[
            const AndroidAuthMessages(
              signInTitle: 'Unlock Ideal Group',
              cancelButton: 'No thanks',
            ),
            const IOSAuthMessages(
              cancelButton: 'No thanks',
            ),
          ]);
        if(!didAuthenticate){
          exit(0);
        }
      }
    } on PlatformException catch (e) {
      if(e.code == error_code.passcodeNotSet){
        exit(0);
      }
      print("Error: $e");
    }
  }

}
