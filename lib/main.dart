import 'package:flutter/material.dart';

void main() {
  runApp(const CounterGoalApp());
}

class CounterGoalApp extends StatelessWidget {
  const CounterGoalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CW1 Counter Goal',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  int _counter = 0;

  int _goal = 10; // user can set this
  int _step = 1;  // user can set this (pace)

  bool _celebrated = false;

  late final AnimationController _celebrationController;
  late final Animation<double> _pop;

  final TextEditingController _goalController = TextEditingController(text: "10");
  final TextEditingController _stepController = TextEditingController(text: "1");

  @override
  void initState() {
    super.initState();
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _pop = CurvedAnimation(parent: _celebrationController, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    _goalController.dispose();
    _stepController.dispose();
    super.dispose();
  }

  void _incrementCounter() {
    setState(() {
      final next = _counter + _step;
      _counter = (next <= _goal) ? next : _goal;
    });
    _checkGoalCelebration();
  }

  void _decrementCounter() {
    setState(() {
      final next = _counter - _step;
      _counter = (next >= 0) ? next : 0;

      // If they go below goal again, allow celebration again when they reach it.
      if (_counter < _goal) _celebrated = false;
    });
  }

  void _resetCounter() {
    setState(() {
      _counter = 0;
      _celebrated = false;
    });
  }

  void _applyGoalAndStep() {
    final goal = int.tryParse(_goalController.text.trim());
    final step = int.tryParse(_stepController.text.trim());

    if (goal == null || goal <= 0) {
      _toast("Goal must be a positive number.");
      return;
    }
    if (step == null || step <= 0) {
      _toast("Step must be a positive number.");
      return;
    }

    setState(() {
      _goal = goal;
      _step = step;

      // Keep counter within [0, goal]
      if (_counter > _goal) _counter = _goal;

      // If we set a new goal higher than current, allow celebration again later.
      if (_counter < _goal) _celebrated = false;
    });

    _checkGoalCelebration();
  }

  void _checkGoalCelebration() {
    if (_counter == _goal && !_celebrated) {
      _celebrated = true;
      _showCelebration();
    }
  }

  void _showCelebration() async {
    await _celebrationController.forward(from: 0);

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Goal reached! 🎉"),
        content: ScaleTransition(
          scale: _pop,
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.emoji_events, size: 64),
              SizedBox(height: 12),
              Text("You hit your goal — nice work!"),
              SizedBox(height: 8),
              Text("🎊🎊🎊"),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Continue"),
          ),
        ],
      ),
    );

    _toast("🎉 Goal completed!");
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reached = _counter == _goal;

    return Scaffold(
      appBar: AppBar(
        title: const Text('CW1 Counter Goal'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$_counter / $_goal',
                style: Theme.of(context).textTheme.displayLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                reached ? "Goal achieved!!!" : "Step: $_step",
                style: Theme.of(context).textTheme.titleLarge,
              ),

              const SizedBox(height: 24),

              // Goal + Step inputs
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      TextField(
                        controller: _goalController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Set Goal",
                          hintText: "e.g., 10",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _stepController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: "Set Step (increment pace)",
                          hintText: "e.g., 1, 2, 5",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _applyGoalAndStep,
                          child: const Text("Apply"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Buttons
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: reached ? null : _incrementCounter,
                    child: Text('Increment (+$_step)'),
                  ),
                  ElevatedButton(
                    onPressed: reached ? null : _decrementCounter,
                    child: Text('Decrement (-$_step)'),
                  ),
                  OutlinedButton(
                    onPressed: _resetCounter,
                    child: const Text('Reset'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

