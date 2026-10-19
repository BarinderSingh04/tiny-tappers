import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../kit/home_button.dart';
import 'car_wash_game.dart';

class CarWashScreen extends StatefulWidget {
  const CarWashScreen({super.key});

  @override
  State<CarWashScreen> createState() => _CarWashScreenState();
}

class _CarWashScreenState extends State<CarWashScreen> {
  final _game = CarWashGame();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget(game: _game),
          const Positioned(
            top: 16,
            left: 16,
            child: SafeArea(child: HomeButton()),
          ),
        ],
      ),
    );
  }
}
