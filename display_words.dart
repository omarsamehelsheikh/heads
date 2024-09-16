import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heads_upp/db%20state%20management/head_up_state.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:heads_upp/db%20state%20management/head_up_logic.dart';

class GameScreen extends StatelessWidget {
  final int categoryId;

  const GameScreen({Key? key, required this.categoryId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Lock the orientation to portrait mode when the screen is built
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight]);

    // Start listening to accelerometer events
    final _accelerometerSubscription = accelerometerEvents.listen((event) {
      if (event.z > 5) {
        // Tilt forward (correct answer)
        context.read<HeadsUplogic>().handleCorrectAnswer();
      } else if (event.z < -5) {
        // Tilt backward (wrong answer)
        context.read<HeadsUplogic>().handleWrongAnswer();
      }
    });

    // Start the game
    context.read<HeadsUplogic>().startGameWithCategory(categoryId);

    return BlocBuilder<HeadsUplogic, HeadUpState>(
      builder: (context, state) {
        if (state is GameInProgress) {
          return Scaffold(
            backgroundColor: state.backgroundColor,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.currentWord,
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Time Left: ${state.timeLeft}',
                    style: TextStyle(fontSize: 24),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _accelerometerSubscription
                          .cancel(); // Cancel the accelerometer subscription
                      context
                          .read<HeadsUplogic>()
                          .EndGame(); // Ensure the game is properly ended
                      Navigator.pop(context, true);
                    },
                    child: Text('Back to Categories'),
                  ),
                ],
              ),
            ),
          );
        } else if (state is GameEnded) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Game Over!',
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _accelerometerSubscription
                          .cancel(); // Cancel the accelerometer subscription
                      Navigator.pop(context, true);
                      // Return to categories page
                    },
                    child: Text('Back to Categories'),
                  ),
                ],
              ),
            ),
          );
        } else {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }

  // Dispose method to cancel subscriptions and reset orientation
  void dispose(BuildContext context) {
    accelerometerEvents.drain();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }
}
