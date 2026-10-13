import 'package:flutter/material.dart';
import 'theme.dart';

/// Prototype auth: in-memory accounts. Replace with Firebase Auth later.
final Map<String, Map<String, String>> _accounts = {
  'raseena@gmail.com': {'name': 'Raseena', 'password': 'raseena'},
};

class LoginPage extends StatefulWidget {
  final void Function(String name) onLogin;
  const LoginPage({super.key, required this.onLogin});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController(), _email = TextEditingController(), _pass = TextEditingController();
  bool signUp = false, hide = true;
  String? error;

  void submit() {
    if (!_form.currentState!.validate()) return;
    final email = _email.text.trim().toLowerCase();
    if (signUp) {
      if (_accounts.containsKey(email)) return setState(() => error = 'An account with this email already exists.');
      _accounts[email] = {'name': _name.text.trim(), 'password': _pass.text};
      widget.onLogin(_name.text.trim());
    } else {
      final acc = _accounts[email];
      if (acc == null || acc['password'] != _pass.text) return setState(() => error = 'Incorrect email or password.');
      widget.onLogin(acc['name']!);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(color: navy, borderRadius: BorderRadius.circular(14)),
                  child: const Icon(Icons.call_split, color: Colors.white, size: 30),
                ),
                const SizedBox(height: 16),
                const Text('Splyce', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
                const SizedBox(height: 4),
                const Text('Shared expenses and group coordination', style: TextStyle(color: muted)),
                const SizedBox(height: 28),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _form,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                        Text(signUp ? 'Create your account' : 'Sign in', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 20),
                        if (signUp) ...[
                          TextFormField(
                            controller: _name,
                            decoration: const InputDecoration(labelText: 'Full name'),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your name' : null,
                          ),
                          const SizedBox(height: 14),
                        ],
                        TextFormField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(labelText: 'Email'),
                          validator: (v) => (v == null || !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim())) ? 'Enter a valid email' : null,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _pass,
                          obscureText: hide,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            suffixIcon: IconButton(
                              icon: Icon(hide ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20),
                              onPressed: () => setState(() => hide = !hide),
                            ),
                          ),
                          validator: (v) => (v == null || v.length < 6) ? 'At least 6 characters' : null,
                          onFieldSubmitted: (_) => submit(),
                        ),
                        if (error != null) ...[
                          const SizedBox(height: 12),
                          Text(error!, style: const TextStyle(color: negative, fontSize: 13)),
                        ],
                        const SizedBox(height: 20),
                        FilledButton(onPressed: submit, child: Text(signUp ? 'Create account' : 'Sign in')),
                      ]),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => setState(() { signUp = !signUp; error = null; }),
                  child: Text(signUp ? 'Already have an account? Sign in' : 'New to Splyce? Create an account'),
                ),
                const SizedBox(height: 8),
                const Text('Demo: demo@splyce.app / demo1234', style: TextStyle(color: muted, fontSize: 12)),
              ]),
            ),
          ),
        ),
      );
}
