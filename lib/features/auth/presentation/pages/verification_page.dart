// lib/features/auth/presentation/pages/verification_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sms_autofill/sms_autofill.dart';
import '../../../../core/ui/widgets/custom_button.dart';
import '../../../../core/utils/extensions.dart';
import '../providers/auth_provider.dart';
import '../../../home/presentation/pages/home_page.dart';

class VerificationPage extends StatefulWidget {
  final String phone;
  final String email;

  const VerificationPage({super.key, required this.phone, required this.email});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> with CodeAutoFill {
  String _verificationCode = '';
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    _initializeAutoOTP();
  }

  @override
  void dispose() {
    cancel(); // Cancel SMS listening
    super.dispose();
  }

  // Initialize auto-OTP detection
  Future<void> _initializeAutoOTP() async {
    try {
      await SmsAutoFill().listenForCode;
      print('📱 SMS Auto-fill initialized');
    } catch (e) {
      print('❌ SMS Auto-fill initialization failed: $e');
    }
  }

  // Auto-fill callback for SMS OTP
  @override
  void codeUpdated() {
    if (code != null && code!.length == 6) {
      setState(() {
        _verificationCode = code!;
      });

      // Auto-verify when SMS is detected
      _verifyAccount();

      print('📱 Auto-detected SMS code: $code');
    }
  }

  Future<void> _verifyAccount() async {
    if (_verificationCode.length != 6) {
      context.showSnackBar(
        'Please enter the 6-digit verification code',
        isError: true,
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Use phone as identifier (you can also use email)
    final result = await authProvider.verifyAccount(
      identifier: widget.phone,
      code: _verificationCode,
    );

    if (mounted) {
      result.fold(
        (failure) {
          context.showSnackBar(failure.message, isError: true);
          setState(() {
            _verificationCode = '';
          });
        },
        (user) {
          // Success - user is verified and logged in
          context.showSnackBar('Account verified successfully! Welcome! 🎉');

          // Navigate to home
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => HomePage()),
            (route) => false,
          );
        },
      );
    }
  }

  Future<void> _resendCode() async {
    setState(() {
      _isResending = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final result = await authProvider.resendVerificationCode(
      identifier: widget.phone,
    );

    if (mounted) {
      setState(() {
        _isResending = false;
      });

      result.fold(
        (failure) {
          context.showSnackBar(failure.message, isError: true);
        },
        (success) {
          context.showSnackBar('New verification code sent! 📱📧');
          setState(() {
            _verificationCode = '';
          });
          // Restart SMS listening
          SmsAutoFill().listenForCode;
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // Prevent going back
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              // Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.verified_user,
                  size: 50,
                  color: theme.primaryColor,
                ),
              ),

              const SizedBox(height: 32),

              // Title
              Text(
                'Verify Your Account',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // Subtitle
              Text(
                'Enter the 6-digit code sent to:',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Contact info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.sms, size: 18, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Text(
                          widget.phone,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.email, size: 18, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Text(
                          widget.email,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Auto-detection notice
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.auto_fix_high,
                      color: Colors.blue[600],
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Auto-detecting SMS code...',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Code input with auto-fill
              PinFieldAutoFill(
                decoration: BoxLooseDecoration(
                  textStyle: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                  strokeColorBuilder: FixedColorBuilder(
                    _verificationCode.length == 6
                        ? theme.primaryColor
                        : Colors.grey[300]!,
                  ),
                  bgColorBuilder: FixedColorBuilder(
                    _verificationCode.length == 6
                        ? theme.primaryColor.withOpacity(0.1)
                        : Colors.grey[50]!,
                  ),
                  strokeWidth: 2,
                  gapSpace: 12,
                  radius: const Radius.circular(8),
                ),
                currentCode: _verificationCode,
                onCodeSubmitted: (code) {
                  setState(() {
                    _verificationCode = code;
                  });
                  _verifyAccount();
                },
                onCodeChanged: (code) {
                  setState(() {
                    _verificationCode = code ?? '';
                  });
                },
              ),

              const SizedBox(height: 40),

              // Verify button
              CustomButton(
                text: 'Verify Account',
                onPressed:
                    authProvider.isLoading || _verificationCode.length != 6
                        ? null
                        : _verifyAccount,
                isLoading: authProvider.isLoading,
              ),

              const SizedBox(height: 24),

              // Resend button
              TextButton(
                onPressed: _isResending ? null : _resendCode,
                child:
                    _isResending
                        ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: theme.primaryColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Sending...',
                              style: TextStyle(
                                color: theme.primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        )
                        : Text(
                          'Didn\'t receive the code? Resend',
                          style: TextStyle(
                            color: theme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
              ),

              const SizedBox(height: 20),

              // Help text
              Text(
                'The same code was sent to both your phone and email for your convenience',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}