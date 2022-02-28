import 'package:flutter/gestures.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:roppou_app/test_detail.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
// import 'dart:js';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  dynamic _fetchedData;
  final JavascriptRuntime javascriptRuntime = getJavascriptRuntime();
  final ScrollController _scrollController = ScrollController();
  AnimationController? _controller;
  Animation<double>? _sizeAnimation;

  @override
  void initState() {
    super.initState();
    getData();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _sizeAnimation = TweenSequence(<TweenSequenceItem<double>>[
      TweenSequenceItem(tween: Tween(begin: 10, end: 20), weight: 20),
      // TweenSequenceItem(tween: Tween(begin: 30, end: 10), weight: 10),
    ]).animate(_controller!);

    _controller?.addListener(() {
      // print(_controller?.value);
      print(_sizeAnimation?.value);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
    _scrollController.dispose();
  }

  void getData() async {
    http
        .get(Uri.parse(
            'https://xn--eckucmux0ukcy120betvc.com/%E6%A4%9C%E7%B4%A2/data.js'
            // "https://jsonplaceholder.typicode.com/users"
            ))
        .then((res) {
      print(res.toString());
      // String responseBody = String.fromCharCodes(res.bodyBytes);
      // 文字化けする
      String responseBody = utf8.decode(res.bodyBytes);
      // print(responseBody);
      String responseData = javascriptRuntime.evaluate("""
${responseBody}
JSON.stringify(data);
""").stringResult;
      setState(() {
        // _fetchedData = responseData;
        _fetchedData = json.decode(responseData);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: _fetchedData == null
          ? const Text('Getting data')
          : AnimatedBuilder(
              animation: _controller!,
              builder: (BuildContext context, _) {
                return Stack(
                  children: [
                    Expanded(
                      child: ListView.builder(
                          controller: _scrollController,
                          shrinkWrap: true,
                          itemBuilder: (BuildContext context, int index) {
                            if (index <= 4) {
                              return Container();
                            }
                            return itemCard(index);
                          }),
                    ),
                    scrollButton(),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                            MaterialPageRoute(builder: (BuildContext context) {
                          return TestDetail();
                        }));
                      },
                      child: Container(
                        width: 100,
                        height: 100,
                        child: Hero(
                            tag: "test_anim",
                            child: Image.network("https://picsum.photos/200")),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Positioned scrollButton() {
    return Positioned(
      right: 30,
      bottom: 30,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onLongPress: () {
              print('Long Press');
              _controller?.forward();
            },
            onLongPressUp: () {
              print('Long Press up');
              _controller?.reverse();
            },
            onTap: () {
              _scrollController.animateTo(
                  _scrollController.position.minScrollExtent,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeIn);
            },
            child: const Icon(
              Icons.arrow_drop_up,
              size: 50,
            ),
          ),
          Text(
            '一番上までスクロール',
            style: TextStyle(fontSize: _sizeAnimation?.value),
          )
        ],
      ),
    );
  }

  Card itemCard(int index) {
    return Card(
      elevation: 3,
      child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(10),
          child: InkWell(
            onTap: () {
              launch(_fetchedData[index]['url']);
            },
            child: Text('${_fetchedData[index]['title']}'),
          )),
    );
  }
}
