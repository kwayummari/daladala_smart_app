import 'package:flutter/material.dart';
import 'package:daladala_smart_app/config/app_config.dart';
import 'package:daladala_smart_app/services/storage_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final StorageService _storageService = StorageService();
  
  String _selectedTheme = 'system';
  String _selectedLanguage = 'en';
  bool _notificationsEnabled = true;
  bool _locationEnabled = true;
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    final theme = await _storageService.getTheme();
    final language = await _storageService.getLanguage();
    
    // TODO: Load notification and location settings from preferences
    
    setState(() {
      _selectedTheme = theme;
      _selectedLanguage = language;
    });
  }
  
  Future<void> _saveTheme(String theme) async {
    await _storageService.saveTheme(theme);
    setState(() {
      _selectedTheme = theme;
    });
    
    // TODO: Apply theme change to app
  }
  
  Future<void> _saveLanguage(String language) async {
    await _storageService.saveLanguage(language);
    setState(() {
      _selectedLanguage = language;
    });
    
    // TODO: Apply language change to app
  }
  
  Future<void> _toggleNotifications(bool value) async {
    // TODO: Save notification setting to preferences
    setState(() {
      _notificationsEnabled = value;
    });
  }
  
  Future<void> _toggleLocation(bool value) async {
    // TODO: Save location setting to preferences
    setState(() {
      _locationEnabled = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        children: [
          // Appearance Section
          const Text(
            'Appearance',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSizes.marginSmall),
          
          // Theme Settings
          Card(
            margin: const EdgeInsets.only(bottom: AppSizes.marginMedium),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Theme',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: AppSizes.marginSmall),
                  
                  // System Theme
                  RadioListTile<String>(
                    title: const Text('System default'),
                    value: 'system',
                    groupValue: _selectedTheme,
                    onChanged: (value) => _saveTheme(value!),
                  ),
                  
                  // Light Theme
                  RadioListTile<String>(
                    title: const Text('Light'),
                    value: 'light',
                    groupValue: _selectedTheme,
                    onChanged: (value) => _saveTheme(value!),
                  ),
                  
                  // Dark Theme
                  RadioListTile<String>(
                    title: const Text('Dark'),
                    value: 'dark',
                    groupValue: _selectedTheme,
                    onChanged: (value) => _saveTheme(value!),
                  ),
                ],
              ),
            ),
          ),
          
          // Language Section
          const Text(
            'Language',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSizes.marginSmall),
          
          // Language Settings
          Card(
            margin: const EdgeInsets.only(bottom: AppSizes.marginMedium),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'App Language',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: AppSizes.marginSmall),
                  
                  // English
                  RadioListTile<String>(
                    title: const Text('English'),
                    value: 'en',
                    groupValue: _selectedLanguage,
                    onChanged: (value) => _saveLanguage(value!),
                  ),
                  
                  // Swahili
                  RadioListTile<String>(
                    title: const Text('Swahili'),
                    value: 'sw',
                    groupValue: _selectedLanguage,
                    onChanged: (value) => _saveLanguage(value!),
                  ),
                ],
              ),
            ),
          ),
          
          // Notifications Section
          const Text(
            'Notifications',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSizes.marginSmall),
          
          // Notification Settings
          Card(
            margin: const EdgeInsets.only(bottom: AppSizes.marginMedium),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Push Notifications',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: AppSizes.marginSmall),
                  
                  // Enable/Disable Notifications
                  SwitchListTile(
                    title: const Text('Enable push notifications'),
                    subtitle: const Text('Receive alerts for bookings, trips and promotions'),
                    value: _notificationsEnabled,
                    onChanged: _toggleNotifications,
                  ),
                  
                  // Divider
                  const Divider(),
                  
                  // Notification Types (enabled only if notifications are on)
                  CheckboxListTile(
                    title: const Text('Booking updates'),
                    value: _notificationsEnabled,
                    enabled: _notificationsEnabled,
                    onChanged: (value) {
                      // TODO: Implement specific notification type toggle
                    },
                  ),
                  
                  CheckboxListTile(
                    title: const Text('Trip reminders'),
                    value: _notificationsEnabled,
                    enabled: _notificationsEnabled,
                    onChanged: (value) {
                      // TODO: Implement specific notification type toggle
                    },
                  ),
                  
                  CheckboxListTile(
                    title: const Text('Payment notifications'),
                    value: _notificationsEnabled,
                    enabled: _notificationsEnabled,
                    onChanged: (value) {
                      // TODO: Implement specific notification type toggle
                    },
                  ),
                  
                  CheckboxListTile(
                    title: const Text('Promotions and offers'),
                    value: _notificationsEnabled,
                    enabled: _notificationsEnabled,
                    onChanged: (value) {
                      // TODO: Implement specific notification type toggle
                    },
                  ),
                ],
              ),
            ),
          ),
          
          // Privacy Section
          const Text(
            'Privacy',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSizes.marginSmall),
          
          // Privacy Settings
          Card(
            margin: const EdgeInsets.only(bottom: AppSizes.marginMedium),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Location Services',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: AppSizes.marginSmall),
                  
                  // Enable/Disable Location
                  SwitchListTile(
                    title: const Text('Enable location services'),
                    subtitle: const Text('Allow the app to access your location for better trip planning'),
                    value: _locationEnabled,
                    onChanged: _toggleLocation,
                  ),
                  
                  // Divider
                  const Divider(),
                  
                  // Data Collection Consent
                  const ListTile(
                    title: Text('Data Collection'),
                    subtitle: Text('Manage how your data is collected and used'),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: null, // TODO: Implement data collection settings
                  ),
                  
                  const ListTile(
                    title: Text('Clear Search History'),
                    subtitle: Text('Remove all your search history'),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: null, // TODO: Implement clear search history
                  ),
                ],
              ),
            ),
          ),
          
          // App Info
          const Text(
            'App Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSizes.marginSmall),
          
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.cardRadius),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: const Text('App Version'),
                    subtitle: Text(AppConfig.appVersion),
                    leading: const Icon(Icons.info_outline),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}