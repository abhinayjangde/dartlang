import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Demo App",
      theme: ThemeData(primarySwatch: Colors.amber),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("hello")),
      body: Column(
        children: [
          Row(
            children: [
              Container(width: 50, height: 200, color: Colors.red),
              Container(width: 50, height: 200, color: Colors.green),
              Expanded(
                child: Container(
                  width: 50,
                  height: 200,
                  color: Colors.blueGrey,
                  child: Center(
                    child: Text(
                      "Expanded Widget",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ),
              ),
              Container(width: 50, height: 200, color: Colors.amber),
            ],
          ),
          Row(
            children: [
              Padding(padding: EdgeInsets.only(left: 20), child: Text("hello")),
            ],
          ),
        ],
      ),
    );
  }
}
