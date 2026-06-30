import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    // var time = DateTime.now();
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
      ),
      body: GridView.count(
        crossAxisCount: 3,
        children: [
          Container(color: Colors.red),
          Container(color: Colors.orange),
          Container(color: Colors.yellow),
          Container(color: Colors.green),
          Container(color: Colors.blue),
          Container(color: Colors.indigo),
          Container(color: Colors.purple),
          Container(color: Colors.pink),
        ],
      ),
    );
  }
}
