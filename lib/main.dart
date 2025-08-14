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
          scaffoldBackgroundColor: Color(0xFFF9F9F9),
        ),
        home: const MyHomePage(title: 'Timer'),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = 1;
  int secondsRemaining = 30;
  Timer? _timer;
  var turnTime = 30;
  var numPlayers = 2;
  var maxNumberOfPlayers = 4;
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
        backgroundColor: Color(0xFF1E3A5F),
        foregroundColor: Colors.white,
        //backgroundColor: Color(0xFF2F6F73),
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: TextButton.icon(
              icon: Icon(Icons.refresh, color: Color(0xFF212121)),
              label: Text(
                'New Game',
                style: TextStyle(color: Color(0xFF212121)),
              ),
              style: TextButton.styleFrom(backgroundColor: Color(0xFFF4B400)),
              onPressed: () {
                setState(() {
                  selectedView = 0; // Switch to NewGamePage
                });
                context.read<MyAppState>().resetTimer();
              },
            ),
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
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 40), // Add top space
          Image.asset('assets/rummikb-tiles.png', width: 150, height: 150),
          Text(
            'Rummikub',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 36,
            ),
          ),
          SizedBox(height: 0),
          Text(
            'Timer',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 32,
            ),
          ),
          SizedBox(height: 25),
          Text(
            appState.playersName[appState.current - 1],
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: int.parse(tseconds) <= 5
                  ? [
                      BoxShadow(
                        color: Colors.red.withAlpha(
                          (0.6 * 255).toInt(),
                        ), // Glow color
                        blurRadius: 30, // Spread of the glow
                        spreadRadius: 8,
                      ),
                    ]
                  : [], // No glow if tseconds > 5
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: int.parse(tseconds) > 10
                    ? Color(0xFFF57C00)
                    : Color(0xFFE53935),
                foregroundColor: Colors.white,
                shape: CircleBorder(),
                minimumSize: Size(230, 230), // Makes the button big and square
                textStyle: Theme.of(context).textTheme.labelLarge
                    ?.copyWith(fontSize: 58)
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                context.read<MyAppState>().nextPlayer();
              },
              child: Text(tseconds),
            ),
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
  int maxNumberOfPlayers = 4;
  int selectedTurnTime = 30; //Default value
  late List<TextEditingController> nameControllers;

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<MyAppState>(context, listen: false);
    selectedPlayers = appState.numPlayers;
    selectedTurnTime = appState.turnTime;
    nameControllers = List.generate(
      maxNumberOfPlayers,
      (index) => TextEditingController(
        text: index < appState.playersName.length
            ? appState.playersName[index]
            : '',
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in nameControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'Game Setup:',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 15),
              Text(
                'Time per turn (seconds):',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.remove),
                      onPressed: selectedTurnTime > 30
                          ? () {
                              setState(() {
                                selectedTurnTime -= 30;
                              });
                            }
                          : null,
                    ),
                  ),
                  Container(
                    height: 40,
                    width: 125,
                    color: Color(0xFFFFFFFF),
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: 125,
                      child: Text(
                        '$selectedTurnTime',
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),

                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.add),
                      onPressed: selectedTurnTime < 120
                          ? () {
                              setState(() {
                                selectedTurnTime += 30;
                              });
                            }
                          : null,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Text(
                'Number of players:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.remove),
                      onPressed: selectedPlayers > 2
                          ? () {
                              setState(() {
                                selectedPlayers--;
                              });
                            }
                          : null, // Disable if at minimum
                    ),
                  ),
                  Container(
                    height: 40,
                    width: 125,
                    color: Color(0xFFFFFFFF),
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: 125,
                      child: Text(
                        '$selectedPlayers',
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.add),
                      onPressed: selectedPlayers < 4
                          ? () {
                              setState(() {
                                selectedPlayers++;
                              });
                            }
                          : null, // Disable if at maximum
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              // First player's name
              SizedBox(
                width: 320,
                child: TextField(
                  controller: nameControllers[0],
                  enabled: true,
                  decoration: InputDecoration(
                    hintText: 'Player 1',
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                    filled: true,
                    fillColor: Color(0xFFFFFFFF),
                  ),
                  style: TextStyle(color: Color(0xFF555555)),
                ),
              ),

              SizedBox(height: 10),
              // Second players name
              SizedBox(
                width: 320,
                child: TextField(
                  controller: nameControllers[1],
                  enabled: true,
                  decoration: InputDecoration(
                    hintText: 'Player 2',
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    border: OutlineInputBorder(borderSide: BorderSide.none),
                    filled: true,
                    fillColor: Color(0xFFFFFFFF),
                  ),
                  style: TextStyle(color: Color(0xFF555555)),
                ),
              ),

              SizedBox(height: 10),
              // Third player's name
              selectedPlayers > 2
                  ? SizedBox(
                      width: 320,
                      child: TextField(
                        controller: nameControllers[2],
                        enabled: selectedPlayers > 2,
                        decoration: InputDecoration(
                          hintText: 'Player 3',
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Color(0xFFFFFFFF),
                        ),
                        style: TextStyle(color: Color(0xFF555555)),
                      ),
                    )
                  : SizedBox(height: 56),
              SizedBox(height: 10),
              // Fourth player's name
              selectedPlayers > 3
                  ? SizedBox(
                      width: 320,
                      child: TextField(
                        controller: nameControllers[3],
                        enabled: selectedPlayers > 3,
                        decoration: InputDecoration(
                          hintText: 'Player 4',
                          floatingLabelBehavior: FloatingLabelBehavior.never,
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Color(0xFFFFFFFF),
                        ),
                        style: TextStyle(color: Color(0xFF555555)),
                      ),
                    )
                  : SizedBox(height: 56),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1976D2),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  minimumSize: Size(320, 48),
                  textStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  context.read<MyAppState>().numPlayers = selectedPlayers;
                  context.read<MyAppState>().turnTime = selectedTurnTime;
                  context.read<MyAppState>().playersName = List.generate(
                    selectedPlayers,
                    (index) => nameControllers[index].text.isNotEmpty
                        ? nameControllers[index].text
                        : 'Player ${index + 1}',
                  );
                  context.read<MyAppState>().startGameTimer();
                  widget.onStartGame();
                },
                child: Text('Start'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
