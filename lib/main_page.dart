import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
// import 'dart:js';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  dynamic _fetchedData;
  final JavascriptRuntime javascriptRuntime = getJavascriptRuntime();
  @override
  void initState() {
    super.initState();
    getData();
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
          ? Text('Getting data')
          : ListView.builder(
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                if (index <= 4) {
                  return Container();
                }
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
              }),
    );
  }
}
