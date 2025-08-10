import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // TRY THIS: Try running your application with "flutter run". You'll see
          // the application has a purple toolbar. Then, without quitting the app,
          // try changing the seedColor in the colorScheme below to Colors.green
          // and then invoke "hot reload" (save your changes or press the "hot
          // reload" button in a Flutter-supported IDE, or press "r" if you used
          // the command line to start the app).
          //
          // Notice that the counter didn't reset back to zero; the application
          // state is not lost during the reload. To reset the state, use hot
          // restart instead.
          //
          // This works for code too, not just values: Most code changes can be
          // tested with just a hot reload.
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        ),
        home: const MyHomePage(title: 'The Rummikub Timer'),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = 1;
  int secondsElapsed = 0;
  Timer? _timer;
  var turnTime = 120;
  var numPlayers = 4;
  var playersName = <String>['Player 1', 'Player 2', 'Player 3', 'Player 4'];

  void nextPlayer() {
    current = (current % numPlayers) + 1;
    startTimer();
    notifyListeners();
  }

  void startTimer() {
    resetTimer();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (secondsElapsed < turnTime) {
        secondsElapsed++;
        notifyListeners();
      } else {
        _timer?.cancel();
      }
    });
    notifyListeners();
  }

  void resetTimer() {
    _timer?.cancel();
    secondsElapsed = 0;
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(child: TimerPage()),
    );
  }
}

class TimerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    final minutes = (appState.secondsElapsed ~/ 60).toString().padLeft(2, '0');
    final seconds = (appState.secondsElapsed % 60).toString().padLeft(2, '0');
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            appState.playersName[appState.current - 1],
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Colors.white,
              textStyle: Theme.of(context).textTheme.labelLarge
                  ?.copyWith(fontSize: 48)
                  .copyWith(fontWeight: FontWeight.bold),
              minimumSize: Size(250, 400), // Makes the button big and square
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20), // Square corners
              ),
            ),
            onPressed: () {
              context.read<MyAppState>().nextPlayer();
            },
            child: Text('$minutes:$seconds'),
          ),
        ],
      ),
    );
  }
}
