import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';

class StepCountPage extends StatefulWidget {
  const StepCountPage({super.key});

  @override
  _StepCountPageState createState() => _StepCountPageState();
}

class _StepCountPageState extends State<StepCountPage> {
  int _steps = 0;
  late StreamSubscription<StepCount> _stepCountStreamSubscription;
  final int _stepGoal = 5000;

  @override
  void initState() {
    super.initState();
    _startStepCounting();
  }

  void _startStepCounting() {
    _stepCountStreamSubscription = Pedometer.stepCountStream.listen(
      (StepCount stepCount) {
        setState(() {
          _steps = stepCount.steps;
        });
      },
      onError: (error) {
        print("Step Count Error: $error");
      },
      cancelOnError: true,
    );
  }

  @override
  void dispose() {
    _stepCountStreamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double progress = (_steps / _stepGoal).clamp(0.0, 1.0);
    int percent = (progress * 100).toInt();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Step Count Tracker',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.lightBlue.shade700,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 200,
                    width: 200,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 15,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.lightBlueAccent.shade700,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$percent%',
                        style: TextStyle(
                          fontSize: 32,
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '$_steps / $_stepGoal steps',
                        style: TextStyle(fontSize: 18, color: Colors.black87),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _steps = 0;
                  });
                },
                icon: Icon(Icons.refresh, color: Colors.white),
                label: Text('Refresh Steps'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlueAccent.shade700,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  textStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
