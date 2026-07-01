Future<String> getName() {
  return Future.delayed(Duration(seconds: 2), () {
    return "Abhi";
  });
}

void main() {
  print("start");

  getName().then((name) {
    print(name);
  });

  print("done");
}
