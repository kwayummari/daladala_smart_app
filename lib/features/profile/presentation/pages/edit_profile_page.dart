// lib/features/profile/presentation/pages/edit_profile_page.dart
import 'dart:io';
import 'package:daladala_smart_app/features/profile/presentation/providers/profile_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/widgets/custom_button.dart';
import '../../../../core/ui/widgets/custom_input.dart';
import '../../../../core/utils/validators.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  
  File? _selectedImage;
  bool _isLoading = false;
  
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
  
  void _loadUserData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;
    
    if (user != null) {
      _firstNameController.text = user.firstName;
      _lastNameController.text = user.lastName;
      _emailController.text = user.email ?? '';
      _phoneController.text = user.phone;
    }
  }
  
  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      
      // Show image source selection
      final source = await showModalBottomSheet<ImageSource>(
        context: context,
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Camera'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      );
      
      if (source != null) {
        final XFile? image = await picker.pickImage(
          source: source,
          maxWidth: 800,
          maxHeight: 800,
          imageQuality: 85,
        );
        
        if (image != null) {
          setState(() {
            _selectedImage = File(image.path);
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
      
      final profileData = {
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'email': _emailController.text.trim(),
      };
      
      final result = await profileProvider.updateProfile(
        profileData,
        profileImage: _selectedImage,
      );
      
      if (mounted) {
        result.fold(
          (failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(failure.message),
                backgroundColor: Colors.red,
              ),
            );
          },
          (user) {
            // Update auth provider with new user data
            final authProvider = Provider.of<AuthProvider>(context, listen: false);
            authProvider.updateCurrentUser(user);
            
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile updated successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            
            Navigator.pop(context);
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;
    
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('User not found')),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 20),
              
              // Profile Picture Section
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.primaryColor,
                          width: 3,
                        ),
                      ),
                      child: ClipOval(
                        child: _selectedImage != null
                            ? Image.file(
                                _selectedImage!,
                                fit: BoxFit.cover,
                                width: 120,
                                height: 120,
                              )
                            : user.profilePicture != null
                                ? Image.network(
                                    user.profilePicture!,
                                    fit: BoxFit.cover,
                                    width: 120,
                                    height: 120,
                                    errorBuilder: (context, error, stackTrace) {
                                      return _buildDefaultAvatar();
                                    },
                                  )
                                : _buildDefaultAvatar(),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 8),
              Text(
                'Tap to change photo',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Form Fields
              CustomInput(
                controller: _firstNameController,
                label: 'First Name',
                prefix: Icon(Icons.person_outline),
                validator: Validators.validateName,
                textCapitalization: TextCapitalization.words,
              ),
              
              const SizedBox(height: 20),
              
              CustomInput(
                controller: _lastNameController,
                label: 'Last Name',
                prefix: Icon(Icons.person_outline),
                validator: Validators.validateName,
                textCapitalization: TextCapitalization.words,
              ),
              
              const SizedBox(height: 20),
              
              CustomInput(
                controller: _emailController,
                label: 'Email Address',
                prefix: Icon(Icons.email_outlined),
                keyboardType: TextInputType.emailAddress,
                validator: Validators.validateEmail,
              ),
              
              const SizedBox(height: 20),
              
              CustomInput(
                controller: _phoneController,
                label: 'Phone Number',
                prefix: Icon(Icons.phone_outlined),
                enabled: false,
                hint: 'Contact support to change your phone number',
              ),
              
              const SizedBox(height: 40),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: 'Save Changes',
                  onPressed: _isLoading ? null : _saveProfile,
                  isLoading: _isLoading,
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    
    return Container(
      width: 120,
      height: 120,
      color: Colors.grey.shade200,
      child: user != null && user.firstName.isNotEmpty && user.lastName.isNotEmpty
          ? Center(
              child: Text(
                '${user.firstName[0]}${user.lastName[0]}',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            )
          : Icon(
              Icons.person,
              size: 50,
              color: Colors.grey.shade600,
            ),
    );
  }
}