import 'package:agnostiko/agnostiko.dart';
import 'package:flutter/material.dart';
import 'package:prueba_ag/dialogs/card_indicator_dialog.dart';
import 'package:prueba_ag/models/transaction_args.dart';
import 'package:prueba_ag/views/game_screen/game_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  static String route = "/auth";

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  TransactionArgs? transactionArgs;
  void Function(bool)? changeRFCardDialogFn;

  void _showGameScreen(BuildContext context) {
    Navigator.pushReplacementNamed(context, GameScreen.route);
  }

  Future<void> _onRFCard() async {
    changeRFCardDialogFn = showCardIndicatorDialog(context, true);
    _runTransaction();
  }

  void _runTransaction() async {
    ///Por ahora solamente se simula una transacción con un delay.
    ///

    await Future.delayed(const Duration(milliseconds: 500));

    if (changeRFCardDialogFn != null) {
      changeRFCardDialogFn!(false);
    }

    _onEmvFinished();
  }

  void _onEmvFinished() {
    Navigator.pop(context);
    Navigator.of(context).pushReplacementNamed(GameScreen.route);
  }

  void _startCardDetection(CardType cardType) async {
    final cardReaderStream = openCardReader(cardTypes: [cardType]);

    try {
      await for (final event in cardReaderStream) {
        if (!mounted) return;
        if (event.cardType == CardType.RF) {
          await _onRFCard();
        }
      }
    } catch (e) {
      print("¡Error en lectura de RF!");
    }
  }

  @override
  void initState() {
    super.initState();
    _startCardDetection(CardType.RF);
  }

  @override
  void dispose() {
    closeCardReader();
    super.dispose();
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
