// lib/screens/profile/profile_page.dart
import 'package:daladala_smart_app/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ApiService _apiService = ApiService();
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();

  User? user;
  bool isLoading = true;
  bool isEditing = false;
  bool isSaving = false;
  File? _selectedImage;
  String? errorMessage;
  String? successMessage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      print("========== Profile data Loading ===========");
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final response = await _apiService.getProfile();

      print("Profile data=========== ${response}");

      if (response['status'] == 'success') {
        setState(() {
          user = User.fromJson(response['data']);
          _populateFields();
          isLoading = false;
        });
      } else {
        throw Exception(response['message'] ?? 'Failed to load profile');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load profile. Please try again.';
      });
      print('Profile load error: $e');
    }
  }

  void _populateFields() {
    if (user != null) {
      _firstNameController.text = user!.firstName ?? '';
      _lastNameController.text = user!.lastName ?? '';
      _emailController.text = user!.email ?? '';
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() {
        isSaving = true;
        errorMessage = null;
        successMessage = null;
      });

      final updateData = {
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'email': _emailController.text.trim(),
      };

      // If there's a new profile picture, upload it first
      if (_selectedImage != null) {
        final imageUrl = await _apiService.uploadProfilePicture(
          _selectedImage!,
        );
        updateData['profile_picture'] = imageUrl;
      }

      final response = await _apiService.updateProfile(updateData);

      if (response['status'] == 'success') {
        setState(() {
          user = User.fromJson(response['data']);
          isEditing = false;
          successMessage = 'Profile updated successfully!';
        });

        // Clear success message after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() => successMessage = null);
          }
        });
      } else {
        throw Exception(response['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to update profile. Please try again.';
      });
      print('Profile update error: $e');
    } finally {
      setState(() => isSaving = false);
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
    }
  }

  void _cancelEdit() {
    setState(() {
      isEditing = false;
      _selectedImage = null;
      errorMessage = null;
      _populateFields();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: isLoading ? _buildLoadingState() : _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 280,
      floating: false,
      pinned: true,
      backgroundColor: Theme.of(context).primaryColor,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.8),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                _buildProfilePicture(),
                const SizedBox(height: 16),
                _buildUserInfo(),
              ],
            ),
          ),
        ),
      ),
      actions: [
        if (!isEditing && !isLoading)
          IconButton(
            onPressed: () => setState(() => isEditing = true),
            icon: const Icon(Icons.edit, color: Colors.white),
          ),
      ],
    );
  }

  Widget _buildProfilePicture() {
    return Stack(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipOval(child: _buildProfileImage()),
        ),
        if (isEditing)
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
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
          ),
      ],
    );
  }

  Widget _buildProfileImage() {
    if (_selectedImage != null) {
      return Image.file(
        _selectedImage!,
        fit: BoxFit.cover,
        width: 120,
        height: 120,
      );
    } else if (user?.profilePicture != null &&
        user!.profilePicture!.isNotEmpty) {
      return Image.network(
        user!.profilePicture!,
        fit: BoxFit.cover,
        width: 120,
        height: 120,
        errorBuilder: (context, error, stackTrace) {
          return _buildDefaultAvatar();
        },
      );
    } else {
      return _buildDefaultAvatar();
    }
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 120,
      height: 120,
      color: Colors.grey[300],
      child: Icon(Icons.person, size: 60, color: Colors.grey[600]),
    );
  }

  Widget _buildUserInfo() {
    final fullName = '${user?.firstName ?? ''} ${user?.lastName ?? ''}'.trim();

    return Column(
      children: [
        Text(
          fullName.isEmpty ? 'Complete Your Profile' : fullName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          user?.phone ?? '',
          style: const TextStyle(color: Colors.white70, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.shield, color: Colors.white, size: 16),
              const SizedBox(width: 4),
              Text(
                user?.role?.roleName.toUpperCase() ?? 'PASSENGER',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return SizedBox(
      height: 400,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading profile...'),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (errorMessage != null) _buildErrorMessage(),
          if (successMessage != null) _buildSuccessMessage(),
          const SizedBox(height: 16),
          _buildProfileForm(),
          const SizedBox(height: 24),
          if (!isEditing) _buildProfileStats(),
        ],
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              errorMessage!,
              style: TextStyle(color: Colors.red.shade600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, color: Colors.green.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              successMessage!,
              style: TextStyle(color: Colors.green.shade600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileForm() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Personal Information',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  if (isEditing)
                    Row(
                      children: [
                        TextButton(
                          onPressed: _cancelEdit,
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: isSaving ? null : _updateProfile,
                          child:
                              isSaving
                                  ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Text('Save'),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _firstNameController,
                enabled: isEditing,
                decoration: const InputDecoration(
                  labelText: 'First Name',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (isEditing && (value == null || value.trim().isEmpty)) {
                    return 'First name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lastNameController,
                enabled: isEditing,
                decoration: const InputDecoration(
                  labelText: 'Last Name',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (isEditing && (value == null || value.trim().isEmpty)) {
                    return 'Last name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                enabled: isEditing,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (isEditing && (value == null || value.trim().isEmpty)) {
                    return 'Email is required';
                  }
                  if (isEditing &&
                      !RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                      ).hasMatch(value!)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: user?.phone ?? '',
                enabled: false,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(),
                  helperText: 'Contact support to change phone number',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileStats() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Account Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              Icons.verified_user,
              'Account Status',
              user?.isVerified == true ? 'Verified' : 'Not Verified',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.calendar_today,
              'Member Since',
              _formatDate(user?.createdAt).toString(),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.access_time,
              'Last Login',
              _formatDate(user?.lastLogin) ?? 'Never',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  String? _formatDate(String? dateString) {
    if (dateString == null) return null;
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}

// lib/models/user_model.dart
class User {
  final int userId;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String phone;
  final String? profilePicture;
  final bool isVerified;
  final String? lastLogin;
  final String status;
  final String createdAt;
  final String updatedAt;
  final UserRole? role;

  User({
    required this.userId,
    this.firstName,
    this.lastName,
    this.email,
    required this.phone,
    this.profilePicture,
    required this.isVerified,
    this.lastLogin,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      phone: json['phone'],
      profilePicture: json['profile_picture'],
      isVerified: json['is_verified'] ?? false,
      lastLogin: json['last_login'],
      status: json['status'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      role: json['role'] != null ? UserRole.fromJson(json['role']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'profile_picture': profilePicture,
      'is_verified': isVerified,
      'last_login': lastLogin,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'role': role?.toJson(),
    };
  }
}

class UserRole {
  final int roleId;
  final String roleName;

  UserRole({required this.roleId, required this.roleName});

  factory UserRole.fromJson(Map<String, dynamic> json) {
    return UserRole(roleId: json['role_id'], roleName: json['role_name']);
  }

  Map<String, dynamic> toJson() {
    return {'role_id': roleId, 'role_name': roleName};
  }
}
