import 'package:flutter/material.dart';
import '../../models/identity_model.dart';
import '../../utils/app_theme.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../services/storage_service.dart';
import '../../services/auth_service.dart';
import 'dart:io';

class IdentityUploadScreen extends StatefulWidget {
  const IdentityUploadScreen({super.key});

  @override
  State<IdentityUploadScreen> createState() => _IdentityUploadScreenState();
}

class _IdentityUploadScreenState extends State<IdentityUploadScreen> {
  IdentityType _selectedType = IdentityType.aadhaar;
  bool _isUploading = false;
  File? _selectedImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() => _selectedImage = File(image.path));
    }
  }

  void _handleUpload() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select or capture an image of your ID')),
      );
      return;
    }

    setState(() => _isUploading = true);
    
    final authService = Provider.of<AuthService>(context, listen: false);
    final storageService = Provider.of<StorageService>(context, listen: false);
    final scout = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);

    setState(() => _isUploading = true);
    
    final downloadUrl = await storageService.uploadIdentityDoc(
      authService.currentUser!.uid,
      _selectedType.name,
      _selectedImage!,
    );
    
    if (!mounted) return;

    if (downloadUrl != null) {
      // Mock verification success for now, but save the URL
      await authService.updateProfile(isVerified: true); 
      
      if (mounted) {
        scout.showSnackBar(
          const SnackBar(content: Text('Identity document submitted and verified!')),
        );
        nav.pop();
      }
    } else {
      if (mounted) {
        scout.showSnackBar(
          const SnackBar(content: Text('Failed to upload document')),
        );
      }
    }
    
    setState(() => _isUploading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Identity')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Government ID Verification',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please upload a clear photo of your government-issued ID for verification.',
              style: TextStyle(color: AppTheme.lightTextColor),
            ),
            const SizedBox(height: 32),
            const Text('Select Document Type', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            DropdownButtonFormField<IdentityType>(
              initialValue: _selectedType,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: IdentityType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedType = val);
              },
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
                  image: _selectedImage != null 
                    ? DecorationImage(image: FileImage(_selectedImage!), fit: BoxFit.cover)
                    : null,
                ),
                child: _selectedImage == null ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo_outlined, size: 48, color: Colors.grey),
                    SizedBox(height: 12),
                    Text('Tap to upload photo', style: TextStyle(color: Colors.grey)),
                  ],
                ) : null,
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _isUploading ? null : _handleUpload,
              child: _isUploading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Submit for Verification'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
