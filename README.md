# flutter_hk

A new flutter plugin project.

## Getting Started

This project is a starting point for a Flutter
[plug-in package](https://flutter.dev/developing-packages/),
a specialized package that includes platform-specific implementation code for
Android and/or iOS.

For help getting started with Flutter, view our 
[online documentation](https://flutter.dev/docs), which offers tutorials, 
samples, guidance on mobile development, and a full API reference.

## 平台
Android, iOS

For iOS you needed to add this two rows into Info.plist file (see example for details):
```
<key>io.flutter.embedded_views_preview</key>
<true/>
```

## 说明flutter_hk插件基于海康的原生SDK的二次封装，支持多路硬盘录像机的登录和多个视频窗口的播放。
特别注意：新建项目时只能用objc, 不能用swift不然会报错
```
flutter create -i objc projName
```

## 依赖
在pubspec.yaml里加入
```
dependencies:
  flutter_hk: ^0.1.0
```

## 安装
你可以用下面的命令安装组件
```
$  flutter pub get
```

## 引用
在代码里
```
import 'package:flutter_hk/hk_controller.dart';
import 'package:flutter_hk/hk_player.dart';
import 'package:flutter_hk/hk_player_controller.dart';
```

## 使用方法
定义管理控制器及播放器控制器
定义摄像头列表及错误参数
```
  HkController hkController;
  HkPlayerController playerController;
  Map cameras = null;
  String errMsg = null;
```

初始化
```
  try {
      hkController = HkController("hk");  // 必须要有名字，如果有多个摄像头或硬盘录像机就要定义多个
      playerController = HkPlayerController(hkController);  // 有多个播放器就要定义多个

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
```

定义获取摄像头后的列表方法
```
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
```

定义build
```
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
```

在不用的时候一定要记得销毁控制器
```
  @override
  void dispose() {
    this.hkController.logout();
    this.hkController.dispose();
    super.dispose();
  }
```