import 'package:flutter/material.dart';
import 'package:prueba_ag/views/game_screen/game_screen.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  static String route = "/auth";

  void _showGameScreen(BuildContext context) {
    Navigator.pushReplacementNamed(context, GameScreen.route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bienvenido'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          color: const Color.fromARGB(255, 40, 40, 40),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Acerca tu tarjeta para comenzar a jugar",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 32,
                ),
                Image.asset(
                  "assets/images/tap_card.png",
                  color: Colors.white,
                ),
                const SizedBox(
                  height: 16,
                ),
                ElevatedButton(
                  onPressed: () {
                    _showGameScreen(context);
                  },
                  child: const Text("Comenzar"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
