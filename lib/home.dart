import 'dart:developer';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String errorMessage = "";
  bool canUseBiometrics = false;
  final LocalAuthentication auth = LocalAuthentication();

  _checkIsSupported() async {
    final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
    if (!canAuthenticateWithBiometrics) {
      errorMessage = "Cannot authenticate with Biometrics";
    }
    final bool isDeviceSupported = await auth.isDeviceSupported();
    if (!isDeviceSupported) {
      errorMessage = "This device is supported for biometrics";
    }
    canUseBiometrics = canAuthenticateWithBiometrics || isDeviceSupported;
    setState(() {});
  }

  @override
  void initState() {
    _checkIsSupported();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: canUseBiometrics
            ? ElevatedButton(
                onPressed: () {
                  _authenticate();
                },
                child: const Text("Authenticate with biometrics"),
              )
            : Text(errorMessage),
      ),
    );
  }

  _authenticate() async {
    try {
      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Please authenticate to continue',
        options: const AuthenticationOptions(
          biometricOnly: true,
        ),
      );
      if (didAuthenticate) {
        log("Success");
      }
    } on PlatformException catch (e) {
      if (e.code == auth_error.notAvailable) {
        log("Not available");
      } else if (e.code == auth_error.notEnrolled) {
        log("Not enrolled");
      } else {
        log(e.message.toString());
      }
    }
  }
}
