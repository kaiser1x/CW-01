import 'package:flutter/material.dart';

void main() {
  runApp(const CW1App());
}

/// CW1 Counter App
/// - Part 1: Counter + Goal + Step (pace) + Decrement + Reset + Celebration
class CW1App extends StatefulWidget {
  const CW1App({super.key});

  @override
  State<CW1App> createState() => _CW1AppState();
}

class _CW1AppState extends State<CW1App> {
  bool _isDark = false;

  void _toggleTheme() => setState(() => _isDark = !_isDark);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CW1 Counter & Toggle',
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: HomePage(
        isDark: _isDark,
        onToggleTheme: _toggleTheme,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;

  const HomePage({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  // Part 1: Counter + Goal + Step
  int _counter = 0;
  int _goal = 10;
  int _step = 1;
  bool _celebrated = false;

  final TextEditingController _goalController = TextEditingController(text: "10");
  final TextEditingController _stepController = TextEditingController(text: "1");

  // Part 2: Image Toggle
  bool _isFirstImage = true;

  // Celebration animation (pop)
  late final AnimationController _celebrationController;
  late final Animation<double> _pop;

  @override
  void initState() {
    super.initState();
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
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

  // Part 1 
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

      // If they dip below the goal, allow celebration again when they reach it.
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

      if (_counter > _goal) _counter = _goal;
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

  Future<void> _showCelebration() async {
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
              Text("🎊 🎊 🎊 🎊 🎊 🎊 "),
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

  // ---------- Part 2 logic ----------
  void _toggleImage() => setState(() => _isFirstImage = !_isFirstImage);

  @override
  Widget build(BuildContext context) {
    final reached = _counter == _goal;

    return Scaffold(
      appBar: AppBar(
        title: const Text('CW1 Counter & Toggle'),
        actions: [
          IconButton(
            onPressed: widget.onToggleTheme,
            icon: Icon(widget.isDark ? Icons.light_mode : Icons.dark_mode),
            tooltip: widget.isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ===== Part 1 UI: Counter + Goal + Step =====
              Text(
                '$_counter / $_goal',
                style: Theme.of(context).textTheme.displayLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                reached ? "Goal achieved!!!" : "Step: $_step",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 18),

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

              const SizedBox(height: 14),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: reached ? null : _incrementCounter,
                      child: Text('Increment (+$_step)'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _toggleImage,
                      child: const Text('Toggle Image'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _counter == 0 ? null : _decrementCounter,
                      child: Text('Decrement (-$_step)'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _resetCounter,
                      child: const Text('Reset'),
                    ),
                  ),
                ],
              ),


              const SizedBox(height: 28),
              const Divider(),
              const SizedBox(height: 18),

              // Part 2: Image Toggle + Theme Toggle (Light/Dark) + Animated transition
              Text(
                'Image Toggle',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (child, animation) {
                  // Fade + scale transition
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(scale: animation, child: child),
                  );
                },
                child: Image.asset(
                  _isFirstImage ? 'assets/image1.png' : 'assets/image2.jpg',
                  key: ValueKey(_isFirstImage),
                  width: 200,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(height: 12),

              ElevatedButton(
                onPressed: _toggleImage,
                child: const Text('Toggle Image'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
