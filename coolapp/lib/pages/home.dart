import 'package:coolapp/pages/second.dart';
import 'package:flutter/material.dart';
import '../widgets/rounded_btn.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar(),
      drawer: myDrawer(),
      body: const RoundedBtn(),
    );
  }
}

Drawer myDrawer() {
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: const [
        DrawerHeader(
          decoration: BoxDecoration(color: Colors.green),
          child: Text(
            'Menu',
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
        ),
        ListTile(
          leading: Icon(Icons.home),
          title: Text('Home'),
          // trailing: Icon(Icons.arrow_forward),
        ),
        ListTile(leading: Icon(Icons.settings), title: Text('Settings')),
      ],
    ),
  );
}

AppBar myAppBar() {
  return AppBar(
    title: const Text('CoolApp', style: TextStyle(color: Colors.black)),
    backgroundColor: Colors.green,
  );
}
