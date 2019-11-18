//import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hk/hk_controller.dart';
import 'package:flutter_hk/hk_player.dart';
import 'package:flutter_hk/hk_player_controller.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: FirstPage(),
        onGenerateRoute: (RouteSettings settings) {
          switch (settings.name) {
            case "/":
              return MaterialPageRoute(
                  builder: (context) => FirstPage(), maintainState: false);
              break;
            case "/v":
              Map<String, Object> map = settings.arguments;
              return MaterialPageRoute(
                  builder: (context) => SecondPage(map), maintainState: false);
              break;
          }
        });
  }
}

class FirstPage extends StatelessWidget {
  String ip;
  int port = 0;
  String user, psd;
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("海康视频Demo"),
        ),
        body: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(10), labelText: "请输入ip"),
                  initialValue: "218.2.210.206",
                  onSaved: (v) => this.ip = v,
                ),
                TextFormField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(10), labelText: "请输入端口"),
                  initialValue: "8190",
                  onSaved: (v) => this.port = int.parse(v),
                ),
                TextFormField(
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(10), labelText: "请输入user"),
                  initialValue: "admin",
                  onSaved: (v) => this.user = v,
                ),
                TextFormField(
                  decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(10), labelText: "请输入密码"),
                  initialValue: "zxc654321",
                  onSaved: (v) => this.psd = v,
                ),
                IconButton(
                  icon: Icon(Icons.arrow_downward),
                  onPressed: () {
                    if (_formKey.currentState.validate()) {
                      _formKey.currentState.save();
                      Navigator.pushNamed(context, "/v", arguments: {
                        "ip": ip,
                        "port": port,
                        "user": user,
                        "psd": psd,
                      });
                    }
                  },
                )
              ],
            )));
  }
}

class SecondPage extends StatefulWidget {
  String ip;
  int port = 0;
  String user, psd;

  SecondPage(Map<String, Object> map) {
    ip = map["ip"];
    port = map["port"];
    psd = map["psd"];
    user = map["user"];
  }
  @override
  _SecondPageState createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  String _platformVersion = 'Unknown';
  HkController hkController;
  HkPlayerController playerController;
  Map cameras = null;
  String errMsg = null;

  @override
  void initState() {
    super.initState();

    initPlatformState();
  }

  @override
  void dispose() {
    this.hkController.logout();
    this.hkController.dispose();
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    try {
      hkController = HkController("hk"); // 必须要有名字，如果有多个摄像头或硬盘录像机就要定义多个
      playerController = HkPlayerController(hkController); // 有多个播放器就要定义多个

      await hkController.init();
      await hkController.login(
          this.widget.ip, this.widget.port, this.widget.user, this.widget.psd);

      var chans = await hkController.getChans();

      if (!mounted) return;

      setState(() {
        cameras = chans;
      });
    } catch (e, r) {
      setState(() {
        errMsg = e.toString();
      });
    }
  }

  Widget buildCameras(Map cameras) {
    var list = List<Widget>();
    List<int> keys = List.from(cameras.keys);
    keys.sort((l, r) => l.compareTo(r));
    for (int key in keys) {
      list.add(FlatButton(
        child: Text(cameras[key]),
        padding: EdgeInsets.all(1),
        color: Colors.lightBlueAccent,
        onPressed: () {
          if (this.playerController.isPlaying) {
            this.playerController.stop();
          }
          this.playerController.play(key);
        },
      ));
    }
    return Container(
      height: 200,
      child: GridView.count(
        crossAxisCount: 5,
        padding: EdgeInsets.all(4),
        mainAxisSpacing: 4,
        crossAxisSpacing: 4,
        children: list,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget loading() {
      if (this.cameras == null) {
        if (errMsg == null) {
          return Center(
            child: Text("登录中。。。"),
          );
        } else {
          return Center(
            child: Text(errMsg),
          );
        }
      } else {
        return Column(
          children: [
            buildCameras(this.cameras),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(4),
                child: HkPlayer(
                  controller: this.playerController,
                ),
              ),
            ),
          ],
        );
      }
    }

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: loading(),
      ),
    );
  }
}
