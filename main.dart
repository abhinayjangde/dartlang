Future<String> getName() {
  return Future.delayed(Duration(seconds: 2), () {
    return "Abhi";
  });
}

void main() async {
  print("start");
  var name = await getName();
  print(name);
  print("done");
}
