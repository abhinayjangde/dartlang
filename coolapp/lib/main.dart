import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text("Hello")),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Container(
                        height: 200,
                        color: Colors.blue,
                        margin: EdgeInsets.all(8.0),
                      ),
                      Container(
                        height: 200,
                        color: Colors.red,
                        margin: EdgeInsets.all(8.0),
                      ),
                    ],
                  ),
                ),

                Container(
                  height: 200,
                  color: Colors.redAccent,
                  margin: EdgeInsets.all(8.0),
                ),
                Container(
                  height: 200,
                  color: Colors.green,
                  margin: EdgeInsets.all(8.0),
                ),
                Container(
                  height: 200,
                  color: Colors.orange,
                  margin: EdgeInsets.all(8.0),
                ),
                Container(
                  height: 200,
                  color: Colors.pink,
                  margin: EdgeInsets.all(8.0),
                ),
                Container(
                  height: 200,
                  color: Colors.black,
                  margin: EdgeInsets.all(8.0),
                ),
                Container(
                  height: 200,
                  color: Colors.yellow,
                  margin: EdgeInsets.all(8.0),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
