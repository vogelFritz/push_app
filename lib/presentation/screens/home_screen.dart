import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Permisos'),
          actions: [
            IconButton(
                onPressed: () {
                  //TODO: solicitar permiso de notificaciones
                },
                icon: const Icon(Icons.settings))
          ],
        ),
        body: const _HomeView());
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
