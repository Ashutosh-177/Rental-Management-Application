import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/property_service.dart';
import '../../services/auth_service.dart';
import '../../utils/app_theme.dart';

class JoinPropertyScreen extends StatefulWidget {
  const JoinPropertyScreen({super.key});

  @override
  State<JoinPropertyScreen> createState() => _JoinPropertyScreenState();
}

class _JoinPropertyScreenState extends State<JoinPropertyScreen> {
  final _codeController = TextEditingController();
  bool _isLoading = false;

  void _handleJoin() async {
    final code = _codeController.text.trim();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 6-digit code')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final propertyService = Provider.of<PropertyService>(context, listen: false);
    final authService = Provider.of<AuthService>(context, listen: false);

    final property = await propertyService.findPropertyByJoinCode(code);
    
    if (property == null) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid or expired join code'), backgroundColor: Colors.red),
        );
      }
      return;
    }

    final error = await propertyService.sendJoinRequest(
      propertyId: property.id,
      propertyName: property.name,
      ownerId: property.ownerId,
      tenantId: authService.currentUser!.uid,
      tenantName: authService.userModel!.name,
      tenantPhone: authService.userModel!.phoneNumber,
    );

    setState(() => _isLoading = false);
    if (mounted) {
      if (error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Join request sent! Waiting for owner approval.'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Join Property')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.home_work_outlined, size: 80, color: AppTheme.primaryColor),
            const SizedBox(height: 24),
            const Text(
              'Enter Property Join Code',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Ask your property owner for the 6-digit security code to join their property.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.lightTextColor),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _codeController,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 6,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 8),
              decoration: const InputDecoration(
                counterText: '',
                hintText: '000000',
              ),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleJoin,
              child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Send Join Request'),
            ),
          ],
        ),
      ),
    );
  }
}
