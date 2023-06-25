import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _login() async {
    final response = await http.post(
      Uri.parse('http://localhost:8080/api/auth/signin'),
      body: jsonEncode({
        'username': _usernameController.text,
        'password': _passwordController.text,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => RoleScreen()),
      );
    } else {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: _login,
              child: Text('Login'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SignupScreen()),
                );
              },
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _signup() async {
    final response = await http.post(
      Uri.parse('http://localhost:8080/api/auth/signup'),
      body: jsonEncode({
        'username': _usernameController.text,
        'email': _emailController.text,
        'password': _passwordController.text,
        'role': ['ROLE_USER'],
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => RoleScreen()),
      );
    } else {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
        TextField(
        controller: _usernameController,
          decoration: InputDecoration(labelText: 'Username'),
        ),
        TextField(
          controller: _emailController,
          decoration: InputDecoration(labelText: 'Email'),
        ),
        TextField(
          controller: _passwordController,
          decoration: InputDecoration(labelText: 'Password'),
          obscureText: true,
        ),
        ElevatedButton(
          onPressed: _signup,
          child: Text('Register'),
        ),
        ],
      ),
    ),
    );
  }
}

class RoleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Role'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Zaloguj się jako:'),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OwnerScreen()),
                );
              },
              child: Text('Właściciel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RenterScreen()),
                );
              },
              child: Text('Wynajmujący'),
            ),
          ],
        ),
      ),
    );
  }
}

class OwnerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Owner Screen'),
      ),
      body: Center(
        child: Text('Owner Screen'),
      ),
    );
  }
}

class RenterScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Renter Screen'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CleaningScheduleScreen()),
            );
          },
          child: Text('Harmonogram sprzątania'),
        ),
      ),
    );
  }
}



class CleaningScheduleScreen extends StatefulWidget {
  @override
  _CleaningScheduleScreenState createState() => _CleaningScheduleScreenState();
}

class _CleaningScheduleScreenState extends State<CleaningScheduleScreen> {
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  List<TimeSlot> _timeSlots = [];

  Future<void> _addTimeSlot() async {
    final response = await http.post(
      Uri.parse('http://localhost:8080/api/schedules/{scheduleId}/timeslots'),
      body: jsonEncode({
        'startDate': _startDate.toIso8601String(),
        'endDate': _endDate.toIso8601String(),
        'user': {'id': 'your-user-id'}, // Replace with your user id
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 201) {
      _getTimeSlots();
    } else {
      // Handle error
    }
  }

  Future<void> _removeTimeSlot(String timeSlotId) async {
    final response = await http.delete(
      Uri.parse('http://localhost:8080/api/schedules/{scheduleId}/timeslots/$timeSlotId'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 204) {
      _getTimeSlots();
    } else {
      // Handle error
    }
  }

  Future<void> _getTimeSlots() async {
    final response = await http.get(
      Uri.parse('http://localhost:8080/api/schedules/users/{userId}/timeslots'), // Replace with your user id
    );

    if (response.statusCode == 200) {
      final List<dynamic> timeSlotsJson = jsonDecode(response.body);
      setState(() {
        _timeSlots = timeSlotsJson.map((json) => TimeSlot.fromJson(json)).toList();
      });
    } else {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cleaning Schedule'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Start Date: $_startDate'),
            Text('End Date: $_endDate'),
            ElevatedButton(
              onPressed: () async {
                final picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(DateTime.now().year - 5),
                  lastDate: DateTime(DateTime.now().year + 5),
                );
                if (picked != null) {
                  setState(() {
                    _startDate = picked.start;
                    _endDate = picked.end;
                  });
                }
              },
              child: Text('Pick date range'),
            ),
            ElevatedButton(
              onPressed: _addTimeSlot,
              child: Text('Add Time Slot'),
            ),
            ListView.builder(
              itemCount: _timeSlots.length,
              itemBuilder: (context, index) {
                final timeSlot = _timeSlots[index];
                return ListTile(
                  title: Text('${timeSlot.startDate} - ${timeSlot.endDate}'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _removeTimeSlot(timeSlot.id),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class TimeSlot {
  final String id;
  final DateTime startDate;
  final DateTime endDate;

  TimeSlot({
    required this.id,
    required this.startDate,
    required this.endDate,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      id: json['id'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
    );
  }
}

