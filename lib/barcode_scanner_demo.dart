import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BarcodeScannerDemo extends StatefulWidget {
  const BarcodeScannerDemo({Key? key}) : super(key: key);

  @override
  _BarcodeScannerDemoState createState() => _BarcodeScannerDemoState();
}

class _BarcodeScannerDemoState extends State<BarcodeScannerDemo> {
  late final WebViewController _controller;
  String _scanBarcode = 'Unknown';

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..addJavaScriptChannel('JedApp',
          onMessageReceived: (JavaScriptMessage javaScriptMessage) {
        print('hello 2');
        barcodeScan();
      })
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading bar.
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) async {
            await _controller.runJavaScriptReturningResult(
                'window.addEventListener("message", (event) => {JedApp.postMessage(\'...\');}, false);');
            print('hello 1');
          },
          onWebResourceError: (WebResourceError error) {},
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(
          Uri.parse('http://www.arcossalazar.net/barcode/barcode.php'));
  }

  /// For Continuous scan
  Future<void> startBarcodeScanStream() async {
    FlutterBarcodeScanner.getBarcodeStreamReceiver(
            '#ff6666', 'Cancel', true, ScanMode.BARCODE)!
        .listen((barcode) => print(barcode));
  }

  Future<void> barcodeScan() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.QR);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }
    if (!mounted) return;
    setState(() {
      _scanBarcode = barcodeScanRes;
      _controller.runJavaScript("onBarcodeScanned('$barcodeScanRes')");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SafeArea(
      child: WebViewWidget(controller: _controller),
    ));
  }
}
