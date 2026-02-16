import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_logo.dart';
import '../../providers/auth_notifier.dart';

class LoginSignupPage extends ConsumerStatefulWidget {
  const LoginSignupPage({super.key});

  @override
  ConsumerState<LoginSignupPage> createState() => _LoginSignupPageState();
}

class _LoginSignupPageState extends ConsumerState<LoginSignupPage> {
    Future<void> _handleGoogleSignIn() async {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      try {
        final authNotifier = ref.read(authStateNotifierProvider.notifier);
        await authNotifier.signInWithGoogle();
        if (mounted) {
          setState(() {
            _errorMessage = null;
          });
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        }
      } catch (e) {
        final cleanError = _cleanErrorMessage(e.toString());
        if (mounted) {
          setState(() {
            _errorMessage = cleanError;
          });
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(cleanError),
              backgroundColor: Colors.red[700],
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Dismiss',
                textColor: Colors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  bool _isLogin = true;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    super.dispose();
  }

  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authNotifier = ref.read(authStateNotifierProvider.notifier);
      
      if (_isLogin) {
        await authNotifier.login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        await authNotifier.signup(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          firstName: _firstNameController.text.trim(),
        );
      }

      // Success - auth notifier handles navigation
      // Clear any error messages and snackbars
      if (mounted) {
        setState(() {
          _errorMessage = null;
        });
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }
    } catch (e) {
        final cleanError = _cleanErrorMessage(e.toString());
        
        if (mounted) {
          setState(() {
            _errorMessage = cleanError;
          });
          
          // Hide any previous snackbars first
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          
          // Show SnackBar for immediate visibility
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(cleanError),
              backgroundColor: Colors.red[700],
              duration: const Duration(seconds: 5),
              action: SnackBarAction(
                label: 'Dismiss',
                textColor: Colors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
            ),
          );
        }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

    String _cleanErrorMessage(String error) {
      // Remove "Exception: " prefix if present
      if (error.startsWith('Exception: ')) {
        return error.substring(11);
      }
      // Remove "Error: " prefix if present
      if (error.startsWith('Error: ')) {
        return error.substring(7);
      }
      return error;
    }

  void _toggleAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
      _errorMessage = null;
      _emailController.clear();
      _passwordController.clear();
      _confirmPasswordController.clear();
      _firstNameController.clear();
    });
    // Hide any snackbars when switching modes
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  
                  // Logo
                  Center(
                    child: SizedBox(
                      height: 80,
                      child: AppLogo(),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Title
                  Text(
                    _isLogin ? 'Welcome Back' : 'Create Account',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Subtitle
                  Text(
                    _isLogin
                        ? 'Sign in to continue to your destiny reading'
                        : 'Join us to explore your spiritual path',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'you@example.com',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Email is required';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value!)) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),
                  
                  // First Name Field (only for signup)
                  if (!_isLogin) ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _firstNameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        hintText: 'John Doe',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Full name is required';
                        }
                        if (value!.length < 2) {
                          return 'Name must be at least 2 characters';
                        }
                        return null;
                      },
                    ),
                  ],
                  
                  const SizedBox(height: 16),
                  
                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscurePassword,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Password is required';
                      }
                      if (value!.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  
                  // Confirm Password Field (only for signup)
                  if (!_isLogin) ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmPasswordController,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        hintText: 'Re-enter your password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                      obscureText: _obscureConfirmPassword,
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please confirm your password';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                  ],
                  
                  // Error Message
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        border: Border.all(color: Colors.red[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red[700]),
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 32),
                  
                  // Auth Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleAuth,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            _isLogin ? 'Sign In' : 'Create Account',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),
                  // Google Sign-In Button
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _handleGoogleSignIn,
                    icon: Image.asset(
                      'assets/google_logo.png',
                      height: 24,
                      width: 24,
                    ),
                    label: Text(
                      _isLogin ? 'Sign in with Google' : 'Sign up with Google',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      side: const BorderSide(color: Colors.black12),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(fontSize: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Toggle Auth Mode
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isLogin
                            ? "Don't have an account? "
                            : 'Already have an account? ',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      GestureDetector(
                        onTap: _toggleAuthMode,
                        child: Text(
                          _isLogin ? 'Sign Up' : 'Sign In',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
