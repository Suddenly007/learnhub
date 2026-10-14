import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../core/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  final String title;
  final bool allowSignUp;
  const LoginScreen({super.key, required this.title, this.allowSignUp = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _auth = AuthService();
  bool _signUp = false, _busy = false;
  String? _error;

  Future<void> _submit() async {
    setState(() { _busy = true; _error = null; });
    try {
      if (_signUp) {
        await _auth.register(_email.text.trim(), _pass.text);
      } else {
        await _auth.signIn(_email.text.trim(), _pass.text);
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.title, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 24),
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: _pass,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _busy ? null : _submit,
                    child: Text(_signUp ? 'Create account' : 'Sign in'),
                  ),
                ),
                if (widget.allowSignUp)
                  TextButton(
                    onPressed: () => setState(() => _signUp = !_signUp),
                    child: Text(_signUp ? 'I already have an account' : 'Create an account'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
