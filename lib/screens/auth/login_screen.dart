import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import '../../utils/app_theme.dart';
import 'role_selection_screen.dart';
import 'forgot_password_screen.dart';
import 'otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _obscurePassword = true;
  bool _usePhone = false;

  Future<void> _handleEmailLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final authService = Provider.of<AuthService>(context, listen: false);

    final error = await authService.loginWithEmail(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _handlePhoneLogin() async {
    String phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your phone number')),
      );
      return;
    }

    if (!phone.startsWith('+')) phone = '+91$phone';

    setState(() => _isLoading = true);
    final authService = Provider.of<AuthService>(context, listen: false);

    final error = await authService.verifyPhoneNumber(
      phone,
      (verificationId) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OTPScreen(
              contactInfo: phone,
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
  }

  Future<void> _handleGoogleSignIn() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    setState(() => _isGoogleLoading = true);

    String? error = await authService.signInWithGoogle();

    if (!mounted) return;

    if (error == 'role_required') {
      final UserRole? role = await showDialog<UserRole>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppTheme.card(context),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Welcome! You are a...',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.text(context)),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Choose your role to complete sign-up.',
                  style: TextStyle(color: AppTheme.subtext(context))),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _roleDialogButton(
                      context, 'Owner', Icons.business_center_outlined,
                      AppTheme.primary(context), UserRole.owner,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _roleDialogButton(
                      context, 'Tenant', Icons.person_outline,
                      AppTheme.accent(context), UserRole.tenant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

      if (role == null) {
        await authService.signOut();
        setState(() => _isGoogleLoading = false);
        return;
      }

      error = await authService.signInWithGoogle(role: role);
    }

    if (!mounted) return;
    setState(() => _isGoogleLoading = false);

    if (error != null && error != 'cancelled') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    }
  }

  Widget _roleDialogButton(BuildContext context, String label, IconData icon,
      Color color, UserRole role) {
    return InkWell(
      onTap: () => Navigator.pop(context, role),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(label,
                style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primary(context).withValues(alpha: 0.08),
              AppTheme.bg(context),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 60),
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary(context).withValues(alpha: 0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: AppTheme.card(context),
                        backgroundImage: const AssetImage('assets/images/logo.jpg'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  Text(
                    'Welcome Back',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.secondary(context),
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Log in to manage your properties.',
                    style: TextStyle(color: AppTheme.subtext(context)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 36),

                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.dividerColor(context)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _usePhone = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: !_usePhone
                                    ? AppTheme.primary(context)
                                    : Colors.transparent,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(11),
                                  bottomLeft: Radius.circular(11),
                                ),
                              ),
                              child: Text(
                                'Email',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: !_usePhone
                                      ? (AppTheme.isDark(context) ? Colors.black87 : Colors.white)
                                      : AppTheme.subtext(context),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _usePhone = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _usePhone
                                    ? AppTheme.primary(context)
                                    : Colors.transparent,
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(11),
                                  bottomRight: Radius.circular(11),
                                ),
                              ),
                              child: Text(
                                'Phone',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: _usePhone
                                      ? (AppTheme.isDark(context) ? Colors.black87 : Colors.white)
                                      : AppTheme.subtext(context),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  if (!_usePhone) ...[
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'Email Address',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Please enter your email';
                        if (!val.contains('@')) return 'Enter a valid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: AppTheme.subtext(context),
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      validator: (val) => val!.isEmpty ? 'Please enter your password' : null,
                    ),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const ForgotPasswordScreen()),
                          );
                        },
                        child: const Text('Forgot Password?'),
                      ),
                    ),

                    const SizedBox(height: 16),

                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleEmailLogin,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20, width: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('Log In'),
                    ),
                  ] else ...[
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: Icon(Icons.phone_outlined),
                        hintText: '9876543210',
                        prefixText: '+91 ',
                      ),
                    ),

                    const SizedBox(height: 32),

                    ElevatedButton(
                      onPressed: _isLoading ? null : _handlePhoneLogin,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20, width: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text('Send OTP'),
                    ),
                  ],

                  const SizedBox(height: 28),

                  Row(
                    children: [
                      Expanded(child: Divider(color: AppTheme.dividerColor(context))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text('OR', style: TextStyle(
                          color: AppTheme.subtext(context),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1,
                        )),
                      ),
                      Expanded(child: Divider(color: AppTheme.dividerColor(context))),
                    ],
                  ),

                  const SizedBox(height: 28),

                  OutlinedButton(
                    onPressed: _isGoogleLoading ? null : _handleGoogleSignIn,
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
                                'Continue with Google',
                                style: TextStyle(
                                  color: AppTheme.text(context),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                  ),

                  const SizedBox(height: 36),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account?",
                          style: TextStyle(color: AppTheme.subtext(context))),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const RoleSelectionScreen()),
                          );
                        },
                        child: const Text('Register Now'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
