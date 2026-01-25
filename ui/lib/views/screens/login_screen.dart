import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  
  bool isLoading = false;
  bool isSignUp = false;

  Future<void> _submit() async {
    setState(() => isLoading = true);
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    try {
      if (isSignUp) {
        if (password != confirmPasswordController.text.trim()) {
          throw const AuthException('Passwords do not match');
        }
        
        await Supabase.instance.client.auth.signUp(
          email: email,
          password: password,
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account created! Logging you in...')),
          );
        }
      } else {
        await Supabase.instance.client.auth.signInWithPassword(
          email: email,
          password: password,
        );
      }
      
    } on AuthException catch (e) {
      if (mounted) _showError(e.message);
    } catch (e) {
      if (mounted) _showError('Unexpected error occurred');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.lock_person_outlined, 
                size: 64, 
                color: Theme.of(context).colorScheme.primary
              ),
              const SizedBox(height: 24),
              Text(
                isSignUp ? 'Create Account' : 'OneAI',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                isSignUp ? 'Sign up to start chatting' : 'Login to continue your chat',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email', 
                  prefixIcon: Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                obscureText: true,
              ),
              
              if (isSignUp) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: confirmPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                ),
              ],

              const SizedBox(height: 24),

              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else
                FilledButton(
                  onPressed: _submit,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  child: Text(isSignUp ? 'Sign Up' : 'Log In'),
                ),

              const SizedBox(height: 16),

              TextButton(
                onPressed: () {
                  setState(() {
                    isSignUp = !isSignUp;
                    confirmPasswordController.clear();
                  });
                },
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(color: Colors.grey.shade700),
                    children: [
                      TextSpan(text: isSignUp ? "Already have an account? " : "Don't have an account? "),
                      TextSpan(
                        text: isSignUp ? 'Log In' : 'Sign Up',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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