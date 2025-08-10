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
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        ),
        home: const MyHomePage(title: 'The Rummikub Timer'),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = 1;
  int secondsRemaining = 120;
  Timer? _timer;
  var turnTime = 120;
  var numPlayers = 2;
  var playersName = <String>['Player 1', 'Player 2'];
  void nextPlayer() {
    current = (current % numPlayers) + 1;
    startTimer();
    notifyListeners();
  }

  void startTimer() {
    resetTimer();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (secondsRemaining > 0) {
        secondsRemaining--;
        notifyListeners();
      } else {
        _timer?.cancel();
        nextPlayer();
      }
    });
    notifyListeners();
  }

  void resetTimer() {
    _timer?.cancel();
    secondsRemaining = turnTime;
    notifyListeners();
  }

  void startGameTimer() {
    current = 1;
    startTimer();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int selectedView = 0; // 0: NewGamePage, 1: TimerPage
  void switchToTimerPage() {
    setState(() {
      selectedView = 1;
    });
  }

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
        actions: [
          TextButton.icon(
            icon: Icon(Icons.refresh, color: Colors.white),
            label: Text('New Game', style: TextStyle(color: Colors.white)),
            onPressed: () {
              setState(() {
                selectedView = 0; // Switch to NewGamePage
              });
              context.read<MyAppState>().resetTimer();
            },
          ),
        ],
      ),
      body: selectedView == 0
          ? NewGamePage(onStartGame: switchToTimerPage)
          : TimerPage(),
    );
  }
}

class TimerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    final tseconds = appState.secondsRemaining.toString().padLeft(2, '0');
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
                  ?.copyWith(fontSize: 58)
                  .copyWith(fontWeight: FontWeight.bold),
              minimumSize: Size(250, 400), // Makes the button big and square
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20), // Square corners
              ),
            ),
            onPressed: () {
              context.read<MyAppState>().nextPlayer();
            },
            child: Text(tseconds),
          ),
        ],
      ),
    );
  }
}

class NewGamePage extends StatefulWidget {
  final VoidCallback onStartGame;
  const NewGamePage({super.key, required this.onStartGame});

  @override
  State<NewGamePage> createState() => _NewGamePageState();
}

class _NewGamePageState extends State<NewGamePage> {
  int selectedPlayers = 2; // Default value
  int selectedTurnTime = 120;
  late List<TextEditingController> nameControllers;

  @override
  void initState() {
    super.initState();
    nameControllers = List.generate(
      selectedPlayers,
      (index) => TextEditingController(),
    );
  }

  @override
  void dispose() {
    for (var controller in nameControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void updateControllers(int count) {
    if (count > nameControllers.length) {
      nameControllers.addAll(
        List.generate(
          count - nameControllers.length,
          (index) => TextEditingController(),
        ),
      );
    } else if (count < nameControllers.length) {
      nameControllers = nameControllers.sublist(0, count);
    }
  }

  Widget build(BuildContext context) {
    updateControllers(selectedPlayers);

    return Scaffold(
      appBar: AppBar(title: Text('New Game')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Select number of players:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 10),
            DropdownButton<int>(
              value: selectedPlayers,
              items: [2, 3, 4].map((num) {
                return DropdownMenuItem<int>(value: num, child: Text('$num'));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedPlayers = value!;
                });
              },
            ),
            SizedBox(height: 20),
            Text(
              'Enter player names:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            ...List.generate(selectedPlayers, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 4.0,
                  horizontal: 40.0,
                ),
                child: TextField(
                  controller: nameControllers[index],
                  decoration: InputDecoration(
                    labelText: 'Player ${index + 1} Name',
                    border: OutlineInputBorder(),
                  ),
                ),
              );
            }),
            SizedBox(height: 20),
            Text(
              'Select turn time (seconds):',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            DropdownButton<int>(
              value: selectedTurnTime,
              items: [30, 60, 90, 120].map((num) {
                return DropdownMenuItem<int>(value: num, child: Text('$num'));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedTurnTime = value!;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.read<MyAppState>().numPlayers = selectedPlayers;
                context.read<MyAppState>().turnTime = selectedTurnTime;
                context.read<MyAppState>().playersName = List.generate(
                  selectedPlayers,
                  (index) => nameControllers[index].text.isNotEmpty
                      ? nameControllers[index].text
                      : 'Player ${index + 1}', // <-- Use entered name or default
                );
                context.read<MyAppState>().startGameTimer();
                widget.onStartGame();
              },
              child: Text('Start Game'),
            ),
          ],
        ),
      ),
    );
  }
}
