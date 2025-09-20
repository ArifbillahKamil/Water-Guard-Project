import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Masuk", style: theme.textTheme.titleLarge),
              const SizedBox(height: 32),
              TextField(
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Email",
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password",
                  prefixIcon: Icon(Icons.lock_outline),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // TODO: integrasi login
                },
                child: const Text("Masuk"),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  // TODO: pindah ke halaman register
                },
                child: const Text("Tidak memiliki akun ? Daftar"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
