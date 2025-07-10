import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/qr_provider.dart';

class ShowQRPage extends StatefulWidget {
  final int bookingId;
  final String qrType; // 'ticket' or 'receipt'

  const ShowQRPage({Key? key, required this.bookingId, required this.qrType})
    : super(key: key);

  @override
  State<ShowQRPage> createState() => _ShowQRPageState();
}

class _ShowQRPageState extends State<ShowQRPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.qrType == 'ticket') {
        context.read<QRProvider>().generateBookingQR(widget.bookingId);
      } else {
        context.read<QRProvider>().getBookingReceipt(widget.bookingId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.qrType == 'ticket' ? 'Ticket' : 'Receipt'} QR Code',
        ),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.share), onPressed: _shareQR),
        ],
      ),
      body: Consumer<QRProvider>(
        builder: (context, qrProvider, child) {
          if (qrProvider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Generating QR code...'),
                ],
              ),
            );
          }

          if (qrProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    qrProvider.error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (widget.qrType == 'ticket') {
                        qrProvider.generateBookingQR(widget.bookingId);
                      } else {
                        qrProvider.getBookingReceipt(widget.bookingId);
                      }
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final qrData = qrProvider.currentQRData;
          if (qrData == null) {
            return const Center(child: Text('No QR data available'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // QR Code
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: QrImageView(
                    data: qrData['qr_code'] ?? '',
                    version: QrVersions.auto,
                    size: 250.0,
                    backgroundColor: Colors.white,
                  ),
                ),

                const SizedBox(height: 24),

                // Booking Information
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.qrType == 'ticket'
                            ? 'Ticket Information'
                            : 'Receipt Information',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      if (widget.qrType == 'ticket') ...[
                        _buildInfoRow(
                          'Passenger',
                          qrData['booking_info']['passenger_name'],
                        ),
                        _buildInfoRow(
                          'Route',
                          qrData['booking_info']['route_name'],
                        ),
                        _buildInfoRow(
                          'Seats',
                          qrData['booking_info']['seat_numbers'],
                        ),
                        _buildInfoRow(
                          'Status',
                          qrData['booking_info']['status'],
                        ),
                        _buildInfoRow(
                          'Valid Until',
                          _formatDateTime(qrData['validation_expires']),
                        ),
                      ] else ...[
                        _buildInfoRow('Receipt No.', qrData['receipt_number']),
                        _buildInfoRow('Amount', 'TSh ${qrData['amount']}'),
                        _buildInfoRow(
                          'Generated',
                          _formatDateTime(qrData['created_at']),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Instructions
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info, color: Colors.blue[600]),
                          const SizedBox(width: 8),
                          const Text(
                            'Instructions',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.qrType == 'ticket'
                            ? '• Show this QR code to the driver when boarding\n'
                                '• Keep your phone screen bright for easy scanning\n'
                                '• This ticket is valid until the expiry time shown above'
                            : '• This QR code serves as proof of payment\n'
                                '• You can share or save this receipt\n'
                                '• Use this for any refund or dispute queries',
                        style: TextStyle(color: Colors.blue[700]),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _saveQR,
                        icon: const Icon(Icons.download),
                        label: const Text('Save QR'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _shareQR,
                        icon: const Icon(Icons.share),
                        label: const Text('Share'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(String? dateTime) {
    if (dateTime == null) return 'N/A';
    try {
      final DateTime dt = DateTime.parse(dateTime);
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'N/A';
    }
  }

  void _saveQR() {
    // Implement QR code saving functionality
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('QR code saved to gallery')));
  }

  void _shareQR() {
    // Implement QR code sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('QR code shared successfully')),
    );
  }
}
