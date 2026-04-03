import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../utils/app_theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  void _handleReset() async {
    if (_emailController.text.isEmpty) return;
    
    setState(() => _isLoading = true);
    final authService = Provider.of<AuthService>(context, listen: false);
    String? error = await authService.resetPassword(_emailController.text);
    setState(() => _isLoading = false);

    if (!mounted) return;
    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset link sent to your email.')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Reset Password',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.secondary(context),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter your registered email address to receive a password reset link.',
              style: TextStyle(color: AppTheme.subtext(context)),
            ),
            const SizedBox(height: 48),
            
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                prefixIcon: Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 32),
            
            ElevatedButton(
              onPressed: _isLoading ? null : _handleReset,
              child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Send Reset Link'),
            ),
          ],
        ),
      ),
    );
  }
}
