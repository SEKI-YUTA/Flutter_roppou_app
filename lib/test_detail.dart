import 'package:flutter/material.dart';

class TestDetail extends StatelessWidget {
  const TestDetail({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Hero(
      tag: "test_anim",
      child: Expanded(
        child: Image.network('https://picsum.photos/200'),
      ),
    ));
  }
}
