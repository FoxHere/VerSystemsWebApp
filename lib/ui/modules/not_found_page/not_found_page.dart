import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:versystems_app/config/helpers/routes/routes_helper.dart';

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Página não encontrada")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "404 - Página não encontrada",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(RoutesHelper.dashboard),
              child: const Text("Voltar para o início"),
            ),
          ],
        ),
      ),
    );
  }
}
