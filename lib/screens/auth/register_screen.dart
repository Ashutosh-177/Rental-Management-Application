import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../utils/app_theme.dart';
import 'otp_screen.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  final UserRole selectedRole;

  const RegisterScreen({super.key, required this.selectedRole});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailPhoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _verificationMethod = 'email';
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailPhoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final authService = Provider.of<AuthService>(context, listen: false);
    String contactInfo = _emailPhoneController.text.trim();

    if (_verificationMethod == 'phone') {
      // Phone registration: send OTP via Firebase
      if (!contactInfo.startsWith('+')) {
        contactInfo = '+91$contactInfo';
      }

      String? error = await authService.verifyPhoneNumber(
        contactInfo,
        (verificationId) {
          if (!mounted) return;
          setState(() => _isLoading = false);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OTPScreen(
                name: _nameController.text,
                contactInfo: contactInfo,
                role: widget.selectedRole,
                verificationId: verificationId,
              ),
            ),
          );
        },
        (errorMessage) {
          if (!mounted) return;
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $errorMessage'), backgroundColor: Colors.red),
          );
        },
      );

      if (error != null && mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      }
    } else {
      // Email registration: create account directly, send verification email
      String? error = await authService.signUpWithEmail(
        email: contactInfo,
        password: _passwordController.text,
        name: _nameController.text,
        role: widget.selectedRole,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created! A verification link has been sent to your email.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        // Auth state listener will navigate to dashboard automatically
        Navigator.popUntil(context, (route) => route.isFirst);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _handleGoogleSignUp() async {
    setState(() => _isGoogleLoading = true);
    final authService = Provider.of<AuthService>(context, listen: false);
    final error = await authService.signInWithGoogle(role: widget.selectedRole);
    if (!mounted) return;
    setState(() => _isGoogleLoading = false);
    if (error != null && error != 'cancelled') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEmail = _verificationMethod == 'email';
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.selectedRole.toString().split('.').last.toUpperCase()} Registration'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary(context).withValues(alpha: 0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: AppTheme.card(context),
                      backgroundImage: AssetImage('assets/images/logo.jpg'),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Create Account',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.secondary(context),
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Fill in your details to get started as a ${widget.selectedRole.toString().split('.').last}.',
                  style: TextStyle(color: AppTheme.subtext(context)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Verification method selector
                Text(
                  'Register with',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.text(context)),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildVerificationOption(
                        title: 'Email',
                        value: 'email',
                        icon: Icons.email_outlined,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildVerificationOption(
                        title: 'Phone',
                        value: 'phone',
                        icon: Icons.phone_android_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (val) => val!.isEmpty ? 'Please enter your name' : null,
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _emailPhoneController,
                  keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: isEmail ? 'Email Address' : 'Phone Number',
                    prefixIcon: Icon(isEmail ? Icons.email_outlined : Icons.phone_outlined),
                    hintText: isEmail ? 'you@example.com' : '9876543210',
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Required';
                    if (isEmail && !val.contains('@')) return 'Enter a valid email';
                    if (!isEmail && val.length < 10) return 'Enter a valid phone number';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                if (isEmail) ...[
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (val) => val!.length < 6 ? 'Password must be 6+ characters' : null,
                  ),
                  const SizedBox(height: 20),

                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirm,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      prefixIcon: const Icon(Icons.lock_reset_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),
                    validator: (val) => val != _passwordController.text ? 'Passwords do not match' : null,
                  ),
                ],

                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(isEmail ? 'Create Account' : 'Send OTP'),
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(child: Divider(color: AppTheme.dividerColor(context))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('OR', style: TextStyle(color: AppTheme.subtext(context), fontSize: 12)),
                    ),
                    Expanded(child: Divider(color: AppTheme.dividerColor(context))),
                  ],
                ),

                const SizedBox(height: 24),

                OutlinedButton(
                  onPressed: _isGoogleLoading ? null : _handleGoogleSignUp,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(color: AppTheme.dividerColor(context)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    backgroundColor: AppTheme.card(context),
                  ),
                  child: _isGoogleLoading
                      ? const SizedBox(
                          height: 20, width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.network(
                              'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                              height: 20,
                              width: 20,
                              errorBuilder: (_, __, ___) => const Icon(Icons.g_mobiledata, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Sign up with Google',
                              style: TextStyle(
                                color: AppTheme.text(context),
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                ),

                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account?', style: TextStyle(color: AppTheme.subtext(context))),
                    TextButton(
                      onPressed: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      ),
                      child: const Text('Log In'),
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

  Widget _buildVerificationOption({
    required String title,
    required String value,
    required IconData icon,
  }) {
    bool isSelected = _verificationMethod == value;
    return InkWell(
      onTap: () => setState(() => _verificationMethod = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary(context) : AppTheme.card(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primary(context) : AppTheme.dividerColor(context),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primary(context).withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? (AppTheme.isDark(context) ? Colors.black87 : Colors.white) : AppTheme.subtext(context)),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? (AppTheme.isDark(context) ? Colors.black87 : Colors.white) : AppTheme.subtext(context),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
