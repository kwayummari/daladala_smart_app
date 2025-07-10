import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class PermissionHandler {
  
  // Request location permission with explanation
  static Future<bool> requestLocationPermission(BuildContext context) async {
    final status = await Permission.location.status;
    
    if (status.isGranted) {
      return true;
    }
    
    if (status.isDenied) {
      // Show explanation dialog
      final shouldRequest = await _showPermissionDialog(
        context,
        'Location Permission Required',
        'This app needs location access to provide real-time tracking and find nearby trips. '
        'Your location will only be used for transportation services.',
        'Grant Permission',
      );
      
      if (!shouldRequest) return false;
      
      final result = await Permission.location.request();
      return result.isGranted;
    }
    
    if (status.isPermanentlyDenied) {
      // Show dialog to open settings
      final shouldOpenSettings = await _showPermissionDialog(
        context,
        'Location Permission Denied',
        'Location permission has been permanently denied. '
        'Please enable it in app settings to use location-based features.',
        'Open Settings',
      );
      
      if (shouldOpenSettings) {
        await openAppSettings();
      }
      return false;
    }
    
    return false;
  }
  
  // Request camera permission for QR scanning
  static Future<bool> requestCameraPermission(BuildContext context) async {
    final status = await Permission.camera.status;
    
    if (status.isGranted) {
      return true;
    }
    
    if (status.isDenied) {
      final shouldRequest = await _showPermissionDialog(
        context,
        'Camera Permission Required',
        'This app needs camera access to scan QR codes for tickets and receipts. '
        'The camera will only be used for scanning purposes.',
        'Grant Permission',
      );
      
      if (!shouldRequest) return false;
      
      final result = await Permission.camera.request();
      return result.isGranted;
    }
    
    if (status.isPermanentlyDenied) {
      final shouldOpenSettings = await _showPermissionDialog(
        context,
        'Camera Permission Denied',
        'Camera permission has been permanently denied. '
        'Please enable it in app settings to scan QR codes.',
        'Open Settings',
      );
      
      if (shouldOpenSettings) {
        await openAppSettings();
      }
      return false;
    }
    
    return false;
  }
  
  // Request storage permission for saving QR codes
  static Future<bool> requestStoragePermission(BuildContext context) async {
    final status = await Permission.storage.status;
    
    if (status.isGranted) {
      return true;
    }
    
    if (status.isDenied) {
      final shouldRequest = await _showPermissionDialog(
        context,
        'Storage Permission Required',
        'This app needs storage access to save QR codes and receipts to your device. '
        'This will help you access your tickets offline.',
        'Grant Permission',
      );
      
      if (!shouldRequest) return false;
      
      final result = await Permission.storage.request();
      return result.isGranted;
    }
    
    if (status.isPermanentlyDenied) {
      final shouldOpenSettings = await _showPermissionDialog(
        context,
        'Storage Permission Denied',
        'Storage permission has been permanently denied. '
        'Please enable it in app settings to save QR codes.',
        'Open Settings',
      );
      
      if (shouldOpenSettings) {
        await openAppSettings();
      }
      return false;
    }
    
    return false;
  }
  
  // Show permission explanation dialog
  static Future<bool> _showPermissionDialog(
    BuildContext context,
    String title,
    String message,
    String actionText,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(actionText),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }
  
  // Check all required permissions
  static Future<Map<String, bool>> checkAllPermissions() async {
    return {
      'location': await Permission.location.isGranted,
      'camera': await Permission.camera.isGranted,
      'storage': await Permission.storage.isGranted,
    };
  }
}