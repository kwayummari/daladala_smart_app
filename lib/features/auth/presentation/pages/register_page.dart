import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/ui/widgets/custom_button.dart';
import '../../../../core/ui/widgets/custom_input.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/extensions.dart';
import '../providers/auth_provider.dart';
import '../../../home/presentation/pages/home_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _acceptTerms = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (!_acceptTerms) {
        context.showSnackBar(
          'Please accept the terms and conditions',
          isError: true,
        );
        return;
      }
      
      // Hide keyboard
      FocusScope.of(context).unfocus();
      
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      final result = await authProvider.register(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );
      
      if (mounted) {
        result.fold(
          (failure) {
            // Show error
            context.showSnackBar(failure.message, isError: true);
          },
          (user) {
            // Navigate to home page
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) =>  HomePage()),
              (route) => false,
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        backgroundColor: Colors.transparent,
        foregroundColor: theme.textTheme.bodyLarge?.color,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title
                Text(
                  'Create Account',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign up to get started with Daladala Smart',
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                
                // First Name field
                CustomInput(
                  label: 'First Name',
                  hint: 'Enter your first name',
                  controller: _firstNameController,
                  textCapitalization: TextCapitalization.words,
                  prefix: const Icon(Icons.person_outline),
                  validator: Validators.validateName,
                ),
                
                const SizedBox(height: 16),
                
                // Last Name field
                CustomInput(
                  label: 'Last Name',
                  hint: 'Enter your last name',
                  controller: _lastNameController,
                  textCapitalization: TextCapitalization.words,
                  prefix: const Icon(Icons.person_outline),
                  validator: Validators.validateName,
                ),
                
                const SizedBox(height: 16),
                
                // Phone field
                CustomInput(
                  label: 'Phone Number',
                  hint: 'Enter your phone number',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefix: const Icon(Icons.phone),
                  validator: Validators.validatePhone,
                ),
                
                const SizedBox(height: 16),
                
                // Email field
                CustomInput(
                  label: 'Email',
                  hint: 'Enter your email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefix: const Icon(Icons.email_outlined),
                  validator: Validators.validateEmail,
                ),
                
                const SizedBox(height: 16),
                
                // Password field
                CustomInput(
                  label: 'Password',
                  hint: 'Create a password',
                  controller: _passwordController,
                  obscureText: true,
                  prefix: const Icon(Icons.lock_outline),
                  validator: Validators.validatePassword,
                ),
                
                const SizedBox(height: 16),
                
                // Confirm Password field
                CustomInput(
                  label: 'Confirm Password',
                  hint: 'Confirm your password',
                  controller: _confirmPasswordController,
                  obscureText: true,
                  prefix: const Icon(Icons.lock_outline),
                  validator: (value) => Validators.validatePasswordConfirmation(
                    value,
                    _passwordController.text,
                  ),
                ),
                
                // Terms and conditions
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    children: [
                      Checkbox(
                        value: _acceptTerms,
                        activeColor: theme.primaryColor,
                        onChanged: (value) {
                          setState(() {
                            _acceptTerms = value ?? false;
                          });
                        },
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _acceptTerms = !_acceptTerms;
                            });
                          },
                          child: RichText(
                            text: TextSpan(
                              text: 'I agree to the ',
                              style: theme.textTheme.bodyMedium,
                              children: [
                                TextSpan(
                                  text: 'Terms and Conditions',
                                  style: TextStyle(
                                    color: theme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Register button
                CustomButton(
                  text: 'Register',
                  onPressed: _register,
                  isLoading: authProvider.isLoading,
                ),
                
                const SizedBox(height: 24),
                
                // Login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account?'),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Login'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}