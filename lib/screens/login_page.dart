import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:seminarium/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Logowanie'),
      ),
      body: Form(
        key: _formKey,
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Adres e-mail',
                  icon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Hasło',
                  icon: Icon(Icons.lock),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                child: Text('Zaloguj'),
                onPressed: () async {
                  final container = ProviderContainer();
                  bool loginSuccessful = await container.read(authProvider).login(
                      _emailController.text, _passwordController.text);
                  if (loginSuccessful) {
                    GoRouter.of(context).go('/');
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Nie udało się zalogować.')),
                    );
                  }
                },
              ),
              const SizedBox(height: 25),
              OutlinedButton.icon(
                icon: Icon(Icons.person_add),
                label: Text('Zarejestruj się'),
                onPressed: () async {
                  final container = ProviderContainer();
                  bool registrationSuccessful = await container.read(authProvider).register(
                      _emailController.text, _passwordController.text);
                  if (registrationSuccessful) {
                    GoRouter.of(context).go('/');
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Nie udało się zarejestrować.')),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
