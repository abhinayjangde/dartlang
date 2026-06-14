class Person {
  String name;
  int age;

  Person(this.name, this.age);

  void introduce() {
    print("my name is $name");
  }
}

Future<int> getDate() {
  return Future.delayed(Duration(seconds: 3), () => 42);
}

Future<void> main() async {
  // async code
  int data = await getDate();
  print(data);
  print("Program End");
}
