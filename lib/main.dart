import 'package:flutter/material.dart';
import 'database.dart'; // Import the database helper

void main() {
  runApp(AquariumApp());
}

class AquariumApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Virtual Aquarium',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AquariumScreen(),
    );
  }
}

class AquariumScreen extends StatefulWidget {
  @override
  _AquariumScreenState createState() => _AquariumScreenState();
}

class _AquariumScreenState extends State<AquariumScreen> with TickerProviderStateMixin {
  List<Fish> fishList = [];
  String selectedImagePath = 'assets/bluefish.png'; 
  double selectedSpeed = 1.0; 

  final DatabaseHelper _dbHelper = DatabaseHelper(); 

  @override
  void initState() {
    super.initState();
    _loadSettings(); 
  }

  void _loadSettings() async {
    final settings = await _dbHelper.loadSettings();
    setState(() {
      selectedImagePath = settings['fishColor'] ?? 'assets/bluefish.png';
      selectedSpeed = settings['fishSpeed'] ?? 1.0;
      int fishCount = settings['fishCount'] ?? 0;
      for (int i = 0; i < fishCount; i++) {
        fishList.add(Fish(imagePath: selectedImagePath, speed: selectedSpeed));
      }
    });
  }

  Future<void> _saveSettings() async {
    try {
      await _dbHelper.saveSettings(fishList.length, selectedSpeed, selectedImagePath);
      // Show success message if the widget is still mounted
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings saved successfully!')),
        );
      }
    } catch (e) {
      // Handle any error that occurs while saving settings
      print("Error during saving settings: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save settings!')),
        );
      }
    }
  }

  void _addFish() {
    if (fishList.length < 10) { // Limit to 10 fish
      setState(() {
        fishList.add(Fish(imagePath: selectedImagePath, speed: selectedSpeed));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Virtual Aquarium')),
      body: Column(
        children: [
          SizedBox(height: 20),
          // Aquarium container
          Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              color: Colors.blue[100],
              border: Border.all(color: Colors.blue, width: 2),
            ),
            child: Stack(
              children: fishList.map((fish) => AnimatedFish(fish: fish)).toList(),
            ),
          ),
          SizedBox(height: 20),
          // Dropdown to select fish image
          DropdownButton<String>(
            value: selectedImagePath,
            items: [
              DropdownMenuItem(
                value: 'assets/bluefish.png',
                child: Text("Blue Fish"),
              ),
              DropdownMenuItem(
                value: 'assets/redfish.png',
                child: Text("Red Fish"),
              ),
              DropdownMenuItem(
                value: 'assets/greenfish.png',
                child: Text("Green Fish"),
              ),
            ],
            onChanged: (value) {
              setState(() {
                selectedImagePath = value!;
              });
            },
          ),
          // Slider for fish speed
          Slider(
            value: selectedSpeed,
            min: 0.5,
            max: 3.0,
            divisions: 5,
            label: selectedSpeed.toString(),
            onChanged: (value) {
              setState(() {
                selectedSpeed = value;
              });
            },
          ),
          SizedBox(height: 20),
          // Button to add fish
          ElevatedButton(
            onPressed: _addFish,
            child: Text("Add Fish"),
          ),
          SizedBox(height: 10),
          // Button to save settings
          ElevatedButton(
            onPressed: _saveSettings,
            child: Text("Save Settings"),
          ),
        ],
      ),
    );
  }
}

class Fish {
  String imagePath;
  double speed;

  Fish({required this.imagePath, required this.speed});
}

class AnimatedFish extends StatefulWidget {
  final Fish fish;

  AnimatedFish({required this.fish});

  @override
  _AnimatedFishState createState() => _AnimatedFishState();
}

class _AnimatedFishState extends State<AnimatedFish> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _xMovement;
  late Animation<double> _yMovement;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: (4 / widget.fish.speed).round()),
      vsync: this,
    )..repeat(reverse: true);

    _xMovement = Tween<double>(begin: 0, end: 250).animate(_controller);
    _yMovement = Tween<double>(begin: 0, end: 250).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: _xMovement.value,
          top: _yMovement.value,
          child: Image.asset(
            widget.fish.imagePath,
            width: 40,
            height: 40,
          ),
        );
      },
    );
  }
}
