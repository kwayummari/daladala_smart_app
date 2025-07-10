import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
// import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../providers/qr_provider.dart';

class QRScannerPage extends StatefulWidget {
  final String scanType; // 'ticket' or 'receipt'

  const QRScannerPage({Key? key, required this.scanType}) : super(key: key);

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  // QRViewController? controller;
  bool isScanning = true;

  // @override
  // void reassemble() {
  //   super.reassemble();
  //   if (controller != null) {
  //     controller!.pauseCamera();
  //     controller!.resumeCamera();
  //   }
  // }

  Widget QRView({
    required Function(BarcodeCapture) onDetect,
    required MobileScannerController controller,
  }) {
    return MobileScanner(controller: controller, onDetect: onDetect);
  }

  Widget QrScannerOverlayShape() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget ScanResultDialog(String result) {
    return AlertDialog(
      title: const Text('QR Code Scanned'),
      content: Text(result),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    );
  }

  // For _ShowQRPageState, add:
  Widget QrImageView({required String data, required double size}) {
    return QrImageView(data: data, 
    // version: QrVersions.auto, 
    size: size);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Scan ${widget.scanType == 'ticket' ? 'Ticket' : 'Receipt'}',
        ),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(isScanning ? Icons.flash_on : Icons.flash_off),
            onPressed: () async {
              // await controller?.toggleFlash();
              setState(() {
                isScanning = !isScanning;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Expanded(
          //   flex: 4,
          //   child: QRView(onDetect: (BarcodeCapture ) {  }, controller: QrcodeController
          //     // key: qrKey,
          //     // onQRViewCreated: _onQRViewCreated,
          //     // overlay: QrScannerOverlayShape(
          //     //   borderColor: Colors.blue,
          //     //   borderRadius: 10,
          //     //   borderLength: 30,
          //     //   borderWidth: 10,
          //     //   cutOutSize: 300,
          //     ),
          //   ),
          // ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    widget.scanType == 'ticket'
                        ? 'Point camera at passenger ticket QR code'
                        : 'Point camera at receipt QR code',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // void _onQRViewCreated(QRViewController controller) {
  //   this.controller = controller;
  //   controller.scannedDataStream.listen((scanData) {
  //     if (scanData.code != null && isScanning) {
  //       setState(() {
  //         isScanning = false;
  //       });
  //       controller.pauseCamera();
  //       _handleScanResult(scanData.code!);
  //     }
  //   });
  // }

  void _handleScanResult(String qrData) async {
    final qrProvider = context.read<QRProvider>();

    if (widget.scanType == 'ticket') {
      await qrProvider.validateTicket(qrData);
    } else {
      await qrProvider.verifyReceipt(qrData);
    }

    if (mounted) {
      // showDialog(
      //   context: context,
      //   barrierDismissible: false,
      //   builder:
      //       (context) => ScanResultDialog(
      //         scanType: widget.scanType,
              // result: qrProvider.lastScanResult,
              // isLoading: qrProvider.isLoading,
              // error: qrProvider.error,
              // onClose: () {
              //   Navigator.pop(context); // Close dialog
              //   Navigator.pop(context); // Close scanner
              // },
              // onScanAgain: () {
              //   Navigator.pop(context); // Close dialog
              //   setState(() {
              //     isScanning = true;
              //   });
              //   controller?.resumeCamera();
              // },
      //       ),
      // );
    }
  }

  // @override
  // void dispose() {
  //   controller?.dispose();
  //   super.dispose();
  // }
}
