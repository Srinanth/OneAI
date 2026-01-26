import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../logic/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  
  bool isSignUp = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  void _submit() {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final notifier = ref.read(authControllerProvider.notifier);

    if (isSignUp) {
      if (password != confirmController.text.trim()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match')),
        );
        return;
      }
      notifier.signUp(email, password);
    } else {
      notifier.signIn(email, password);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<void>>(authControllerProvider, (prev, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
      if (next is AsyncData && isSignUp && !next.isLoading) {
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created! Please log in.')),
        );
        setState(() => isSignUp = false);
      }
    });

    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_person_outlined, size: 64, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 24),
              Text(
                isSignUp ? 'Create Account' : 'Welcome Back',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                enabled: !isLoading,
              ),
              const SizedBox(height: 16),
              
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                obscureText: true,
                enabled: !isLoading,
              ),
              
              if (isSignUp) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: confirmController,
                  decoration: const InputDecoration(labelText: 'Confirm Password', border: OutlineInputBorder()),
                  obscureText: true,
                  enabled: !isLoading,
                ),
              ],

              const SizedBox(height: 24),

              if (isLoading)
                const CircularProgressIndicator()
              else
                FilledButton(
                  onPressed: _submit,
                  style: FilledButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                  child: Text(isSignUp ? 'Sign Up' : 'Log In'),
                ),

              TextButton(
                onPressed: isLoading ? null : () {
                  setState(() => isSignUp = !isSignUp);
                  confirmController.clear();
                },
                child: Text(isSignUp ? 'Already have an account? Log In' : "Don't have an account? Sign Up"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}