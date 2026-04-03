import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../utils/app_theme.dart';
import '../../models/user_model.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/storage_service.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthService>(context, listen: false).userModel;
    if (user != null) {
      _nameController.text = user.name;
      _bioController.text = user.bio ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    final authService = Provider.of<AuthService>(context, listen: false);
    
    final error = await authService.updateProfile(
      name: _nameController.text,
      bio: _bioController.text,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.userModel;

    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (_isSaving)
            const Center(child: Padding(padding: EdgeInsets.all(16.0), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))))
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveProfile,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildProfileHeader(user),
            const SizedBox(height: 32),
            _buildEditSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(UserModel user) {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
                child: user.photoUrl == null ? const Icon(Icons.person, size: 60, color: AppTheme.primaryColor) : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: CircleAvatar(
                  backgroundColor: AppTheme.primaryColor,
                  radius: 20,
                  child: IconButton(
                    icon: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                    onPressed: () async {
                      final picker = ImagePicker();
                      
                      // Capture context BEFORE any async gap
                      final storageService = Provider.of<StorageService>(context, listen: false);
                      final authService = Provider.of<AuthService>(context, listen: false);
                      final scout = ScaffoldMessenger.of(context);
                      
                      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                      
                      if (image == null) return;
                      
                      setState(() => _isSaving = true);
                      
                      final downloadUrl = await storageService.uploadProfileImage(
                        user.uid, 
                        File(image.path)
                      );
                      
                      if (!mounted) return;

                      if (downloadUrl != null) {
                        final error = await authService.updateProfile(photoUrl: downloadUrl);
                            
                        if (!mounted) return;
                        setState(() => _isSaving = false);
                        
                        if (error == null) {
                          scout.showSnackBar(
                            const SnackBar(content: Text('Profile picture updated!')),
                          );
                        }
                      } else {
                        setState(() => _isSaving = false);
                        scout.showSnackBar(
                          const SnackBar(content: Text('Failed to upload image.')),
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            user.role == UserRole.owner ? 'Property Owner' : 'Tenant',
            style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold, letterSpacing: 1.2),
          ),
          const SizedBox(height: 4),
          Text(
            user.phoneNumber ?? user.email ?? '',
            style: const TextStyle(color: AppTheme.lightTextColor),
          ),
        ],
      ),
    );
  }

  Widget _buildEditSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Full Name', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: _nameController,
          decoration: AppTheme.inputDecoration('Enter your name', Icons.person_outline),
        ),
        const SizedBox(height: 24),
        const Text('Bio / About', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: _bioController,
          maxLines: 3,
          decoration: AppTheme.inputDecoration('Tell owners about yourself', Icons.info_outline),
        ),
        const SizedBox(height: 32),
        if (Provider.of<AuthService>(context).userModel?.isVerified ?? false)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
            ),
            child: const Row(
              children: [
                Icon(Icons.verified, color: Colors.green),
                SizedBox(width: 12),
                Text('Identity Verified', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
      ],
    );
  }
}
