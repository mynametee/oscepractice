import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        await _handleLogin();
      } else {
        await _handleRegister();
      }
    } catch (e) {
      _showErrorDialog(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLogin() async {
    final credential = await _authService.signInWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (credential?.user != null) {
      _navigateToHome();
    }
  }

  Future<void> _handleRegister() async {
    final credential = await _authService.createUserWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      displayName: _nameController.text.trim(),
    );

    if (credential?.user != null) {
      // Create user document in Firestore
      final userModel = UserModel(
        id: credential!.user!.uid,
        email: credential.user!.email!,
        displayName: _nameController.text.trim(),
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      await _firestoreService.createUserDocument(userModel);
      _navigateToHome();
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              
              // App Logo/Title
              Container(
                padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.medical_services,
                  size: 64,
                  color: AppColors.primary,
                ),
              ),
              
              const SizedBox(height: AppDimensions.paddingLarge),
              
              Text(
                AppConstants.appName,
                style: AppTextStyles.heading1.copyWith(
                  color: AppColors.primary,
                ),
              ),
              
              const SizedBox(height: AppDimensions.paddingSmall),
              
              Text(
                'Master clinical reasoning through practice',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 48),
              
              // Login/Register Form
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(AppDimensions.paddingLarge),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Toggle buttons
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _isLogin = true),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: AppDimensions.paddingMedium,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _isLogin 
                                          ? AppColors.primary 
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                                    ),
                                    child: Text(
                                      'Login',
                                      style: AppTextStyles.button.copyWith(
                                        color: _isLogin 
                                            ? AppColors.surface 
                                            : AppColors.textSecondary,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _isLogin = false),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: AppDimensions.paddingMedium,
                                    ),
                                    decoration: BoxDecoration(
                                      color: !_isLogin 
                                          ? AppColors.primary 
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                                    ),
                                    child: Text(
                                      'Register',
                                      style: AppTextStyles.button.copyWith(
                                        color: !_isLogin 
                                            ? AppColors.surface 
                                            : AppColors.textSecondary,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: AppDimensions.paddingLarge),
                        
                        // Name field (only for register)
                        if (!_isLogin) ...[
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Full Name',
                              prefixIcon: const Icon(Icons.person_outline),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppDimensions.paddingMedium),
                        ],
                        
                        // Email field
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: const Icon(Icons.email_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: AppDimensions.paddingMedium),
                        
                        // Password field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword 
                                    ? Icons.visibility_off 
                                    : Icons.visibility,
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (!_isLogin && value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        
                        // Confirm password field (only for register)
                        if (!_isLogin) ...[
                          const SizedBox(height: AppDimensions.paddingMedium),
                          TextFormField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirmPassword,
                            decoration: InputDecoration(
                              labelText: 'Confirm Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword 
                                      ? Icons.visibility_off 
                                      : Icons.visibility,
                                ),
                                onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm your password';
                              }
                              if (value != _passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                        ],
                        
                        const SizedBox(height: AppDimensions.paddingLarge),
                        
                        // Submit button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.surface,
                              padding: const EdgeInsets.symmetric(
                                vertical: AppDimensions.paddingMedium,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.surface),
                                    ),
                                  )
                                : Text(
                                    _isLogin ? 'Login' : 'Register',
                                    style: AppTextStyles.button,
                                  ),
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
      ),
    );
  }
}