import 'package:daladala_smart_app/features/profile/presentation/pages/payment_history_page.dart';
import 'package:daladala_smart_app/features/splash/presentation/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/widgets/custom_button.dart';
import '../../../../core/ui/widgets/loading_indicator.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/profile_menu_item.dart';
import 'edit_profile_page.dart';
import '../../../wallet/presentation/pages/wallet_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with AutomaticKeepAliveClientMixin {
  bool _isLoading = false;
  
  @override
  bool get wantKeepAlive => true;
  
  Future<void> _logout() async {
    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Logout',
              style: TextStyle(color: AppTheme.primaryColor),
            ),
          ),
        ],
      ),
    );
    
    if (confirm != true) {
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final result = await authProvider.logout();
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      
      result.fold(
        (failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(failure.message),
              backgroundColor: Colors.red,
            ),
          );
        },
        (_) {
          // Navigate to login screen
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false,
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please log in to view your profile'),
        ),
      );
    }
    
    return Scaffold(
      body: _isLoading
          ? const Center(child: LoadingIndicator())
          : CustomScrollView(
              slivers: [
                // App bar with profile header
                SliverAppBar(
                  expandedHeight: 200,
                  pinned: true,
                  backgroundColor: AppTheme.primaryColor,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      color: AppTheme.primaryColor,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          // Profile image
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.white,
                            backgroundImage: user.profilePicture != null
                                ? NetworkImage(user.profilePicture!)
                                : null,
                            child: user.profilePicture == null
                                ? Text(
                                    '${user.firstName[0]}${user.lastName[0]}',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryColor,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(height: 16),
                          // User name
                          Text(
                            '${user.firstName} ${user.lastName}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // User email/phone
                          Text(
                            user.phone,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                
                // Profile menu
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Account section
                      const Text(
                        'Account',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ProfileMenuItem(
                        icon: Icons.person_outline,
                        title: 'Edit Profile',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const EditProfilePage(),
                            ),
                          );
                        },
                      ),
                      ProfileMenuItem(
                        icon: Icons.account_balance_wallet_outlined,
                        title: 'My Wallet',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const WalletPage(),
                            ),
                          );
                        },
                      ),
                      ProfileMenuItem(
                        icon: Icons.receipt_long_outlined,
                        title: 'Payment History',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PaymentHistoryPage(),
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Settings section
                      const Text(
                        'Settings',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ProfileMenuItem(
                        icon: Icons.language,
                        title: 'Language',
                        subtitle: 'English',
                        onTap: () {
                          // Language settings
                        },
                      ),
                      ProfileMenuItem(
                        icon: Icons.notifications_outlined,
                        title: 'Notifications',
                        onTap: () {
                          // Notification settings
                        },
                      ),
                      ProfileMenuItem(
                        icon: Icons.security,
                        title: 'Security',
                        onTap: () {
                          // Security settings
                        },
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Support section
                      const Text(
                        'Support',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ProfileMenuItem(
                        icon: Icons.help_outline,
                        title: 'Help Center',
                        onTap: () {
                          // Help center
                        },
                      ),
                      ProfileMenuItem(
                        icon: Icons.info_outline,
                        title: 'About Daladala Smart',
                        onTap: () {
                          // About page
                        },
                      ),
                      ProfileMenuItem(
                        icon: Icons.privacy_tip_outlined,
                        title: 'Privacy Policy',
                        onTap: () {
                          // Privacy policy
                        },
                      ),
                      ProfileMenuItem(
                        icon: Icons.description_outlined,
                        title: 'Terms of Service',
                        onTap: () {
                          // Terms of service
                        },
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Logout button
                      CustomButton(
                        text: 'Logout',
                        type: ButtonType.secondary,
                        onPressed: _logout,
                        icon: Icons.logout,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // App version
                      Center(
                        child: Text(
                          'Version 1.0.0',
                          style: TextStyle(
                            color: AppTheme.textTertiaryColor,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                    ]),
                  ),
                ),
              ],
            ),
    );
  }
}