import 'package:biometric_signature/biometric_signature.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyHomeNewPage extends StatefulWidget {
  const MyHomeNewPage({super.key, required this.title});

  final String title;

  @override
  State<MyHomeNewPage> createState() => _MyHomeNewPageState();
}

class _MyHomeNewPageState extends State<MyHomeNewPage> {
  String message = "";
  final _biometricSignaturePlugin = BiometricSignature();

  Future<void> asyncInit() async {
    try {
      final String? biometricsType =
          await _biometricSignaturePlugin.biometricAuthAvailable();
      debugPrint("biometricsType : $biometricsType");
      final bool doExist =
          await _biometricSignaturePlugin.biometricKeyExists() ?? false;
      debugPrint("doExist : $doExist");
      if (!doExist) {
        final String? publicKey = await _biometricSignaturePlugin.createKeys();
        debugPrint("publicKey : $publicKey");
      }
      final String? signature = await _biometricSignaturePlugin
          .createSignature(options: {"promptMessage": "You are Welcome!"});
      message = "signature : $signature";
    } on PlatformException catch (e) {
      debugPrint(e.message);
      debugPrint(e.code);
      message = e.message.toString();
    } on Exception catch (exp) {
      message = exp.toString();
    }
    setState(() {});
  }

  @override
  void initState() {
    asyncInit();
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
        child: Text(message),
      ),
    );
  }
}
