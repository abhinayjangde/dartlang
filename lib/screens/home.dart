import 'package:dartlang/constants/colors.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: tdBGColor,
      appBar: _buildAppBar(),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Column(
          children: [
            searchBox(),
            Expanded(
              child: ListView(
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 20, bottom: 20),
                    child: Text(
                      "All todos",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

AppBar _buildAppBar() {
  return AppBar(
    title: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Icon(Icons.menu, color: tdBlack, size: 30),
        SizedBox(
          height: 36,
          width: 36,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Image.network(
              "https://avatars.githubusercontent.com/u/64852930?v=4",
            ),
          ),
        ),
      ],
    ),
    backgroundColor: tdBGColor,
  );
}

Widget searchBox() {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 15),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(13),
    ),
    child: TextField(
      decoration: InputDecoration(
        hintText: "Search",
        hintStyle: TextStyle(color: tdGray, fontSize: 20),
        contentPadding: EdgeInsets.all(0),
        border: InputBorder.none,
        prefixIcon: Icon(Icons.search, color: tdBlack, size: 20),
        prefixIconConstraints: BoxConstraints(maxHeight: 20, minWidth: 25),
      ),
    ),
  );
}
